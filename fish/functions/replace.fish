function replace
  sd "$argv[1]" "$argv[2]" (rg "$argv[1]" "$argv[3]" --hidden --files-with-matches)
end
