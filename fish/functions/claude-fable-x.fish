function claude-fable-x --wraps=claude --description 'alias claude-fable-x=claude --model fable --effort xhigh'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'fable' --effort xhigh $argv
end
