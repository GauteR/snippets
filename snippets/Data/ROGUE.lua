-- Forever rogue macros. Cold Blood / Pick Pocket GCD Unverified — no free stack with finishers.
local S = Snippets.Shared

Snippets.DB:Register("ROGUE", {
  id = "rogue_stealth_cs",
  name = "Stealth CS",
  icon = "Ability_Stealth",
  body = [[
/cast [nostealth] Stealth; Cheap Shot
]],
  category = "general",
  note = "Stealth then Cheap Shot",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_pick_pocket",
  name = "Pick Pocket",
  icon = "INV_Misc_Bag_01",
  body = "/cast Pick Pocket",
  category = "general",
  note = "Pick Pocket alone (GCD Unverified — do not stack Cheap Shot on same press)",
})


Snippets.DB:Register("ROGUE", {
  id = "rogue_kick_mo",
  name = "Kick MO",
  icon = "Ability_Kick",
  body = [[
/cast [@mouseover,harm,nodead][] Kick
]],
  category = "general",
  note = "Kick mouseover",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_finishers",
  name = "Finishers",
  icon = "Ability_Rogue_Eviscerate",
  body = [[
/cast [mod:shift] Slice and Dice; [mod:ctrl] Rupture; Eviscerate
]],
  category = "pve",
  note = "Eviscerate; Shift SnD; Ctrl Rupture",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_cold_blood",
  name = "Cold Blood",
  icon = "Spell_Ice_Lament",
  body = S.withRacialBurst("/cast Cold Blood"),
  category = "pve",
  note = "Racial burst + Cold Blood alone (CB GCD Unverified — do not stack finisher on same press)",
})


Snippets.DB:Register("ROGUE", {
  id = "rogue_mutilate",
  name = "Mutilate",
  icon = "Ability_Rogue_ShadowStrikes",
  body = [[
/startattack
/cast Mutilate
]],
  category = "pve",
  note = "Assassination Mutilate",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_vanish",
  name = "Vanish",
  icon = "Ability_Vanish",
  body = [[
/stopattack
/cast Vanish
]],
  category = "pvp",
  note = "Clean Vanish",
})
