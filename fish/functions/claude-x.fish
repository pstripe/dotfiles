function claude-x --wraps=claude --description 'alias claude-x=claude --model opus[1m] --effort xhigh'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'opus[1m]' --effort xhigh $argv
end
