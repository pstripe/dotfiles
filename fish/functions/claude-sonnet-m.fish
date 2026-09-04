function claude-sonnet-m --wraps=claude --description 'alias claude-sonnet-m=claude --model sonnet[1m] --effort high'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'sonnet[1m]' --effort high $argv
end
