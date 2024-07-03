set --universal --export NNN_PLUG "u:getplugs;p:preview-tui;i:imgview;d:diffs;s:suedit"

# -a uto-setup temporary NNN_FIFO (described in ENVIRONMENT section)
# -e open text files in $VISUAL (else $EDITOR, fallback vi)
# -E use $EDITOR for internal undetached edits
# -o open files only on Enter key
set --universal --export NNN_OPTS "Eeao"

set --universal --export NNN_COLORS "2641"
