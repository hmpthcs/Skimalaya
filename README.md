# Skimalaya
Attempt at a featureful Fzf / Skim TUI for Himalaya

Does not actually use skim at all (yet). Plan is to get fzf version working fully --> make skim variant

NOTICE: Very poor quality shell scripting. Would discourage real-world use other than for
demonstration purposes.


## Status
### Current features:
 - List emails
 - Search emails 
 - Read emails in preview window
 
### High-piority WIP features:
 - Multi-account support / switch account interactively
 - Built-in menu for managing UI, script and himalaya configurations
 - View attachments
 - Reply, delete, mark emails as read
 - Compose new mail
 
### Short-term goal features:
 - Proper paging of results (get terminal lines --> fetch one page; next 
    key advances one page. Page # shown in header.
 - Search mails with IMAP querying
 - Switch to Chawan from w3m, toggleable image loading in preview

### Later goal features:
 - Hot-update mails with IMAP listening
 - Management of local storage of mails + attachments
 - Full himalaya config management
 - Read emails externally in w3m(or chawan) for interactive links
 - ? Move view attachments, reply, other functionality to a prompt after reading
    externally to clean up UI ?(from original)

## Brainstorms

- Direct Skim-Himalaya integration in compiled rust code (no need for them to communicate via shell)

## References, Examples, Prior art
### Fzf / Skim Help
https://junegunn.github.io/fzf/getting-started/

