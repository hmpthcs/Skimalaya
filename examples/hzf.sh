#!/bin/bash
# 
# INFO:
#  Hmpthcs's initial revision of Callum Macrae's original mail.zsh
#  Original was released under MIT license. All revisions intended to 
#  continue with the same MIT licensing terms.
# 
#  It will list your mail envelopes and display previews appropriately.
#  All other functionality is essentially missing. Rewrite from scratch 
#  in progress.
#
#  This file is intended for use in bash. Can be sourced from bashrc, then called
#  by running `mail`.
#
# NOTE:
#  If you use this, you're gonna have to change the acct and _himalaya variables
#  so that they match your setup.
#
# Dependencies:
# - himalaya
# - fzf
# - jq
# - chawan

### Global options flags for himalaya ###
# Change these 
_himalaya="/home/m4n4pe/git/bin/himalaya"
acct=" --account wsu"

preview_height() {
	if (( LINES > 30 )); then
		echo "80%"
	else
		echo "50%"
	fi
}

mail() {
   old_IFS=$IFS
   IFS=$'\n'
   acct_raw=$($_himalaya -o json accounts list)
   def_acct=$( echo "$acct_raw" | jq -r '.[] | select(.default) .name' )
#   default_account=$($_himalaya -o json accounts list | jq -r '.[] | select(.default) .name' )
   acct_list=$( echo "$acct_raw" | jq -r 'map(.name) | join("\n")')
   acct_count="${#acct_list[@]}"
   acct_file="${TMPDIR:-/tmp}/hfz_account"
   query_file="${TMPDIR:-/tmp}/hfz_qry"

##### Accounts var
   if [[ -f "$acct_file" ]]; then
     curr_acct=$(cat "$acct_file")

     if [[ ! " ${acct[*]} " =~ " ${curr_acct} " ]]; then
       rm -f "$acct_file"
       curr_acct="${acct[@]:0:1}"
     fi
  
   else
     curr_acct="${acct[@]:0:1}"
   fi

   echo "$curr_acct" >| "$acct_file"


#### Select item in fzf

##  read_email='
##    current_account=$(cat "'"${account_file}"'")

  read_email="
    $_himalaya message read {1} --html --header="From,To,Cc,Subject" $acct | w3m -T text/html -sixel -o auto_image=TRUE -o display_image=1"
    # cha -T text/html
    # w3m -T text/html -sixel -o auto_image=TRUE -o display_image=1
    
    # yeah idk -cols $FZF_PREVIEW_COLUMNS -o display_link_number=1

## old:     /home/m4n4pe/git/bin/himalaya account "${current_account}" read {1} -t html | w3m -T text/html -cols $FZF_PREVIEW_COLUMNS -o display_link_number=1



#########
#   account_previous='
#     IFS=$'\''\n'\'' accounts=($(echo "'"$(IFS=$'\n'; echo "${accounts[*]}")"'"))
#     current_account=$(cat "'"${account_file}"'")

#     for i in ${!accounts[@]}; do
#       if [[ "${accounts[$i]}" = "${current_account}" ]]; then
#         if (( i > 0 )); then
#           new_account="${accounts[$i - 1]}"
#           echo $new_account >| '$account_file'
#         fi
#       fi
#     done
#   '

# #####
#   account_next='
#     IFS=$'\''\n'\'' accounts=($(echo "'"$(IFS=$'\n'; echo "${accounts[*]}")"'"))
#     current_account=$(cat "'"${account_file}"'")

#     for i in ${!accounts[@]}; do
#       if [[ "${accounts[$i]}" = "${current_account}" ]]; then
#         if (( i < ${#accounts[@]} - 1 )); then
#           new_account="${accounts[$i + 1]}"
#           echo $new_account >| '$account_file'
#         fi
#       fi
#     done
#   '

_lines="--page-size $(tput lines)"

rm -f /tmp/rg-fzf-{r,f}
search_query="${_himalaya} envelopes list $acct $_lines"
SHELL=/bin/bash FZF_DEFAULT_COMMAND="$search_query" fzf \
    --disabled \
    --separator="_" \
    --preview-window border-bold \
    --border thinblock \
    --color=fg:#000000,bg:#ffffff,hl:#333333,fg+:#ffffff,bg+:#000000,hl+:#aaaaaa:underline:-1,info:#333333,prompt:#333333,pointer:#aaaaaa,marker:#aaaaaa,spinner:#000000,header:#333333,gutter:#333333,preview-bg:#ffffff,preview-fg:#000000,border:#000000 \
    --query "$search_query" \
    --bind "enter:change-preview:$read_email" \
    --bind "enter:+reload:sleep 0.4; $search_query" \
    --bind 'ctrl-j:change-preview()+down' \
    --bind 'ctrl-k:change-preview()+up' \
    --bind 'down:change-preview()+down' \
    --bind 'up:change-preview()+up' \
    --bind 'esc:change-preview()' \
    --bind "ctrl-x:+change-preview()+reload:sleep 0.1; $search_query" \
    --bind "ctrl-r:reload:$search_query" \
    --bind ">:reload:$search_query" \
    --bind "change:change-preview()+reload:sleep 0.25; $search_query" \
    --bind "q:abort" \
    --bind "esc:abort" \
    --bind 'click-header:transform:[[ ! $FZF_PROMPT=~ $def_acct ]] && echo "rebind(change)+change-prompt(primary account)+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" || echo "unbind(change):change-prompt(secondary account)+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
    --prompt "primary account" \
    --preview-window "top,$(preview_height)" \
    --header "DEF_ACCT: $def_acct | CURR_ACCT: $curr_acct | ACCT_FILE: $acct_file | acct[*]: ${acct[*]} | acct[@]: ${acct[@]:0:1} " \
    --ansi


# ${acct[@]:0:1}
#    --header "enter: read email, c-n: reply, [a]ttachments, mark [s]een, c-x: delete, [q]uery mode, c-f: normal mode, [r]eload, c-c: exit" \
#    --header-lines $(( accounts_count > 1 ? 2 : 1 )) \

# --bind 'ctrl-n:execute:/home/m4n4pe/git/bin/himalaya account "$(cat "'"${account_file}"'")" reply {1}' \
# --bind "ctrl-n:+reload:sleep 0.4; $search_query" \
#     --bind 'ctrl-a:execute:/home/m4n4pe/git/bin/himalaya account "$(cat "'"${account_file}"'")" attachments {1}' \
#  --bind 'ctrl-s:execute-silent:/home/m4n4pe/git/bin/himalaya account "$(cat "'"${account_file}"'")" flag add {1} \\seen' \
#     --bind "ctrl-s:+reload:sleep 0.1; $search_query" \
#     --bind 'ctrl-x:execute-silent:/home/m4n4pe/git/bin/himalaya account "$(cat "'"${account_file}"'")" delete {1}' \
##     --bind "ctrl-x:+change-preview()+reload:sleep 0.1; $search_query" \
#     --bind "ctrl-r:reload:$search_query" \
##     --bind "change:change-preview()+reload:sleep 0.25; $search_query" \
#     --bind "ctrl-q:change-prompt(Query > )+execute-silent:touch $query_file" \
#     --bind "ctrl-f:change-prompt(> )+execute-silent:rm -f $query_file" \
#     --bind "ctrl-h:change-preview()+execute-silent:$account_previous" \
#     --bind "ctrl-h:+first+reload:$search_query" \
#     --bind "ctrl-l:change-preview()+execute:$account_next" \
#      --bind "ctrl-l:+first+reload:$search_query" \
##     --preview-window "top,$(preview_height)" \
##     --header "enter: read email, c-n: reply, [a]ttachments, mark [s]een, c-x: delete, [q]uery mode, c-f: normal mode, [r]eload, c-c: exit" \
##     --header-lines $(( accounts_count > 1 ? 2 : 1 )) \
## --ansi

  rm -f $query_file

  IFS=$old_IFS
}

mail

### From original (with some sloppy mods), for reference: 

#### Search Q var (initial fzf input)
  # search_query='
  #   IFS=$('\''\n'\'' accounts=($(echo "'"$(IFS=$'\n'; echo "${accounts[*]}")"'"))
    
  #   current_account=$(cat "'"${account_file}"'")

  #   if (( ${#accounts[@]} > 1 )); then
  #     accounts_header="${#accounts[@]} accounts:"
  #       for account in "${accounts[@]}"; do
        
  #       if [ "${account}" = "${current_account}" ]; then
  #         prefix="*\x1b[22;1m"
  #       else
  #         prefix=""
  #       fi
        
  #       accounts_header+=" ${prefix}${account}\x1b[0m"
  #     done
  #     echo -e "$accounts_header (ctrl-h / ctrl-l to switch)"
  #   fi

  #   if [[ "{q}" = "'\'''\''" || "{q}" = "$(echo {)q}" ]]; then
  #     cmd="list"
  #     query=""
      
  #   else
  #     cmd="search"
  #     if [[ -f "'${query_file}'" ]]; then
  #       query=$(eval "echo {q}")
  #     else
  #       query="OR OR SUBJECT {q} FROM {q} BODY {q}"
  #     fi
  #   fi  
  #   else
  #     script -q -f -e --command "/home/m4n4pe/git/bin/himalaya envelope "$cmd" -s 100 --max-width "'$(tput cols)'" $query" /dev/null | tail -n +2
  #   fi
  # ')
## Old, for macs? : 
#  
#    if [[ `uname` == "Darwin" ]]; then
#      script -t 0 -q /dev/null /home/m4n4pe/git/bin/himalaya --color never account "${current_account}" "$cmd" -s 100 --max-width "'$(tput cols)'" $query | tail -n +2
