-- Forever priest macros. Off-GCD High: Inner Focus, racial burst.
local S = Snippets.Shared

Snippets.DB:Register("PRIEST", {
  id = "priest_flash_heal_mo",
  name = "Flash Heal MO",
  icon = "Spell_Holy_FlashHeal",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Flash Heal
]],
  category = "general",
  note = "Flash Heal mouseover",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_dispel_mo",
  name = "Dispel MO",
  icon = "Spell_Holy_DispelMagic",
  body = [[
/cast [@mouseover,exists,nodead][] Dispel Magic
]],
  category = "general",
  note = "Dispel Magic friend or enemy under cursor",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_pws_mo",
  name = "PWS MO",
  icon = "Spell_Holy_PowerWordShield",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Power Word: Shield
]],
  category = "general",
  note = "Power Word: Shield mouseover",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_penance_mo",
  name = "Penance MO",
  icon = "Spell_Holy_Penance",
  body = [[
/cast [@mouseover,exists,nodead][] Penance
]],
  category = "pve",
  note = "Disc Penance heal or harm",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_if_gheal",
  name = "IF GHeal",
  icon = "Spell_Holy_GreaterHeal",
  body = S.withRacialBurst([[
/cast Inner Focus
/cast Greater Heal
]]),
  category = "pve",
  note = "Racial burst + Inner Focus → Greater Heal",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_swd_mo",
  name = "SWD MO",
  icon = "Spell_Shadow_DemonicFortitude",
  body = [[
/cast [@mouseover,harm,nodead][] Shadow Word: Death
]],
  category = "pve",
  note = "Shadow Word: Death mouseover",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_mind_flay",
  name = "Mind Flay",
  icon = "Spell_Shadow_SiphonMana",
  body = [[
/cast [nochanneling] Mind Flay
]],
  category = "pve",
  note = "Mind Flay without clipping",
})

Snippets.DB:Register("PRIEST", {
  id = "priest_fear_ward_mo",
  name = "Fear Ward MO",
  icon = "Spell_Holy_Excorcism",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Fear Ward
]],
  category = "general",
  note = "Fear Ward mouseover",
})
