function claude-sonnet-x --wraps=claude --description 'alias claude-sonnet-x=claude --model sonnet --effort xhigh'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'sonnet' --effort xhigh $argv
end
