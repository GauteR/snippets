-- Forever hunter macros. Off-GCD High: pet commands.
Snippets.DB:Register("HUNTER", {
  id = "hunter_mark_pet",
  name = "Mark Pet",
  icon = "Ability_Hunter_SniperShot",
  body = [[
/cast Hunter's Mark
/petattack
]],
  category = "general",
  note = "Hunter's Mark + High off-GCD /petattack",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_pet_ctrl",
  name = "Pet Control",
  icon = "Ability_Hunter_Pet_Wolf",
  body = [[
/petattack [nomod]
/petpassive [mod:alt]
/petfollow [mod:alt]
]],
  category = "general",
  note = "Pet commands (High: no GCD)",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_cancel_aspect",
  name = "Cancel Aspect",
  icon = "Ability_Mount_JungleTiger",
  body = [[
/cancelaura Aspect of the Cheetah
/cancelaura Aspect of the Pack
]],
  category = "general",
  note = "Drop Cheetah/Pack to avoid daze",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_aimed_multi",
  name = "Aimed Multi",
  icon = "INV_Spear_07",
  body = [[
/cast [mod:shift] Multi-Shot; Aimed Shot
]],
  category = "pve",
  note = "Aimed Shot; Shift Multi-Shot",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_flare_cursor",
  name = "Flare Cursor",
  icon = "Spell_Fire_Flare",
  body = [[
/cast [@cursor] Flare
]],
  category = "pvp",
  note = "Flare at cursor",
})
