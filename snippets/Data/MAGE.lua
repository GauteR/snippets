-- Forever mage macros. Off-GCD High: Presence of Mind, trinkets, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("MAGE", {
  id = "mage_counterspell_mo",
  name = "Counterspell",
  icon = "Spell_Frost_IceShock",
  body = [[
/stopcasting
/cast [@mouseover,harm,nodead][] Counterspell
]],
  category = "pvp",
  note = "Stopcasting + Counterspell mouseover (Counterspell GCD Unverified)",
})

Snippets.DB:Register("MAGE", {
  id = "mage_poly_mo",
  name = "Poly MO",
  icon = "Spell_Nature_Polymorph",
  body = [[
/cast [@mouseover,harm,nodead][] Polymorph
]],
  category = "pvp",
  note = "Polymorph mouseover",
})

Snippets.DB:Register("MAGE", {
  id = "mage_ab_am",
  name = "AB AM",
  icon = "Spell_Arcane_Blast",
  body = [[
/cast [mod:shift,nochanneling] Arcane Missiles; [nomod] Arcane Blast
]],
  category = "pve",
  note = "Arcane Blast; Shift Arcane Missiles",
})

Snippets.DB:Register("MAGE", {
  id = "mage_pom_pyro",
  name = "PoM Pyro",
  icon = "Spell_Fire_Fireball02",
  body = S.withRacialBurst([[
/cast Presence of Mind
/cast Pyroblast
]]),
  category = "pve",
  note = "Racial burst + Presence of Mind → Pyroblast",
})

Snippets.DB:Register("MAGE", {
  id = "mage_ap_trinkets",
  name = "AP Trinkets",
  icon = "Spell_Nature_Lightning",
  body = S.withBurstPrefix("/cast Arcane Power"),
  category = "pve",
  note = "Trinkets + racial burst, then Arcane Power (AP GCD Unverified)",
})

Snippets.DB:Register("MAGE", {
  id = "mage_frost_il",
  name = "Frost IL",
  icon = "Spell_Frost_FrostBolt02",
  body = [[
/cast [mod:shift] Ice Lance; Frostbolt
]],
  category = "pve",
  note = "Frostbolt; Shift Ice Lance",
})

Snippets.DB:Register("MAGE", {
  id = "mage_ice_block",
  name = "Ice Block",
  icon = "Spell_Frost_Frost",
  body = [[
/cancelaura Ice Block
/cast Ice Block
]],
  category = "pvp",
  note = "Ice Block toggle",
})

Snippets.DB:Register("MAGE", {
  id = "mage_remove_curse_mo",
  name = "Decurse MO",
  icon = "Spell_Nature_RemoveCurse",
  body = [[
/cast [mod:shift,@player][@mouseover,help,nodead][help,nodead][@player] Remove Lesser Curse
]],
  category = "general",
  note = "Remove Lesser Curse mouseover / target / self; Shift self",
})
