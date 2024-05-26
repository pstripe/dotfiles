-- TODO: move to ftplugins
vim.g.mysnippets = {
  php = '<?php',
  namespace = 'namespace VK\\Messages\\v2\\${1:namespace};',
  use = 'use VK\\Messages\\${1:symbol};',
  class = 'final class ${1:class} {$0}',
  method = '${1|public,protected,private|} ${2|static |}function ${3:foo}(): ${4:int} {$0}',
}
