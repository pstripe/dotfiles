function claude --wraps=claude --description 'alias claude=claude --model opus[1m] --effort high'
  set -x ENABLE_LSP_TOOL 1
  command claude --model 'opus[1m]' --effort high $argv
end
