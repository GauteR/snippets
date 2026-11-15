# WoW Forever — common macros

**Game:** World of Warcraft: Forever (not Vanilla / Classic Era).  
**Spell names:** English Forever client.  
**Purpose:** Reference of *common* general and per-class macros. Essentials are shipped as Snippets templates under [`snippets/Data/`](../snippets/Data/) (`GENERAL.lua` + per-class files). This doc also keeps **patterns** (`SPELL_NAME` placeholders) that are not registered as templates.

Full curated sets (300+ macros) live at [wowclassicforever.info/macros](https://wowclassicforever.info/macros/) (built from Forever trainer data).

---

## Forever rules (read first)

1. **One press = one GCD.** Only stack a second `/cast` when the first is off-GCD (trinkets, pet commands, Presence of Mind, Nature’s Swiftness, Bloodrage, Inner Focus, Fel Domination, Eureka!, …). See [`forever-offgcd-research.md`](forever-offgcd-research.md).
2. **Stance / form + ability = two presses** on Forever (e.g. Battle Stance then Taunt). Do not expect Classic “one-press stance swap” myths.
3. Prefer **highest rank** names; Forever downranking is weaker than Classic habits.
4. Use **`#showtooltip`** and the **`?` icon** so the bar shows the spell/item you cast.
5. Forever renames / adds spells (examples: **Bane of Agony**, **Victory Rush**, **Penance**, **Call of the Elements**, **Holy Strike**, **Mutilate**). Do not paste Classic-only names blindly.

---

## General macros (all characters)

### Trinkets + racial burst

```
#showtooltip
/use 13
/use 14
/cast Blood Fury
/cast Berserking
/cast Eureka!
```

Missing racials are skipped. Pair with your real damage cooldown on the same key or the next line.

### Mouseover harm (interrupt / CC / DoT)

```
#showtooltip
/cast [@mouseover,harm,nodead][] SPELL_NAME
```

### Mouseover help (heal / buff / dispel)

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] SPELL_NAME
```

### Self cast without retargeting

```
#showtooltip
/cast [@player] SPELL_NAME
```

### Tank’s target (healer / support)

```
#showtooltip
/cast [@targettarget,harm,nodead][] SPELL_NAME
```

### Stopcasting then cast (escape / interrupt)

```
#showtooltip SPELL_NAME
/stopcasting
/cast SPELL_NAME
```

### Modifier: two spells, one key

```
#showtooltip
/cast [mod:shift] SECOND_SPELL; FIRST_SPELL
```

### Focus / nearest enemy when you have none

```
#showtooltip SPELL_NAME
/targetenemy [noharm][dead]
/cast SPELL_NAME
```

### Cancel immunity / aura early

```
#showtooltip SPELL_NAME
/cancelaura SPELL_NAME
/cast SPELL_NAME
```

### Soft mute around a noisy cast (optional)

```
#showtooltip
/run SetCVar("Sound_EnableSFX",0)
/cast SPELL_NAME
/run SetCVar("Sound_EnableSFX",1)
```

---

## Warrior

Sources: [Forever Warrior macros](https://wowclassicforever.info/macros/warrior/)

**Charge / Intercept (two presses after stance swap):**

```
#showtooltip
/cast [nocombat,nostance:1] Battle Stance; [nocombat] Charge; [nostance:3] Berserker Stance; Intercept
```

**Interrupt any stance:**

```
#showtooltip
/cast [stance:1/2] Shield Bash; Pummel
```

**Victory Rush else Heroic Strike (Forever):**

```
#showtooltip
/cast Victory Rush
/cast Heroic Strike
```

**Mortal Strike + auto attack:**

```
#showtooltip Mortal Strike
/startattack
/cast Mortal Strike
```

**Bloodrage opener (off-GCD prefix — verify + stack with main CD):**

```
#showtooltip Bloodthirst
/cast Bloodrage
/startattack
/cast Bloodthirst
```

---

## Paladin

Sources: [Forever Paladin macros](https://wowclassicforever.info/macros/paladin/)

**Judgement (Forever: Seal is not consumed):**

```
#showtooltip Judgement
/startattack
/cast Judgement
```

**Cleanse mouseover:**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Cleanse
```

(Paladin Cleanse covers magic, poison, and disease — no separate cure-key template.)

**Holy Strike (Forever Ret filler):**

```
#showtooltip Holy Strike
/startattack
/cast Holy Strike
```

**Hammer of the Righteous / Consecration (Prot):**

```
#showtooltip
/cast [mod:shift] Consecration; Hammer of the Righteous
```

**Divine Favor (GCD Unverified — do not stack heal on the same press):**

```
#showtooltip Divine Favor
/cast Divine Favor
```

---

## Hunter

Sources: [Forever Hunter macros](https://wowclassicforever.info/macros/hunter/)

**Mark + send pet:**

```
#showtooltip Hunter's Mark
/cast Hunter's Mark
/petattack
```

**Pet attack / Alt recall:**

```
/petattack [nomod]
/petpassive [mod:alt]
/petfollow [mod:alt]
```

**Cancel Cheetah / Pack (avoid daze):**

```
/cancelaura Aspect of the Cheetah
/cancelaura Aspect of the Pack
```

**Aimed Shot / Multi-Shot:**

```
#showtooltip
/cast [mod:shift] Multi-Shot; Aimed Shot
```

**Flare at cursor:**

```
#showtooltip Flare
/cast [@cursor] Flare
```

---

## Rogue

Sources: [Forever Rogue macros](https://wowclassicforever.info/macros/rogue/)

**Stealth then Cheap Shot (two-step logic):**

```
#showtooltip
/cast [nostealth] Stealth; Cheap Shot
```

**Pick Pocket (GCD Unverified — keep Cheap Shot on a separate key):**

```
#showtooltip Pick Pocket
/cast Pick Pocket
```

**Kick mouseover:**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Kick
```

**Finishers on modifiers:**

```
#showtooltip
/cast [mod:shift] Slice and Dice; [mod:ctrl] Rupture; Eviscerate
```

**Cold Blood (GCD Unverified — do not stack finisher on the same press):**

```
#showtooltip Cold Blood
/cast Cold Blood
```

**Mutilate (Forever Assassination):**

```
#showtooltip Mutilate
/startattack
/cast Mutilate
```

**Clean Vanish:**

```
#showtooltip Vanish
/stopattack
/cast Vanish
```

---

## Priest

Sources: [Forever Priest macros](https://wowclassicforever.info/macros/priest/)

**Flash Heal mouseover:**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Flash Heal
```

**Dispel Magic (friend or enemy under cursor):**

```
#showtooltip
/cast [@mouseover,exists,nodead][] Dispel Magic
```

**Cure Disease / Abolish Disease:**

```
#showtooltip
/cast [mod:shift,@mouseover,help,nodead][mod:shift,help,nodead][mod:shift,@player] Abolish Disease; [@mouseover,help,nodead][help,nodead][@player] Cure Disease
```

- Press: Cure Disease on mouseover, target, or self
- Shift: Abolish Disease on the same picks

**Power Word: Shield mouseover:**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Power Word: Shield
```

**Penance (Forever Disc — heal or harm):**

```
#showtooltip
/cast [@mouseover,exists,nodead][] Penance
```

**Inner Focus → Greater Heal:**

```
#showtooltip Greater Heal
/cast Inner Focus
/cast Greater Heal
```

**Shadow Word: Death mouseover (Forever):**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Shadow Word: Death
```

**Mind Flay without clipping:**

```
#showtooltip
/cast [nochanneling] Mind Flay
```

**Fear Ward mouseover (baseline for all priests in Forever):**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Fear Ward
```

---

## Shaman

Sources: [Forever Shaman macros](https://wowclassicforever.info/macros/shaman/)

**Call of the Elements / Totemic Recall (Forever):**

```
#showtooltip
/cast [mod:shift] Totemic Recall; Call of the Elements
```

**Three totem sets:**

```
#showtooltip
/cast [mod:shift] Call of the Ancestors; [mod:ctrl] Call of the Spirits; Call of the Elements
```

**Earth Shock interrupt (stopcasting + mouseover):**

```
#showtooltip Earth Shock
/stopcasting
/cast [@mouseover,harm,nodead][] Earth Shock
```

**Cure Poison / Cure Disease:**

```
#showtooltip
/cast [mod:shift,@mouseover,help,nodead][mod:shift,help,nodead][mod:shift,@player] Cure Disease; [@mouseover,help,nodead][help,nodead][@player] Cure Poison
```

- Press: Cure Poison on mouseover, target, or self
- Shift: Cure Disease on the same picks

**Lightning Bolt / Chain Lightning:**

```
#showtooltip
/cast [mod:shift] Chain Lightning; Lightning Bolt
```

**Stormstrike + attack:**

```
#showtooltip Stormstrike
/startattack
/cast Stormstrike
```

**Nature's Swiftness → big heal:**

```
#showtooltip Healing Wave
/cast Nature's Swiftness
/cast Healing Wave
```

---

## Mage

Sources: [Forever Mage macros](https://wowclassicforever.info/macros/mage/)

**Counterspell mouseover:**

```
#showtooltip Counterspell
/stopcasting
/cast [@mouseover,harm,nodead][] Counterspell
```

**Polymorph mouseover:**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Polymorph
```

**Arcane Blast / Arcane Missiles (Forever Arcane):**

```
#showtooltip
/cast [mod:shift,nochanneling] Arcane Missiles; [nomod] Arcane Blast
```

**Presence of Mind → Pyroblast:**

```
#showtooltip Pyroblast
/cast Presence of Mind
/cast Pyroblast
```

**Burst CD + trinkets:**

```
#showtooltip Arcane Power
/use 13
/use 14
/cast Arcane Power
```

**Frostbolt / Ice Lance (Forever):**

```
#showtooltip
/cast [mod:shift] Ice Lance; Frostbolt
```

**Ice Block toggle:**

```
#showtooltip Ice Block
/cancelaura Ice Block
/cast Ice Block
```

**Remove Lesser Curse (Forever; also removes a Bane):**

```
#showtooltip
/cast [mod:shift,@player][@mouseover,help,nodead][help,nodead][@player] Remove Lesser Curse
```

- Press: Decurse mouseover, friendly target, or self
- Shift: Decurse self

---

## Warlock

Sources: [Forever Warlock macros](https://wowclassicforever.info/macros/warlock/)

**Shadow Bolt + pet:**

```
#showtooltip Shadow Bolt
/petattack
/cast Shadow Bolt
```

**Fear mouseover:**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Fear
```

**Bane of Agony mouseover (Forever name):**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Bane of Agony
```

**Fel Domination → Voidwalker:**

```
#showtooltip Summon Voidwalker
/cast Fel Domination
/cast Summon Voidwalker
```

**Curse key (Elements / Recklessness / Weakness):**

```
#showtooltip
/cast [mod:shift] Curse of Recklessness; [mod:ctrl] Curse of Weakness; Curse of the Elements
```

**Drain Life without clipping:**

```
#showtooltip
/cast [nochanneling] Drain Life
```

**Bane of Havoc mouseover (Forever Dest):**

```
#showtooltip
/cast [@mouseover,harm,nodead][] Bane of Havoc
```

---

## Druid

Sources: [Forever Druid macros](https://wowclassicforever.info/macros/druid/)

**Travel form picker:**

```
#showtooltip
/cast [swimming] Aquatic Form; [outdoors] Travel Form; Cat Form
```

**Cat + Dash:**

```
#showtooltip Dash
/cancelform [noform:3]
/cast [noform:3] Cat Form
/cast Dash
```

**Rejuvenation mouseover:**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Rejuvenation
```

**Nature's Swiftness → Healing Touch:**

```
#showtooltip Healing Touch
/cast Nature's Swiftness
/cast Healing Touch
```

**Bear then Feral Charge (two presses):**

```
#showtooltip
/cast [noform:1] Bear Form; Feral Charge
```

**Cat opener logic:**

```
#showtooltip
/cast [noform:3] Cat Form; [nostealth,nocombat] Prowl; Pounce
```

**Leave form emergency Regrowth:**

```
#showtooltip Regrowth
/cancelform
/cast [@mouseover,help,nodead][help,nodead][@player] Regrowth
```

**Wild Growth mouseover (Forever Resto):**

```
#showtooltip
/cast [@mouseover,help,nodead][help,nodead][@player] Wild Growth
```

**Revive mouseover (Forever combat rez train):**

```
#showtooltip
/cast [@mouseover,help,dead][help,dead] Revive
```

**Cure key (Remove Curse / Cure Poison / Abolish Poison):**

Compact mouseover-or-self targeting (skips the mid `help,nodead` tier) so the body plus `#showtooltip` stays within 255 characters.

```
#showtooltip
/cancelform
/cast [mod:alt,@mouseover,help,nodead][mod:alt,@player] Abolish Poison; [mod:shift,@mouseover,help,nodead][mod:shift,@player] Cure Poison; [@mouseover,help,nodead][@player] Remove Curse
```

- Press: Remove Curse on mouseover or self (leave form first)
- Shift: Cure Poison
- Alt: Abolish Poison

---

## Cast sequences (fixed order)

`/castsequence` advances one spell per successful press. Prefer Forever-sourced pairs/openers; keep long cooldowns out of the list so a resist does not strand the sequence. Bare `#showtooltip` (no spell name) is applied at create time.

**Reset:** join with `/` — `target`, `combat`, seconds (`6`, `8`, `20`, `30`, `60`), or modifiers.

**Burst prefix:** damage openers and heal sequences that benefit from crit (trinkets + racial burst, including Night Elf **Elune's Light** +10% crit) use `withBurstPrefix`. Utility/PvP pairs omit it. Demo Warlock sacrifice sequence keeps Fel Domination inside the list and has no extra burst prefix.

| Class | Template id | Body idea |
| --- | --- | --- |
| Warlock Aff | `warlock_aff_dots_seq` | burst + `/petattack` + `reset=target/combat Corruption, Bane of Agony, Siphon Life` |
| Warlock Dest | `warlock_immol_conflag` | burst + `reset=target Immolate, Conflagrate` |
| Warlock Demo | `warlock_demo_sac_imp` | `reset=60 Demonic Sacrifice, Fel Domination, Summon Imp` |
| Hunter | `hunter_mark_sting_seq` | burst + `/petattack` + `reset=target Hunter's Mark, Serpent Sting` |
| Hunter Surv | `hunter_clip_kick_seq` | `reset=6 Wing Clip, Strider Kick` |
| Hunter MM PvP | `hunter_scatter_trap_seq` | `reset=20 Scatter Shot, Freezing Trap` |
| Rogue | `rogue_gouge_bs_seq` | `reset=6 Gouge, Backstab` |
| Mage Frost | `mage_nova_lance_seq` | `reset=8 Frost Nova, Ice Lance` |
| Paladin Holy | `paladin_vigil_shock_seq` | burst + mouseover/`@player` `reset=30 Light's Vigil, Holy Shock` |
| Warrior | `warrior_rend_hs_seq` | burst + Bloodrage + `/startattack` + `reset=combat Rend, Heroic Strike` |
| Druid | `druid_motw_thorns_seq` | `/cancelform` + `reset=10/target Mark of the Wild, Thorns` |

Sources: [wowclassicforever.info macros](https://wowclassicforever.info/macros/), [wow-forever.gg macros](https://wow-forever.gg/guides/setup/macros/), [Undying Forever macros](https://undying.app/guides/macros). Use Forever names (**Bane of Agony**, not Curse of Agony).

---

## Mapping to Snippets addon templates

Concrete essentials from this doc are registered in:

| File | Contents |
| --- | --- |
| `Data/SHARED.lua` | Racial `{IF:…}` fragments + High off-GCD burst helpers |
| `Data/GENERAL.lua` | Trinkets + racial burst for every class |
| `Data/WARRIOR.lua` … `Data/DRUID.lua` | Per-class essentials (High off-GCD prefixes where researched) |

`#showtooltip` is added at expand/create time (`EnsureShowTooltip`). Bodies in Data files omit it.

**Off-GCD stacking (High only):** trinkets, Orc/Troll/Gnome racial burst, Bloodrage, Presence of Mind, Inner Focus, Nature's Swiftness, Fel Domination, pet commands. **Elune's Light** is included in Shared racial burst for crit windows (damage and heals) but its GCD remains Unverified — see [`forever-offgcd-research.md`](forever-offgcd-research.md). Unverified CDs (Divine Favor, Cold Blood, Arcane Power, …) are not treated as free prefixes.


| Idea | Snippets template tip |
| --- | --- |
| Trinkets | `/use 13` / `/use 14` (see `GENERAL.lua`) |
| Race burst | `{IF:ORC=/cast Blood Fury\|TROLL=/cast Berserking\|GNOME=/cast Eureka!\|NIGHTELF=/cast Elune's Light}` |
| Race defensive | `RACIAL_DEFENSIVE_IF`: Stoneform / Escape Artist / WotF / Shadowmeld / Will to Survive / War Stomp / Shatter Curse / Walk on Air; plus second block Perception / Read Ley Line / Skysight |
| Mute / SPELL_NAME patterns | Keep as doc patterns; not registered |
| Icon | `?` icon at create + `#showtooltip` |
| Category | `general` / `pve` / `pvp` |


---

## Sources

- https://wowclassicforever.info/macros/ (+ `/warrior`, `/paladin`, `/hunter`, `/rogue`, `/priest`, `/shaman`, `/mage`, `/warlock`, `/druid`)
- Forever trainer/talent data via wago.tools (as cited by those pages)
- Cross-check spell names on [ForeverDB spells](https://foreverdb.net/spells) and in-game Forever tooltips

**Not sources of truth:** Vanilla/Classic Era macro dumps without Forever spell names.
