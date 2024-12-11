#!/bin/bash

### FUNCTION LIST ###
#  - get_viewport_dims()
#      - him_get_accounts()
#      - him_get_enveloptes
#          - build_menus()
#          - menu()
#              - him_read_message()
#              - parse_output()
#  - TODO: ead_message() ; compose_message() ; change_account() ; 

### VARIABLE LIST ###
#  - ???


# Define Himalaya executable location
him_path="/home/m4n4pe/git/bin/himalaya"

#######################################################################
# UI
#######################################################################


### Terminal Info, orientation ###

get_viewport_dims() {
  
# Determine whether we are portrait or landscape
#  Example data:
#  Landscape -- lines=51 ; cols=155
#               ratio=3.0392
#  Portrait  -- lines=68 ; cols=116 
#               ratio=1.7059

# First get line + column counts
_lines=$(tput lines)
_cols=$(tput cols)


# Divide columns by lines for viewport_ratio variable
viewport_ratio=$(echo "${_cols}/${_lines}" | bc)
echo "_viewport_ratio var = $viewport_ratio"


# Set port/land orientation variable based on ratio of columns to lines
if [ "$viewport_ratio" -gt 2 ]
then
  _orientation="land"
else
  _orientation="port"
fi
echo "_orientation var = $_orientation"


# Tell himalaya about viewport dimensions 
#  + modify lines count to accomodate added menu item(s)
him_lines="--page-size $(echo "$_lines-4" | bc)"
him_cols="--max-width $_cols"


# Tell fzf about viewport dims
# TODO -- PLACHOLDER
#  set up fzf preview and stuff

}

### FZF / Text Styling ###
# TODO -- maybe move above viewport function?



#######################################################################
# GET DATA FROM HIMALAYA
#######################################################################

# X=$(cmd) -- the literal OUTPUT OF the command within the parentheses

### READ AN EMAIL ###
read_email() {
    $_himalaya message read {1} --html --header="From,To,Cc,Subject" $acct | w3m -T text/html -sixel -o auto_image=TRUE -o "display_image=1"
    # cha -T text/html
    # w3m -T text/html -sixel -o auto_image=TRUE -o display_image=1
    
    # yeah idk -cols $FZF_PREVIEW_COLUMNS -o display_link_number=1
    }


### GET HIMALAYA ACCOUNTS ###

him_get_accounts() {

# Raw output of himalaya accounts list command:
him_accounts_cmd_output="$($him_path accounts list)"
# TODO: REPLACE ABOVE WITH JSON OUTPUT + JQ


# Decap'd himalaya accounts list output with:
him_accounts_list=$(echo "$him_accounts_cmd_output" | tail -n +3)


# Header extracted from himalaya accounts list command:
him_accounts_header=$(echo "$him_accounts_cmd_output" | awk 'NR==2{print;exit}')


# Formatted accounts list for input to fzf (+header):
accounts_fzf_input=$(printf '%s\n' "$him_accounts_list" "$him_accounts_header")
# TODO: CLEAN UP print / echo FOR CONSISTENCY


# Default account var:
him_def_account=""
# TODO: QUERY HIMALAYA FOR DEFAULT ACCOUNT / EXTRACT FROM JSON


# Current account var:
#  Set as Himalaya's configured default account; change 
#  later based on user input
him_current_account=$him_def_account

}

### GET HIMALAYA ENVELOPES: ###

him_get_envelopes() {
# Raw output of himalaya list envelopes command:
him_envelopes_cmd_output="$($him_path envelopes list $him_lines $him_cols $him_current_acct)"


# Decap'd envelopes list:
him_envelopes_list=$(echo "$him_envelopes_cmd_output" | tail -n +3)


# Header from envelopes list command:
him_envelopes_header=$(echo "$him_envelopes_cmd_output" | awk 'NR==2{print;exit}')


# Envelopes list for input to fzf:
envelopes_fzf_input=$(printf '%s\n' "$him_envelopes_list" "$him_envelopes_header")

}


#######################################################################
### SEARCH QUERY, MENU-BUILDING
#######################################################################

## Items appended to all lists?
# appendlist=$(printf '%s' "Exit")
## Base list here is going to list mails (eventually)
# baselist=("${him_envelopes_list}"\nMenu)

build_menus() {
  
# Define list to give FZF for the menu screen
  menulist=$(printf '%s\n' "Change Account" "Compose New Mail" "Back" "Exit")


#prevlist=$(printf '%s' "")
#accountlist=$(printf '%s' "${him_acct_list[@]}" "\nBack")
# Set initial list
#currentlist=("${baselist[@]}")


# Set initial search query to list envelopes
  default_search_query="$envelopes_fzf_input"
  search_query="$default_search_query"

}


#######################################################################
# MENU FUNCTION
#######################################################################


menu() {

# junk:
# chosen=$(echo -e "$currentlist" | 
#  FZF_DEFAULT_COMMAND=$search_query 
#  --header="$him_envelopes_header" --bind "esc:abort")


# Pipe list into fzf, then set output as "chosen" var
# %s for string, \n means newline after each of the items that follow
chosen=$(printf '%s\n' "Menu" "$search_query" | fzf --disabled --ansi )


}



#######################################################################
# PARSE_OUTPUT FROM MENU FUNCTION
#######################################################################

# Set the list you just used as the "prevlist" var
#  (unless we selected "Back")
#  if [ "$currentlist" = "$menulist" ]
#  then  
#    prevlist=$baselist
#  elif [ "$currentlist" = "$accountlist" ]
#  then
#    prevlist=$menulist
#  else
#    echo "null"
#  fi


parse_output() {

# Debug ponit
echo "DEBUG: $chosen was chosen"


# Pass chosen item, do stuff as a result
case $chosen in

# Exit option was chosen
    Exit)
    ;;
    

#  DummyListItem1)
#    echo "$chosen"
#    ;;
#  choice=$(echo "item1_of_menu1\nitem2_of_menu1" | fzf)
#  DummyListItem2)
#    echo "$chosen"
#    ;;

# Menu option was chosen
  Menu) 
    echo "Setting search_query to ${menulist}"
    search_query="$menulist"
    echo "Setting fzf_prev_list to ${default_search_query}"
    fzf_prev_list="$default_search_query"
    ;;

# Change Account option was chosen
  "Change Account")
    echo "Setting search_query to ${accounts_fzf_input}"
    search_query="$accounts_fzf_input"
    echo "Setting fzf_prev_list to ${menulist}"
    fzf_prev_list="$menulist"
    ;;

# Set list to accountlist
#    currentlist=$accountlist
# Compose new
#  "Compose New Mail")
# Set list to previous list

# Back option was chosen
  "Back")
    echo "Back was chosen"
    echo "Setting search_query to ${fzf_prev_list}"
    search_query="$fzf_prev_list"
    echo "Setting fzf_prev_list to null"
    fzf_prev_list=""
    ;;
    
esac


# Exit script if the "Exit" option was chosen:
if [ "$chosen" == "Exit" ]
then
  exit
  
# Run menu again if "Exit" was NOT chosen:
else
    echo "Running menu again with new vars"
  menu ; parse_output
fi


}



#######################################################################
# Main / first iteration of menu
#######################################################################

# Set up viewport / UI variables for first run
get_viewport_dims
him_get_accounts
him_get_envelopes
build_menus
echo "UI DEBUG: him_lines: $him_lines"
echo "UI DEBUG: _lines: $_lines"
echo "UI DEBUG: envelopes_fzf_input: $envelopes_fzf_input"
echo "HIMALAYA DEBUG: $him_envelopes_cmd_output"


# Run menu, then do stuff based on output
menu ; parse_output
# TODO: how to ensure clean exit?
