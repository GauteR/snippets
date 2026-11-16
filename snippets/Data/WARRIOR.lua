-- Forever warrior macros. Off-GCD High: Bloodrage, trinkets, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("WARRIOR", {
  id = "warrior_charge_intercept",
  name = "Charge Intercept",
  icon = "Ability_Warrior_Charge",
  body = [[
/cast [nocombat,nostance:1] Battle Stance; [nocombat] Charge; [nostance:3] Berserker Stance; Intercept
]],
  category = "general",
  note = "Stance swap may need a second press",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_interrupt",
  name = "Interrupt",
  icon = "Ability_Warrior_ShieldBash",
  body = [[
/cast [stance:1/2] Shield Bash; Pummel
]],
  category = "general",
  note = "Shield Bash in stance 1/2, else Pummel",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_victory_heroic",
  name = "Victory Heroic",
  icon = "Ability_Warrior_Devastate",
  body = [[
/cast Victory Rush
/cast Heroic Strike
]],
  category = "pve",
  note = "Victory Rush then Heroic Strike",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_mortal_strike",
  name = "Mortal Strike",
  icon = "Ability_Warrior_SavageBlow",
  body = [[
/startattack
/cast Mortal Strike
]],
  category = "pve",
  note = "Mortal Strike with auto-attack",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_bloodrage_bt",
  name = "Bloodrage BT",
  icon = "Spell_Nature_BloodLust",
  body = S.withBurstPrefix([[
/cast Bloodrage
/startattack
/cast Bloodthirst
]]),
  category = "pve",
  note = "Trinkets, racial burst, Bloodrage → Bloodthirst",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_rend_hs_seq",
  name = "Rend HS",
  icon = "Ability_Gouge",
  body = S.withBurstPrefix([[
/cast Bloodrage
/startattack
/castsequence reset=combat Rend, Heroic Strike
]]),
  category = "pve",
  note = "Trinkets + racial + Bloodrage; Rend then Heroic Strike, reset combat",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_bloodrage_charge_victory_rush",
  name = "Bloodrage and charge into combat",
  icon = "Ability_Warrior_Charge",
  body = S.withBurstPrefix([[
/cast Bloodrage
/cast [nocombat,nostance:1] Battle Stance; [nocombat] Charge; [nostance:3] Berserker Stance; Intercept
/startattack
/cast Victory Rush
]]),
  category = "pve",
  note = "racial + Bloodrage; Charge then Victory Rush",
})
