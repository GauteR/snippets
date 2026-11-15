-- Forever druid macros. Off-GCD High: Nature's Swiftness, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("DRUID", {
  id = "druid_travel_picker",
  name = "Travel Form",
  icon = "Ability_Druid_TravelForm",
  body = [[
/cast [swimming] Aquatic Form; [outdoors] Travel Form; Cat Form
]],
  category = "general",
  note = "Travel form picker",
})

Snippets.DB:Register("DRUID", {
  id = "druid_cat_dash",
  name = "Cat Dash",
  icon = "Ability_Druid_Dash",
  body = [[
/cancelform [noform:3]
/cast [noform:3] Cat Form
/cast Dash
]],
  category = "general",
  note = "Enter Cat then Dash (form+ability may need two presses)",
})

Snippets.DB:Register("DRUID", {
  id = "druid_rejuv_mo",
  name = "Rejuv MO",
  icon = "Spell_Nature_Rejuvenation",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Rejuvenation
]],
  category = "general",
  note = "Rejuvenation mouseover",
})

Snippets.DB:Register("DRUID", {
  id = "druid_ns_ht",
  name = "NS HT",
  icon = "Spell_Nature_HealingTouch",
  body = S.withRacialBurst([[
/cast Nature's Swiftness
/cast Healing Touch
]]),
  category = "pve",
  note = "Racial burst + Nature's Swiftness → Healing Touch",
})

Snippets.DB:Register("DRUID", {
  id = "druid_bear_charge",
  name = "Bear Charge",
  icon = "Ability_Hunter_Pet_Bear",
  body = [[
/cast [noform:1] Bear Form; Feral Charge
]],
  category = "pve",
  note = "Bear then Feral Charge (two presses on Forever)",
})

Snippets.DB:Register("DRUID", {
  id = "druid_cat_opener",
  name = "Cat Opener",
  icon = "Ability_Druid_SupriseAttack",
  body = [[
/cast [noform:3] Cat Form; [nostealth,nocombat] Prowl; Pounce
]],
  category = "pve",
  note = "Cat / Prowl / Pounce opener logic",
})

Snippets.DB:Register("DRUID", {
  id = "druid_regrowth_emerg",
  name = "Regrowth MO",
  icon = "Spell_Nature_ResistNature",
  body = [[
/cancelform
/cast [@mouseover,help,nodead][help,nodead][@player] Regrowth
]],
  category = "pvp",
  note = "Leave form emergency Regrowth",
})

Snippets.DB:Register("DRUID", {
  id = "druid_wild_growth_mo",
  name = "Wild Growth",
  icon = "Ability_Druid_Flourish",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Wild Growth
]],
  category = "pve",
  note = "Resto Wild Growth mouseover",
})

Snippets.DB:Register("DRUID", {
  id = "druid_revive_mo",
  name = "Revive MO",
  icon = "Spell_Nature_Regenerate",
  body = [[
/cast [@mouseover,help,dead][help,dead] Revive
]],
  category = "pve",
  note = "Combat rez mouseover",
})

-- Compact mouseover/@player (no mid help-tier) so body + #showtooltip stays ≤ 255.
Snippets.DB:Register("DRUID", {
  id = "druid_cure_key",
  name = "Cure Key",
  icon = "Spell_Nature_RemoveCurse",
  body = [[
/cancelform
/cast [mod:alt,@mouseover,help,nodead][mod:alt,@player] Abolish Poison; [mod:shift,@mouseover,help,nodead][mod:shift,@player] Cure Poison; [@mouseover,help,nodead][@player] Remove Curse
]],
  category = "general",
  note = "Leave form; Remove Curse; Shift Cure Poison; Alt Abolish Poison (mouseover or self)",
})

-- Buff sequence (no damage/heal crit window on press) — cancelform only, no burst prefix.
Snippets.DB:Register("DRUID", {
  id = "druid_motw_thorns_seq",
  name = "MotW Thorns",
  icon = "Spell_Nature_Regeneration",
  body = [[
/cancelform
/castsequence reset=10/target Mark of the Wild, Thorns
]],
  category = "general",
  note = "Leave form; MotW then Thorns; reset 10s or target change",
})
