-- Forever shaman macros. Off-GCD High: Nature's Swiftness, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("SHAMAN", {
  id = "shaman_call_recall",
  name = "Call Recall",
  icon = "Spell_Nature_EarthElemental_Totem",
  body = [[
/cast [mod:shift] Totemic Recall; Call of the Elements
]],
  category = "general",
  note = "Call of the Elements; Shift Totemic Recall",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_totem_sets",
  name = "Totem Sets",
  icon = "Spell_Nature_StoneClawTotem",
  body = [[
/cast [mod:shift] Call of the Ancestors; [mod:ctrl] Call of the Spirits; Call of the Elements
]],
  category = "general",
  note = "Three totem call sets",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_earth_shock_kick",
  name = "Earth Shock",
  icon = "Spell_Nature_EarthShock",
  body = [[
/stopcasting
/cast [@mouseover,harm,nodead][] Earth Shock
]],
  category = "general",
  note = "Stopcasting + Earth Shock mouseover interrupt",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_lb_cl",
  name = "LB CL",
  icon = "Spell_Nature_Lightning",
  body = [[
/cast [mod:shift] Chain Lightning; Lightning Bolt
]],
  category = "pve",
  note = "Lightning Bolt; Shift Chain Lightning",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_stormstrike",
  name = "Stormstrike",
  icon = "Ability_Shaman_Stormstrike",
  body = [[
/startattack
/cast Stormstrike
]],
  category = "pve",
  note = "Stormstrike with auto-attack",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_ns_hw",
  name = "NS Heal Wave",
  icon = "Spell_Nature_MagicImmunity",
  body = S.withRacialBurst([[
/cast Nature's Swiftness
/cast Healing Wave
]]),
  category = "pve",
  note = "Racial burst + Nature's Swiftness → Healing Wave",
})

Snippets.DB:Register("SHAMAN", {
  id = "shaman_cure_key",
  name = "Cure Key",
  icon = "Spell_Nature_NullifyPoison",
  body = [[
/cast [mod:shift,@mouseover,help,nodead][mod:shift,help,nodead][mod:shift,@player] Cure Disease; [@mouseover,help,nodead][help,nodead][@player] Cure Poison
]],
  category = "general",
  note = "Cure Poison; Shift Cure Disease (mouseover / target / self)",
})
