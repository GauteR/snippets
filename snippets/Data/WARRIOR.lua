-- Example warrior macro templates. Replace bodies with your own macros.
Snippets.DB:Register("WARRIOR", {
  id = "warrior_charge",
  name = "Charge",
  icon = "Ability_Warrior_Charge",
  body = [[
/cast Charge
{IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist|ORC=/cast Blood Fury|TROLL=/cast Berserking|TAUREN=/cast War Stomp|SCOURGE=/cast Will of the Forsaken|NIGHTELF=/cast Shadowmeld|HUMAN=/cast Perception}
]],
  note = "Example with race {IF:...} conditional",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_battle_shout",
  name = "Battle Shout",
  icon = "Ability_Warrior_BattleShout",
  body = "/cast Battle Shout",
  note = "Example template",
})

Snippets.DB:Register("WARRIOR", {
  id = "warrior_shield_block",
  name = "Shield Block",
  icon = "Ability_Defend",
  body = "/cast Shield Block",
  note = "Example template",
})
