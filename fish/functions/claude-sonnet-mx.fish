function claude-sonnet-mx --wraps=claude --description 'alias claude-sonnet-mx=claude --model sonnet[1m] --effort xhigh'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'sonnet[1m]' --effort xhigh $argv
end
