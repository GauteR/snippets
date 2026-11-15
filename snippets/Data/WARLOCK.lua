-- Forever warlock macros. Off-GCD High: Fel Domination, pet commands, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("WARLOCK", {
  id = "warlock_sb_pet",
  name = "SB Pet",
  icon = "Spell_Shadow_ShadowBolt",
  body = [[
/petattack
/cast Shadow Bolt
]],
  category = "general",
  note = "petattack with Shadow Bolt",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_fear_mo",
  name = "Fear MO",
  icon = "Spell_Shadow_Possession",
  body = [[
/cast [@mouseover,harm,nodead][] Fear
]],
  category = "pvp",
  note = "Fear mouseover",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_bane_agony_mo",
  name = "Bane Agony MO",
  icon = "Spell_Shadow_CurseOfSargeras",
  body = [[
/cast [@mouseover,harm,nodead][] Bane of Agony
]],
  category = "pve",
  note = "Bane of Agony mouseover",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_fel_dom_vw",
  name = "Fel Dom VW",
  icon = "Spell_Shadow_SummonVoidWalker",
  body = S.withRacialBurst([[
/cast Fel Domination
/cast Summon Voidwalker
]]),
  category = "general",
  note = "Racial burst + Fel Domination → Voidwalker",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_curse_key",
  name = "Curse Key",
  icon = "Spell_Shadow_ChillTouch",
  body = [[
/cast [mod:shift] Curse of Recklessness; [mod:ctrl] Curse of Weakness; Curse of the Elements
]],
  category = "pve",
  note = "Elements; Shift Recklessness; Ctrl Weakness",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_drain_life",
  name = "Drain Life",
  icon = "Spell_Shadow_LifeDrain02",
  body = [[
/cast [nochanneling] Drain Life
]],
  category = "general",
  note = "Drain Life without clipping",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_bane_havoc_mo",
  name = "Bane Havoc MO",
  icon = "Ability_Warlock_BaneOfHavoc",
  body = [[
/cast [@mouseover,harm,nodead][] Bane of Havoc
]],
  category = "pve",
  note = "Dest Bane of Havoc mouseover",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_aff_dots_seq",
  name = "Aff DoTs",
  icon = "Spell_Shadow_AbominationExplosion",
  body = S.withBurstPrefix([[
/petattack
/castsequence reset=target/combat Corruption, Bane of Agony, Siphon Life
]]),
  category = "pve",
  note = "Trinkets + racial burst + pet; Aff DoTs reset target/combat",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_immol_conflag",
  name = "Immol Conflag",
  icon = "Spell_Fire_Fireball",
  body = S.withBurstPrefix([[
/castsequence reset=target Immolate, Conflagrate
]]),
  category = "pve",
  note = "Trinkets + racial burst; Dest Immolate then Conflagrate",
})

Snippets.DB:Register("WARLOCK", {
  id = "warlock_demo_sac_imp",
  name = "Demo Sac Imp",
  icon = "Spell_Shadow_Metamorphosis",
  body = [[
/castsequence reset=60 Demonic Sacrifice, Fel Domination, Summon Imp
]],
  category = "pve",
  note = "Demo Demonic Pact: sacrifice, Fel Domination, Imp (no burst prefix)",
})
