package com.mcleodgaming.ssf2.engine
{
    /** Shared tuning for the strength mod. Height is an engine unit, not lore height. */
    public final class StrengthSystem
    {
        public static const ENABLED:Boolean = true;
        public static const DEBUG_TRACE:Boolean = false;

        // Provisional neutral fighter: weight 100, engine height 40.
        // Changing these affects absolute bonuses, but cancels out of matchup ratios.
        public static const WEIGHT_REFERENCE:Number = 100.0;
        public static const HEIGHT_REFERENCE:Number = 40.0;
        public static const WEIGHT_POWER:Number = 1.0;
        public static const HEIGHT_POWER:Number = 1.0;

        public static const MIN_GRAB_RATIO:Number = 0.60;
        public static const NO_ESCAPE_RATIO:Number = 1.70;
        public static const ESCAPE_CURVE:Number = 3.2;
        public static const SMALL_STRENGTH_CUTOFF:Number = 0.65;
        public static const SMALLNESS_CURVE:Number = 8.0;
        public static const MIN_GRAB_DURATION:Number = 0.08;
        public static const MAX_GRAB_DURATION:Number = 30.0;

        public static const GRAB_REACH_POWER:Number = 0.65;
        public static const MIN_GRAB_REACH:Number = 0.55;
        public static const MAX_GRAB_REACH:Number = 1.65;
        public static const DAMAGE_DEALT_POWER:Number = 0.14;
        public static const DAMAGE_TAKEN_POWER:Number = -0.12;
        public static const HITSTUN_POWER:Number = -0.45;
        public static const ARMOR_START:Number = 1.0;
        public static const ARMOR_POWER:Number = 1.10;
        public static const ARMOR_SCALE:Number = 12.0;
        public static const MAX_ARMOR_DAMAGE:Number = 30.0;
        // Defender/attacker ratio. This armor has no per-hit damage ceiling.
        public static const MATCHUP_ARMOR_RATIO:Number = 1.70;
        public static const WEAK_ATTACK_DAMAGE_POWER:Number = 3.0;
        public static const MIN_WEAK_ATTACK_DAMAGE:Number = 0.03;
        public static const MAX_ARMORED_ATTACK_DAMAGE:Number = 0.10;
        public static const DIZZY_STRENGTH_RATIO:Number = 2.50;
        public static const STRENGTH_DIZZY_FRAMES:int = 900;
        public static const PUMMEL_POWER:Number = 1.40;
        public static const MIN_PUMMEL_DAMAGE:Number = 0.20;
        public static const MAX_PUMMEL_DAMAGE:Number = 5.0;
        public static const THROW_POWER:Number = 0.80;
        public static const MIN_THROW_KNOCKBACK:Number = 0.25;
        public static const MAX_THROW_KNOCKBACK:Number = 4.0;

        private static function clamp(value:Number, minimum:Number, maximum:Number):Number
        {
            return Math.max(minimum, Math.min(maximum, value));
        }

        private static function positiveOr(value:Number, fallback:Number):Number
        {
            return (isFinite(value) && value > 0) ? value : fallback;
        }

        public static function getScore(weight:Number, height:Number):Number
        {
            if (!ENABLED)
            {
                return 1.0;
            }
            weight = positiveOr(weight, WEIGHT_REFERENCE) / WEIGHT_REFERENCE;
            height = positiveOr(height, HEIGHT_REFERENCE) / HEIGHT_REFERENCE;
            return clamp(Math.pow(weight, WEIGHT_POWER) * Math.pow(height, HEIGHT_POWER), 0.02, 100.0);
        }

        public static function getStrength(stats:InteractiveSpriteStats):Number
        {
            return stats ? getScore(stats.Weight1, stats.Height) : 1.0;
        }

        public static function getMatchupRatio(attacker:Number, victim:Number):Number
        {
            return positiveOr(attacker, 1.0) / positiveOr(victim, 1.0);
        }

        public static function canGrab(ratio:Number):Boolean
        {
            return !ENABLED || ratio > MIN_GRAB_RATIO;
        }

        public static function isGrabLocked(ratio:Number):Boolean
        {
            return ENABLED && ratio >= NO_ESCAPE_RATIO;
        }

        public static function getGrabDurationMultiplier(ratio:Number, victimStrength:Number):Number
        {
            if (!ENABLED || isGrabLocked(ratio))
            {
                return 1.0;
            }
            var exponent:Number = ESCAPE_CURVE * (ratio - 1.0);
            if (victimStrength < SMALL_STRENGTH_CUTOFF)
            {
                exponent += (SMALL_STRENGTH_CUTOFF - victimStrength) * SMALLNESS_CURVE;
            }
            return clamp(Math.exp(exponent), MIN_GRAB_DURATION, MAX_GRAB_DURATION);
        }

        public static function getGrabReachMultiplier(strength:Number):Number
        {
            return ENABLED ? clamp(Math.pow(strength, GRAB_REACH_POWER), MIN_GRAB_REACH, MAX_GRAB_REACH) : 1.0;
        }

        public static function getDamageDealtMultiplier(strength:Number):Number
        {
            return ENABLED ? clamp(Math.pow(strength, DAMAGE_DEALT_POWER), 0.82, 1.18) : 1.0;
        }

        public static function getDamageTakenMultiplier(strength:Number):Number
        {
            return ENABLED ? clamp(Math.pow(strength, DAMAGE_TAKEN_POWER), 0.85, 1.18) : 1.0;
        }

        public static function getHitstunMultiplier(strength:Number):Number
        {
            return ENABLED ? clamp(Math.pow(strength, HITSTUN_POWER), 0.60, 1.60) : 1.0;
        }

        public static function scaleHitstun(frames:Number, strength:Number):int
        {
            // Preserve zero hitstun and scripted sentinel values.
            if (!ENABLED || frames <= 0)
            {
                return int(frames);
            }
            return Math.max(1, int(Math.round(frames * getHitstunMultiplier(strength))));
        }

        public static function getArmorThreshold(strength:Number):Number
        {
            if (!ENABLED || strength <= ARMOR_START)
            {
                return 0.0;
            }
            return Math.min(MAX_ARMOR_DAMAGE, ARMOR_SCALE * Math.pow(strength - ARMOR_START, ARMOR_POWER));
        }

        public static function hasMatchupArmor(attackerVictimRatio:Number):Boolean
        {
            return ENABLED && attackerVictimRatio > 0 &&
                attackerVictimRatio <= 1.0 / MATCHUP_ARMOR_RATIO;
        }

        public static function getWeakAttackDamageMultiplier(attackerVictimRatio:Number):Number
        {
            if (!ENABLED || attackerVictimRatio >= 1.0)
            {
                return 1.0;
            }
            var multiplier:Number = clamp(Math.pow(attackerVictimRatio, WEAK_ATTACK_DAMAGE_POWER),
                MIN_WEAK_ATTACK_DAMAGE, 1.0);
            return hasMatchupArmor(attackerVictimRatio) ?
                Math.min(MAX_ARMORED_ATTACK_DAMAGE, multiplier) : multiplier;
        }

        public static function isNormalAttackFrame(frame:String):Boolean
        {
            return frame != null && (frame == "a" || frame.indexOf("a_") == 0 ||
                frame == "crouch_attack" || frame == "getup_attack" || frame == "ledge_attack");
        }

        public static function getDizzyDuration(attackerVictimRatio:Number):int
        {
            return (ENABLED && attackerVictimRatio >= DIZZY_STRENGTH_RATIO) ? STRENGTH_DIZZY_FRAMES : 0;
        }

        public static function getPummelMultiplier(ratio:Number):Number
        {
            return ENABLED ? clamp(Math.pow(ratio, PUMMEL_POWER), MIN_PUMMEL_DAMAGE, MAX_PUMMEL_DAMAGE) : 1.0;
        }

        public static function getThrowMultiplier(ratio:Number):Number
        {
            return ENABLED ? clamp(Math.pow(ratio, THROW_POWER), MIN_THROW_KNOCKBACK, MAX_THROW_KNOCKBACK) : 1.0;
        }
    }
}
