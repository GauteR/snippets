-- Example rogue macro templates. Replace bodies with your own macros.
Snippets.DB:Register("ROGUE", {
  id = "rogue_sinister",
  name = "Sinister Strike",
  icon = "Spell_Shadow_RitualOfSacrifice",
  body = "/cast Sinister Strike",
  category = "general",
  note = "Example template",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_eviscerate",
  name = "Eviscerate",
  icon = "Ability_Rogue_Eviscerate",
  body = "/cast Eviscerate",
  category = "pve",
  note = "PvE example template",
})

Snippets.DB:Register("ROGUE", {
  id = "rogue_sprint",
  name = "Sprint",
  icon = "Ability_Rogue_Sprint",
  body = "/cast Sprint",
  category = "pvp",
  note = "PvP example template",
})
