-- Example hunter macro templates. Replace bodies with your own macros.
Snippets.DB:Register("HUNTER", {
  id = "hunter_auto_shot",
  name = "Auto Shot",
  icon = "Ability_Whirlwind",
  body = "/cast !Auto Shot",
  note = "Example template",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_hunters_mark",
  name = "Hunter's Mark",
  icon = "Ability_Hunter_SniperShot",
  body = "/cast Hunter's Mark",
  note = "Example template",
})

-- Multiline macro via escaped newlines (\n). Equivalent to a long string.
Snippets.DB:Register("HUNTER", {
  id = "hunter_feign",
  name = "Feign Death",
  icon = "Ability_Rogue_FeignDeath",
  body = "/stopattack\n/cast Feign Death",
  note = "Multiline example (escaped \\n)",
})
