-- Forever hunter macros. Off-GCD High: pet commands, trinkets, racial burst.
local S = Snippets.Shared

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

Snippets.DB:Register("HUNTER", {
  id = "hunter_mark_sting_seq",
  name = "Mark Sting",
  icon = "Ability_Hunter_SniperShot",
  body = S.withBurstPrefix([[
/petattack
/castsequence reset=target Hunter's Mark, Serpent Sting
]]),
  category = "pve",
  note = "Trinkets + racial burst + pet; Mark then Serpent Sting",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_clip_kick_seq",
  name = "Clip Kick",
  icon = "Ability_Rogue_Trip",
  body = [[
/castsequence reset=6 Wing Clip, Strider Kick
]],
  category = "pve",
  note = "Surv melee escape: Wing Clip then Strider Kick",
})

Snippets.DB:Register("HUNTER", {
  id = "hunter_scatter_trap_seq",
  name = "Scatter Trap",
  icon = "Spell_Frost_Stun",
  body = [[
/castsequence reset=20 Scatter Shot, Freezing Trap
]],
  category = "pvp",
  note = "Scatter Shot then Freezing Trap",
})
