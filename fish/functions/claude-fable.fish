function claude-fable --wraps=claude --description 'alias claude-fable=claude --model fable --effort high'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'fable' --effort high $argv
end
