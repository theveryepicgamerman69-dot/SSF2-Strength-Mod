# Strength mod

This branch adds one shared strength model to the SSF2 v1.3.1.1 engine. Settings live in `src/Super Smash Flash 2 Beta v1.3.1.1/com/mcleodgaming/ssf2/engine/StrengthSystem.as`. Set `ENABLED` to `false` and rebuild to restore the original modifiers.

## Strength and tuning

`strength = (Weight1 / 100)^WEIGHT_POWER * (Height / 40)^HEIGHT_POWER`

`Height` and `Weight1` are SSF2 engine stats. The reference height of 40 is a provisional calibration, not a verified Mario measurement. Roster stats are packaged in the character `.ssf` resources. The current Bowser, Pichu, and DK resources have now been inspected; their verified values are listed below. Set `DEBUG_TRACE` to `true`, rebuild, and load fighters to print their stats, strength, damage multipliers, hitstun multiplier, and armor threshold. Adjust the references after collecting those values. Reference changes affect absolute bonuses and the small-victim penalty; away from the protective score caps, they cancel out of attacker/victim ratios.

Zero, negative, or nonfinite stats fall back to the reference value. Scores are capped at 0.02–100 to prevent unstable arithmetic from malformed custom data. Strength follows current fighter stats; metal/item weight multipliers and temporary sprite size are not additional strength inputs in this version. Native engine weight/size effects still apply.

| Mechanic | Default rule |
| --- | --- |
| Normal grab success | Attacker/victim strength ratio must exceed 0.60 |
| Normal grab and DK cargo duration | Vanilla timer × `exp(3.2 × (ratio − 1))` |
| Small-victim penalty | Below strength 0.65, add `8 × (0.65 − victimStrength)` to the duration exponent |
| Duration limits | 0.08×–30×; at least one frame |
| Inescapable tier | Ratio ≥ 1.70 freezes normal-grab and DK cargo timer decay/mashing |
| Grab reach | Strength^0.65, capped at 0.55×–1.65× horizontally |
| Ordinary damage dealt | Strength^0.14, capped at 0.82×–1.18× |
| Damage received | Strength^−0.12, capped at 0.85×–1.18× |
| Received hitstun | Strength^−0.45, capped at 0.60×–1.60× |
| Passive damage armor | Above strength 1.00: `12 × (strength − 1.00)^1.1`, capped at 30 damage |
| Matchup armor | Defender ≥ 1.70× attacker: no launch, hitstun, paralysis, or disabling hit statuses from damaging non-throw hits |
| Damage from weaker foes | Multiply by `(attacker / defender)^3`, floored at 0.03×; at the matchup armor tier, capped at 0.10× |
| Normal-attack dizziness | Attacker ≥ 2.50× victim: protected dizzy for 900 grounded frames; no strength-dizzy mash or airborne cancellation |
| Pummel damage | Ratio^1.4, capped at 0.20×–5×, stacks with ordinary damage modifiers |
| Throw knockback | Ratio^0.8, capped at 0.25×–4× |

These are intentionally severe strength rules. Custom fighters use the same formulas. Lower `MATCHUP_ARMOR_RATIO` to make full matchup armor more common; raise it to restrict armor to larger mismatches. Raise `MIN_WEAK_ATTACK_DAMAGE` for less damage resistance. `ARMOR_START`, `ARMOR_SCALE`, and `MAX_ARMOR_DAMAGE` tune the separate passive armor. `DIZZY_STRENGTH_RATIO` and `STRENGTH_DIZZY_FRAMES` control the new dizzy trigger and its base duration. Rebuild after editing constants.

### Verified packaged stats

| Fighter/form | Weight1 | Height | Strength |
| --- | ---: | ---: | ---: |
| Pichu | 74 | 30 | 0.555 |
| Bowser | 120 | 64 | 1.920 |
| Donkey Kong | 114 | 75 | 2.1375 |
| Giga Bowser | 400 | 150 | 15.000 |

Bowser/Pichu is approximately 3.46. Pichu's damaging non-throw hits cannot flinch or launch an uncaptured Bowser, even when charged or flagged to bypass native armor. After the ordinary strength damage modifiers, Bowser receives about **2.6% of vanilla damage** from Pichu. Bowser's normal attacks also meet the dizzy threshold against Pichu. DK/Pichu is approximately 3.85 and locks cargo escape; DK/Bowser is approximately 1.11 and gives a finite, roughly 1.44× cargo timer. No fighter-specific override is used.

The values were read from `Main.as` in the existing `build/data/character/{pichu,bowser,donkeykong}.ssf` resources. Giga Bowser has its own final-form stat profile. Temporary mushroom scale still does not enter the strength formula.

## Engine behavior

- Normal grabs reject weak attackers before `Capture()`. Captures converted to normal grabs via `toGrabbing()` are checked and initialized too. DK cargo also uses strength through its separate timer (see below). Other command grabs, inhaling, final-smash captures, and special capture scripts retain native duration until normal-grab conversion.
- Normal-grab locks are snapshotted at grab connection. It blocks natural escape and mashing, while throws, pummels, releases, death, and outside interruptions continue through the existing engine. Empty captures and release paths clear the lock. Changing stats during a hold changes subsequent damage, but does not retroactively change its escape lock.
- Grab collision uses a temporary scale point. It scales horizontal positions and widths around the fighter origin, preserving vertical scale and facing/rotation handling. It is not a per-capsule forward-endpoint edit. The broad-phase `MASTER` box expands for extended grabs and never shrinks; stored animation boxes remain unchanged. The original hitbox debug drawing may not show the extra collision reach.
- Direct attacks and character-owned projectiles get the attacker's damage bonus. Reflected projectiles use the credited player's strength. Unattributed hazards/items receive no attacker bonus; the victim's resistance still applies. Ongoing poison, recoil, healing, and direct script calls to `dealDamage()` are not rescaled.
- The extra weak-attacker damage resistance applies to attributed damaging hits, including projectiles, throws, and pummels; it does not invent strength for hazards/items. Damage modifiers run in both the ordinary-hit and armored/no-effect branches, before damage counters and recovery absorption. Existing attack/damage ratios are preserved. Ordinary attack knockback still uses the original attack damage; throws receive the separate launch modifier, including the launch-resistance path.
- Pummels require an active normal grab, its pummel flag, and the held victim. Classification is captured before hit processing can change capture state. Pummel cadence uses the original grab timer.
- Hitstun modifies incoming hit reactions, including dramatic mode. It does not modify attacker self-hitstun or shield stun. Full matchup armor prevents new paralysis and disabling hit statuses; it does not cancel an existing status. Zero-damage scripted release reactions keep their original hitstun.
- Passive armor compares modified incoming damage against its larger strength threshold, honors `BypassHeavyArmor`, and excludes throws/captured victims. Full matchup armor has no damage ceiling and overrides native armor-bypass flags for damaging hits from sufficiently weak fighters. Both use the native no-flinch damage path and leave the shared attack data intact after processing. Throws, zero-damage scripted releases/windboxes, and captured victims retain their native reactions.
- Dizziness uses the normal attack source frame: jabs, tilts, smashes, dash attacks, aerials, crouch attacks, get-up attacks, and ledge attacks. Normal-attack projectiles snapshot their source when spawned, including child projectiles, so changing moves before impact does not reclassify them. Specials/final smashes, throws, pummels, items, hazards, and reflected projectiles do not add strength dizziness. Existing move-specific dizziness remains. The strength duration is local to each victim and finalizes both hit-reaction branches, honoring status immunity and capture/KO exclusions. Strength dizziness is finalized after launch/stack/crash processing and clears both normal and knockback velocities. It has a separate 900-frame grounded countdown that ignores mashing and airborne cancellation; airborne victims fall normally and serve the full duration after landing. Landing selects the dizzy animation directly instead of triggering a crash/get-up. Leaving DIZZY clears the strength countdown, and repeated qualifying hits refresh it. Native move/shield dizziness retains its original recovery rules. Shielded hits do not add it.

### DK cargo integration

The stock `donkeykong_fla.dkfthrowstart_52` movie starts `getFree` with a one-frame repeating timer. Its `endTimer` begins at `90 + victimDamage / 4`; `getFree` subtracts time and `mashInfluence` for changed controls. The normal grab timer is never consulted.

`Character.createTimer()` recognizes only that cargo callback during `throw_forward`, matching the packaged `statsName` of `donkeykong` or engine `linkage_id` of `dkong`. The roster filename is not its engine linkage ID; checking `LinkageID == "donkeykong"` would silently skip the hook. The regression uses the exported resource identifiers in `tests/fixtures/dk-cargo-stats.json`. At timer registration it snapshots the current ratio and scales `endTimer` with the same capped duration formula as normal grabs. At ratio ≥ 1.70 it pauses the native escape timer through `IntervalTimer.pauseCondition`, preventing both decay and the callback's mashing. The movement/throw callback is untouched. Keeping the original callback identity preserves native `destroyTimer`, throw transitions, interrupts, and cleanup; no replacement `.ssf` is needed. The off switch leaves the native cargo timer unchanged.

The regression fixture contains the original `getFree` callback. The inspected DK resource SHA-256 is `357c7c1b643015373eca7c0f0b0de547ed2227a269ad5b3e7dfa308424aff354`. This adapter targets that stock cargo script; custom DK resources that replace its callback/field names need their own adapter.

## Build and check

1. Check out the `strength-mechanic` branch locally.
2. Open `src/Super Smash Flash 2 Beta v1.3.1.1/SSF2.fla` in Adobe Animate and publish with the project's AIR setup, as described by the upstream README.
3. Run the newly published game with its accompanying resources. This source commit does not regenerate the existing `build/` executable or SWF.
4. Enable `DEBUG_TRACE` for a calibration build. Record the actual stock and custom fighters' height/weight/score values, then tune the constants. Disable logging afterward.

For formula and selected engine-method regression checks, run:

```sh
node tests/strength-system.test.cjs
```

The dependency-free runner executes the numeric ActionScript, selected engine methods, the actual `takeDamage()` method for armored hits, and stock `FrameTimer`/`IntervalTimer` classes after adapting ActionScript syntax for JavaScript. It checks caps, monotonicity, threshold boundaries, zero/sentinel hitstun, reverse mismatches, grab lock decay/mashing, release cleanup, capture conversion, pummel classification, modified damage, projectile attribution, armor exclusions, temporary collision scales, and the off switch. It additionally runs the packaged DK escape callback against the native timer classes, tests Bowser/Pichu with verified stats against charged-size damage, projectiles/reflections and native armor-bypass flags, verifies attack-data restoration and disabling-status immunity, and exercises normal/projectile dizziness and the off switch. Recovery regressions run the actual dizzy and animation handlers through 1,000 airborne frames and all 900 grounded frames, verifying launch cleanup, no mashing, no landing crash, and expiration. Cargo tests use the packaged identifiers rather than a fabricated linkage ID. It also checks the key source integration points. It does **not** compile ActionScript or replace Animate/AIR runtime testing. No Animate/AIR compiler or game runtime was available in the implementation environment.

### Gameplay checks after publishing

| Scenario | Expected result |
| --- | --- |
| Neutral score 1 vs score 1 | Original timer, damage, hitstun and reach; no added armor |
| Grab ratio exactly 0.60 | Capture fails |
| Grab ratio just above 0.60 | Short hold, subject to any small-victim penalty |
| Grab ratio just below 1.70 | Finite timer; mashing still works |
| Grab ratio at/above 1.70 | No timer or mash escape; throw/release/interrupt still ends it |
| Locked hold ends, then an equal-strength grab | New hold escapes normally |
| Strong/weak fighters pummel the same victim | Strong pummels do substantially more damage |
| Strong/weak fighters throw the same victim | Strong throws launch substantially farther, subject to move/stage behavior |
| Pichu hits Bowser with a normal/special/charged hit or projectile | No flinch/launch; approximately 2.6% damage; native armor-bypass flags do not defeat matchup armor |
| Strong victim takes an equal-strength hit | Larger passive armor may suppress flinch below its threshold |
| Throw or zero-damage release hits a strong victim | Matchup armor does not stop the native reaction |
| Bowser normal attack hits Pichu | Native dizzy state with 900 grounded frames; no launch, mash escape, or landing get-up; test ground and air |
| Bowser special/throw hits Pichu | No added strength dizziness |
| Normal projectile lands after owner starts a special | Uses its normal-attack launch provenance for dizziness |
| DK carries Pichu and the victim mashes | No timeout or mash escape; DK can still move/jump/throw |
| DK carries Bowser | Approximately 1.44× finite cargo timer; native mashing still works |
| Cargo ends through throw, interruption, death, or escape | Original timer is removed; the next grab/cargo starts fresh |
| Extended grab near the edge of the original bounds | Connects in both facing directions without frame-to-frame range growth |
| Direct attack, projectile, and reflected projectile | Modifier uses the appropriate attacker |
| Stamina, metal, dramatic mode, multiplayer interruptions | Native behavior survives alongside the modifiers |

Start with the packaged Pichu, Bowser, and Donkey Kong, then Mario, Kirby, Pikachu, Jigglypuff and any custom fighters. Check tether grabs, angled/circular grab boxes, special-to-normal conversions, and death during a locked hold in the actual runtime before treating the mod as playtested.
