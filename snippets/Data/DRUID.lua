-- Example druid macro templates. Replace bodies with your own macros.
Snippets.DB:Register("DRUID", {
  id = "druid_wrath",
  name = "Wrath",
  icon = "Spell_Nature_AbolishMagic",
  body = "/cast Wrath",
  note = "Example template",
})

Snippets.DB:Register("DRUID", {
  id = "druid_healing_touch",
  name = "Healing Touch",
  icon = "Spell_Nature_HealingTouch",
  body = "/cast Healing Touch",
  note = "Example template",
})

Snippets.DB:Register("DRUID", {
  id = "druid_bear",
  name = "Bear Form",
  icon = "Ability_Racial_BearForm",
  body = "/cast Bear Form",
  note = "Example template",
})
