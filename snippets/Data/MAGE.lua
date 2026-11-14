-- Example mage macro templates. Replace bodies with your own macros.
Snippets.DB:Register("MAGE", {
  id = "mage_frostbolt",
  name = "Frostbolt",
  icon = "Spell_Frost_FrostBolt02",
  body = "/cast Frostbolt",
  note = "Example template",
})

Snippets.DB:Register("MAGE", {
  id = "mage_fireball",
  name = "Fireball",
  icon = "Spell_Fire_FlameBolt",
  body = "/cast Fireball",
  note = "Example template",
})

-- Multiline macro via Lua long string. Newlines become separate macro lines in-game.
Snippets.DB:Register("MAGE", {
  id = "mage_counterspell",
  name = "Counterspell",
  icon = "Spell_Frost_IceShock",
  body = [[
/stopcasting
/cast Counterspell
]],
  category = "pvp",
  note = "PvP multiline example (long string)",
})
