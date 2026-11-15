# WoW Forever — off-GCD research (macro stacking)

**Purpose:** Personal research map of abilities that do **not** start (or consume) the global cooldown on **World of Warcraft: Forever**, so they can share one button press with a normal cast.  
**Not** implemented in addon code.  
**Date:** 2026-11-15 (updated same day: Forever-first framing)  
**Client:** Forever 1.60.x (`## Interface: 16001`), Retail-derived API with Forever game rules

---

## Important: Forever ≠ Vanilla ≠ Classic

Forever is its **own** game ruleset:

- New and reworked spells, racials (e.g. Eureka!, Will to Survive, Elune’s Light, Skyborne), talents, and cooldowns
- Retail-style client APIs with Forever-specific behaviour (e.g. stance/form + ability still needs **two presses**)
- Spell power / downranking / trainer lists differ from Classic

**Do not treat Vanilla or Classic Era off-GCD lists as truth for Forever.**  
Those lists are only weak hints. **Primary sources for Forever:**

1. In-game tooltip / behaviour on Forever (does the GCD sweep start?)
2. Wowhead **Forever** spell pages (`GCD: 0 seconds`)
3. Forever-specific guides (e.g. wowclassicforever.info macros, ForeverDB, Warcraft Tavern Forever racials)
4. Client data dumps aimed at Forever (wago.tools Forever build), not Classic DB2s

If Classic and Forever disagree, **Forever wins**.

---

## How to read this document

- **One press = one GCD** on Forever macro design: stack only when the *first* line is off-GCD (“free cooldown first” — Forever macro guides).
- **Confidence (Forever-only):**
  - **High** — Explicitly described for Forever macros/coaches **or** Wowhead Forever shows `GCD: 0 seconds`
  - **Unverified** — Plausible or Classic-legacy guess; **must** be checked on Forever before trusting in a macro
- Wowhead index `wowhead.com/forever/spells/abilities` returned **HTTP 500** during research; use per-spell Forever URLs + in-game checks.

---

## Items and non-spell actions (Forever macro guides)

| Action | Macro | Confidence | Notes |
| --- | --- | --- | --- |
| Top trinket | `/use 13` | High | Forever guides: on-use trinkets do not use the GCD |
| Bottom trinket | `/use 14` | High | Same |
| Pet commands | `/petattack`, `/petfollow`, … | High | Forever guides: pet commands cost no GCD |
| SFX mute scripts | `/run SetCVar("Sound_EnableSFX",0)` … `,1)` | High | Not a spell; client script |

---

## Racials (Forever matrix — not Classic)

Forever: **two active + two passive** per race; many Classic weapon/resist racials removed; **Skyborne** added; several new actives (Warcraft Tavern Forever racial guide).

Off-GCD must be confirmed **per Forever spell**, especially new names.

| Race | Active racials (Forever) | Forever notes | Confidence |
| --- | --- | --- | --- |
| Dwarf | Stoneform, Find Treasure | Names familiar; GCD not assumed from Classic | Unverified (except check Stoneform in-game) |
| Gnome | Escape Artist, **Eureka!** | Eureka!: Wowhead Forever **GCD 0 seconds** | High (Eureka!); Unverified (Escape Artist) |
| Human | **Will to Survive**, Perception | New PvP-trinket-style active | Unverified |
| Night Elf | **Elune’s Light**, Shadowmeld | New burst racial + classic-named Shadowmeld | Unverified |
| Skyborne (High Order) | Walk on Air, Read Ley Line | Forever-only race | Unverified |
| Orc | Blood Fury, **Shatter Curse** | Blood Fury used in Forever racial+trinket macros | High (Blood Fury usage in Forever guides); Unverified (Shatter Curse GCD) |
| Tauren | War Stomp, Cultivation† | Do not assume Classic War Stomp GCD | Unverified |
| Troll | Berserking, **Rapid Regeneration** | Berserking used in Forever racial+trinket macros | High (Berserking usage); Unverified (Rapid Regeneration GCD) |
| Undead | Will of the Forsaken, Cannibalize | Familiar names; verify GCD on Forever | Unverified |
| Skyborne (Windshaper) | Walk on Air, Skysight | Forever-only | Unverified |

†Treat Cultivation as non-combat / non-macro unless tooltip says otherwise.

**Race+class priest spells** (Divine Grace, Confounding Flash, Dark Sacrifice, …) are Forever-specific or Forever-tuned — **Unverified** for off-GCD until tooltip-checked.

---

## Class “free cooldown first” — Forever-oriented

Only rows with Forever-facing evidence are **High**. Everything else is **Unverified** and listed only as *candidates to test on Forever*, not as Classic facts.

### Confirmed / strongly Forever-supported prefixes

| Class | Ability | Confidence | Forever evidence |
| --- | --- | --- | --- |
| Mage | Presence of Mind | High | Forever macro “free cooldown first”; ForeverDB coach (PoM → Arcane Blast) |
| Druid | Nature's Swiftness | High | Forever macro free-cooldown-first; ForeverDB coach CD notes |
| Shaman | Nature's Swiftness | High | Same family of Forever coach notes |
| Warrior | Bloodrage | High | Forever macro free-cooldown-first; ForeverDB coach simulator/coach uses on pull |
| Priest | Inner Focus | High | Forever macro free-cooldown-first pattern; ForeverDB coach CD |
| Warlock | Fel Domination | High | Wowhead Forever: **GCD 0 seconds** |
| Any | Trinkets `/use 13` `/use 14` | High | Forever macro guides |
| Hunter (etc.) | Pet commands | High | Forever macro guides |
| Gnome | Eureka! | High | Wowhead Forever: **GCD 0 seconds** |

### Candidates to verify on Forever (do not copy Classic lists)

Test each with: press alone (GCD sweep?) then `/cast Candidate` + `/cast MainSpell` same macro.

**Warrior:** Death Wish, Recklessness, Sweeping Strikes, Shield Block, interrupts — *Unverified*  
**Paladin:** Divine Favor and other “prep” CDs — *Unverified* (Forever also has new seals/judgements; don’t assume Classic Divine Favor behaviour)  
**Hunter:** Rapid Fire, Bestial Wrath, Feign Death, Aspects, Intimidation — *Unverified*  
**Rogue:** Cold Blood, Preparation, Adrenaline Rush — *Unverified* (ignore Retail/Wrath “Kick/Vanish off GCD” nonsense)  
**Priest:** Power Infusion, Fade, race priest CDs — *Unverified*  
**Shaman:** Elemental Mastery, totems (totems may use a GCD; not “free”) — *Unverified*  
**Mage:** Cold Snap, Arcane Power, Combustion, Counterspell — *Unverified* (Counterspell is instant but often still on GCD)  
**Warlock:** Amplify Curse and other prep CDs — *Unverified*  
**Druid:** Barkskin, Frenzied Regeneration, form buttons — *Unverified*; **form + ability = two presses** on Foreve

Forever also adds **new trainer spells** (Slam, Frostfire Bolt, Shadow Word: Death, Totemic Recall, Ferocious Bite, …). **None of these should be assumed off-GCD** without a Forever tooltip check.

---

## Forever-specific macro constraints (from Forever guides)

1. **Stance/form then ability:** still **two presses** (reproduced on Forever; not a Classic myth).
2. **Downranking** is less rewarding on Forever (client notes / Forever macro guide) — prefer highest rank names.
3. **Racial + trinket + main CD** on one key is the intended Forever pattern when racial/trinket are off-GCD.
4. Spell names must match the **Forever English client** (ForeverDB / wago trainer data).

### Example patterns (only using High-confidence prefixes)

```text
#showtooltip
/use 13
/use 14
/cast Blood Fury
/cast Berserking
/cast Death Wish
```

```text
#showtooltip
/cast Presence of Mind
/cast Arcane Blast
```

```text
#showtooltip
/cast Bloodrage
/cast Bloodthirst
```

```text
#showtooltip
/cast Eureka!
/cast Frostbolt
```

(Replace main CD with whatever you actually press; verify Eureka!/racial lines for your race.)

---

## Verification checklist (Forever client)

For every candidate spell:

1. Open Forever spellbook / Wowhead Forever spell page → note **GCD**.
2. Press the spell alone → watch action bars for GCD animation.
3. Macro test: candidate then a known on-GCD spell → does the second fire on the same press?
4. Record: `name | spellId | GCD | verified build | notes`.

---

## Sources (Forever-first)

- https://wowclassicforever.info/macros/ — Forever macro rules (GCD, trinkets, racials, pets, stance)
- https://wowclassicforever.info/cooldown-manager/ — Forever client cooldown-set rows (not an off-GCD list, but Forever-native)
- https://www.warcrafttavern.com/forever/guides/racial-abilities/ — Forever racial matrix
- https://foreverdb.net/spells / https://foreverdb.net/coach — Forever spell DB and Forever coach tips
- https://www.wowhead.com/forever/spell=… — Forever spell tooltips (GCD field)

**Deprioritized:** Vanilla wiki GCD pages, Classic Era spreadsheets, Wrath/Retail “off GCD” compilations.

---

## Status

- **High** prefixes are wired into Snippets templates via `Data/SHARED.lua` helpers (`withBurstPrefix` / `withRacialBurst`) and per-class Data files. **Unverified** CDs are not stacked as free GCD on the same press.
- Full class-by-class **verified** off-GCD map for Forever is **incomplete** until in-game / Wowhead Forever GCD fields are walked systematically.
- Next research step: export Forever spells with `GCD == 0` from ForeverDB/MetaForge/wago for the current build, then validate the High list and fill Unverified rows.
