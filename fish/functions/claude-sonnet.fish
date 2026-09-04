function claude-sonnet --wraps=claude --description 'alias claude-sonnet=claude --model sonnet --effort high'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'sonnet' --effort high $argv
end
