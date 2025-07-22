function replace --wraps='sd $1 $2 (rg $1 --files-with-matches)'
  set --local orig $argv[1]
  set --local new $argv[2]

  set --erase argv[1] argv[1]
  
  sd "$orig" "$new" "$argv" (rg "$orig" --files-with-matches "$argv")
end
