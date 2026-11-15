-- Forever paladin macros. Divine Favor GCD is Unverified — not treated as High off-GCD.
local S = Snippets.Shared

Snippets.DB:Register("PALADIN", {
  id = "paladin_judgement",
  name = "Judgement",
  icon = "Spell_Holy_RighteousFury",
  body = [[
/startattack
/cast Judgement
]],
  category = "general",
  note = "Seal is not consumed by Judgement",
})

Snippets.DB:Register("PALADIN", {
  id = "paladin_cleanse_mo",
  name = "Cleanse MO",
  icon = "Spell_Holy_Purify",
  body = [[
/cast [@mouseover,help,nodead][help,nodead][@player] Cleanse
]],
  category = "general",
  note = "Cleanse mouseover / target / self",
})

Snippets.DB:Register("PALADIN", {
  id = "paladin_holy_strike",
  name = "Holy Strike",
  icon = "Spell_Holy_HolySmite",
  body = [[
/startattack
/cast Holy Strike
]],
  category = "pve",
  note = "Forever Ret filler",
})

Snippets.DB:Register("PALADIN", {
  id = "paladin_hot_r_cons",
  name = "HotR Cons",
  icon = "Ability_Paladin_HammerOfTheRighteous",
  body = [[
/cast [mod:shift] Consecration; Hammer of the Righteous
]],
  category = "pve",
  note = "Prot: HotR, Shift Consecration",
})

Snippets.DB:Register("PALADIN", {
  id = "paladin_divine_favor",
  name = "Divine Favor",
  icon = "Spell_Holy_HolyBolt",
  body = S.withRacialBurst("/cast Divine Favor"),
  category = "pve",
  note = "Racial burst + Divine Favor alone (DF GCD Unverified — do not stack heal on same press)",
})

-- Burst prefix includes Elune's Light (Night Elf +10% crit) and trinkets that can raise heal crit.
Snippets.DB:Register("PALADIN", {
  id = "paladin_vigil_shock_seq",
  name = "Vigil Shock",
  icon = "Spell_Holy_SearingLight",
  body = S.withBurstPrefix([[
/castsequence [@mouseover,help,nodead][help,nodead][@player] reset=30 Light's Vigil, Holy Shock
]]),
  category = "pve",
  note = "Trinkets + racial burst (incl. Elune's Light); Light's Vigil then Holy Shock",
})

