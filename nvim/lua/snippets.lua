local luasnip = require('luasnip')


-- Snippets
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local c = luasnip.choice_node


luasnip.add_snippets('php', {
  s('phptag', {
    t({ '<?php' }),
  }),

  s('namespace', {
    t({ 'namespace VK\\Messages\\v2\\' }), i(1), t({ ';' }),
  }),
  s('use', {
    t({ 'use VK\\Messages\\' }), i(1), t({ ';' }),
  }),
  s('class', {
      t({'final class '}), i(1, 'ClassName'), t({' {', '' , '}' }),
  }),

  s('method', {
    c(1, {
      t('public '),
      t('private '),
      t('protected '),
    }),
    t('function '), i(2, 'funcName'), t('('), i(3), t(')'), i(4, ': void'), t({' {', '  '}),
    i(0),
    t({'', '}'})
  }),

  s('static', {
    c(1, {
      t('public '),
      t('private '),
      t('protected '),
    }),
    t({'static function'}), i(1, 'funcName'), t('('), i(2), t(')'), i(3, ': void'), t({' {', '  '}),
    i(0),
    t({'', '}'})
  }),

  s('strict', {
    t({
      '/** @kphp-strict-types-enable */',
      'declare(strict_types = 1);',
    })
  }),

  s('immutable', {
    t({
      '/** @kphp-immutable-class */'
    })
  })
})
