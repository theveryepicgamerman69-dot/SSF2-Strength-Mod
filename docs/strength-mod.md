# Strength mod

This branch adds one shared strength model to the SSF2 v1.3.1.1 engine. Settings live in `src/Super Smash Flash 2 Beta v1.3.1.1/com/mcleodgaming/ssf2/engine/StrengthSystem.as`. Set `ENABLED` to `false` and rebuild to restore the original modifiers.

## Strength and tuning

`strength = (Weight1 / 100)^WEIGHT_POWER * (Height / 40)^HEIGHT_POWER`

`Height` and `Weight1` are SSF2 engine stats. The reference height of 40 is a provisional calibration, not a verified Mario measurement. Actual roster stats are packaged in the character `.ssf` resources and were unavailable as readable source during implementation. Set `DEBUG_TRACE` to `true`, rebuild, and load fighters to print their stats, strength, damage multipliers, hitstun multiplier, and armor threshold. Adjust the references after collecting those values. Reference changes affect absolute bonuses and the small-victim penalty; away from the protective score caps, they cancel out of attacker/victim ratios.

Zero, negative, or nonfinite stats fall back to the reference value. Scores are capped at 0.02–100 to prevent unstable arithmetic from malformed custom data. Strength follows current fighter stats; metal/item weight multipliers and temporary sprite size are not additional strength inputs in this version. Native engine weight/size effects still apply.

| Mechanic | Default rule |
| --- | --- |
| Normal grab success | Attacker/victim strength ratio must exceed 0.60 |
| Normal grab duration | Vanilla timer × `exp(3.2 × (ratio − 1))` |
| Small-victim penalty | Below strength 0.65, add `8 × (0.65 − victimStrength)` to the duration exponent |
| Duration limits | 0.08×–30×; at least one frame |
| Inescapable tier | Ratio ≥ 1.70 freezes timer decay and mash reduction |
| Grab reach | Strength^0.65, capped at 0.55×–1.65× horizontally |
| Ordinary damage dealt | Strength^0.14, capped at 0.82×–1.18× |
| Damage received | Strength^−0.12, capped at 0.85×–1.18× |
| Received hitstun | Strength^−0.45, capped at 0.60×–1.60× |
| Passive damage armor | Above strength 1.25: `3 × (strength − 1.25)^1.1`, capped at 6 damage |
| Pummel damage | Ratio^1.4, capped at 0.20×–5×, stacks with ordinary damage modifiers |
| Throw knockback | Ratio^0.8, capped at 0.25×–4× |

These are intentionally severe grab rules. The stock roster's actual matchup outcomes need runtime calibration; illustrative Pichu/Ridley matchups from the design discussion are not evidence that those fighters exist in this base roster. Custom fighters automatically use the same formulas when added.

## Engine behavior

- Normal grabs reject weak attackers before `Capture()`. Captures converted to normal grabs via `toGrabbing()` are checked and initialized too. Command grabs, inhaling, final-smash captures, and other special capture scripts retain their own capture/duration behavior until they convert to a normal grab.
- The lock is snapshotted at grab connection. It blocks natural escape and mashing, while throws, pummels, releases, death, and outside interruptions continue through the existing engine. Empty captures and release paths clear the lock. Changing stats during a hold changes subsequent damage, but does not retroactively change its escape lock.
- Grab collision uses a temporary scale point. It scales horizontal positions and widths around the fighter origin, preserving vertical scale and facing/rotation handling. It is not a per-capsule forward-endpoint edit. The broad-phase `MASTER` box expands for extended grabs and never shrinks; stored animation boxes remain unchanged. The original hitbox debug drawing may not show the extra collision reach.
- Direct attacks and character-owned projectiles get the attacker's damage bonus. Reflected projectiles use the credited player's strength. Unattributed hazards/items receive no attacker bonus; the victim's resistance still applies. Ongoing poison, recoil, healing, and direct script calls to `dealDamage()` are not rescaled.
- Damage modifiers run in both the ordinary-hit and armored/no-effect branches, before damage counters and recovery absorption. Existing attack/damage ratios are preserved. Ordinary attack knockback still uses the original attack damage; throws receive the separate launch modifier, including the launch-resistance path.
- Pummels require an active normal grab, its pummel flag, and the held victim. Classification is captured before hit processing can change capture state. Pummel cadence uses the original grab timer.
- Hitstun modifies incoming hit reactions, including dramatic mode. It does not modify attacker self-hitstun, shield stun, or paralysis duration. Zero-damage scripted release reactions keep their original hitstun.
- Passive armor compares modified incoming damage against the strength threshold. It uses the existing no-flinch damage path, stacks with native armor, honors `BypassHeavyArmor`, and excludes throws and already-captured victims. This is limited damage armor, not permanent super armor.

## Build and check

1. Check out the `strength-mechanic` branch locally.
2. Open `src/Super Smash Flash 2 Beta v1.3.1.1/SSF2.fla` in Adobe Animate and publish with the project's AIR setup, as described by the upstream README.
3. Run the newly published game with its accompanying resources. This source commit does not regenerate the existing `build/` executable or SWF.
4. Enable `DEBUG_TRACE` for a calibration build. Record the actual stock and custom fighters' height/weight/score values, then tune the constants. Disable logging afterward.

For formula and selected engine-method regression checks, run:

```sh
node tests/strength-system.test.cjs
```

The dependency-free test runner executes the actual numeric ActionScript and selected new engine methods after removing type annotations. It checks caps, monotonicity, threshold boundaries, zero/sentinel hitstun, reverse mismatches, grab lock decay/mashing, release cleanup, capture conversion, pummel classification, modified damage, projectile attribution, armor exclusions, temporary collision scales, and the off switch. It also checks the key source integration points. It does **not** compile ActionScript or replace Animate/AIR runtime testing. No Animate/AIR compiler or game runtime was available in the implementation environment.

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
| Strong victim takes a weak hit | Added armor may suppress flinch; damage still applies |
| Throw or armor-bypass attack hits a strong victim | Added passive armor does not stop it |
| Extended grab near the edge of the original bounds | Connects in both facing directions without frame-to-frame range growth |
| Direct attack, projectile, and reflected projectile | Modifier uses the appropriate attacker |
| Stamina, metal, dramatic mode, multiplayer interruptions | Native behavior survives alongside the modifiers |

Start with stock Bowser, Donkey Kong, Mario, Kirby, Pikachu and Jigglypuff, then test any custom Pichu/Ridley fighters separately. Check tether grabs, angled/circular grab boxes, special-to-normal conversions, and death during a locked hold in the actual runtime before treating the mod as playtested.
