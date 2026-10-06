// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.Character

package com.mcleodgaming.ssf2.engine
{
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.controllers.PlayerSetting;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.controllers.MatchResults;
    import com.mcleodgaming.ssf2.util.Controller;
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import com.mcleodgaming.ssf2.util.ControlsObject;
    import com.mcleodgaming.ssf2.platforms.Platform;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.items.Item;
    import com.mcleodgaming.ssf2.platforms.BitmapCollisionBoundary;
    import com.mcleodgaming.ssf2.api.SSF2Character;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.enums.CState;
    import com.mcleodgaming.ssf2.menus.DebugConsole;
    import com.mcleodgaming.ssf2.enums.ModeFeatures;
    import com.mcleodgaming.ssf2.enums.Mode;
    import com.mcleodgaming.ssf2.enums.CPUState;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.MouseEvent;
    import com.mcleodgaming.ssf2.util.MouseTracker;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.api.SSF2Event;
    import flash.display.Bitmap;
    import com.mcleodgaming.ssf2.enums.SpecialMode;
    import com.mcleodgaming.ssf2.util.Vcam;
    import com.mcleodgaming.ssf2.enums.CFreeState;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import com.mcleodgaming.ssf2.enums.PState;
    import com.mcleodgaming.ssf2.Config;
    import com.mcleodgaming.ssf2.controllers.GameController;
    import com.mcleodgaming.ssf2.net.MultiplayerManager;
    import com.mcleodgaming.ssf2.platforms.MovingPlatform;
    import com.mcleodgaming.ssf2.enums.TState;
    import com.mcleodgaming.ssf2.enemies.Enemy;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.audio.SoundObject;
    import com.mcleodgaming.ssf2.menus.HudMenu;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.assists.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.mcleodgaming.ssf2.enemies.*;
    import com.mcleodgaming.ssf2.items.*;
    import com.mcleodgaming.ssf2.net.*;
    import com.mcleodgaming.ssf2.platforms.*;
    import __AS3__.vec.*;
    import com.pecefulmods.TrainingMenus.GameMenu;

    public class Character extends InteractiveSprite 
    {

        public static var HEAVY_KNOCKBACK_THRESHOLD:Number = (2.4 * Utils.VELOCITY_SCALE);
        public static var HEAVY_KNOCKBACK_HITLAG_THRESHOLD:Number = (32 / 2);//16
        private static var CROWD_AWE_KNOCKBACK_THRESHOLD:Number = 35;

        private const MAX_STOCK_ICONS:Number = 5;

        private var m_preFrameInfo:String;
        private var m_freezePlayback:Boolean;
        private var m_hitLagHack:Number = 1.79769313486232E308;
        private var SDI_BASE:Number = 6;
        private var MAX_DI_CHANGE:Number = 23;
        private var DI_CAP:Number = 17;
        private var PAUSE_CAM_MAX_SPEED:Number = 15;
        private var PAUSE_CAM_ACCEL:Number = 4;
        private var m_characterStats:CharacterData;
        private var m_playerSettings:PlayerSetting;
        private var m_expansion_id:int;
        private var m_transformingSpecial:Boolean;
        private var m_transformedSpecial:Boolean;
        private var m_transformTime:int;
        private var m_transformLimit:int;
        private var m_finalSmashMeterCharge:Number;
        private var m_finalSmashMeterReady:Boolean;
        private var m_finalSmashCutinMC:MovieClip;
        private var m_matchResults:MatchResults;
        private var m_droughtTimer:int;
        private var m_justHit:Boolean;
        private var m_justHitTimer:int;
        private var m_key:Controller;
        private var m_pauseCamXSpeed:Number;
        private var m_pauseCamYSpeed:Number;
        private var m_starKOTimer:FrameTimer;
        private var m_starKOMC:MovieClip;
        private var m_screenKO:Boolean;
        private var m_starKOHolder:MovieClip;
        private var m_screenKOHolder:MovieClip;
        private var m_crowdAwe:Boolean;
        private var m_originalSizeRatio:Number;
        private var m_sizeStatus:int;
        private var m_sizeStatusPermanent:Boolean;
        private var m_sizeStatusTimer:FrameTimer;
        private var m_isMetal:Boolean;
        private var m_lives:int;
        private var m_lastLivesTextNum:int;
        private var m_usingLives:Boolean;
        private var m_jumpSpeedMidairDelay:FrameTimer;
        private var m_jumpStartup:FrameTimer;
        private var m_jumpJustChambered:Boolean;
        private var m_jumpSpeedList:Array;
        private var m_jumpEffectTimer:FrameTimer;
        private var m_preJumpState:uint;
        private var m_initialAirDodgeAngle:Number;
        private var m_waveLand:Boolean;
        private var m_waveDashPenalty:Number;
        private var m_airDodgeCount:int;
        private var m_skidTimer:int;
        private var m_jumpTimer:int;
        private var m_shortHop:Boolean;
        private var m_jumpJustLetGo:Boolean;
        private var m_attackHovering:Boolean;
        private var m_canHover:Boolean;
        private var m_midAirHoverTime:FrameTimer;
        private var m_midAirJumpConstantTime:FrameTimer;
        private var m_midAirJumpConstantDelay:FrameTimer;
        private var m_rocketSpeed:Number;
        private var m_rocketRotation:Boolean;
        private var m_rocketDecay:Number;
        private var m_rocketAngle:Number;
        private var m_smashTimer:int;
        private var m_smashTimerUp:int;
        private var m_smashTimerSide:int;
        private var m_smashTimerDown:int;
        private var m_upSpecialTimer:int;
        private var m_specialTurnTimer:FrameTimer;
        private var m_specialTurnRight:Boolean;
        private var m_runningSpeedLevel:Boolean;
        private var m_speedTimer:int;
        private var m_speedLetGo:Boolean;
        private var m_dashReady:Boolean;
        private var m_speedFacingForward:Boolean;
        private var m_norm_xSpeed:Number;
        private var m_max_xSpeed:Number;
        private var m_glideAngle:Number;
        private var m_glideMaxHeight:Number;
        private var m_glideDelay:int;
        private var m_glideReady:Boolean;
        private var m_flyingRight:Boolean;
        private var m_flyingUp:Boolean;
        private var m_windBoxHit:Boolean;
        private var m_hasArced:Boolean;
        private var m_forcedCrash:Boolean;
        private var m_tumbledCrash:Boolean;
        private var m_jabResets:int;
        private var m_jabResetTimer:FrameTimer;
        private var m_fallTiltTimer:FrameTimer;
        private var m_fallTiltRight:Boolean;
        private var m_forceTumbleFall:Boolean;
        private var m_hitLag:int;
        private var m_hitLagCancelTimer:FrameTimer;
        private var m_hitLagCanCancelWithJump:Boolean;
        private var m_hitLagCanCancelWithUpB:Boolean;
        private var m_hitLagStunTimer:FrameTimer;
        private var m_hitLagLandDelay:FrameTimer;
        private var m_hitsDealtCounter:int;
        private var m_hitsReceivedCounter:int;
        private var m_smashDIAmount:Number;
        private var m_smashDISelf:Boolean;
        private var m_smashDIDirection:Number;
        private var m_smashDIDirectionCStick:Number;
        private var m_canDI:Boolean;
        private var m_techLetGo:Boolean;
        private var m_techTimer:FrameTimer;
        private var m_techDelay:FrameTimer;
        private var m_techReady:Boolean;
        private var m_justTechedTimer:FrameTimer;
        private var m_canTech:Boolean;
        private var m_canWallTech:Boolean;
        private var m_canBounce:Boolean;
        private var m_hasBounced:Boolean;
        private var m_stunTimer:int;
        private var m_dizzyTimer:int;
        private var m_strengthDizzyTimer:int = 0;
        private var m_stunCancelTimer:FrameTimer;
        private var m_dizzyShield:Boolean;
        private var m_pitfallTimer:int;
        private var m_ricochetCount:FrameTimer;
        private var m_ricochetTimer:FrameTimer;
        private var m_ricochetX:FrameTimer;
        private var m_ricochetY:FrameTimer;
        private var m_invisibleTimer:FrameTimer;
        private var m_invincibleBrightness:Number;
        private var m_invincibleUp:Boolean;
        private var m_disableHurtFallOff:Boolean;
        private var m_jumpCount:int;
        private var m_bufferedAttackJump:Boolean;
        private var m_jumpSpeedBuffer:Number;
        private var m_multiJumpDelay:FrameTimer;
        private var m_lastCrouchTimer:int;
        private var m_crouchLength:int;
        private var m_crouchFrame:int;
        private var m_wallJumpCount:int;
        private var m_wallStickTime:FrameTimer;
        private var m_wallClingDelay:FrameTimer;
        private var m_shieldTimer:int;
        private var m_shieldStartFrame:int;
        private var m_shieldType:String;
        private var m_shieldPower:Number;
        private var m_shield_originalWidth:Number;
        private var m_shield_originalHeight:Number;
        private var m_shieldDelay:int;
        private var m_shieldDelayTimer:FrameTimer;
        private var m_shieldStartTimer:int;
        private var m_shieldDropLag:FrameTimer;
        private var m_previousAttack:String;
        private var m_lastHitStun:int;
        private var m_attackDelay:int;
        private var m_attackIDIncremented:Boolean;
        private var m_heldControlsBuffer:Array;
        private var m_pressedControlsBuffer:Array;
        private var m_heldControls:ControlsObject;
        private var m_pressedControls:ControlsObject;
        private var m_heldKeyHistory:ControlsObject;
        private var m_cStickUse:Boolean;
        private var m_c_buffered_down:Boolean;
        private var m_c_buffered_left:Boolean;
        private var m_c_buffered_right:Boolean;
        private var m_tap_jump:Boolean;
        private var m_auto_dash:Boolean;
        private var m_dt_dash:Boolean;
        private var m_walkTimer:int;
        private var m_hitForceVisible:Boolean;
        private var m_caughtInvincibility:Boolean;
        private var m_tetherCount:int;
        private var m_pauseLetGo:Boolean;
        private var m_pauseFreeze:Boolean;
        private var m_pauseTimer:int;
        private var m_zLetGo:Boolean;
        private var m_ledge:MovieClip;
        private var m_ledgeHangTimer:FrameTimer;
        private var m_lastLedge:MovieClip;
        private var m_ledgeDelay:FrameTimer;
        private var m_rollTimer:int;
        private var m_currentRollSpeed:Number;
        private var m_recoveryAmount:int;
        private var m_justFellThroughPlatform:Boolean;
        private var m_fallthroughPlatform:Platform;
        private var m_fallthroughTimer:FrameTimer;
        private var m_blinkTimer:int;
        private var m_blinkNumber:int;
        private var m_calcAngles:Boolean;
        private var m_player:MovieClip;
        private var m_human:Boolean;
        private var m_attachedFPS:MovieClip;
        private var m_attachedReticule:MovieClip;
        private var m_usingSpecialAttack:Boolean;
        private var m_lastSFX:int;
        private var m_lastVFX:int;
        private var m_staleMovesArr:Array;
        private var m_staleMoveVals:Array;
        private var m_projectile:Vector.<Projectile>;
        private var m_lastProjectile:int;
        private var m_item:Item;
        private var m_item2:Item;
        private var m_itemJustPickedUp:Boolean;
        private var m_itemPrePickup:Item;
        private var m_ledges:Array;
        private var m_grabbed:Vector.<Character>;
        private var m_walls:Vector.<BitmapCollisionBoundary>;
        private var m_outsideCameraBounds:Boolean;
        private var m_outsideMainTerrain:Boolean;
        private var m_grabTimer:int;
        private var m_strengthGrabLocked:Boolean;
        private var m_pummelTimer:int;
        private var m_justPummeled:Boolean;
        private var m_grabberID:int;
        private var m_caughtLock:Boolean;
        private var m_internalGrabLock:Boolean;
        private var m_grabCancelled:Boolean;
        private var m_initTimer:int;
        private var m_ignoreTauntAudio:Boolean;
        private var m_showPlayerID:Boolean;
        private var m_turnTimer:FrameTimer;
        private var m_frozenTimer:int;
        private var m_sleepingTimer:int;
        private var m_eggTimer:int;
        private var m_dustTimer:FrameTimer;
        private var m_currentPower:String;
        private var m_kirbyLastGrabbed:int;
        private var m_charIsFull:Boolean;
        private var m_holdTimer:int;
        private var m_starTimer:int;
        private var m_justReleased:Boolean;
        private var m_kirbyDamageCounter:int;
        private var m_itemDamageCounter:int;
        private var m_lastYPosition:Number;
        private var m_forceRight:Boolean;
        private var m_forceTimer:int;
        private var m_getUpTimer:FrameTimer;
        private var m_crashTimer:FrameTimer;
        private var m_revivalTimer:int;
        private var m_revivalInvincibility:FrameTimer;
        private var m_respawnDelay:FrameTimer;
        private var m_standby:Boolean;
        private var m_comboTimer:FrameTimer;
        private var m_comboCount:int;
        private var m_comboID:int;
        private var m_comboDamage:Number;
        private var m_comboDamageTotal:Number;
        private var m_damageIncreaseInterval:FrameTimer;
        private var m_poisonIncrease:int;
        private var m_poisonIncreaseInterval:FrameTimer;
        private var m_poisonIncreaseTime:FrameTimer;
        private var m_offscreenDamageTimer:FrameTimer;
        private var m_offScreenBubble:MovieClip;
        private var m_offScreenIndicatorEnabled:Boolean;
        private var m_poisonEffect:MovieClip;
        private var m_pitfallEffect:MovieClip;
        private var m_healEffect:MovieClip;
        private var m_burnSmoke:MovieClip;
        private var m_darknessSmoke:MovieClip;
        private var m_auraSmoke:MovieClip;
        private var m_warioWareIcon:MovieClip;
        private var m_starmanInvincibility:MovieClip;
        private var m_hatMC:MovieClip;
        private var m_hatHolder:MovieClip;
        private var m_shieldHolderMC:MovieClip;
        private var m_chargeGlowHolderMC:MovieClip;
        private var m_fsGlowHolderMC:MovieClip;
        private var m_pidHolderMC:MovieClip;
        private var m_pidHolderNameMC:MovieClip;
        private var m_kirbyStarMC:MovieClip;
        private var m_yoshiEggMC:MovieClip;
        private var m_freezeMC:MovieClip;
        private var m_lastFrameInterrupt:String;
        private var m_lastFrameInterruptState:int;
        private var m_lastFrameInterruptSmashTimer:int;
        private var m_burnSmokeTimer:FrameTimer;
        private var m_darknessSmokeTimer:FrameTimer;
        private var m_auraSmokeTimer:FrameTimer;
        private var m_shockEffectTimer:FrameTimer;
        private var m_poisonTintTimer:FrameTimer;
        private var m_injureFlashTimer:FrameTimer;
        private var m_warioWareIconTimer:FrameTimer;
        private var m_starmanInvincibilityTimer:FrameTimer;
        private var m_forceTransformTime:FrameTimer;
        private var m_safeToEndAttack:Boolean;
        private var m_lastAttackUsedTurbo:String;
        private var m_invisiblePulseTimer:FrameTimer;
        private var m_invisiblePulseToggle:Boolean;
        private var m_invisiblePulseCount:int;
        private var m_costume:int;
        private var CPU:AI;
        private var m_attackControlsArr:Vector.<int>;
        private var dragging:Boolean;
        public var DisableKey:Boolean;
		public var AIShieldGrabCPU:int = 0;

        public function Character(stats:CharacterData, parameters:PlayerSetting, stageData:StageData)
        {
            m_baseStats = (this.m_characterStats = stats);
            if (this.m_characterStats.PlayerID > 0)
            {
                stageData.addPlayer(this.m_characterStats.PlayerID, this);
            };
            stageData.addCharacter(this);
            this.m_playerSettings = parameters;
            m_apiInstance = new SSF2Character(this.m_characterStats.ClassAPI, this);
            if ((!(this.m_playerSettings.character)))
            {
                this.m_characterStats.importData(m_apiInstance.getOwnStats());
                this.m_characterStats.importAttacks(m_apiInstance.getAttackStats());
                this.m_characterStats.addProjectiles(m_apiInstance.getProjectileStats());
                this.m_characterStats.addItems(m_apiInstance.getItemStats());
            }
            else
            {
                if (this.m_playerSettings.character)
                {
                    this.m_characterStats.importData({
                        "attackRatio":this.m_playerSettings.attackRatio,
                        "damageRatio":this.m_playerSettings.damageRatio,
                        "unlimitedFinal":this.m_playerSettings.unlimitedFinal,
                        "startDamage":this.m_playerSettings.startDamage,
                        "finalSmashMeter":this.m_playerSettings.finalSmashMeter
                    });
                };
            };
            var tmpMC:MovieClip = ResourceManager.getLibraryMC(this.m_characterStats.LinkageID);
            super(tmpMC, stageData);
            m_player_id = this.m_characterStats.PlayerID;
            m_state = CState.IDLE;
            tmpMC.player_id = m_player_id;
            tmpMC.uid = m_uid;
			if(STAGEDATA.GameRef.GameMode == Mode.EVENT && this.m_playerSettings.character == "marth" && this.m_playerSettings.costume == 3 ) {
            m_sprite.x = 85;
            m_sprite.y = 86;
			}
			else if(STAGEDATA.GameRef.GameMode == Mode.EVENT && this.m_playerSettings.character == "marth" && this.m_playerSettings.costume == 2) {
            m_sprite.x = 60;
            m_sprite.y = 86;
			}
			else if(STAGEDATA.GameRef.GameMode == Mode.EVENT && this.m_playerSettings.character == "falco" && this.m_playerSettings.costume == 4) {
            m_sprite.x = -85;
            m_sprite.y = -386;
			}			
			else{
			m_sprite.x = this.m_playerSettings.x_start;
            m_sprite.y = this.m_playerSettings.y_start;
			}
            m_sizeRatio = stageData.GameRef.SizeRatio;
            this.m_originalSizeRatio = m_sizeRatio;
            m_sprite.width = (m_sprite.width * m_sizeRatio);
            m_sprite.height = (m_sprite.height * m_sizeRatio);
            this.m_costume = this.m_playerSettings.costume;
            this.m_jumpSpeedMidairDelay = new FrameTimer(1);
            this.m_jumpStartup = new FrameTimer(0);
            this.m_jumpJustChambered = false;
            this.m_jumpSpeedList = new Array();
            this.m_jumpEffectTimer = new FrameTimer(6);
            this.m_preJumpState = CState.IDLE;
            this.m_initialAirDodgeAngle = 0;
            this.m_waveLand = false;
            this.m_waveDashPenalty = 0;
            this.m_airDodgeCount = 0;
            this.m_skidTimer = 0;
            this.m_kirbyLastGrabbed = -1;
            this.m_glideAngle = 0;
            this.m_glideMaxHeight = 0;
            this.m_glideDelay = 0;
            this.m_glideReady = false;
            this.m_attachedReticule = null;
            this.m_attachedFPS = null;
            this.m_damageIncreaseInterval = new FrameTimer(30);
            this.m_wallStickTime = new FrameTimer(0);
            this.m_wallJumpCount = 0;
            this.m_wallClingDelay = new FrameTimer(10);
            this.m_shieldDropLag = new FrameTimer(7);
            this.m_disableHurtFallOff = false;
            this.m_outsideCameraBounds = false;
            this.m_outsideMainTerrain = false;
            this.m_tap_jump = false;
            this.m_auto_dash = false;
            this.m_dt_dash = false;
            this.m_walkTimer = 0;
            this.m_shieldStartTimer = 0;
            m_facingForward = true;
            this.m_speedFacingForward = true;
            this.m_tetherCount = 0;
            if ((!(this.m_playerSettings.facingRight)))
            {
                m_faceLeft();
                this.m_speedFacingForward = false;
            };
            this.m_usingLives = STAGEDATA.GameRef.LevelData.usingLives;
            this.m_showPlayerID = STAGEDATA.GameRef.ShowPlayerID;
            m_team_id = this.m_playerSettings.team;
            this.m_lives = this.m_playerSettings.lives;
            this.m_lastLivesTextNum = -1;
            this.m_expansion_id = ((this.m_playerSettings.character == "xp") ? this.m_playerSettings.expansion : -1);
            this.m_human = this.m_playerSettings.human;
            this.m_matchResults = new MatchResults(m_player_id);
            this.m_matchResults.StockRemaining = this.m_lives;
            this.m_midAirHoverTime = new FrameTimer(0);
            this.m_midAirJumpConstantTime = new FrameTimer(0);
            this.m_midAirJumpConstantTime.CurrentTime = 0;
            this.m_midAirJumpConstantDelay = new FrameTimer(0);
            this.m_forceTransformTime = new FrameTimer(0);
            this.m_safeToEndAttack = true;
            this.m_offscreenDamageTimer = new FrameTimer(30);
            m_shadowEffect = new MovieClip();
            this.m_offScreenBubble = new MovieClip();
            this.m_offScreenIndicatorEnabled = (!(DebugConsole.DISABLE_OFFSCREEN_BUBBLE));
            this.m_poisonEffect = ResourceManager.getLibraryMC("poison_effect");
            this.m_pitfallEffect = ResourceManager.getLibraryMC("pitfall_dirt");
            this.m_healEffect = ResourceManager.getLibraryMC("effect_heal");
            this.m_burnSmoke = ResourceManager.getLibraryMC("burn_smoke");
            this.m_darknessSmoke = ResourceManager.getLibraryMC("darkness_smoke");
            this.m_auraSmoke = ResourceManager.getLibraryMC("aura_smoke");
            this.m_warioWareIcon = ResourceManager.getLibraryMC("wariowareResultsIcon");
            this.m_starmanInvincibility = ResourceManager.getLibraryMC("effect_heal");
            this.m_yoshiEggMC = ResourceManager.getLibraryMC("egg_mc");
            this.m_kirbyStarMC = ResourceManager.getLibraryMC("star_mc");
            this.m_freezeMC = ResourceManager.getLibraryMC("freeze_mc");
            Utils.setColorFilter(this.m_starmanInvincibility, {
                "hue":-59,
                "saturation":34,
                "brightness":0,
                "contrast":25
            });
            this.m_hatMC = new MovieClip();
            this.m_hatHolder = null;
            this.m_shieldType = this.m_characterStats.ShieldType;
            this.m_shieldHolderMC = ResourceManager.getLibraryMC(this.m_shieldType);
            if ((!(this.m_shieldHolderMC)))
            {
                this.m_shieldHolderMC = ResourceManager.getLibraryMC("shield1");
            };
            this.m_chargeGlowHolderMC = null;
            this.m_pidHolderMC = ResourceManager.getLibraryMC("pid_mc");
            this.m_pidHolderNameMC = MovieClip(this.m_pidHolderMC.addChildAt(new MovieClip(), 0));
            if (((this.m_playerSettings.name) && (this.m_human)))
            {
                this.m_pidHolderMC.pname.text = this.m_playerSettings.name;
                this.m_pidHolderMC.pid.text = "";
                this.m_pidHolderNameMC.graphics.clear();
                this.m_pidHolderNameMC.graphics.beginFill(0, 0.5);
                this.m_pidHolderNameMC.graphics.drawRect(((-(this.m_pidHolderMC.pname.textWidth) / 2) - 3), this.m_pidHolderMC.pname.y, (this.m_pidHolderMC.pname.textWidth + 6), this.m_pidHolderMC.pname.height);
                this.m_pidHolderNameMC.graphics.endFill();
            }
            else
            {
                this.m_pidHolderNameMC.graphics.clear();
            };
            Utils.tryToGotoAndStop(this.m_pidHolderMC, ("p" + Utils.convertTeamToColor(m_player_id, ((ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode)) ? -1 : m_team_id))));
            Utils.tryToGotoAndStop(this.m_pidHolderMC.arrow, ("p" + Utils.convertTeamToColor(m_player_id, ((ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode)) ? -1 : m_team_id))));
            this.m_fsGlowHolderMC = ResourceManager.getLibraryMC("finalsmash_standby");
            this.m_warioWareIconTimer = new FrameTimer(20);
            this.m_warioWareIconTimer.finish();
            this.m_burnSmokeTimer = new FrameTimer(75);
            this.m_burnSmokeTimer.finish();
            this.m_darknessSmokeTimer = new FrameTimer(75);
            this.m_darknessSmokeTimer.finish();
            this.m_auraSmokeTimer = new FrameTimer(75);
            this.m_auraSmokeTimer.finish();
            this.m_injureFlashTimer = new FrameTimer(3);
            this.m_injureFlashTimer.finish();
            this.m_shockEffectTimer = new FrameTimer(10);
            this.m_shockEffectTimer.finish();
            this.m_poisonTintTimer = new FrameTimer(12);
            this.m_poisonTintTimer.finish();
            this.m_starmanInvincibilityTimer = new FrameTimer((30 * 10));
            this.m_starmanInvincibilityTimer.finish();
            this.m_currentRollSpeed = 0;
            this.m_starKOTimer = new FrameTimer(90);
            this.m_starKOTimer.finish();
            this.m_screenKO = false;
            this.m_starKOHolder = ResourceManager.getLibraryMC("starkoholder");
            this.m_starKOHolder.uid = m_uid;
            this.m_starKOHolder.stop();
            this.m_screenKOHolder = ResourceManager.getLibraryMC("screenkoholder");
            this.m_screenKOHolder.uid = m_uid;
            this.m_screenKOHolder.stop();
            this.m_lastFrameInterrupt = null;
            this.m_lastFrameInterruptState = CState.IDLE;
            this.m_lastFrameInterruptSmashTimer = 0;
            this.m_sizeStatus = 0;
            this.m_sizeStatusPermanent = false;
            this.m_sizeStatusTimer = new FrameTimer((30 * 10));
            this.m_isMetal = false;
            this.m_sizeStatusTimer.finish();
            this.m_crowdAwe = false;
            this.m_attackHovering = false;
            this.m_canHover = true;
            this.m_rocketSpeed = 0;
            this.m_rocketRotation = false;
            this.m_rocketDecay = 0;
            this.m_rocketAngle = 0;
            this.m_droughtTimer = 0;
            this.m_recoveryAmount = 0;
            this.m_justHit = false;
            this.m_justHitTimer = 5;
            this.resetJustHitTimer();
            this.m_hitLag = -1;
            this.m_hitLagCancelTimer = new FrameTimer(9);
            this.m_hitLagStunTimer = new FrameTimer(12);
            this.m_hitLagLandDelay = new FrameTimer(15);
            this.m_hitLagStunTimer.finish();
            this.m_hitLagCanCancelWithJump = false;
            this.m_hitLagCanCancelWithUpB = false;
            this.m_hitsDealtCounter = 0;
            this.m_hitsReceivedCounter = 0;
            this.m_techTimer = new FrameTimer(10);
            this.m_techDelay = new FrameTimer(10);
            this.m_smashDIAmount = 18;
            this.m_smashDISelf = false;
            this.m_smashDIDirection = -1;
            this.m_smashDIDirectionCStick = -1;
            this.m_canDI = true;
            this.m_techReady = false;
            this.m_justTechedTimer = new FrameTimer(3);
            this.m_justTechedTimer.finish();
            this.m_techLetGo = false;
            this.m_canTech = false;
            this.m_canWallTech = true;
            this.m_canBounce = false;
            this.m_hasBounced = false;
            this.m_revivalTimer = 0;
            this.m_revivalInvincibility = new FrameTimer(75);
            this.m_revivalInvincibility.finish();
            this.m_respawnDelay = new FrameTimer(30);
            this.m_getUpTimer = new FrameTimer(110);
            this.m_crashTimer = new FrameTimer(13);
            this.m_forceRight = true;
            this.m_forceTimer = 0;
            this.m_currentPower = null;
            this.m_charIsFull = false;
            this.m_poisonIncrease = 0;
            this.m_poisonIncreaseInterval = new FrameTimer(15);
            this.m_poisonIncreaseTime = new FrameTimer(300);
            this.m_rollTimer = 0;
            this.m_starTimer = 0;
            this.m_item = null;
            this.m_item2 = null;
            this.m_itemJustPickedUp = false;
            this.m_itemPrePickup = null;
            this.m_justReleased = false;
            this.m_kirbyDamageCounter = -1;
            this.m_itemDamageCounter = -1;
            this.m_lastYPosition = m_sprite.y;
            this.m_lastAttackUsedTurbo = null;
            this.m_invisiblePulseTimer = new FrameTimer(10);
            this.m_invisiblePulseToggle = false;
            this.m_invisiblePulseCount = 0;
            this.m_grabTimer = 0;
            this.m_strengthGrabLocked = false;
            if (StrengthSystem.DEBUG_TRACE)
            {
                this.traceStrengthStats();
            };
            this.m_pummelTimer = 0;
            this.m_justPummeled = false;
            this.m_eggTimer = 0;
            this.m_projectile = new Vector.<Projectile>();
            var i:int;
            while (i < this.m_characterStats.MaxProjectile)
            {
                this.m_projectile[i] = null;
                i++;
            };
            this.m_lastProjectile = 0;
            this.m_turnTimer = new FrameTimer(5);
            this.m_frozenTimer = 0;
            this.m_sleepingTimer = 0;
            this.m_grabberID = -1;
            this.m_internalGrabLock = false;
            this.m_grabCancelled = false;
            this.m_caughtLock = false;
            this.m_justFellThroughPlatform = false;
            this.m_fallthroughPlatform = null;
            this.m_fallthroughTimer = new FrameTimer(30);
            this.m_fallthroughTimer.finish();
            this.m_transformingSpecial = false;
            this.m_transformedSpecial = false;
            this.m_usingSpecialAttack = false;
            this.m_transformTime = 0;
            this.m_transformLimit = 0;
            this.m_finalSmashMeterCharge = 0;
            this.m_finalSmashMeterReady = false;
            this.m_finalSmashCutinMC = null;
            this.m_blinkTimer = 0;
            this.m_blinkNumber = 1;
            this.m_invisibleTimer = new FrameTimer(1);
            this.m_invisibleTimer.finish();
            this.m_holdTimer = 0;
            this.m_invincibleBrightness = 25;
            this.m_invincibleUp = true;
            this.m_attackIDIncremented = false;
            this.m_previousAttack = null;
            this.m_lastHitStun = 0;
            this.m_attackDelay = 0;
            this.m_stunTimer = 0;
            this.m_dizzyTimer = 0;
            this.m_strengthDizzyTimer = 0;
            this.m_stunCancelTimer = new FrameTimer(10);
            this.m_dizzyShield = false;
            this.m_pitfallTimer = 0;
            this.m_ricochetTimer = new FrameTimer(3);
            this.m_ricochetCount = new FrameTimer(5);
            this.m_ricochetX = new FrameTimer(2);
            this.m_ricochetY = new FrameTimer(2);
            this.m_ricochetX.finish();
            this.m_ricochetY.finish();
            this.m_dustTimer = new FrameTimer(1);
            this.m_staleMovesArr = [null, null, null, null, null, null, null, null, null];
            this.m_staleMoveVals = [0.1, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02];
            this.m_key = STAGEDATA.getControllerNum(m_player_id);
            this.m_heldControlsBuffer = new Array();
            this.m_pressedControlsBuffer = new Array();
            this.m_heldControls = new ControlsObject();
            this.m_pressedControls = new ControlsObject();
            this.m_heldKeyHistory = new ControlsObject();
            this.m_lastSFX = -1;
            this.m_lastVFX = -1;
            m_xSpeed = 0;
            m_ySpeed = 0;
            this.m_jumpCount = this.m_characterStats.MaxJump;
            this.m_cStickUse = false;
            this.m_pauseLetGo = true;
            this.m_zLetGo = true;
            this.m_pauseTimer = 0;
            this.m_bufferedAttackJump = false;
            this.m_jumpSpeedBuffer = 0;
            this.m_multiJumpDelay = new FrameTimer(2);
            this.m_c_buffered_down = false;
            this.m_c_buffered_left = false;
            this.m_c_buffered_right = false;
            m_collision.ground = true;
            m_currentPlatform = null;
            this.m_ledge = null;
            this.m_ledgeHangTimer = new FrameTimer((4 * 30));
            this.m_lastLedge = null;
            this.m_ledgeDelay = new FrameTimer(15);
            Utils.hasLabel(m_sprite, "edgelean", true);
            this.m_calcAngles = true;
            this.resetSpeedLevel();
            this.m_speedLetGo = false;
            this.m_dashReady = true;
            this.m_jumpTimer = 0;
            this.m_shortHop = false;
            this.m_jumpJustLetGo = false;
            this.m_smashTimer = 0;
            this.m_smashTimerUp = 0;
            this.m_smashTimerSide = 0;
            this.m_smashTimerDown = 0;
            this.m_upSpecialTimer = 0;
            this.m_specialTurnTimer = new FrameTimer(3);
            this.m_specialTurnTimer.finish();
            this.m_specialTurnRight = false;
            this.m_lastCrouchTimer = 0;
            this.m_crouchLength = 0;
            this.m_crouchFrame = -1;
            this.setState(CState.IDLE);
            this.m_windBoxHit = false;
            this.m_hasArced = false;
            this.m_forceTumbleFall = false;
            this.m_forcedCrash = false;
            this.m_tumbledCrash = false;
            this.m_jabResets = 0;
            this.m_jabResetTimer = new FrameTimer(30);
            this.m_fallTiltTimer = new FrameTimer(15);
            this.m_fallTiltTimer.finish();
            this.m_fallTiltRight = true;
            this.m_shieldTimer = 0;
            this.m_shieldStartFrame = 1;
            this.m_pauseFreeze = false;
            m_damage = ((this.m_characterStats.Stamina > 0) ? this.m_characterStats.Stamina : this.m_characterStats.StartDamage);
            this.m_shieldPower = 100;
            this.m_shield_originalWidth = 0;
            this.m_shield_originalHeight = 0;
            this.m_shieldDelay = 0;
            this.m_shieldDelayTimer = new FrameTimer(1);
            this.m_flyingRight = false;
            this.m_flyingUp = false;
            this.m_comboTimer = new FrameTimer(1);
            this.m_comboCount = 0;
            this.m_comboID = 0;
            this.m_comboDamage = 0;
            this.m_comboDamageTotal = 0;
            this.m_hitForceVisible = true;
            this.m_caughtInvincibility = false;
            this.m_standby = false;
            this.m_attackControlsArr = new Vector.<int>();
            this.m_ledges = new Array();
            this.m_grabbed = new Vector.<Character>();
            this.m_walls = new Vector.<BitmapCollisionBoundary>();
            this.m_initTimer = 0;
            this.m_preFrameInfo = "";
            this.m_freezePlayback = false;
            this.m_pauseCamXSpeed = 0;
            this.m_pauseCamYSpeed = 0;
            this.DisableKey = false;
            if ((!(this.m_human)))
            {
                this.CPU = new AI(this.m_playerSettings.level, this, STAGEDATA);
                if (((((this.m_characterStats.StatsName === "sandbag") && (!(this.m_human))) && (STAGEDATA.GameRef.GameMode === Mode.ONLINE_WAITING_ROOM)) && (STAGEDATA.CamBounds)))
                {
                    this.CPU.ForcedAction = CPUState.FORCE_DO_NOTHING;
                };
            };
            this.reapplyCostume();
            this.setStats(this.m_characterStats);
            if ((!(this.m_human)))
            {
                this.CPU.refreshRecoveryAttackList();
                this.CPU.refreshDisabledAttackList();
            };
            this.setVisibility(false);
            if (this.m_characterStats.AlternateStatsID != null)
            {
                buildHitBoxData(this.m_characterStats.AlternateStatsID, false);
            };
            if (this.m_characterStats.LinkageID2 != null)
            {
                buildHitBoxData(this.m_characterStats.LinkageID2, false);
            };
            if (this.m_characterStats.LinkageIDSpecial != null)
            {
                buildHitBoxData(this.m_characterStats.LinkageIDSpecial, false);
            };
            buildHitBoxData(this.m_characterStats.LinkageID);
            if (Main.DEBUG)
            {
                verifiyHitBoxData();
            };
            this.generatePummelData();
            m_attackData.getAttack("star").importAttackData({"attackBoxes":{"attackBox":{
                        "atk_id":m_attack.AttackID,
                        "damage":5,
                        "kbConstant":100,
                        "weightKB":110,
                        "power":0,
                        "direction":70,
                        "hitStun":1,
                        "hitLag":5,
                        "effectSound":"ssb_hit1",
                        "reversableAngle":false,
                        "isForward":(!(m_facingForward))
                    }}});
            this.setDamage(m_damage);
            this.getTerrainData();
            this.setState(CState.IDLE);
            applyPalette(m_sprite);
            this.applySpecialModeEffects();
            if (this.m_standby)
            {
                this.StandBy = false;
                this.StandBy = true;
            }
            else
            {
                this.setVisibility(true);
            };
            if (((((this.m_characterStats.StatsName === "sandbag") && (!(this.m_human))) && (STAGEDATA.GameRef.GameMode === Mode.ONLINE_WAITING_ROOM)) && (STAGEDATA.CamBounds)))
            {
                m_sprite.x = 408;
                m_sprite.y = 280;
                this.m_playerSettings.importSettings({
                    "x_respawn":(STAGEDATA.CamBounds.x + (STAGEDATA.CamBounds.width / 2)),
                    "y_respawn":(STAGEDATA.CamBounds.y + (STAGEDATA.CamBounds.height / 2)),
                    "x_start":(STAGEDATA.CamBounds.x + (STAGEDATA.CamBounds.width / 2)),
                    "y_start":(STAGEDATA.CamBounds.y + (STAGEDATA.CamBounds.height / 2))
                });
            };
        }

        private function blahd(e:MouseEvent):void
        {
            m_sprite.startDrag();
            this.dragging = true;
        }

        private function blahd2(e:MouseEvent):void
        {
            m_sprite.stopDrag();
            this.dragging = false;
        }

        private function ugh(e:Event):void
        {
            trace(testTerrainWithCoord(MouseTracker.X, MouseTracker.Y));
        }

        public function getStateInfo():String
        {
            return ((((((((((((((((((("{" + "x:") + m_sprite.x) + ", y:") + m_sprite.y) + ", state:") + CState.toString(m_state)) + ", stanceFrame#:") + ((HasStance) ? m_sprite.stance.currentFrame : "err")) + ", onGround:") + m_collision.ground) + ", attackingFrame:") + (((inState(CState.ATTACKING)) && (m_attack.Frame)) ? m_attack.Frame : "null")) + ", preFrameInfo: ") + this.m_preFrameInfo) + ", postFrameInfo: ") + this.getFrameData()) + ", controlBits: ") + this.m_key.getControlsObject().controls) + " }");
        }

        override public function get CurrentAnimation():HitBoxAnimation
        {
            return ((m_hitBoxManager == null) ? null : (((m_hitBoxManager.HitBoxAnimationList.length <= 0) || (!(m_currentAnimationID))) ? null : m_hitBoxManager.getHitBoxAnimation(((this.m_characterStats.LinkageID + "_") + m_currentAnimationID))));
        }

        private function generatePummelData():void
        {
            var grabAttackObj:AttackObject;
            if ((!(m_attackData.getAttack("grab"))))
            {
                grabAttackObj = new AttackObject("grab");
                grabAttackObj.importAttackData({"refreshRate":5});
                grabAttackObj.AttackBoxes["attackBox"] = new AttackDamage(m_player_id, this);
                grabAttackObj.AttackBoxes["attackBox"].importAttackDamageData({
                    "team_id":m_team_id,
                    "damage":this.m_characterStats.GrabDamage,
                    "hasEffect":false,
                    "bypassNonGrabbed":true,
                    "effectSound":this.m_characterStats.Sounds["pummel"]
                });
                m_attackData.setAttack("grab", grabAttackObj);
            };
        }

        public function modifyAttack(name:String, num:Number, value:Number):void
        {
            if (m_attackData.getAttack(name) != null)
            {
                switch (num)
                {
                    case 1:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].Direction = value;
                        break;
                    case 2:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].KBConstant = value;
                        break;
                    case 3:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].Power = value;
                        break;
                    case 4:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].HitStun = value;
                        break;
                    case 5:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].SelfHitStun = value;
                        break;
                    case 6:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].HitLag = value;
                        break;
                    case 7:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].Priority = value;
                        break;
                    case 8:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].Damage = value;
                        break;
                    case 9:
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].WeightKB = value;
                        break;
                };
            };
        }
	
        public function modifyCanDI(name:String, value:Boolean):void
        {
            if (m_attackData.getAttack(name) != null)
            {
                        m_attackData.getAttack(name).AttackBoxes["attackBox"].CanDI = value;
			}
        }		

        public function getAttack(name:String, num:Number):*
        {
            if (m_attackData.getAttack(name) != null)
            {
                switch (num)
                {
                    case 1:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].Direction);
                    case 2:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].KBConstant);
                    case 3:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].Power);
                    case 4:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].HitStun);
                    case 5:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].SelfHitStun);
                    case 6:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].HitLag);
                    case 7:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].Priority);
                    case 8:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].Damage);
                    case 9:
                        return (m_attackData.getAttack(name).AttackBoxes["attackBox"].WeightKB);
                };
            }
            else
            {
                return (null);
            };
        }

        public function getFrameData():String
        {
            var frame:String = ((HasStance) ? ((m_sprite.currentFrame + ":") + m_sprite.stance.currentFrame) : ((m_sprite.currentFrame + ":") + "nullstance"));
            return (frame);
        }

        public function getAI():AI
        {
            return (this.CPU);
        }

        public function getTerrainData():void
        {
            this.m_ledges = new Array(STAGEDATA.getLedges_L(), STAGEDATA.getLedges_R());
            m_terrains = STAGEDATA.Terrains;
            m_platforms = STAGEDATA.Platforms;
            this.m_walls = STAGEDATA.getWalls();
        }

        public function grabAPI(grabberID:int, hitVisible:Boolean=true, caughtInvincibility:Boolean=false, grabLock:Boolean=false):Boolean
        {
            var result:Boolean;
            var character:Character = STAGEDATA.getCharacterByUID(grabberID);
            if (((character) && (character.Grabbed.indexOf(character) < 0)))
            {
                result = this.Capture(grabberID, hitVisible, caughtInvincibility, grabLock);
                if (result)
                {
                    character.Grabbed.push(this);
                    character.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.CHAR_GRAB, {
                        "caller":character.APIInstance.instance,
                        "grabbed":m_apiInstance.instance
                    }));
                };
            }
            else
            {
                if (grabberID == -1)
                {
                    result = this.Capture(grabberID, hitVisible, caughtInvincibility, grabLock);
                };
            };
            if ((((!(result)) && (character)) && (character.Grabbed.indexOf(character) >= 0)))
            {
                return (true);
            };
            return (result);
        }

        public function Capture(grabberID:int, hitVisible:Boolean=true, caughtInvincibility:Boolean=false, grabLock:Boolean=false):Boolean
        {
            if (((((((((((((((((this.m_charIsFull) || (this.m_standby)) || (this.m_caughtLock)) || (this.IsCaught)) || (inState(CState.STAMINA_KO))) || ((m_damage <= 0) && (m_baseStats.Stamina > 0))) || ((Invincible) && (!((inState(CState.ATTACKING)) && (m_attack.ForceGrabbable))))) || (!(this.m_revivalInvincibility.IsComplete))) || (!(this.m_starmanInvincibilityTimer.IsComplete))) || (this.Dead)) || (this.Hanging)) || (this.Frozen)) || (this.UsingFinalSmash)) || ((this.m_usingSpecialAttack) && ((this.m_characterStats.SpecialType == 2) || (this.m_characterStats.SpecialType == 3)))) || (this.Egg)) || (inState(CState.BARREL))))
            {
                return (false);
            };
            this.m_caughtLock = grabLock;
            this.m_grabberID = grabberID;
            var grabber:Character = (((this.m_grabberID >= 0) && (STAGEDATA.getCharacterByUID(this.m_grabberID))) ? STAGEDATA.getCharacterByUID(this.m_grabberID) : null);
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_GRABBED, {
                "caller":this.APIInstance.instance,
                "grabber":((grabber) ? grabber.APIInstance.instance : null)
            }));
            m_knockbackStackingTimer.reset();
            this.stopActionShot();
            this.turnOffInvincibility();
            this.m_hitForceVisible = hitVisible;
            this.m_caughtInvincibility = caughtInvincibility;
            if (inState(CState.SHIELDING))
            {
                this.m_deactivateShield();
            };
            this.grabReleaseOpponent();
            this.m_jumpStartup.reset();
            this.m_attackHovering = false;
            m_attack.Rocket = false;
            this.m_midAirJumpConstantTime.finish();
            if (inState(CState.FLYING))
            {
                this.killAllSpeeds();
                this.resetRotation();
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            };
            if (inState(CState.GLIDING))
            {
                m_xSpeed = 0;
                m_ySpeed = 0;
            };
            if (inState(CState.ATTACKING))
            {
                if (m_attackData.getAttack(m_attack.Frame).ChargeRetain)
                {
                    m_attackData.getAttack(m_attack.Frame).ChargeTime = 0;
                };
                this.killAllSpeeds();
                if ((((((inState(CState.ATTACKING)) && (!(m_attack.Frame == null))) && (!(this.getCurrentProjectile() == null))) && (this.getCurrentProjectile().Visible)) && (!(this.getCurrentProjectile().Dead))))
                {
                    this.getCurrentProjectile().endControl();
                };
                this.resetRotation();
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                this.updateItemHolding();
                this.forceEndAttack();
                this.setState(CState.IDLE);
            };
            if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
            {
                STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
            };
            if (this.m_usingSpecialAttack)
            {
                this.m_usingSpecialAttack = false;
            };
            if (this.HasFinalSmash)
            {
                this.m_fsGlowHolderMC.visible = false;
            };
            this.setState(CState.CAUGHT);
            this.playHurtFrame();
            m_skipAttackProcessing = true;
            return (true);
        }

        public function Uncapture():void
        {
            this.m_caughtInvincibility = false;
            this.m_caughtLock = false;
            this.m_hitForceVisible = true;
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            if (this.HasFinalSmash)
            {
                this.m_fsGlowHolderMC.visible = true;
            };
            if ((!(inState(CState.STAMINA_KO))))
            {
                this.setState(CState.IDLE);
            };
        }

        public function Caught():Boolean
        {
            return (inState(CState.CAUGHT));
        }

        public function Struggle(val:int=4):int
        {
            var struggleAmount:int;
            if (((((this.m_pressedControls.UP) || (this.m_pressedControls.DOWN)) || (this.m_pressedControls.LEFT)) || (this.m_pressedControls.RIGHT)))
            {
                struggleAmount = (struggleAmount + val);
            };
            if (((((this.m_pressedControls.C_UP) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT)))
            {
                struggleAmount = (struggleAmount + val);
            };
            if (this.m_pressedControls.BUTTON2)
            {
                struggleAmount = (struggleAmount + val);
            };
            if (this.m_pressedControls.BUTTON1)
            {
                struggleAmount = (struggleAmount + val);
            };
            return (struggleAmount);
        }

        public function destroy(e:SSF2Event=null):void
        {
            var i:int;
            var index:int;
            if (STAGEDATA.Characters.indexOf(this) >= 0)
            {
                if (inState(CState.CAUGHT))
                {
                    i = 0;
                    while (i < STAGEDATA.Characters.length)
                    {
                        index = STAGEDATA.Characters[i].Grabbed.indexOf(this);
                        if (index >= 0)
                        {
                            STAGEDATA.Characters[i].releaseOpponent(index);
                        };
                        i++;
                    };
                };
                if (this.m_finalSmashCutinMC)
                {
                    if ((!(this.m_finalSmashCutinMC.parent)))
                    {
                        this.m_finalSmashCutinMC = null;
                        STAGEDATA.CamRef.deleteForcedTarget(m_sprite);
                        STAGEDATA.FSCutins--;
                    };
                };
                m_skipAttackCollisionTests = true;
                m_skipAttackProcessing = true;
                this.setState(CState.DEAD);
                this.removeFromCamera();
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_DESTROYED, {"caller":this.APIInstance.instance}));
                if (m_sprite.parent)
                {
                    m_sprite.parent.removeChild(m_sprite);
                };
                removeAllTempEvents();
                flushTimers();
                Utils.bulkRemoveMC([m_shadowEffect, m_reflectionEffect, this.m_starKOHolder, this.m_screenKOHolder, this.m_burnSmoke, this.m_darknessSmoke, this.m_auraSmoke, this.m_pitfallEffect, this.m_poisonEffect, this.m_healEffect, this.m_shockEffectTimer]);
                if (((this.m_hatMC) && (this.m_hatMC.parent)))
                {
                    this.m_hatMC.parent.removeChild(this.m_hatMC);
                };
                STAGEDATA.removeCharacter(this);
            };
        }

        override public function dispose():void
        {
            super.dispose();
            while (((this.m_offScreenBubble) && (this.m_offScreenBubble.numChildren > 0)))
            {
                if ((this.m_offScreenBubble.getChildAt(0) is Bitmap))
                {
                    (this.m_offScreenBubble.getChildAt(0) as Bitmap).bitmapData.dispose();
                    (this.m_offScreenBubble.getChildAt(0) as Bitmap).bitmapData = null;
                };
                this.m_offScreenBubble.removeChild(this.m_offScreenBubble.getChildAt(0));
            };
        }

        public function getMatchResults():MatchResults
        {
            return (this.m_matchResults);
        }

        public function updateRanksProxy():void
        {
            if (ModeFeatures.hasFeature(ModeFeatures.IS_CUSTOM, STAGEDATA.GameRef.GameMode))
            {
                STAGEDATA.updateRanks();
            };
        }

        public function resetDroughtTimer():void
        {
            if (((this.m_matchResults.LongestDrought < this.m_droughtTimer) && (!(STAGEDATA.GameEnded))))
            {
                this.m_matchResults.LongestDrought = this.m_droughtTimer;
            };
            this.m_droughtTimer = 0;
        }

        override public function setState(state:uint):void
        {
            var becameIdle:Boolean;
            var changedStates:Boolean = (!(state == m_state));
            var oldState:uint = m_state;
            if (((state == CState.IDLE) && (!(inState(CState.IDLE)))))
            {
                becameIdle = true;
                if (!m_collision.ground)
                {
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                    state = CState.JUMP_FALLING;
                };
                this.turnOffInvincibility();
                this.m_dashReady = true;
            }
            else
            {
                if (state == CState.LAND)
                {
                    this.turnOffInvincibility();
                };
            };
            if (((this.isBufferableState(oldState)) && (!(this.isBufferableState(state)))))
            {
                if (((m_collision.ground) && (((((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.SHIELD)) || (this.m_heldControls.SHIELD2)) || ((this.m_heldControls.DOWN) && (!((oldState === CState.ATTACKING) && (this.m_previousAttack === "crouch_attack")))))))
                {
                };
                this.validateControlsBuffer();
            };
            m_state = state;
            if (state != CState.DIZZY)
            {
                this.m_strengthDizzyTimer = 0;
            };
            if (((oldState === CState.EGG) && (!(inState(CState.EGG)))))
            {
                this.egg(false);
            };
            if (((oldState === CState.ATTACKING) && (m_attack.IASA)))
            {
                m_attack.IASA = false;
            };
            if (changedStates)
            {
                this.m_grabCancelled = false;
                if ((((inState(CState.IDLE)) && (m_collision.ground)) && (this.checkItemInterrupt("idle", 1))))
                {
                    return;
                };
                if (((inState(CState.JUMP_FALLING)) && (this.checkItemInterrupt("fall", 1))))
                {
                    return;
                };
            };
            if (becameIdle)
            {
                this.checkEdgeLean();
            };
            if (changedStates)
            {
                m_framesSinceLastState = 0;
                if (((((((m_intangible) && (!(inState(CState.CRASH_GETUP)))) && (!(inState(CState.TECH_ROLL)))) && (!(inState(CState.TECH_GROUND)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.LEDGE_HANG)))))
                {
                    this.setIntangibility(false);
                };
                this.m_controlFrames();
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.STATE_CHANGE, {
                    "caller":this.APIInstance.instance,
                    "fromState":oldState,
                    "toState":m_state
                }));
                if (((!(m_state == CState.ATTACKING)) && (!(m_state == CState.ITEM_TOSS))))
                {
                    flushTimers();
                    removeAllTempEvents();
                };
                if (m_state == CState.LAND)
                {
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_LAND, {"caller":this.APIInstance.instance}));
                };
                if ((((oldState == CState.ATTACKING) && (!(inState(CState.ATTACKING)))) && (!(this.m_charIsFull))))
                {
                    this.grabReleaseOpponent();
                };
                if ((!(inState(CState.CAUGHT))))
                {
                    this.m_caughtLock = false;
                };
            };
        }

        public function starmanEffect(length:int=300):void
        {
            this.m_starmanInvincibilityTimer.reset();
            this.m_starmanInvincibilityTimer.MaxTime = length;
            toggleEffect(this.m_starmanInvincibility, true);
            this.m_starmanInvincibility.x = m_sprite.x;
            this.m_starmanInvincibility.y = (m_sprite.y - ((m_height * m_sizeRatio) / 2));
        }

        public function warioWareEffect(win:Boolean, effect:Boolean):void
        {
            var availableItems:Vector.<ItemData>;
            var itemList:Vector.<ItemData>;
            var i:int;
            var prize:Number;
            var linkage:String;
            var oldSize:int = this.m_sizeStatus;
            if ((((((((this.m_warioWareIcon) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAMINA_KO)))) && (!(this.m_standby))) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.SCREEN_KO)))))
            {
                toggleEffect(this.m_warioWareIcon, true);
                this.m_warioWareIcon.x = m_sprite.x;
                this.m_warioWareIcon.y = (m_sprite.y - ((m_height * m_sizeRatio) / 2));
                this.m_warioWareIconTimer.reset();
                this.m_warioWareIcon.gotoAndStop(((win) ? "win" : "lose"));
                if (((effect) && (win)))
                {
                    availableItems = new Vector.<ItemData>();
                    itemList = ((ModeFeatures.hasFeature(ModeFeatures.FORCE_ITEM_AVAILABILITY, STAGEDATA.GameRef.GameMode)) ? STAGEDATA.ItemsRef.FullItemsList : STAGEDATA.ItemsRef.ItemsList);
                    i = 0;
                    while (i < itemList.length)
                    {
                        linkage = itemList[i].LinkageID;
                        if (((((((linkage == "smashball") && (!(STAGEDATA.ItemsRef.CurrentSmashBall))) || (linkage == "homerunbat")) || (linkage == "pokeball")) || (linkage == "assistTrophy")) || (linkage == "spinyShell")))
                        {
                            availableItems.push(itemList[i]);
                        };
                        i++;
                    };
                    prize = Utils.random();
                    if (prize < 0.3333)
                    {
                        this.setSizeStatus(1);
                        if (oldSize != this.m_sizeStatus)
                        {
                            STAGEDATA.playSpecificSound("mushroom_grow");
                        };
                    }
                    else
                    {
                        if (prize < 0.66666)
                        {
                            this.recover(50);
                        }
                        else
                        {
                            if (prize >= 0.6666)
                            {
                                this.starmanEffect((10 * 30));
                            }
                            else
                            {
                                if (prize == 4)
                                {
                                    STAGEDATA.ItemsRef.generateItemObj(availableItems[Utils.randomInteger(0, (availableItems.length - 1))], m_sprite.x, (m_sprite.y - (m_height / 2)));
                                };
                            };
                        };
                    };
                };
            };
        }

        public function setMetalStatus(status:Boolean):void
        {
            var metalCostume:Object;
            if (status !== this.m_isMetal)
            {
                this.m_isMetal = status;
                if (this.m_isMetal)
                {
                    metalCostume = ResourceManager.getMetalCostume(this.m_characterStats.StatsName);
                    Utils.setColorFilter(m_sprite, metalCostume);
                    if (metalCostume)
                    {
                        this.setPaletteSwap(((metalCostume.paletteSwap) || (null)), ((metalCostume.paletteSwapPA) || (null)));
                    };
                    m_gravity = (this.m_characterStats.Gravity * 1.25);
                    m_max_ySpeed = (this.m_characterStats.MaxYSpeed * 2);
                    this.m_max_xSpeed = (this.m_characterStats.MaxXSpeed * 0.95);
                    this.m_norm_xSpeed = (this.m_characterStats.NormalXSpeed * 0.95);
                }
                else
                {
                    if ((!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.METAL))))
                    {
                        this.reapplyCostume();
                        applyPalette(m_healthBoxMC.charHead);
                        m_gravity = this.m_characterStats.Gravity;
                        m_max_ySpeed = this.m_characterStats.MaxYSpeed;
                        this.m_max_xSpeed = this.m_characterStats.MaxXSpeed;
                        this.m_norm_xSpeed = this.m_characterStats.NormalXSpeed;
                    };
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_METAL_CHANGE, {
                    "caller":this.APIInstance.instance,
                    "isMetal":this.m_isMetal
                }));
            };
        }

        public function getMetalStatus():Boolean
        {
            return (this.m_isMetal);
        }

        private function reapplyCostume():void
        {
            updateColorFilter(m_sprite, ((ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode)) ? -1 : m_team_id), this.CostumeName, this.CostumeID);
        }

        public function get HitLagHack():Number
        {
            return (this.m_hitLagHack);
        }

        public function set HitLagHack(value:Number):void
        {
            this.m_hitLagHack = value;
        }

        public function get OffScreenIndicatorEnabled():Boolean
        {
            return (this.m_offScreenIndicatorEnabled);
        }

        public function set OffScreenIndicatorEnabled(value:Boolean):void
        {
            this.m_offScreenIndicatorEnabled = value;
        }

        public function get ZLetGo():Boolean
        {
            return (this.m_zLetGo);
        }

        public function set ZLetGo(value:Boolean):void
        {
            this.m_zLetGo = value;
        }

        public function get PauseLetGo():Boolean
        {
            return (this.m_pauseLetGo);
        }

        public function set PauseLetGo(value:Boolean):void
        {
            this.m_pauseLetGo = value;
        }

        public function get HoldJump():Boolean
        {
            return (this.m_characterStats.HoldJump);
        }

        public function get CanHover():Boolean
        {
            return (this.m_canHover);
        }

        public function get MidAirHover():int
        {
            return (this.m_characterStats.MidAirHover);
        }

        public function get AttackHovering():Boolean
        {
            return ((inState(CState.ATTACKING)) && (this.m_attackHovering));
        }

        public function get HasMidAirJumps():Boolean
        {
            if (this.m_jumpSpeedList)
            {
                return (this.m_jumpCount < this.m_jumpSpeedList.length);
            };
            return (this.m_jumpCount < this.m_characterStats.MaxJump);
        }

        public function get CurrentMidairJumpSpeed():Number
        {
            if (this.m_jumpSpeedList)
            {
                if (this.m_jumpCount < this.m_jumpSpeedList.length)
                {
                    return (-(this.m_jumpSpeedList[this.m_jumpCount]));
                };
                return (-(this.m_jumpSpeedList[(this.m_jumpSpeedList.length - 1)]));
            };
            return (-(this.m_characterStats.JumpSpeedMidAir));
        }

        public function get CostumeID():int
        {
            return (this.m_costume);
        }

        public function set CostumeID(value:int):void
        {
            this.m_costume = value;
        }

        public function setCostumeAPI(value:int, team_id:int=-1):void
        {
            this.CostumeID = value;
            this.reapplyCostume();
            if (this.m_starKOMC)
            {
                applyPalette(this.m_starKOMC);
            };
            this.redrawHealthBox();
        }

        public function get CostumeName():String
        {
            return ((this.m_transformedSpecial) ? this.m_characterStats.NormalStatsID : this.m_characterStats.StatsName);
        }

        public function get CpuAI():AI
        {
            return (this.CPU);
        }

        public function get State():uint
        {
            return (m_state);
        }

        public function get CanBarrel():Boolean
        {
            return (this.m_characterStats.CanBarrel);
        }

        public function get IsTeching():Boolean
        {
            return ((inState(CState.TECH_ROLL)) || (inState(CState.TECH_GROUND)));
        }

        public function get Frozen():Boolean
        {
            return (inState(CState.FROZEN));
        }

        public function get Pitfall():Boolean
        {
            return (inState(CState.PITFALL));
        }

        public function get DisplayName():String
        {
            return (this.m_characterStats.DisplayName);
        }

        public function get SoundData():Array
        {
            return (this.m_characterStats.Sounds);
        }

        public function get ExpansionID():Number
        {
            return (this.m_expansion_id);
        }

        public function get IsCaught():Boolean
        {
            return (inState(CState.CAUGHT));
        }

        public function get StatsName():String
        {
            return (this.m_characterStats.NormalStatsID);
        }

        public function get CurrentStatsName():String
        {
            return (this.m_characterStats.StatsName);
        }

        public function get StandBy():Boolean
        {
            return (this.m_standby);
        }

        public function set StandBy(value:Boolean):void
        {
            var targets1:Vector.<MovieClip>;
            var i:int;
            var index:int;
            var targets2:Vector.<MovieClip>;
            var preVal:Boolean = this.m_standby;
            this.m_standby = value;
            if (((this.m_standby) && (!(preVal))))
            {
                if (inState(CState.SHIELDING))
                {
                    this.m_deactivateShield();
                };
                if (inState(CState.FROZEN))
                {
                    this.freeze(false);
                };
                if (inState(CState.EGG))
                {
                    this.egg(false);
                };
                if (inState(CState.CAUGHT))
                {
                    i = 0;
                    while (i < STAGEDATA.Characters.length)
                    {
                        index = STAGEDATA.Characters[i].Grabbed.indexOf(this);
                        if (index >= 0)
                        {
                            STAGEDATA.Characters[i].releaseOpponent(index);
                        };
                        i++;
                    };
                };
                m_sprite.x = this.m_playerSettings.x_start;
                m_sprite.y = this.m_playerSettings.y_start;
                this.forceOnGround();
                this.reset();
                targets1 = new Vector.<MovieClip>();
                targets1.push(m_sprite);
                STAGEDATA.CamRef.deleteTargets(targets1);
                this.setVisibility(false);
                showHealthBoxes(false);
                this.m_recoveryAmount = 0;
                this.hideAllEffects();
                this.m_screenKO = false;
                if (this.m_pidHolderMC.parent)
                {
                    this.m_pidHolderMC.parent.removeChild(this.m_pidHolderMC);
                };
                if ((!(this.m_human)))
                {
                    this.CPU.resetControlOverrides();
                };
                this.m_revivalInvincibility.finish();
                this.m_starmanInvincibilityTimer.finish();
                this.turnOffInvincibility();
                this.setState(CState.ENTRANCE);
                this.setState(CState.IDLE);
                if (this.m_starKOMC)
                {
                    this.m_starKOMC.visible = false;
                };
                this.m_burnSmokeTimer.finish();
                this.m_darknessSmokeTimer.finish();
                this.m_auraSmokeTimer.finish();
                this.m_shockEffectTimer.finish();
                this.m_poisonTintTimer.finish();
                this.m_injureFlashTimer.finish();
                this.m_starmanInvincibilityTimer.finish();
                if (this.m_starKOHolder.visible)
                {
                    this.m_starKOHolder.visible = false;
                    this.m_starKOHolder.gotoAndStop(1);
                };
                if (this.m_screenKOHolder.visible)
                {
                    this.m_screenKOHolder.visible = false;
                    this.m_screenKOHolder.gotoAndStop(1);
                };
                if ((!(this.m_playerSettings.facingRight)))
                {
                    m_faceLeft();
                };
            }
            else
            {
                if (((!(this.m_standby)) && (preVal)))
                {
                    if ((!((CAM.Mode == Vcam.ZOOM_MODE) && (m_player_id > 1))))
                    {
                        targets2 = new Vector.<MovieClip>();
                        targets2.push(m_sprite);
                        STAGEDATA.CamRef.addTargets(targets2);
                    };
                    this.setVisibility(true);
                    showHealthBoxes(true);
                };
            };
        }

        public function get ControlSettings():Controller
        {
            return (this.m_key);
        }

        public function get PressedControls():ControlsObject
        {
            return this.m_pressedControls
        }

        public function get Revival():Boolean
        {
            return (currentFrameIs("revival"));
        }

        public function get DizzyShield():Boolean
        {
            return (this.m_dizzyShield);
        }

        public function get HitBox():MovieClip
        {
            var hb:MovieClip = m_sprite.stance.hitBox;
            return (hb);
        }

        public function get AirDodge():Boolean
        {
            return (inState(CState.AIR_DODGE));
        }

        public function get SidestepDodge():Boolean
        {
            return (inState(CState.SIDESTEP_DODGE));
        }

        public function get AttackForward():Boolean
        {
            return (m_attack.IsForward);
        }

        public function get UsingFinalSmash():Boolean
        {
            if ((((this.m_usingSpecialAttack) || (this.m_transformedSpecial)) || (this.m_transformingSpecial)))
            {
                return (true);
            };
            return (false);
        }

        public function get TransformedSpecial():Boolean
        {
            return (this.m_transformedSpecial);
        }

        public function get TransformingFinalSmash():Boolean
        {
            if (((this.m_usingSpecialAttack) && (this.m_transformingSpecial)))
            {
                return (true);
            };
            return (false);
        }

        public function get AttackingFinalSmash():Boolean
        {
            if (((this.m_usingSpecialAttack) && (this.m_characterStats.SpecialType > 0)))
            {
                return (true);
            };
            return (false);
        }

        public function get HasSmashBall():Boolean
        {
            return (!(this.m_item2 == null));
        }

        public function get HasFinalSmash():Boolean
        {
            return ((!(this.m_item2 == null)) || (this.m_finalSmashMeterReady));
        }

        public function get HoldingItem():Boolean
        {
            return (!(this.m_item == null));
        }

        public function get WarningCollision():Boolean
        {
            return ((((m_collision.lbound_lower) || (m_collision.lbound_upper)) || (m_collision.rbound_lower)) || (m_collision.rbound_upper));
        }

        public function get Gliding():Boolean
        {
            return (inState(CState.GLIDING));
        }

        public function get ItemObj():Item
        {
            return (this.m_item);
        }

        public function set ItemObj(value:*):void
        {
            this.m_item = value;
        }

        public function get FinalSmashMeterCharge():Number
        {
            return (this.m_finalSmashMeterCharge);
        }

        public function set FinalSmashMeterCharge(value:Number):void
        {
            if ((!(this.m_characterStats.FinalSmashMeter)))
            {
                return;
            };
            if (value > 1)
            {
                value = 1;
            }
            else
            {
                if (value < 0)
                {
                    value = 0;
                };
            };
            if (((m_healthBoxMC) && (!(this.m_transformedSpecial))))
            {
                m_healthBoxMC.fsmeter.bar.scaleX = value;
            };
            this.m_finalSmashMeterCharge = value;
            if (((value === 1) && (!(this.m_finalSmashMeterReady))))
            {
                this.m_finalSmashMeterReady = true;
                this.m_fsGlowHolderMC.scaleX = m_sizeRatio;
                this.m_fsGlowHolderMC.scaleY = m_sizeRatio;
                this.m_fsGlowHolderMC.x = m_sprite.x;
                this.m_fsGlowHolderMC.y = m_sprite.y;
                this.playGlobalSound("smashball_break");
                toggleEffect(this.m_fsGlowHolderMC, true);
                if (m_healthBoxMC)
                {
                    m_healthBoxMC.fsmeter.bar.gotoAndPlay("full");
                    m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("on");
                };
            }
            else
            {
                if (((value < 1) && (this.m_finalSmashMeterReady)))
                {
                    this.m_finalSmashMeterReady = false;
                    toggleEffect(this.m_fsGlowHolderMC, false);
                    if (m_healthBoxMC)
                    {
                        m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                        m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                    };
                };
            };
        }

        public function get FinalSmashMeterCharged():Boolean
        {
            return (this.m_finalSmashMeterReady);
        }

        public function get Injured():Boolean
        {
            return (inState(CState.INJURED));
        }

        public function get Flying():Boolean
        {
            return (inState(CState.FLYING));
        }

        public function get Crashed():Boolean
        {
            return ((inState(CState.CRASH_LAND)) || (inState(CState.CRASH_GETUP)));
        }

        public function get SmashDISelf():Boolean
        {
            return (this.m_smashDISelf);
        }

        public function set SmashDISelf(value:Boolean):void
        {
            this.m_smashDISelf = value;
        }

        public function get FlyingRight():Boolean
        {
            return (this.m_flyingRight);
        }

        public function get FlyingUp():Boolean
        {
            return (this.m_flyingUp);
        }

        public function get KirbyPower():String
        {
            if (this.m_characterStats.LinkageID == "kirby")
            {
                return (this.m_currentPower);
            };
            return (this.m_characterStats.Power);
        }

        public function get KirbyHatMC():MovieClip
        {
            return (this.m_hatMC);
        }
		
		
        public function set KirbyPower(value:String):void
        {
            var i:int;
            var opponent:Character;
            var p:*;
            if (this.m_characterStats.LinkageID == "kirby")
            {
                if (value != null)
                {
                    i = 0;
                    while (i < STAGEDATA.Characters.length)
                    {
                        opponent = STAGEDATA.Characters[i];
                        if (opponent.KirbyPower == value)
                        {
                            for (p in opponent.AttackDataObj.ProjectilesArray)
                            {
                                if ((!(m_attackData.getProjectile(p))))
                                {
                                    m_attackData.addProjectile(p, opponent.AttackDataObj.ProjectilesArray[p]);
                                };
                            };
                            break;
                        };
                        i++;
                    };
                };
                this.m_currentPower = value;
                this.m_kirbyDamageCounter = 45;
                if (((!(STAGEDATA.getCharacterByUID(this.m_kirbyLastGrabbed) == null)) && (STAGEDATA.getCharacterByUID(this.m_kirbyLastGrabbed).LinkageName == "kirby")))
                {
                    STAGEDATA.getCharacterByUID(this.m_kirbyLastGrabbed).releaseKirbyPower();
                };
            }
            else
            {
                this.m_characterStats.Power = value;
            };
        }

        public function get CharacterStats():CharacterData
        {
            return (this.m_characterStats);
        }

        public function get LinkageName():String
        {
            return (this.m_characterStats.LinkageID);
        }

        public function get LinkageNameSpecial():String
        {
            return (this.m_characterStats.LinkageIDSpecial);
        }

        public function get Ledge():MovieClip
        {
            return (this.m_ledge);
        }

        public function get Hanging():Boolean
        {
            return (inState(CState.LEDGE_HANG));
        }

        public function get AttackDelay():int
        {
            return (this.m_attackDelay);
        }

        public function set AttackDelay(value:int):void
        {
            this.m_attackDelay = value;
        }

        public function get JumpCount():int
        {
            return (this.m_jumpCount);
        }

        public function set JumpCount(value:int):void
        {
            this.m_jumpCount = value;
        }

        public function get MaxJump():int
        {
            return (this.m_characterStats.MaxJump);
        }

        public function get ShieldPower():Number
        {
            return (this.m_shieldPower);
        }

        public function get ShieldStartTimer():Number
        {
            return (this.m_shieldStartTimer);
        }

        public function get PerfectShield():Boolean
        {
            return ((inState(CState.SHIELDING)) && (this.m_shieldStartTimer < 1));
        }

        public function get IsHuman():Boolean
        {
            return (this.m_human);
        }

        public function get Shielding():Boolean
        {
            return (inState(CState.SHIELDING));
        }

        public function get Grabbing():Boolean
        {
            return (inState(CState.GRABBING));
        }

        public function get Dodging():Boolean
        {
            return (((inState(CState.DODGE_ROLL)) || (inState(CState.SIDESTEP_DODGE))) || (inState(CState.AIR_DODGE)));
        }

        public function get Grabbed():Vector.<Character>
        {
            return (this.m_grabbed);
        }

        public function get GrabberID():int
        {
            return (this.m_grabberID);
        }

        public function get Rolling():Boolean
        {
            return (inState(CState.ROLL));
        }

        public function get RollingUp():Boolean
        {
            return (inState(CState.LEDGE_ROLL));
        }

        public function get ClimbingUp():Boolean
        {
            return (inState(CState.LEDGE_CLIMB));
        }

        public function get Dead():Boolean
        {
            return (inState(CState.DEAD));
        }

        public function get FacingRight():Boolean
        {
            return (m_facingForward);
        }

        public function get HitLag():int
        {
            return (this.m_hitLag);
        }

        public function set HitLag(value:int):void
        {
            this.m_hitLag = value;
        }

        public function set FlyingRight(value:Boolean):void
        {
            this.m_flyingRight = value;
        }

        public function set FlyingUp(value:Boolean):void
        {
            this.m_flyingUp = value;
        }

        public function get XVelocity():Number
        {
            return (0);
        }

        public function set XVelocity(value:Number):void
        {
        }

        public function get YVelocity():Number
        {
            return (0);
        }

        public function set YVelocity(value:Number):void
        {
        }

        public function get Terrain():Vector.<Platform>
        {
            return (m_terrains);
        }

        public function get Platforms():Vector.<Platform>
        {
            return (m_platforms);
        }

        public function get ProjectileArray():Vector.<Projectile>
        {
            return (this.m_projectile);
        }

        public function get CharIsFull():Boolean
        {
            return (this.m_charIsFull);
        }

        public function get Combo():Number
        {
            return (this.m_comboCount);
        }

        public function get ComboDamage():Number
        {
            return (this.m_comboDamage);
        }

        public function get SpecialType():int
        {
            return (this.m_characterStats.SpecialType);
        }

        public function get ComboDamageTotal():Number
        {
            return (this.m_comboDamageTotal);
        }

        override public function get PickupHitBoxes():Array
        {
            if (((!(this.inFreeState((CFreeState.ATTACKING | CFreeState.DODGING)))) || ((inState(CState.ATTACKING)) && (m_attack.ExecTime > 0))))
            {
                return ([]);
            };
            var scale:Point = CurrentScale;
            var width:Number = (m_width * scale.x);
            var height:Number = (m_height * scale.y);
            var rect:Rectangle = new Rectangle();
            rect.width = width;
            rect.height = height;
            rect.x = (-(rect.width) / 2);
            rect.y = -(rect.height);
            rect.width = (rect.width + (0.75 * width));
            rect.height = (rect.height / 2);
            rect.y = (rect.y + rect.height);
            var hBox:HitBoxSprite = new HitBoxSprite(HitBoxSprite.PICKUP, rect, true, null);
            return (new Array(hBox));
        }

        override public function get ShieldHitBoxes():Array
        {
            var rect:Rectangle;
            var hBox:HitBoxSprite;
            if (((inState(CState.SHIELDING)) && (this.m_shieldTimer >= this.m_shieldStartFrame)))
            {
                if (this.m_characterStats.CustomShield)
                {
                    return ((HasHitBox) ? this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.SHIELD) : super.ShieldHitBoxes);
                };
                rect = new Rectangle();
                rect.width = (55 * (((this.m_shieldPower / 100) * (this.m_characterStats.MaxShieldSize - this.m_characterStats.MinShieldSize)) + this.m_characterStats.MinShieldSize));
                rect.height = (55 * (((this.m_shieldPower / 100) * (this.m_characterStats.MaxShieldSize - this.m_characterStats.MinShieldSize)) + this.m_characterStats.MinShieldSize));
                rect.x = ((-(rect.width) / 2) + (this.m_characterStats.ShieldXOffset * m_sizeRatio));
                rect.y = ((((-(m_height) / 3) * m_sizeRatio) - (rect.height / 2)) + (this.m_characterStats.ShieldYOffset * m_sizeRatio));
                rect.y = (rect.y - 8.4);
                hBox = new HitBoxSprite(HitBoxSprite.SHIELD, rect, true, null);
                return (new Array(hBox));
            };
            return (super.ShieldHitBoxes);
        }

        override public function get StarHitBoxes():Array
        {
            var rect:Rectangle;
            var hBox:HitBoxSprite;
            if (inState(CState.KIRBY_STAR))
            {
                rect = new Rectangle();
                rect.width = 35;
                rect.height = 35;
                rect.x = (-(rect.width) / 2);
                rect.y = (-(m_height) * m_sizeRatio);
                hBox = new HitBoxSprite(HitBoxSprite.ATTACK, rect, true, null);
                hBox.Name = "attackBox";
                return (new Array(hBox));
            };
            return (null);
        }

        override public function get EggHitBoxes():Array
        {
            var rect:Rectangle;
            var hBox:HitBoxSprite;
            if (inState(CState.EGG))
            {
                rect = new Rectangle();
                rect.width = 30;
                rect.height = 35;
                rect.x = (-(rect.width) / 2);
                rect.y = (-(m_height) * m_sizeRatio);
                hBox = new HitBoxSprite(HitBoxSprite.EGG, rect, true, null);
                return (new Array(hBox));
            };
            return (null);
        }

        override public function get FreezeHitBoxes():Array
        {
            var rect:Rectangle;
            var hBox:HitBoxSprite;
            if (inState(CState.FROZEN))
            {
                rect = new Rectangle();
                rect.width = 85;
                rect.height = 65;
                rect.x = (-(rect.width) / 2);
                rect.y = (-(m_height) * m_sizeRatio);
                hBox = new HitBoxSprite(HitBoxSprite.FREEZE, rect, true, null);
                return (new Array(hBox));
            };
            return (null);
        }

        public function usingMidAirJumpConstant():Boolean
        {
            return ((this.m_midAirJumpConstantTime.MaxTime > 0) && (!(this.m_midAirJumpConstantTime.IsComplete)));
        }

        public function inFreeState(ignoreCFreeStates:uint=0):Boolean
        {
            var attacking:Boolean = (((ignoreCFreeStates & CFreeState.ATTACKING) > 0) ? false : inState(CState.ATTACKING));
            attacking = ((((attacking) && ((ignoreCFreeStates & CFreeState.NON_IASA) > 0)) && (m_attack.IASA)) ? true : ((attacking) && (!(m_attack.IASA))));
            var grabbing:Boolean = (((ignoreCFreeStates & CFreeState.GRABBING) > 0) ? false : inState(CState.GRABBING));
            var charIsFull:Boolean = (((ignoreCFreeStates & CFreeState.SWALLOWING) > 0) ? false : this.m_charIsFull);
            var shielding:Boolean = (((ignoreCFreeStates & CFreeState.SHIELDING) > 0) ? false : inState(CState.SHIELDING));
            var injury:Boolean = (((ignoreCFreeStates & CFreeState.INJURED) > 0) ? false : (!((!(inState(CState.INJURED))) && (!(inState(CState.FLYING))))));
            var disabled:Boolean = (((ignoreCFreeStates & CFreeState.DISABLED) > 0) ? false : inState(CState.DISABLED));
            var dodging:Boolean = (((ignoreCFreeStates & CFreeState.DODGING) > 0) ? false : (((inState(CState.DODGE_ROLL)) || (inState(CState.SIDESTEP_DODGE))) || (inState(CState.AIR_DODGE))));
            var gliding:Boolean = (((ignoreCFreeStates & CFreeState.GLIDING) > 0) ? false : inState(CState.GLIDING));
            var turning:Boolean = (((ignoreCFreeStates & CFreeState.TURNING) > 0) ? false : inState(CState.TURN));
            var jumpChambering:Boolean = (((ignoreCFreeStates & CFreeState.JUMP_CHAMBER) > 0) ? false : this.isJumpChambering());
            var skidding:Boolean = (((ignoreCFreeStates & CFreeState.SKIDDING) > 0) ? false : this.isSkidding());
            var tossing:Boolean = (((ignoreCFreeStates & CFreeState.TOSSING) > 0) ? false : inState(CState.ITEM_TOSS));
            var transformingFinalSmash:Boolean = (((ignoreCFreeStates & CFreeState.TRANSFORMING_FS) > 0) ? false : this.m_transformingSpecial);
            var usingFinalSmash:Boolean = (((ignoreCFreeStates & CFreeState.USING_FS) > 0) ? false : this.m_usingSpecialAttack);
            return ((((((((((((((((((((((((((((((((((((((((((!(this.m_standby)) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAMINA_KO)))) && (!(injury))) && (!(disabled))) && (!(attacking))) && (!(shielding))) && (!(dodging))) && (!(inState(CState.LEDGE_HANG)))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.LEDGE_CLIMB)))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.WALL_CLING)))) && (!(inState(CState.SLEEP)))) && (!(transformingFinalSmash))) && (!(usingFinalSmash))) && (!(inState(CState.TAUNT)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.EGG)))) && (!(this.isLanding()))) && (!(jumpChambering))) && (!(inState(CState.ROLL)))) && (!(grabbing))) && (!(charIsFull))) && (!(inState(CState.KIRBY_STAR)))) && (!(inState(CState.REVIVAL)))) && (!(tossing))) && (!(inState(CState.CRASH_LAND)))) && (!(inState(CState.CRASH_GETUP)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.SCREEN_KO)))) && (!(gliding))) && (!(turning))) && (!(inState(CState.TECH_GROUND)))) && (!(inState(CState.TECH_ROLL)))) && (!(skidding))) && (!(inState(CState.SHIELD_DROP)))) && (!(inState(CState.ITEM_PICKUP))));
        }

        public function get OnKirbyFrame():Boolean
        {
            return (Boolean((((!(this.m_currentPower == null)) && (this.m_characterStats.LinkageID == "kirby")) && ((m_attack.Frame == "kirby") || (m_attack.Frame == "kirby_air")))));
        }

        public function get Disabled():Boolean
        {
            return (inState(CState.DISABLED));
        }

        public function get AttachedFSCutscene():MovieClip
        {
            return (this.m_attachedFPS);
        }

        public function get AttachedReticule():MovieClip
        {
            return (this.m_attachedReticule);
        }

        public function get StarKOMC():MovieClip
        {
            return (this.m_starKOMC);
        }

        public function get ScreenKO():Boolean
        {
            return (this.m_screenKO);
        }

        public function get ScreenKOHolder():MovieClip
        {
            return (this.m_screenKOHolder);
        }

        public function get Egg():Boolean
        {
            return (inState(CState.EGG));
        }

        public function get SizeStatus():int
        {
            return (this.m_sizeStatus);
        }

        public function get SizeStatusPermanent():Boolean
        {
            return (this.m_sizeStatusPermanent);
        }

        public function set SizeStatusPermanent(value:Boolean):void
        {
            this.m_sizeStatusPermanent = value;
        }

        public function get OriginalSizeRatio():Number
        {
            return (this.m_originalSizeRatio);
        }

        public function set OriginalSizeRatio(num:Number):void
        {
            this.m_originalSizeRatio = num;
        }

        public function get FreezePlayback():Boolean
        {
            return (this.m_freezePlayback);
        }

        public function set FreezePlayback(value:Boolean):void
        {
            this.m_freezePlayback = value;
        }

        public function get GrabCancelled():Boolean
        {
            return (this.m_grabCancelled);
        }

        public function set GrabCancelled(value:Boolean):void
        {
            this.m_grabCancelled = value;
        }

        public function lockSizeStatus(value:Boolean):void
        {
            this.m_sizeStatusPermanent = value;
        }

        override public function resetCameraBox():void
        {
            m_sprite.cam_width = this.m_characterStats.CamWidth;
            m_sprite.cam_height = this.m_characterStats.CamHeight;
            m_sprite.cam_x_offset = this.m_characterStats.CamXOffset;
            m_sprite.cam_y_offset = this.m_characterStats.CamYOffset;
        }

        override public function attachHealthBox(name:String, thumbnail:String, seriesIcon:String, team_id:int=-1, costumeName:String=null, costumeNumber:int=-1):void
        {
            super.attachHealthBox(name, thumbnail, seriesIcon, team_id, costumeName, costumeNumber);
            this.m_lastLivesTextNum = -1;
            this.updateLivesDisplay();
            if (((STAGEDATA.GameRef.ScoreDisplay) && (m_healthBoxMC.score)))
            {
                m_healthBoxMC.score.text = ("" + this.m_matchResults.Score);
                m_healthBoxMC.score.visible = true;
                m_healthBoxMC.scoreLabel.visible = true;
            };
            if (m_healthBoxMC.icon.getChildByName("icon"))
            {
                if ((!((team_id > 0) && (!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode))))))
                {
                    if ((!(this.m_human)))
                    {
                        Utils.setTint(m_healthBoxMC.icon, 1, 1, 1, 1, 0, 0, 0, 0);
                    };
                };
            };
            if ((!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode))))
            {
                if (team_id < 0)
                {
                    if ((!(this.m_human)))
                    {
                        Utils.tryToGotoAndStop(m_healthBoxMC.damageBox, "team-1");
                        Utils.tryToGotoAndStop(m_healthBoxMC.damageStrike, "team-1");
                    };
                };
            };
            if (((!(this.m_characterStats.FinalSmashMeter)) && (!(this.m_transformedSpecial))))
            {
                m_healthBoxMC.fsmeter.visible = false;
            }
            else
            {
                m_healthBoxMC.fsmeter.visible = true;
            };
            if (this.m_finalSmashMeterCharge >= 1)
            {
                m_healthBoxMC.fsmeter.bar.gotoAndPlay("full");
                m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("on");
            }
            else
            {
                m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
            };
        }

        override public function getLinkageID():String
        {
            return (this.m_characterStats.LinkageID);
        }

        public function getForceTransformTime():int
        {
            return (this.m_forceTransformTime.MaxTime - this.m_forceTransformTime.CurrentTime);
        }

        public function jumpFullyReleased():Boolean
        {
            return (this.jumpIsPressed());
        }

        public function jumpIsPressed():Boolean
        {
            return (((this.m_pressedControls.JUMP) || (this.m_pressedControls.JUMP2)) || (this.m_pressedControls.JUMP3));
        }

        public function jumpIsHeld():Boolean
        {
            return (((this.m_heldControls.JUMP) || (this.m_heldControls.JUMP2)) || (this.m_heldControls.JUMP3));
        }

        public function shieldIsPressed():Boolean
        {
            return ((this.m_pressedControls.SHIELD) || (this.m_pressedControls.SHIELD2));
        }

        public function shieldIsHeld():Boolean
        {
            return (((this.m_heldControls.SHIELD) || (this.m_heldControls.SHIELD2)) ? true : false);
        }

        override public function recover(amount:int):Boolean
        {
            if (m_damage == 0)
            {
                return (false);
            };
            if (this.m_recoveryAmount <= 0)
            {
                this.m_healEffect.x = m_sprite.x;
                this.m_healEffect.y = m_sprite.y;
                toggleEffect(this.m_healEffect, true);
            };
            this.m_recoveryAmount = (this.m_recoveryAmount + amount);
            return (true);
        }

        private function checkRecovery():void
        {
            if (this.m_recoveryAmount > 0)
            {
                healDamage(1);
                Utils.advanceFrame(this.m_healEffect);
                this.m_recoveryAmount--;
                this.m_healEffect.x = m_sprite.x;
                this.m_healEffect.y = m_sprite.y;
                if (((m_baseStats.Stamina > 0) && (m_damage >= m_baseStats.Stamina)))
                {
                    m_damage = m_baseStats.Stamina;
                    this.m_recoveryAmount = 0;
                }
                else
                {
                    if (m_damage <= 0)
                    {
                        m_damage = 0;
                        this.m_recoveryAmount = 0;
                    };
                };
            };
            if (this.m_recoveryAmount <= 0)
            {
                toggleEffect(this.m_healEffect, false);
            };
        }

        private function checkOffScreenBubble():void
        {
            var boundsRect:Rectangle;
            var outsideRect:Rectangle;
            var bmpData:BitmapData;
            var flippedH:Boolean;
            var flippedV:Boolean;
            var mat:Matrix;
            var bmp:Bitmap;
            var skewMat:Matrix;
            var bubbleMC:MovieClip;
            if (((((this.m_outsideCameraBounds) && (HasStance)) && (this.m_offScreenIndicatorEnabled)) && (ModeFeatures.hasFeature(ModeFeatures.OFFSCREEN_BUBBLE, STAGEDATA.GameRef.GameMode))))
            {
                bubbleMC = this.m_pidHolderMC;
                bubbleMC.pid.visible = false;
                boundsRect = m_sprite.getBounds(m_sprite);
                outsideRect = m_sprite.getBounds(m_sprite.parent);
                bmpData = new BitmapData(Math.round((boundsRect.width + 0.5)), Math.round((boundsRect.height + 0.5)), true, 1127270);
                flippedH = false;
                flippedV = false;
                mat = new Matrix();
                mat.tx = -(boundsRect.x);
                mat.ty = -(boundsRect.y);
                flippedH = (!(m_facingForward));
                flippedV = false;
                bmpData.draw(m_sprite, mat, null, null, null, false);
                if (m_paletteSwapData)
                {
                    Utils.replacePaletteHelper(bmpData, m_paletteSwapData);
                };
                while (this.m_offScreenBubble.numChildren > 0)
                {
                    if ((this.m_offScreenBubble.getChildAt(0) is Bitmap))
                    {
                        (this.m_offScreenBubble.getChildAt(0) as Bitmap).bitmapData.dispose();
                        (this.m_offScreenBubble.getChildAt(0) as Bitmap).bitmapData = null;
                    };
                    this.m_offScreenBubble.removeChild(this.m_offScreenBubble.getChildAt(0));
                };
                bmp = new Bitmap(bmpData);
                skewMat = new Matrix();
                if (flippedH)
                {
                    skewMat.a = -1;
                };
                if (flippedV)
                {
                    skewMat.d = -1;
                };
                skewMat.tx = ((flippedH) ? -(boundsRect.x) : boundsRect.x);
                skewMat.ty = ((flippedV) ? -(boundsRect.y) : boundsRect.y);
                skewMat.scale(0.4, 0.4);
                skewMat.rotate(Utils.toRadians(Utils.forceBase360(((!(m_facingForward)) ? -(CurrentRotation) : -(CurrentRotation)))));
                bmp.transform.matrix = skewMat;
                bmp.y = (bmp.y - (m_height * 0.2));
                this.m_offScreenBubble.addChild(bmp);
                bubbleMC.offScreenBubble.visible = true;
                if ((!(this.m_offScreenBubble.parent)))
                {
                    bubbleMC.offScreenBubble.bmpImage.addChild(this.m_offScreenBubble);
                };
            }
            else
            {
                if (this.m_offScreenBubble.parent)
                {
                    bubbleMC = this.m_pidHolderMC;
                    bubbleMC.pid.visible = true;
                    bubbleMC.offScreenBubble.visible = false;
                    toggleEffect(this.m_offScreenBubble, false);
                }
                else
                {
                    this.m_pidHolderMC.pid.visible = true;
                };
            };
        }

        override protected function hideAllEffects():void
        {
            super.hideAllEffects();
            toggleEffect(this.m_burnSmoke, false);
            toggleEffect(this.m_darknessSmoke, false);
            toggleEffect(this.m_auraSmoke, false);
            toggleEffect(this.m_healEffect, false);
            toggleEffect(this.m_poisonEffect, false);
            toggleEffect(this.m_pitfallEffect, false);
            toggleEffect(this.m_warioWareIcon, false);
            toggleEffect(this.m_starmanInvincibility, false);
            toggleEffect(this.m_offScreenBubble, false);
            toggleEffect(this.m_chargeGlowHolderMC, false);
            toggleEffect(this.m_fsGlowHolderMC, false);
            toggleEffect(this.m_kirbyStarMC, false);
            this.m_burnSmokeTimer.finish();
            this.m_darknessSmokeTimer.finish();
            this.m_auraSmokeTimer.finish();
        }

        override protected function checkReflection(multiplier:Number=1):void
        {
            if (((STAGEDATA.ReflectionsRef) && (HasStance)))
            {
                if (((inState(CState.CAUGHT)) || (inState(CState.BARREL))))
                {
                    toggleEffect(m_reflectionEffect, false);
                }
                else
                {
                    super.checkReflection();
                };
            };
        }

        override protected function checkShadow(multiplier:Number=1):void
        {
            if ((((STAGEDATA.LightSource) && (STAGEDATA.ShadowsRef)) && (HasStance)))
            {
                if (((inState(CState.CAUGHT)) || (inState(CState.BARREL))))
                {
                    toggleEffect(m_shadowEffect, false);
                }
                else
                {
                    super.checkShadow(((this.m_sizeStatus == 0) ? multiplier : ((this.m_sizeStatus > 0) ? 2 : 0.5)));
                };
            };
        }

        public function increaseComboCount(atkObj:AttackDamage, id:Number, force:Boolean=false):void
        {
            if (((atkObj.HasEffect) || (force)))
            {
                if (this.m_comboID != id)
                {
                    this.m_comboCount = 0;
                    this.m_comboDamageTotal = 0;
                };
                this.m_comboID = id;
                this.m_comboCount++;
                this.m_comboTimer.reset();
                this.m_comboDamage = Utils.calculateChargeDamage(atkObj);
                this.m_comboDamageTotal = (this.m_comboDamageTotal + this.m_comboDamage);
            };
        }

        override public function dealDamage(damage:Number):void
        {
            if ((!(STAGEDATA.GameEnded)))
            {
                this.m_matchResults.DamageTaken = (this.m_matchResults.DamageTaken + damage);
            };
            if ((((this.m_characterStats.FinalSmashMeter) && (!(this.m_usingSpecialAttack))) && (!(this.m_transformedSpecial))))
            {
                this.FinalSmashMeterCharge = (this.FinalSmashMeterCharge + (damage / 200));
            };
            super.dealDamage(damage);
        }

        private function m_pushAwayOpponents():void
        {
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var opponent:Character;
            var i:int;
            while (i < STAGEDATA.Characters.length)
            {
                collisionRect = null;
                opponent = STAGEDATA.Characters[i];
                if (((((opponent === this) || (!(m_collision.ground))) || (!(opponent.CollisionObj.ground))) || (!(InteractiveSprite.hitTest(this, opponent, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster, null, true).length))))
                {
                }
                else
                {
                    if (InteractiveSprite.hitTest(this, opponent, HitBoxSprite.HIT, HitBoxSprite.HIT, reactionMaster, null, true).length > 0)
                    {
                        if ((((inState(CState.LEDGE_ROLL)) || (inState(CState.LEDGE_CLIMB))) || ((inState(CState.ATTACKING)) && (m_attack.Frame == "ledge_attack"))))
                        {
                            opponent.pushAway(m_facingForward);
                        }
                        else
                        {
                            if (m_sprite.x < opponent.X)
                            {
                                opponent.pushAway(true);
                            }
                            else
                            {
                                opponent.pushAway(false);
                            };
                        };
                    };
                };
                i++;
            };
        }

        public function m_pushAwayItems():void
        {
            var i:int;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var item:Item;
            var theirRect:Rectangle;
            var myRect:Rectangle;
            if (m_collision.ground)
            {
                i = 0;
                while (i < STAGEDATA.ItemsRef.ItemsInUse.length)
                {
                    collisionRect = null;
                    item = STAGEDATA.ItemsRef.ItemsInUse[i];
                    if ((((((!(item)) || (item.Dead)) || (item.PickedUp)) || (!(item.Ground))) || (!(InteractiveSprite.hitTest(this, item, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length))))
                    {
                    }
                    else
                    {
                        theirRect = item.BoundsRect;
                        myRect = BoundsRect;
                        theirRect.x = (theirRect.x + item.X);
                        theirRect.y = (theirRect.y + item.Y);
                        myRect.x = (myRect.x + m_sprite.x);
                        myRect.y = (myRect.y + m_sprite.y);
                        if (theirRect.intersects(myRect))
                        {
                            if (m_sprite.x > item.X)
                            {
                                item.pushAway(false);
                            }
                            else
                            {
                                if (m_sprite.x < item.X)
                                {
                                    item.pushAway(true);
                                }
                                else
                                {
                                    if (m_sprite.x == item.X)
                                    {
                                        if (item.ItemStats.PushCharacters)
                                        {
                                            this.pushAway(false);
                                        };
                                        item.pushAway(true);
                                    };
                                };
                            };
                        };
                    };
                    i++;
                };
            };
        }

        public function pushAway(toTheRight:Boolean, speed:int=1):void
        {
            if (((((((((((((((((((((((((((((((((m_collision.ground) && (!(inState(CState.LEDGE_HANG)))) && (!(this.m_standby))) && (!(inState(CState.INJURED)))) && (!(inState(CState.CROUCH)))) && (!(inState(CState.FLYING)))) && (!(inState(CState.ATTACKING)))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.WALL_CLING)))) && (!(inState(CState.SLEEP)))) && (!(this.m_transformingSpecial))) && (!(this.m_usingSpecialAttack))) && (!(inState(CState.SHIELDING)))) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.SIDESTEP_DODGE)))) && (!(inState(CState.TAUNT)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(this.isLandingOrSkiddingOrChambering()))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.TECH_GROUND)))) && (!(inState(CState.TECH_ROLL)))) && (!(inState(CState.LEDGE_CLIMB)))) && (!(inState(CState.GRABBING)))) && (!(inState(CState.KIRBY_STAR)))) && (m_xSpeed == 0)) && (!(this.m_charIsFull))) && (!(isIntangible()))))
            {
                if (((toTheRight) && (!(m_collision.rightSide))))
                {
                    this.m_attemptToMove(speed, 0);
                }
                else
                {
                    if (((!(toTheRight)) && (!(m_collision.leftSide))))
                    {
                        this.m_attemptToMove(-(speed), 0);
                    };
                };
            };
        }

        public function pushAwayFromWalls():void
        {
            if ((((!(inState(CState.FLYING))) && (!(m_collision.ground))) && (testTerrainWithCoord((m_sprite.x - ((m_width / 2) * m_sizeRatio)), (m_sprite.y - (m_height * m_sizeRatio))))))
            {
                this.m_attemptToMove((6 - (m_xSpeed / 2)), 0);
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                    "caller":this.APIInstance.instance,
                    "left":(m_xSpeed < 0),
                    "right":(m_xSpeed > 0),
                    "top":false
                }));
            };
            if ((((!(inState(CState.FLYING))) && (!(m_collision.ground))) && (testTerrainWithCoord((m_sprite.x + ((m_width / 2) * m_sizeRatio)), (m_sprite.y - (m_height * m_sizeRatio))))))
            {
                this.m_attemptToMove((-6 - (m_xSpeed / 2)), 0);
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                    "caller":this.APIInstance.instance,
                    "left":(m_xSpeed < 0),
                    "right":(m_xSpeed > 0),
                    "top":false
                }));
            };
        }

        public function getCharacterStat(statName:String):*
        {
            return (this.m_characterStats.getVar(statName));
        }

        public function getPlayerSetting(setting:String):*
        {
            return (this.m_playerSettings.getVar(setting));
        }

        public function updateCharacterStats(statValues:Object):void
        {
            this.m_characterStats.importData(statValues);
            if (statValues)
            {
                if (statValues.linkage_id)
                {
                    this.setStats(this.m_characterStats);
                }
                else
                {
                    if ((((statValues.seriesIcon) || (statValues.displayName)) || (statValues.thumbnail)))
                    {
                        this.redrawHealthBox();
                    };
                };
                this.syncStats();
            };
        }

        public function updatePlayerSettings(settings:Object):void
        {
            var i:*;
            var whitelist:Object = {
                "level":true,
                "damageRatio":true,
                "attackRatio":true,
                "x_start":true,
                "y_start":true,
                "x_respawn":true,
                "y_respawn":true,
                "unlimitedFinal":true,
                "finalSmashMeter":true,
                "startDamage":true
            };
            var deletion:Array = [];
            for (i in settings)
            {
                if ((!(whitelist[i])))
                {
                    deletion.push(i);
                };
            };
            while (deletion.length > 0)
            {
                delete settings[deletion[0]];
                deletion.splice(0, 1);
            };
            this.m_playerSettings.importSettings(settings);
            if (((settings.level) && (this.CPU)))
            {
                this.CPU = new AI(this.m_playerSettings.level, this, STAGEDATA);
            };
            this.m_characterStats.importData({
                "attackRatio":this.m_playerSettings.attackRatio,
                "damageRatio":this.m_playerSettings.damageRatio,
                "unlimitedFinal":this.m_playerSettings.unlimitedFinal,
                "startDamage":this.m_playerSettings.startDamage,
                "finalSmashMeter":this.m_playerSettings.finalSmashMeter
            });
        }

        public function getActiveProjectiles(ignorePID:int, ignoreTeamID:int):Vector.<Projectile>
        {
            var projectilesArr:Vector.<Projectile> = new Vector.<Projectile>();
            var i:int;
            while (i < this.m_projectile.length)
            {
                if ((((!(this.m_projectile[i] == null)) && (!(this.m_projectile[i].Dead))) && (((!(this.m_projectile[i].ID == ignorePID)) && (!(((ignoreTeamID > 0) && (this.m_projectile[i].TeamID > 0)) && (this.m_projectile[i].TeamID == ignoreTeamID)))) || (this.m_projectile[i].WasReversed))))
                {
                    projectilesArr.push(this.m_projectile[i]);
                };
                i++;
            };
            return (projectilesArr);
        }

        public function getCurrentProjectile():Projectile
        {
            if (((this.m_lastProjectile >= 0) && (this.m_lastProjectile < this.m_projectile.length)))
            {
                return (this.m_projectile[this.m_lastProjectile]);
            };
            return (null);
        }

        public function getCurrentProjectileAPI():*
        {
            if ((((this.m_lastProjectile >= 0) && (this.m_lastProjectile < this.m_projectile.length)) && (this.m_projectile[this.m_lastProjectile])))
            {
                return (this.m_projectile[this.m_lastProjectile].APIInstance.instance);
            };
            return (null);
        }

        public function getProjectile(num:Number):Projectile
        {
            if (((num >= 0) && (num < this.m_projectile.length)))
            {
                return (this.m_projectile[num]);
            };
            return (null);
        }

        override public function getProjectiles():Array
        {
            var arr:Array = new Array();
            var i:int;
            while (i < this.m_projectile.length)
            {
                if (((this.m_projectile[i]) && (!(this.m_projectile[i].Dead))))
                {
                    arr.push(this.m_projectile[i]);
                };
                i++;
            };
            return (arr);
        }

        private function getProjectileLimit(linkID:String):Number
        {
            var total:Number = 0;
            var i:int;
            while (i < this.m_projectile.length)
            {
                if ((((!(this.m_projectile[i] == null)) && (!(this.m_projectile[i].inState(PState.DEAD)))) && ((this.m_projectile[i].LinkageID == linkID) || ((this.m_projectile[i].getProjectileStat("statsName")) && (this.m_projectile[i].getProjectileStat("statsName") == linkID)))))
                {
                    total++;
                };
                i++;
            };
            return (total);
        }

        protected function updateLivesDisplay():void
        {
            var i:int;
            var mc:MovieClip;
            var icon:MovieClip;
            if (((((m_healthBoxMC) && (!(inState(CState.DEAD)))) && (this.m_usingLives)) && (!(this.m_lastLivesTextNum === this.m_lives))))
            {
                m_healthBoxMC.lives.text = ((this.m_lives > 0) ? ("x" + this.m_lives) : "");
                this.m_lastLivesTextNum = this.m_lives;
                if (((Config.enable_new_stock_counter) && (m_healthBoxMC.stockiconsingle)))
                {
                    i = 0;
                    while (i < this.MAX_STOCK_ICONS)
                    {
                        icon = (m_healthBoxMC.getChildByName(("stockicon" + i)) as MovieClip);
                        if (((icon) && (icon.numChildren > 0)))
                        {
                            icon.removeChildAt(0);
                        };
                        i++;
                    };
                    if (m_healthBoxMC.stockiconsingle.numChildren > 0)
                    {
                        m_healthBoxMC.stockiconsingle.removeChildAt(0);
                    };
                    if (this.m_lives <= this.MAX_STOCK_ICONS)
                    {
                        i = 0;
                        while (i < this.m_lives)
                        {
                            icon = (m_healthBoxMC.getChildByName(("stockicon" + i)) as MovieClip);
                            if (icon)
                            {
                                Utils.setBrightness(icon, (-15 * (this.m_lives - (i + 1))));
                                mc = ResourceManager.getLibraryMC((this.m_characterStats.StatsName + "_stock"));
                                if (mc)
                                {
                                    icon.addChild(mc);
                                    applyPalette(mc);
                                    Utils.replacePalette(mc, ((m_paletteSwapData) || (Utils.EMPTY_PALETTE_SWAP)), 2, false, true);
                                }
                                else
                                {
                                    m_healthBoxMC.lives.visible = true;
                                    m_healthBoxMC.lives.x = 44;
                                    m_healthBoxMC.lives.y = -18.6;
                                    return;
                                };
                            };
                            i++;
                        };
                        m_healthBoxMC.lives.visible = false;
                    }
                    else
                    {
                        m_healthBoxMC.lives.visible = true;
                        icon = (m_healthBoxMC.getChildByName("stockiconsingle") as MovieClip);
                        mc = ResourceManager.getLibraryMC((this.m_characterStats.StatsName + "_stock"));
                        if (mc)
                        {
                            icon.addChild(mc);
                            applyPalette(mc);
                            Utils.replacePalette(mc, m_paletteSwapData, 2, false, true);
                        }
                        else
                        {
                            m_healthBoxMC.lives.x = 44;
                            m_healthBoxMC.lives.y = -18.6;
                            return;
                        };
                    };
                }
                else
                {
                    m_healthBoxMC.lives.x = 44;
                    m_healthBoxMC.lives.y = -18.6;
                };
            };
        }

        private function applySpecialModeEffects():void
        {
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.MINI))
            {
                this.setSizeStatus(-1);
                this.m_sizeStatusPermanent = true;
            }
            else
            {
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.MEGA))
                {
                    this.setSizeStatus(1);
                    this.m_sizeStatusPermanent = true;
                };
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.METAL))
            {
                this.setMetalStatus(true);
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.LIGHT))
            {
                m_gravity = (m_gravity / 2);
                m_max_ySpeed = (m_max_ySpeed / 2);
            }
            else
            {
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.HEAVY))
                {
                    m_gravity = (m_gravity * 2);
                    m_max_ySpeed = (m_max_ySpeed * 2);
                };
            };
        }

        public function forceOnGround():void
        {
            this.m_pressedControls.DOWN = false;
            var tmpDistance:Number = 0;
            while (((!(m_currentPlatform = STAGEDATA.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1)))) && (tmpDistance < 400)))
            {
                m_sprite.y++;
                tmpDistance++;
            };
            if ((!(m_currentPlatform)))
            {
                trace("what happened?");
                m_sprite.y = this.m_playerSettings.y_start;
            }
            else
            {
                m_collision.ground = true;
                attachToGround();
            };
        }

        private function m_checkInvincible():void
        {
            if (((this.isInvincible()) || (isIntangible())))
            {
                this.m_blinkTimer++;
                setBrightness(this.m_invincibleBrightness);
                this.m_invincibleBrightness = (this.m_invincibleBrightness + ((this.m_invincibleUp) ? 3 : -3));
                this.m_invincibleUp = (((this.m_invincibleUp) && (this.m_invincibleBrightness >= 50)) ? false : (((!(this.m_invincibleUp)) && (this.m_invincibleBrightness <= 15)) ? true : this.m_invincibleUp));
            };
        }

        private function m_checkStun():void
        {
            if (inState(CState.STUNNED))
            {
                this.m_stunCancelTimer.tick();
                if (((!(m_collision.ground)) && (this.m_stunCancelTimer.IsComplete)))
                {
                    this.setState(CState.TUMBLE_FALL);
                }
                else
                {
                    if (m_collision.ground)
                    {
                        this.m_stunCancelTimer.finish();
                        this.m_stunTimer--;
                        if (this.m_stunTimer <= 0)
                        {
                            this.m_stunTimer = 0;
                            this.setState(CState.IDLE);
                        };
                    };
                };
            };
        }

        private function m_checkDizzy():void
        {
            var loss:int;
            if (inState(CState.DIZZY))
            {
                if (this.m_strengthDizzyTimer > 0)
                {
                    // An airborne victim falls normally, then serves the full dizzy duration.
                    // Neither airborne recovery nor mashing can cancel strength dizziness.
                    if (m_collision.ground)
                    {
                        this.m_strengthDizzyTimer--;
                        this.m_dizzyTimer = this.m_strengthDizzyTimer;
                        if (this.m_strengthDizzyTimer <= 0)
                        {
                            this.setState(CState.IDLE);
                        };
                    };
                    return;
                };
                this.m_stunCancelTimer.tick();
                if ((((!(m_collision.ground)) && (this.m_stunCancelTimer.IsComplete)) && (!(this.m_dizzyShield))))
                {
                    this.setState(CState.TUMBLE_FALL);
                }
                else
                {
                    if (m_collision.ground)
                    {
                        this.m_stunCancelTimer.finish();
                        this.m_dizzyTimer--;
                        if ((!(this.m_dizzyShield)))
                        {
                            loss = this.Struggle(3);
                            this.m_dizzyTimer = (this.m_dizzyTimer - ((loss > 0) ? loss : 1));
                        };
                        if (this.m_dizzyTimer <= 0)
                        {
                            this.m_dizzyTimer = 0;
                            this.setState(CState.IDLE);
                        };
                    };
                };
            };
        }

        private function m_checkPitfall():void
        {
            var loss:int;
            if (inState(CState.PITFALL))
            {
                loss = this.Struggle(3);
                this.m_pitfallTimer = (this.m_pitfallTimer - ((loss > 0) ? loss : 1));
                this.m_pitfallEffect.x = m_sprite.x;
                this.m_pitfallEffect.y = m_sprite.y;
                if (this.m_pitfallTimer <= 0)
                {
                    this.pitFallRelease();
                    toggleEffect(this.m_pitfallEffect, false);
                };
            };
        }

        private function pitFallRelease():void
        {
            this.m_pitfallTimer = 0;
            this.unnattachFromGround();
            m_ySpeed = (-(this.m_characterStats.JumpSpeed) / 2);
            this.setState(CState.IDLE);
        }

        public function freeze(status:Boolean, amount:int=-1):void
        {
            if (inState(CState.BARREL))
            {
                return;
            };
            if (status)
            {
                if (this.m_grabbed.length > 0)
                {
                    this.grabReleaseOpponent();
                };
                if (((inState(CState.CAUGHT)) && (this.m_grabberID >= 0)))
                {
                    STAGEDATA.getCharacterByUID(this.m_grabberID).setState(CState.IDLE);
                };
                this.setState(CState.FROZEN);
                toggleEffect(this.m_freezeMC, true);
                this.m_freezeMC.x = m_sprite.x;
                this.m_freezeMC.y = m_sprite.y;
                this.m_freezeMC.rotation = m_sprite.rotation;
                this.m_freezeMC.scaleX = m_sprite.scaleX;
                this.m_freezeMC.scaleY = m_sprite.scaleY;
                this.m_frozenTimer = amount;
                this.resetRotation();
                this.killAllSpeeds(false, true);
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            }
            else
            {
                if ((!(status)))
                {
                    this.m_frozenTimer = 0;
                    this.setState(CState.INJURED);
                    toggleEffect(this.m_freezeMC, false);
                    this.unnattachFromGround();
                    m_yKnockback = -10;
                    resetKnockbackDecay();
                    this.m_hitLag = this.calculateHitLag(10, -1);
                };
            };
        }

        private function m_checkFrozen():void
        {
            var moreFrames:int;
            if (inState(CState.FROZEN))
            {
                if ((!(m_collision.ground)))
                {
                    m_sprite.rotation = (m_sprite.rotation + ((m_facingForward) ? -2 : 2));
                };
                this.m_frozenTimer--;
                moreFrames = this.Struggle();
                this.m_frozenTimer = (this.m_frozenTimer - moreFrames);
                if (moreFrames > 0)
                {
                    m_sprite.stance.x = (m_sprite.stance.x + ((Utils.random() > 0.5) ? -1 : 1));
                    m_sprite.stance.y = (m_sprite.stance.y + ((Utils.random() > 0.5) ? -1 : 1));
                };
                if (this.m_frozenTimer <= 0)
                {
                    this.freeze(false);
                    attachEffect("freeze_break");
                };
            };
        }

        private function m_checkSleeping():void
        {
            var loss:int;
            if (inState(CState.SLEEP))
            {
                this.m_stunCancelTimer.tick();
                if (((!(m_collision.ground)) && (this.m_stunCancelTimer.IsComplete)))
                {
                    this.setState(CState.TUMBLE_FALL);
                }
                else
                {
                    if (m_collision.ground)
                    {
                        this.m_stunCancelTimer.finish();
                        this.m_sleepingTimer--;
                        loss = this.Struggle(3);
                        this.m_sleepingTimer = (this.m_sleepingTimer - ((loss > 0) ? loss : 1));
                        if (this.m_sleepingTimer <= 0)
                        {
                            this.m_sleepingTimer = 0;
                            this.setState(CState.IDLE);
                        };
                    };
                };
            };
        }

        public function egg(status:Boolean, amount:int=-1):void
        {
            if (inState(CState.BARREL))
            {
                return;
            };
            if (status)
            {
                if (this.m_grabbed.length > 0)
                {
                    this.grabReleaseOpponent();
                };
                if (((inState(CState.CAUGHT)) && (this.m_grabberID >= 0)))
                {
                    STAGEDATA.getCharacterByUID(this.m_grabberID).setState(CState.IDLE);
                };
                this.setState(CState.EGG);
                this.m_yoshiEggMC.x = m_sprite.x;
                this.m_yoshiEggMC.y = m_sprite.y;
                this.m_yoshiEggMC.stance.gotoAndStop("idle");
                toggleEffect(this.m_yoshiEggMC, true);
                if (amount > -1)
                {
                    this.m_eggTimer = amount;
                }
                else
                {
                    this.m_eggTimer = (Math.round((90 + Math.floor((m_damage / 2.5)))) / 2);
                    if (this.m_eggTimer > 210)
                    {
                        this.m_eggTimer = 210;
                    };
                };
                this.resetRotation();
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                this.unnattachFromGround();
            }
            else
            {
                if ((!(status)))
                {
                    this.setVisibility(true);
                    toggleEffect(this.m_yoshiEggMC, false);
                    this.m_eggTimer = 0;
                    this.unnattachFromGround();
                    m_ySpeed = (-(this.m_characterStats.JumpSpeed) / 2);
                    this.setState(CState.IDLE);
                };
            };
        }

        private function m_checkEgg():void
        {
            var struggleTotal:int;
            if (inState(CState.EGG))
            {
                this.setVisibility(false);
                this.m_eggTimer--;
                struggleTotal = this.Struggle();
                this.m_eggTimer = (this.m_eggTimer - struggleTotal);
                if (((this.m_eggTimer < 12) && (!(this.m_yoshiEggMC.stance.currentLabel === "break"))))
                {
                    this.m_yoshiEggMC.stance.gotoAndStop("break");
                }
                else
                {
                    if ((((struggleTotal > 0) && (!(this.m_yoshiEggMC.stance.currentLabel === "mash"))) && (!(this.m_yoshiEggMC.stance.currentLabel === "break"))))
                    {
                        this.m_yoshiEggMC.stance.gotoAndStop("mash");
                    };
                };
                if (this.m_yoshiEggMC.stance.currentLabel !== "break")
                {
                    this.m_yoshiEggMC.gotoAndPlay(Math.min((this.m_yoshiEggMC.stance.currentFrame + struggleTotal), this.m_yoshiEggMC.stance.totalFrames));
                };
                if (this.m_eggTimer <= 0)
                {
                    this.egg(false);
                    attachEffect("yoshi_egg_break");
                };
            };
        }

        override public function resetRotation():void
        {
            if ((!(inState(CState.FROZEN))))
            {
                super.resetRotation();
                this.updateItemHolding();
            };
        }

        override public function setRotation(value:Number):void
        {
            super.setRotation(value);
            this.updateItemHolding();
        }

        public function getTetherCount():int
        {
            return (this.m_tetherCount);
        }

        private function resetSpeedLevel():void
        {
            this.m_runningSpeedLevel = false;
            this.m_speedTimer = 0;
        }

        private function resetBufferedCStick():void
        {
            this.m_c_buffered_down = false;
            this.m_c_buffered_left = false;
            this.m_c_buffered_right = false;
        }

        private function alternateBlink():void
        {
            if (this.m_blinkNumber == 1)
            {
                setBrightness(30);
                this.m_blinkNumber = 2;
                this.m_blinkTimer = 0;
            }
            else
            {
                setBrightness(50);
                this.m_blinkNumber = 1;
                this.m_blinkTimer = 0;
            };
        }

        override public function setVisibility(value:Boolean):void
        {
            super.setVisibility(value);
            this.m_burnSmoke.visible = value;
            this.m_darknessSmoke.visible = value;
            this.m_auraSmoke.visible = value;
            this.m_poisonEffect.visible = value;
            this.m_healEffect.visible = value;
            if (this.m_warioWareIcon)
            {
                this.m_warioWareIcon.visible = value;
            };
            this.m_starmanInvincibility.visible = value;
            this.m_hatMC.visible = value;
            if (this.m_item)
            {
                this.m_item.setVisibility(value);
            };
            if (this.m_fsGlowHolderMC)
            {
                this.m_fsGlowHolderMC.visible = value;
            };
            if (this.m_chargeGlowHolderMC)
            {
                this.m_chargeGlowHolderMC.visible = value;
            };
        }

        override public function setDamage(amount:Number):void
        {
            var oldDamage:Number = m_damage;
            if (m_baseStats.Stamina > 0)
            {
                if ((((m_damage > 0) && (amount <= 0)) && ((this.isGrabbedByFinalSmash()) || (this.UsingFinalSmash))))
                {
                    amount = 0.1;
                }
                else
                {
                    if (amount >= m_baseStats.Stamina)
                    {
                        m_damage = m_baseStats.Stamina;
                    };
                };
            };
            super.setDamage(amount);
            if ((((m_baseStats.Stamina <= 0) && (m_damage > this.m_matchResults.PeakDamage)) && (!(STAGEDATA.GameEnded))))
            {
                this.m_matchResults.PeakDamage = m_damage;
            };
        }

        public function reset():void
        {
            var targets1:Vector.<MovieClip> = new Vector.<MovieClip>();
            targets1.push(m_sprite);
            STAGEDATA.CamRef.deleteTargets(targets1);
            this.setVisibility(false);
            if ((!(this.m_sizeStatusPermanent)))
            {
                m_sizeRatio = this.m_originalSizeRatio;
            };
            if (this.m_sizeStatus != 0)
            {
                this.setSizeStatus(0);
            };
            if (((this.m_isMetal) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.METAL)))))
            {
                this.setMetalStatus(false);
            };
            this.hideAllEffects();
            this.m_chargeGlowHolderMC = null;
            this.m_burnSmokeTimer.finish();
            this.m_darknessSmokeTimer.finish();
            this.m_auraSmokeTimer.finish();
            this.m_starmanInvincibilityTimer.finish();
            this.m_burnSmokeTimer.finish();
            this.m_darknessSmokeTimer.finish();
            this.m_auraSmokeTimer.finish();
            this.m_wallStickTime.MaxTime = this.m_characterStats.WallStick;
            this.m_wallClingDelay;
            m_attackData.resetDisabledAttacks();
            this.turnOffInvincibility();
            this.stopActionShot();
            this.releaseOpponent();
            this.m_crowdAwe = false;
            this.m_lastLedge = null;
            this.m_revivalTimer = 150;
            this.m_respawnDelay.reset();
            this.resetStaleMoves();
            this.m_waveLand = false;
            this.m_waveDashPenalty = 0;
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.m_respawnDelay.finish();
            };
            this.m_recoveryAmount = 0;
            if (m_healthBoxMC)
            {
                m_healthBoxMC.damageMC_holder.visible = false;
                m_healthBoxMC.percent_mc.damage.visible = false;
            };
            this.m_justReleased = false;
            this.m_jumpStartup.reset();
            this.setDamage((((STAGEDATA.GameRef.GameMode == Mode.TRAINING) && (m_player_id > 1)) ? GameController.hud.CpuDamage : ((this.m_characterStats.Stamina > 0) ? this.m_characterStats.Stamina : this.m_characterStats.StartDamage)));
            this.m_charIsFull = false;
            this.setState(CState.IDLE);
            this.m_shieldPower = 100;
            this.m_poisonIncreaseTime.reset();
            this.m_poisonIncrease = 0;
            if (((this.m_usingSpecialAttack) || (this.m_transformedSpecial)))
            {
                if (this.m_characterStats.FinalSmashMeter)
                {
                    this.FinalSmashMeterCharge = 0;
                };
                this.killFSCutscene();
                if (this.m_transformedSpecial)
                {
                    STAGEDATA.ItemsRef.SmashBallReady.CurrentTime = STAGEDATA.ItemsRef.SmashBallReady.MaxTime;
                };
                STAGEDATA.brightenCamera();
            }
            else
            {
                if (this.m_characterStats.FinalSmashMeter)
                {
                    if (this.m_item2)
                    {
                        this.FinalSmashMeterCharge = 0;
                    }
                    else
                    {
                        if (((m_player_id > 0) && (this.m_finalSmashMeterReady)))
                        {
                            STAGEDATA.updateRanks();
                            if (((this.m_matchResults.Rank > 1) || (STAGEDATA.GameRef.GameMode == Mode.TRAINING)))
                            {
                                this.FinalSmashMeterCharge = (this.FinalSmashMeterCharge * 0.9);
                            }
                            else
                            {
                                this.FinalSmashMeterCharge = (this.FinalSmashMeterCharge * 0.6);
                            };
                        }
                        else
                        {
                            if (this.m_finalSmashMeterReady)
                            {
                                this.FinalSmashMeterCharge = (this.FinalSmashMeterCharge * 0.6);
                            };
                        };
                    };
                };
            };
            this.m_usingSpecialAttack = false;
            m_facingForward = true;
            this.m_glideReady = true;
            var tempX:Number = 0;
            var tempY:Number = 0;
            var tmpMC:MovieClip;
            var tmpPower:String;
            var self:Vector.<MovieClip>;
            if (this.m_transformedSpecial)
            {
                this.replaceCharacter(((this.m_characterStats.DeathSwitchID != null) ? this.m_characterStats.DeathSwitchID : this.m_characterStats.NormalStatsID), "fall");
                if (((m_healthBoxMC) && (!(this.m_characterStats.FinalSmashMeter))))
                {
                    m_healthBoxMC.fsmeter.visible = false;
                };
            }
            else
            {
                if (this.m_characterStats.DeathSwitchID != null)
                {
                    this.replaceCharacter(this.m_characterStats.DeathSwitchID, "fall");
                    if (((m_healthBoxMC) && (!(this.m_characterStats.FinalSmashMeter))))
                    {
                        m_healthBoxMC.fsmeter.visible = false;
                    };
                };
            };
            m_attackData.resetDisabledAttacks();
            m_faceRight();
            this.m_currentPower = null;
            this.m_transformingSpecial = false;
            this.m_transformedSpecial = false;
            this.m_crouchFrame = -1;
            this.m_deactivateShield();
            this.m_ledge = null;
            m_collision.ground = false;
            m_collision.lbound_lower = false;
            m_collision.rbound_lower = false;
            m_collision.lbound_upper = false;
            m_collision.rbound_upper = false;
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            this.resetRotation();
            this.resetChargedAttacks();
            m_attack.Rocket = false;
            m_attackData.resetCharges();
            this.removeChargeGlow();
            this.killAllSpeeds();
            this.m_jumpCount = 0;
            this.m_airDodgeCount = 0;
            this.m_canHover = true;
            this.m_midAirJumpConstantTime.finish();
            this.m_comboCount = 0;
            if (this.m_item != null)
            {
                STAGEDATA.ItemsRef.killItem(this.m_item.Slot);
                this.m_item = null;
            };
            if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
            {
                STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
            };
            if (this.m_item2 != null)
            {
                this.m_item2.destroy();
                this.m_item2 = null;
            };
            if ((!(this.m_human)))
            {
                this.CPU.resetControlOverrides();
            };
            m_currentPlatform = null;
        }

        public function turnOffInvincibility():void
        {
            m_invincible = false;
            m_intangible = false;
            setBrightness(0);
        }

        public function setHumanControl(setHuman:Boolean, level:Number):void
        {
            this.m_playerSettings.level = level;
            if (setHuman)
            {
                this.CPU = null;
                this.m_human = true;
            }
            else
            {
                this.CPU = new AI(this.m_playerSettings.level, this, STAGEDATA);
                this.CPU.refreshRecoveryAttackList();
                this.m_human = false;
            };
        }

        private function compactControlsBuffer():void
        {
            var ignoreMap:int = ((ControlsObject.TAP_JUMP | ControlsObject.DT_DASH) | ControlsObject.AUTO_DASH);
            var i:int;
            while (i < this.m_pressedControlsBuffer.length)
            {
                if (ControlsObject.getControls(this.m_pressedControlsBuffer[i], ignoreMap) === 0)
                {
                    this.m_pressedControlsBuffer.splice(i, 1);
                    this.m_heldControlsBuffer.splice(i, 1);
                    i--;
                };
                i++;
            };
        }

        private function clearControlsBuffer():void
        {
            this.m_pressedControlsBuffer.splice(0);
            this.m_heldControlsBuffer.splice(0);
        }

        private function controlsBufferContains(controls:int):Boolean
        {
            var tempObj:Object;
            var i:int;
            while (i < this.m_pressedControlsBuffer.length)
            {
                if ((this.m_pressedControlsBuffer[i] & controls) > 0)
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        private function isBufferableState(state:uint):Boolean
        {
            return (((((((((((((((((((((state === CState.ATTACKING) && (!(m_attack.IASA))) || (state === CState.LAND)) || (state === CState.JUMP_CHAMBER)) || (state === CState.LEDGE_ROLL)) || (state === CState.LEDGE_CLIMB)) || (state === CState.TECH_GROUND)) || (state === CState.TECH_ROLL)) || (state === CState.ROLL)) || (state === CState.DODGE_ROLL)) || (state === CState.AIR_DODGE)) || (state === CState.CRASH_GETUP)) || (state === CState.SHIELD_DROP)) || (state === CState.HEAVY_LAND)) || (state === CState.SKID)) || (state === CState.ITEM_TOSS)) || (state === CState.INJURED)) || (state === CState.FLYING)) || ((state === CState.SHIELDING) && (!(this.m_shieldDelayTimer.IsComplete)))) || ((state === CState.GRABBING) && (!(this.m_grabbed.length)))) || ((state === CState.LEDGE_HANG) && (this.m_ledgeHangTimer.CurrentTime <= 4)));
        }

        private function updateControlsBuffer():void
        {
            var grabPrecedence:Boolean;
            var controlsObj:ControlsObject = ((this.m_human) ? this.m_key.getControlsObject() : this.CPU.ControlsObj);
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                controlsObj.SHIELD = false;
                controlsObj.SHIELD2 = false;
                controlsObj.GRAB = false;
                controlsObj.BUTTON2 = ((((((controlsObj.BUTTON2) || (controlsObj.BUTTON1)) || (controlsObj.C_UP)) || (controlsObj.C_DOWN)) || (controlsObj.C_LEFT)) || (controlsObj.C_RIGHT));
                controlsObj.C_UP = false;
                controlsObj.C_DOWN = false;
                controlsObj.C_LEFT = false;
                controlsObj.C_RIGHT = false;
            };
            var ignoreMap:int = ((ControlsObject.TAP_JUMP | ControlsObject.DT_DASH) | ControlsObject.AUTO_DASH);
            this.m_heldControls.controls = controlsObj.controls;
            var currentBits:int = ControlsObject.getControls(this.m_heldControls.controls, ignoreMap);
            if (this.isBufferableState(m_state))
            {
                if (((!(m_collision.ground)) && ((inState(CState.INJURED)) || (inState(CState.FLYING)))))
                {
                    ignoreMap = (ignoreMap | ControlsObject.BUTTON1);
                    ignoreMap = (ignoreMap | ControlsObject.BUTTON2);
                    ignoreMap = (ignoreMap | ControlsObject.GRAB);
                };
                if (((inState(CState.SHIELDING)) && (!(this.m_shieldDelayTimer.IsComplete))))
                {
                    ignoreMap = (ignoreMap | ControlsObject.LEFT);
                    ignoreMap = (ignoreMap | ControlsObject.RIGHT);
                    ignoreMap = (ignoreMap | ControlsObject.DOWN);
                    if (this.m_lastHitStun > 5)
                    {
                        grabPrecedence = this.controlsBufferContains(ControlsObject.GRAB);
                        this.pruneControlsBuffer(((ControlsObject.GRAB | ((!(grabPrecedence)) ? ControlsObject.JUMP : 0)) | ((!(grabPrecedence)) ? ControlsObject.JUMP : 0)));
                        if (grabPrecedence)
                        {
                            ignoreMap = (ignoreMap | ControlsObject.JUMP);
                            ignoreMap = (ignoreMap | ControlsObject.JUMP2);
                            ignoreMap = (ignoreMap | ControlsObject.JUMP3);
                        };
                    };
                };
            }
            else
            {
                this.compactControlsBuffer();
            };
            var bits:int = ControlsObject.getControls(controlsObj.controls, ignoreMap);
            var directionalKeys:int = ((((ControlsObject.UP & currentBits) | (ControlsObject.DOWN & currentBits)) | (ControlsObject.LEFT & currentBits)) | (ControlsObject.RIGHT & currentBits));
            var bufferLimit:int = 5;
            if (STAGEDATA.OnlineMode)
            {
                bufferLimit = (bufferLimit - MultiplayerManager.INPUT_BUFFER);
            }
            else
            {
                if (STAGEDATA.ReplayMode)
                {
                    bufferLimit = (bufferLimit - STAGEDATA.GameRef.LevelData.inputBuffer);
                };
            };
            if (this.m_pressedControlsBuffer.length > bufferLimit)
            {
                this.m_pressedControlsBuffer.pop();
                this.m_heldControlsBuffer.pop();
            };
            if (this.isBufferableState(m_state))
            {
                if ((!(((currentBits & (ControlsObject.BUTTON1 | ControlsObject.BUTTON2)) > 0) || ((directionalKeys & bits) > 0))))
                {
                    directionalKeys = 0;
                };
            };
            bits = (bits | directionalKeys);
            var noHeldKeys:int = (this.m_heldKeyHistory.controls ^ bits);
            var depressedKeysMask:int = (noHeldKeys & this.m_heldKeyHistory.controls);
            bits = (noHeldKeys ^ depressedKeysMask);
            this.m_heldControls.controls = (((currentBits | ((controlsObj.TAP_JUMP) ? ControlsObject.TAP_JUMP : 0)) | ((controlsObj.AUTO_DASH) ? ControlsObject.AUTO_DASH : 0)) | ((controlsObj.DT_DASH) ? ControlsObject.DT_DASH : 0));
            this.m_pressedControls.controls = (((bits | ((controlsObj.TAP_JUMP) ? ControlsObject.TAP_JUMP : 0)) | ((controlsObj.AUTO_DASH) ? ControlsObject.AUTO_DASH : 0)) | ((controlsObj.DT_DASH) ? ControlsObject.DT_DASH : 0));
            this.m_pressedControlsBuffer.unshift(bits);
            this.m_heldControlsBuffer.unshift(this.m_heldControls.controls);
            this.m_heldKeyHistory.controls = this.m_heldControls.controls;
            if (m_player_id === 1)
            {
            };
            if (this.m_pressedControlsBuffer.length !== this.m_heldControlsBuffer.length)
            {
                trace("Warning: Buffers are out of sync!!");
            };
        }

        private function pruneControlsBuffer(ignoreMap:int=0):void
        {
            var tempObj:Object;
            ignoreMap = (ignoreMap | ControlsObject.TAP_JUMP);
            ignoreMap = (ignoreMap | ControlsObject.DT_DASH);
            ignoreMap = (ignoreMap | ControlsObject.AUTO_DASH);
            var i:int;
            while (i < this.m_pressedControlsBuffer.length)
            {
                this.m_pressedControlsBuffer[i] = ControlsObject.getControls(this.m_pressedControlsBuffer[i], ignoreMap);
                this.m_heldControlsBuffer[i] = ControlsObject.getControls(this.m_heldControlsBuffer[i], ignoreMap);
                i++;
            };
        }

        private function validateControlsBuffer():void
        {
            var tempObj:Object;
            var tmpBits:int;
            var ignoreMap:int;
            ignoreMap = (ignoreMap | ControlsObject.TAP_JUMP);
            ignoreMap = (ignoreMap | ControlsObject.DT_DASH);
            ignoreMap = (ignoreMap | ControlsObject.AUTO_DASH);
            var onlyDirectionalBits:int = (((ControlsObject.UP | ControlsObject.DOWN) | ControlsObject.LEFT) | ControlsObject.RIGHT);
            var hasAtLeastOneInput:Boolean;
            var i:int;
            while (i < this.m_pressedControlsBuffer.length)
            {
                tmpBits = ControlsObject.getControls(this.m_pressedControlsBuffer[i], ignoreMap);
                if ((tmpBits - (onlyDirectionalBits & tmpBits)) > 0)
                {
                    hasAtLeastOneInput = true;
                    break;
                };
                i++;
            };
            if ((!(hasAtLeastOneInput)))
            {
                this.clearControlsBuffer();
            };
        }

        private function processControlsBuffer():void
        {
            var controls:Object = {};
            if ((!(this.isBufferableState(m_state))))
            {
                if (this.m_pressedControlsBuffer.length)
                {
                    this.m_pressedControls.controls = this.m_pressedControlsBuffer[(this.m_pressedControlsBuffer.length - 1)];
                    this.m_heldControls.controls = this.m_heldControlsBuffer[(this.m_heldControlsBuffer.length - 1)];
                    if ((!((inState(CState.SHIELDING)) && (this.m_shieldTimer < this.m_shieldStartFrame))))
                    {
                        this.m_pressedControlsBuffer.pop();
                        this.m_heldControlsBuffer.pop();
                    };
                };
            };
        }

        private function m_getKey():void
        {
            if (((!(STAGEDATA.FreezeKeys)) && (!(STAGEDATA.StageEvent))))
            {
                if (this.m_human)
                {
                    if (((STAGEDATA.OnlineMode) || (STAGEDATA.ReplayMode) || (this.DisableKey)))
                    {
                        this.updateControlsBuffer();
                        this.processControlsBuffer();
                        this.m_tap_jump = (this.m_key.getControlsObject().TAP_JUMP == 1);
                        this.m_auto_dash = (this.m_key.getControlsObject().AUTO_DASH == 1);
                        this.m_dt_dash = (this.m_key.getControlsObject().DT_DASH == 1);
                    }
                    else
                    {
                        this.m_key.getControlsObject().controls = this.m_key.getControlStatus().controls;
                        this.updateControlsBuffer();
                        this.processControlsBuffer();
                        this.m_tap_jump = (this.m_key._TAP_JUMP == 1);
                        this.m_auto_dash = (this.m_key._AUTO_DASH == 1);
                        this.m_dt_dash = (this.m_key._DT_DASH == 1);
                    };
                }
                else
                {
                    if ((((!(STAGEDATA.Paused)) && (!(STAGEDATA.FSCutscene))) && (STAGEDATA.FSCutins <= 0)))
                    {
                        this.CPU.getAction();
                        this.updateControlsBuffer();
                        this.processControlsBuffer();
                        this.m_tap_jump = false;
                        this.m_auto_dash = false;
                        this.m_dt_dash = false;
                    };
                };
            }
            else
            {
                if ((!(STAGEDATA.StageEvent)))
                {
                    this.m_pressedControls.LEFT = false;
                    this.m_pressedControls.RIGHT = false;
                    this.m_pressedControls.UP = false;
                    this.m_pressedControls.DOWN = false;
                    this.m_pressedControls.BUTTON1 = false;
                    this.m_pressedControls.BUTTON2 = false;
                    this.m_pressedControls.GRAB = false;
                    this.m_pressedControls.JUMP = false;
                    this.m_pressedControls.TAUNT = false;
                    this.m_pressedControls.START = (((this.m_human) && (this.m_key)) ? ((this.m_key.IsDown(this.m_key._START)) ? true : false) : false);
                    this.m_pressedControls.JUMP2 = false;
                    this.m_pressedControls.C_UP = false;
                    this.m_pressedControls.C_DOWN = false;
                    this.m_pressedControls.C_LEFT = false;
                    this.m_pressedControls.C_RIGHT = false;
                    this.m_pressedControls.SHIELD = false;
                    this.m_pressedControls.SHIELD2 = false;
                    this.m_pressedControls.DASH = false;
                    this.m_heldControls.LEFT = false;
                    this.m_heldControls.RIGHT = false;
                    this.m_heldControls.UP = false;
                    this.m_heldControls.DOWN = false;
                    this.m_heldControls.BUTTON1 = false;
                    this.m_heldControls.BUTTON2 = false;
                    this.m_heldControls.GRAB = false;
                    this.m_heldControls.JUMP = false;
                    this.m_heldControls.TAUNT = false;
                    this.m_heldControls.START = (((this.m_human) && (this.m_key)) ? ((this.m_key.IsDown(this.m_key._START)) ? true : false) : false);
                    this.m_heldControls.JUMP2 = false;
                    this.m_heldControls.C_UP = false;
                    this.m_heldControls.C_DOWN = false;
                    this.m_heldControls.C_LEFT = false;
                    this.m_heldControls.C_RIGHT = false;
                    this.m_heldControls.SHIELD = false;
                    this.m_heldControls.SHIELD2 = false;
                    this.m_heldControls.DASH = false;
                }
                else
                {
                    this.m_pressedControls.LEFT = false;
                    this.m_pressedControls.RIGHT = false;
                    this.m_pressedControls.UP = false;
                    this.m_pressedControls.DOWN = false;
                    this.m_pressedControls.BUTTON1 = false;
                    this.m_pressedControls.BUTTON2 = false;
                    this.m_pressedControls.GRAB = false;
                    this.m_pressedControls.JUMP = false;
                    this.m_pressedControls.TAUNT = false;
                    this.m_pressedControls.START = false;
                    this.m_pressedControls.JUMP2 = false;
                    this.m_pressedControls.C_UP = false;
                    this.m_pressedControls.C_DOWN = false;
                    this.m_pressedControls.C_LEFT = false;
                    this.m_pressedControls.C_RIGHT = false;
                    this.m_pressedControls.SHIELD = false;
                    this.m_pressedControls.SHIELD2 = false;
                    this.m_pressedControls.DASH = false;
                    this.m_heldControls.LEFT = false;
                    this.m_heldControls.RIGHT = false;
                    this.m_heldControls.UP = false;
                    this.m_heldControls.DOWN = false;
                    this.m_heldControls.BUTTON1 = false;
                    this.m_heldControls.BUTTON2 = false;
                    this.m_heldControls.GRAB = false;
                    this.m_heldControls.JUMP = false;
                    this.m_heldControls.TAUNT = false;
                    this.m_heldControls.START = false;
                    this.m_heldControls.JUMP2 = false;
                    this.m_heldControls.C_UP = false;
                    this.m_heldControls.C_DOWN = false;
                    this.m_heldControls.C_LEFT = false;
                    this.m_heldControls.C_RIGHT = false;
                    this.m_heldControls.SHIELD = false;
                    this.m_heldControls.SHIELD2 = false;
                    this.m_heldControls.DASH = false;
                };
            };
        }

        private function checkDoubleTap(tapType:Number):Boolean
        {
            var doubleTap:Boolean;
            switch (tapType)
            {
                case 0:
                    if ((!(m_collision.ground)))
                    {
                        return (false);
                    };
                    if ((((this.m_auto_dash) && (!(this.m_heldControls.DASH))) && (!((inState(CState.WALK)) && (!(this.m_heldControls.RIGHT === this.m_heldControls.LEFT))))))
                    {
                        return (true);
                    };
                    if (this.m_auto_dash)
                    {
                        return (false);
                    };
                    if (((((!(this.m_dt_dash)) && (this.m_heldControls.DASH)) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && ((((inState(CState.IDLE)) || ((inState(CState.WALK)) && (this.m_walkTimer <= 1))) || (inState(CState.DASH))) || (inState(CState.RUN)))))
                    {
                        return (true);
                    };
                    if ((!(this.m_dt_dash)))
                    {
                        return (false);
                    };
                    if (((((this.m_dt_dash) && (this.m_heldControls.DASH)) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && ((inState(CState.IDLE)) || ((inState(CState.WALK)) && (this.m_walkTimer <= 1)))))
                    {
                        return (true);
                    };
                    if ((((!(this.m_heldControls.RIGHT)) && (!(this.m_heldControls.LEFT))) && (Utils.fastAbs(m_xSpeed) < this.m_max_xSpeed)))
                    {
                        this.m_speedLetGo = true;
                    };
                    if (inState(CState.WALK))
                    {
                        this.m_speedTimer = 0;
                    }
                    else
                    {
                        this.m_speedTimer++;
                    };
                    if ((((this.m_heldControls.RIGHT) || (this.m_heldControls.LEFT)) && (inState(CState.RUN))))
                    {
                        doubleTap = true;
                    };
                    if (((inState(CState.TURN)) || (inState(CState.DASH))))
                    {
                        doubleTap = true;
                    };
                    if ((((((this.m_speedTimer < 6) && (((inState(CState.IDLE)) || (inState(CState.WALK))) || (inState(CState.SKID)))) && (!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT))) && (this.m_speedLetGo)) && (((this.m_heldControls.RIGHT) && (m_facingForward)) || ((this.m_heldControls.LEFT) && (!(m_facingForward))))))
                    {
                        this.m_speedLetGo = false;
                        doubleTap = true;
                    };
                    break;
                case 1:
                    doubleTap = false;
                    if (((this.m_lastCrouchTimer > 6) && (!(inState(CState.CROUCH)))))
                    {
                        this.m_lastCrouchTimer = 0;
                    };
                    if (((inState(CState.CROUCH)) && (this.m_lastCrouchTimer == 0)))
                    {
                        this.m_lastCrouchTimer = 1;
                    };
                    if ((((this.m_lastCrouchTimer > 0) && (!(inState(CState.CROUCH)))) && (!(this.m_heldControls.DOWN))))
                    {
                        this.m_lastCrouchTimer++;
                    };
                    if ((((this.m_lastCrouchTimer > 0) && (!(inState(CState.CROUCH)))) && (this.m_heldControls.DOWN)))
                    {
                        this.m_lastCrouchTimer = 0;
                        doubleTap = true;
                    };
                    if ((((inState(CState.CROUCH)) && (this.m_heldControls.DOWN)) && (this.m_heldControls.DASH)))
                    {
                        doubleTap = true;
                    };
                    break;
            };
            return (doubleTap);
        }

        private function initDash(toTheRight:Boolean):void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.m_dashReady = false;
            this.m_speedTimer = 0;
            if (toTheRight)
            {
                m_faceRight();
            }
            else
            {
                m_faceLeft();
            };
            var dashSpeed:Number = ((this.m_characterStats.AccelStartDash >= 0) ? this.m_characterStats.AccelStartDash : this.m_characterStats.AccelStart);
            m_xSpeed = ((toTheRight) ? (dashSpeed * this.m_max_xSpeed) : (-(dashSpeed) * this.m_max_xSpeed));
            this.setState(CState.DASH);
            this.stancePlayFrame("dash");
            this.attachRunEffect();
        }

        override protected function checkPlatformBounce():void
        {
            if (((m_currentPlatform) && (m_currentPlatform.bounce_speed > 0)))
            {
                Utils.tryToGotoAndStop(m_currentPlatform.Container, "bounce");
                m_ySpeed = -(m_currentPlatform.bounce_speed);
                this.unnattachFromGround();
                if (this.m_grabbed.length > 0)
                {
                    this.setState(CState.JUMP_RISING);
                    this.releaseOpponent();
                };
            };
        }

        private function inPreventFallOffState():Boolean
        {
            return (((((((((((((inState(CState.ATTACKING)) && (!(m_attack.CanFallOff))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) || (inState(CState.GRABBING))) || (inState(CState.SHIELDING))) || (inState(CState.SHIELD_DROP))) || (inState(CState.TECH_ROLL))) || (inState(CState.DODGE_ROLL))) || ((inState(CState.CRASH_LAND)) && (getStanceVar("ready", true)))) || (inState(CState.CRASH_GETUP))) || (inState(CState.ROLL))) || (inState(CState.SIDESTEP_DODGE))) || (inState(CState.LEDGE_ROLL)));
        }

        private function m_charRun():void
        {
            var tmpNormRunSpeed:Number;
            var tmpMaxRunSpeed:Number;
            var tmpMaxJumpSpeed:Number;
            var oldSpeedLevel:Boolean;
            var speedLevelChanged:Boolean;
            var wasRunningRight:Boolean;
            var turnReverse:Boolean;
            var absXSpeed:Number;
            var fallOffHeight:Number;
            if ((!(inState(CState.WALK))))
            {
                this.m_walkTimer = 0;
            }
            else
            {
                this.m_walkTimer++;
            };
            if ((!(isHitStunOrParalysis())))
            {
                applyGroundInfluence();
                this.checkPlatformBounce();
            };
            var initialSpeed:Number = m_xSpeed;
            if ((((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (currentFrameIs("run"))) && (m_xSpeed === 0)))
            {
                this.m_controlFrames();
            };
            if (((!(isHitStunOrParalysis())) && (!(inState(CState.GLIDING)))))
            {
                tmpNormRunSpeed = this.m_norm_xSpeed;
                tmpMaxRunSpeed = this.m_max_xSpeed;
                tmpMaxJumpSpeed = this.m_characterStats.MaxJumpSpeed;
                if (this.m_sizeStatus != 0)
                {
                    this.m_norm_xSpeed = (this.m_norm_xSpeed * ((this.m_sizeStatus == 1) ? 2 : 0.5));
                    this.m_max_xSpeed = (this.m_max_xSpeed * ((this.m_sizeStatus == 1) ? 2 : 0.5));
                    this.m_characterStats.MaxJumpSpeed = (this.m_characterStats.MaxJumpSpeed * ((this.m_sizeStatus == 1) ? 2 : 0.5));
                };
                if ((!(inState(CState.ATTACKING))))
                {
                    if (this.m_forceTimer > 0)
                    {
                        this.m_heldControls.RIGHT = this.m_forceRight;
                        this.m_heldControls.LEFT = (!(this.m_forceRight));
                        this.m_forceTimer--;
                    };
                };
                oldSpeedLevel = this.m_runningSpeedLevel;
                this.m_runningSpeedLevel = (((this.checkDoubleTap(0)) && (!((this.HoldingItem) && (!(this.m_item.ItemStats.CanRunWith))))) ? true : false);
                speedLevelChanged = (!(oldSpeedLevel == this.m_runningSpeedLevel));
                wasRunningRight = (m_xSpeed > 0);
                if (((this.m_charIsFull) && (this.m_grabbed.length > 0)))
                {
                    this.resetSpeedLevel();
                    this.m_grabbed[0].X = m_sprite.x;
                    this.m_grabbed[0].Y = m_sprite.y;
                };
                if (((inState(CState.DASH)) || (inState(CState.TURN))))
                {
                    this.m_runningSpeedLevel = true;
                    speedLevelChanged = false;
                };
                if (((inState(CState.TURN)) && (!(m_sprite.stance.currentLabel == "turn"))))
                {
                    this.m_dashReady = false;
                    this.m_turnTimer.reset();
                    this.setState(CState.RUN);
                    if (m_facingForward)
                    {
                        m_faceLeft();
                        if ((((this.m_runningSpeedLevel) && (!(this.m_heldControls.LEFT === this.m_heldControls.RIGHT))) && (this.m_heldControls.RIGHT)))
                        {
                            this.m_dashReady = true;
                        };
                    }
                    else
                    {
                        m_faceRight();
                        if ((((this.m_runningSpeedLevel) && (!(this.m_heldControls.LEFT === this.m_heldControls.RIGHT))) && (this.m_heldControls.LEFT)))
                        {
                            this.m_dashReady = true;
                        };
                    };
                };
                if (inState(CState.DASH))
                {
                    if (((!(this.m_heldControls.LEFT)) && (!(this.m_heldControls.RIGHT))))
                    {
                        this.m_dashReady = true;
                    };
                    if (m_sprite.stance.currentLabel != "dash")
                    {
                        this.m_dashReady = false;
                        this.setState(CState.RUN);
                    }
                    else
                    {
                        if ((((this.m_runningSpeedLevel) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && (((this.m_heldControls.LEFT) && (m_facingForward)) || ((this.m_heldControls.RIGHT) && (!(m_facingForward))))))
                        {
                            if (m_facingForward)
                            {
                                m_faceLeft();
                            }
                            else
                            {
                                m_faceRight();
                            };
                            this.setState(CState.DASH_INIT);
                            m_xSpeed = 0;
                        };
                    };
                }
                else
                {
                    if (inState(CState.DASH_INIT))
                    {
                        this.initDash(m_facingForward);
                    };
                };
                if (inState(CState.SKID))
                {
                    this.m_skidTimer++;
                    if (((!(this.m_heldControls.LEFT)) && (!(this.m_heldControls.RIGHT))))
                    {
                        this.m_dashReady = true;
                    };
                    if (((((speedLevelChanged) && (this.m_runningSpeedLevel)) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && (((this.m_heldControls.LEFT) && (!(m_facingForward))) || ((this.m_heldControls.RIGHT) && (m_facingForward)))))
                    {
                    };
                }
                else
                {
                    this.m_skidTimer = 0;
                };
                if ((((inState(CState.RUN)) && (!(this.m_runningSpeedLevel))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))
                {
                    this.m_speedLetGo = false;
                    this.resetSpeedLevel();
                    this.m_dashReady = true;
                    this.resetSmashTimers();
                    this.m_dashReady = true;
                    this.setState(CState.SKID);
                };
                if ((((((((((this.m_heldControls.RIGHT) && ((!(this.m_heldControls.LEFT)) || ((this.m_heldControls.LEFT) && (m_facingForward)))) && (this.inFreeState((((CFreeState.SWALLOWING | CFreeState.DISABLED) | CFreeState.TOSSING) | ((!((STAGEDATA.AirDodge.match(/melee|solo|vsolo|double|vdouble/)) && (inState(CState.AIR_DODGE)))) ? CFreeState.DODGING : 0))))) && (!(inState(CState.DASH_INIT)))) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.SIDESTEP_DODGE)))) && ((!(inState(CState.CROUCH))) || ((inState(CState.CROUCH)) && (this.m_characterStats.CrouchWalkSpeed > 0)))) && (!(inState(CState.TURN)))) && (!((inState(CState.ITEM_TOSS)) && (m_collision.ground)))))
                {
                    if ((!(m_collision.ground)))
                    {
                        m_xSpeed = (m_xSpeed + ((m_xSpeed < this.m_characterStats.MaxJumpSpeed) ? this.m_characterStats.AccelRateAir : 0));
                        if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                        {
                            if ((!(m_facingForward)))
                            {
                                m_faceRight();
                            };
                        }
                        else
                        {
                            if (((!(m_xSpeed === initialSpeed)) && (m_xSpeed > this.m_characterStats.MaxJumpSpeed)))
                            {
                                m_xSpeed = this.m_characterStats.MaxJumpSpeed;
                            }
                            else
                            {
                                if (m_xSpeed > this.m_characterStats.MaxJumpSpeed)
                                {
                                };
                            };
                        };
                    }
                    else
                    {
                        if ((!(inState(CState.EGG))))
                        {
                            if ((!(this.m_runningSpeedLevel)))
                            {
                                if (m_xSpeed == 0)
                                {
                                    if ((!(inState(CState.CROUCH))))
                                    {
                                        m_xSpeed = (this.m_characterStats.AccelStart * this.m_norm_xSpeed);
                                    };
                                }
                                else
                                {
                                    if (inState(CState.WALK))
                                    {
                                        if (m_xSpeed < this.m_norm_xSpeed)
                                        {
                                            m_xSpeed = (m_xSpeed + (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction));
                                            if (m_xSpeed > this.m_norm_xSpeed)
                                            {
                                                m_xSpeed = this.m_norm_xSpeed;
                                            };
                                        }
                                        else
                                        {
                                            decel(this.m_characterStats.DecelRate);
                                            if (m_xSpeed < this.m_norm_xSpeed)
                                            {
                                                m_xSpeed = this.m_norm_xSpeed;
                                            };
                                        };
                                    };
                                };
                            }
                            else
                            {
                                if ((!(inState(CState.CROUCH))))
                                {
                                    if ((((((this.m_dashReady) && (this.m_runningSpeedLevel)) && (!(inState(CState.DASH)))) && (!(inState(CState.ITEM_TOSS)))) && (Utils.fastAbs(m_xSpeed) < this.m_max_xSpeed)))
                                    {
                                        this.initDash(true);
                                    }
                                    else
                                    {
                                        m_xSpeed = (m_xSpeed + ((m_xSpeed < this.m_max_xSpeed) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                                        if (m_xSpeed > this.m_max_xSpeed)
                                        {
                                            if ((!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (inState(CState.ATTACKING)))))
                                            {
                                                decel(this.m_characterStats.DecelRate);
                                            };
                                            if (m_xSpeed < this.m_max_xSpeed)
                                            {
                                                m_xSpeed = this.m_max_xSpeed;
                                            };
                                        };
                                    };
                                };
                            };
                            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                            {
                                if ((!(m_facingForward)))
                                {
                                    m_faceRight();
                                };
                            };
                            if (((((this.m_turnTimer.IsComplete) && (inState(CState.RUN))) && ((!(wasRunningRight)) && (!(m_facingForward)))) && ((Utils.hasLabel(m_sprite.stance, "turn")) && (!(m_sprite.stance.currentLabel == "turn")))))
                            {
                                this.setState(CState.TURN);
                                this.stancePlayFrame("turn");
                            }
                            else
                            {
                                if (((((inState(CState.RUN)) && (Utils.fastAbs(m_xSpeed) > this.m_norm_xSpeed)) && (!(m_facingForward))) && (!(Utils.hasLabel(m_sprite.stance, "turn")))))
                                {
                                    m_xSpeed = (this.m_characterStats.AccelStart * -(this.m_norm_xSpeed));
                                };
                            };
                        };
                    };
                    if (inState(CState.CROUCH))
                    {
                        if (m_xSpeed > this.m_characterStats.CrouchWalkSpeed)
                        {
                            decel(this.m_characterStats.DecelRate);
                        }
                        else
                        {
                            if (m_xSpeed < this.m_characterStats.CrouchWalkSpeed)
                            {
                                m_xSpeed = Math.min(this.m_characterStats.CrouchWalkSpeed, (m_xSpeed + this.m_characterStats.AccelRate));
                            };
                        };
                    }
                    else
                    {
                        if ((((((((m_collision.ground) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.TURN)))) && (!(inState(CState.DASH)))) && (!(inState(CState.ITEM_TOSS)))))
                        {
                            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                            {
                                this.setState(CState.RUN);
                            }
                            else
                            {
                                if ((!(((inState(CState.ATTACKING)) && (m_attack.IASA)) && (this.m_pressedControls.LEFT === this.m_pressedControls.RIGHT))))
                                {
                                    this.setState(((!(this.m_runningSpeedLevel)) ? CState.WALK : CState.RUN));
                                };
                            };
                            this.m_speedLetGo = false;
                        };
                    };
                }
                else
                {
                    if ((((((((((this.m_heldControls.LEFT) && ((!(this.m_heldControls.RIGHT)) || ((this.m_heldControls.RIGHT) && (!(m_facingForward))))) && (this.inFreeState((((CFreeState.SWALLOWING | CFreeState.DISABLED) | CFreeState.TOSSING) | ((!((STAGEDATA.AirDodge.match(/melee|solo|vsolo|double|vdouble/)) && (inState(CState.AIR_DODGE)))) ? CFreeState.DODGING : 0))))) && (!(inState(CState.DASH_INIT)))) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.SIDESTEP_DODGE)))) && ((!(inState(CState.CROUCH))) || ((inState(CState.CROUCH)) && (this.m_characterStats.CrouchWalkSpeed > 0)))) && (!(inState(CState.TURN)))) && (!((inState(CState.ITEM_TOSS)) && (m_collision.ground)))))
                    {
                        if ((!(m_collision.ground)))
                        {
                            if (((!(inState(CState.DISABLED))) && (this.m_runningSpeedLevel)))
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(this.m_characterStats.MaxJumpSpeed)) ? this.m_characterStats.AccelRateAir : 0));
                            }
                            else
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(this.m_characterStats.MaxJumpSpeed)) ? this.m_characterStats.AccelRateAir : 0));
                            };
                            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                            {
                                if (m_facingForward)
                                {
                                    m_faceLeft();
                                };
                            }
                            else
                            {
                                if (((!(m_xSpeed === initialSpeed)) && (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))))
                                {
                                    m_xSpeed = -(this.m_characterStats.MaxJumpSpeed);
                                }
                                else
                                {
                                    if (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))
                                    {
                                    };
                                };
                            };
                        }
                        else
                        {
                            if ((!(inState(CState.EGG))))
                            {
                                if ((!(this.m_runningSpeedLevel)))
                                {
                                    if (m_xSpeed == 0)
                                    {
                                        if ((!(inState(CState.CROUCH))))
                                        {
                                            m_xSpeed = (this.m_characterStats.AccelStart * -(this.m_norm_xSpeed));
                                        };
                                    }
                                    else
                                    {
                                        if (inState(CState.WALK))
                                        {
                                            if (m_xSpeed > -(this.m_norm_xSpeed))
                                            {
                                                m_xSpeed = (m_xSpeed - (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction));
                                                if (m_xSpeed < -(this.m_norm_xSpeed))
                                                {
                                                    m_xSpeed = -(this.m_norm_xSpeed);
                                                };
                                            }
                                            else
                                            {
                                                decel(this.m_characterStats.DecelRate);
                                                if (m_xSpeed > -(this.m_norm_xSpeed))
                                                {
                                                    m_xSpeed = -(this.m_norm_xSpeed);
                                                };
                                            };
                                        };
                                    };
                                }
                                else
                                {
                                    if ((!(inState(CState.CROUCH))))
                                    {
                                        if ((((((this.m_dashReady) && (this.m_runningSpeedLevel)) && (!(inState(CState.DASH)))) && (!(inState(CState.ITEM_TOSS)))) && (Utils.fastAbs(m_xSpeed) < this.m_max_xSpeed)))
                                        {
                                            this.initDash(false);
                                        }
                                        else
                                        {
                                            m_xSpeed = (m_xSpeed - ((m_xSpeed > -(this.m_max_xSpeed)) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                                            if (m_xSpeed < -(this.m_max_xSpeed))
                                            {
                                                if ((!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (inState(CState.ATTACKING)))))
                                                {
                                                    decel(this.m_characterStats.DecelRate);
                                                };
                                                if (m_xSpeed > -(this.m_max_xSpeed))
                                                {
                                                    m_xSpeed = -(this.m_max_xSpeed);
                                                };
                                            };
                                        };
                                    };
                                };
                                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                                {
                                    if (m_facingForward)
                                    {
                                        faceLeft();
                                    };
                                };
                                if (((((this.m_turnTimer.IsComplete) && (inState(CState.RUN))) && ((wasRunningRight) && (m_facingForward))) && ((Utils.hasLabel(m_sprite.stance, "turn")) && (!(m_sprite.stance.currentLabel == "turn")))))
                                {
                                    this.setState(CState.TURN);
                                    this.stancePlayFrame("turn");
                                }
                                else
                                {
                                    if (((((inState(CState.RUN)) && (Utils.fastAbs(m_xSpeed) > this.m_norm_xSpeed)) && (m_facingForward)) && (!(Utils.hasLabel(m_sprite.stance, "turn")))))
                                    {
                                        m_xSpeed = (this.m_characterStats.AccelStart * this.m_norm_xSpeed);
                                    };
                                };
                            };
                        };
                        if (inState(CState.CROUCH))
                        {
                            if (m_xSpeed < -(this.m_characterStats.CrouchWalkSpeed))
                            {
                                decel(this.m_characterStats.DecelRate);
                            }
                            else
                            {
                                if (m_xSpeed > -(this.m_characterStats.CrouchWalkSpeed))
                                {
                                    m_xSpeed = Math.max(-(this.m_characterStats.CrouchWalkSpeed), (m_xSpeed - this.m_characterStats.AccelRate));
                                };
                            };
                        }
                        else
                        {
                            if ((((((((m_collision.ground) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.TURN)))) && (!(inState(CState.DASH)))) && (!(inState(CState.ITEM_TOSS)))))
                            {
                                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                                {
                                    this.setState(CState.RUN);
                                }
                                else
                                {
                                    if ((!(((inState(CState.ATTACKING)) && (m_attack.IASA)) && (this.m_pressedControls.LEFT === this.m_pressedControls.RIGHT))))
                                    {
                                        this.setState(((!(this.m_runningSpeedLevel)) ? CState.WALK : CState.RUN));
                                    };
                                };
                                this.m_speedLetGo = false;
                            };
                        };
                    }
                    else
                    {
                        if ((((((((((m_collision.ground) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.DASH_INIT)))) && (!(inState(CState.ROLL)))) && (!(inState(CState.TECH_ROLL)))) && (!(inState(CState.DODGE_ROLL)))) && ((!(inState(CState.FLYING))) || (this.m_hasBounced))) && (!(inState(CState.INJURED)))) && (!(inState(CState.ATTACKING)))))
                        {
                            if (m_xSpeed != 0)
                            {
                                if ((!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (inState(CState.ATTACKING)))))
                                {
                                    decel(this.m_characterStats.DecelRate);
                                };
                            };
                        };
                    };
                };
                if (((((!(inState(CState.BARREL))) && (!(inState(CState.CAUGHT)))) && ((!(inState(CState.FLYING))) || (this.m_hasBounced))) && (!(inState(CState.INJURED)))))
                {
                    if (((((inState(CState.CROUCH)) && (this.m_characterStats.CrouchWalkSpeed > 0)) && (this.m_crouchLength >= 3)) && (currentFrameIs("crouch"))))
                    {
                        if (((!(m_xSpeed === 0)) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))))
                        {
                            if (getStanceVar("moving", false))
                            {
                                Utils.tryToGotoAndStop(Stance, "walking");
                            };
                        }
                        else
                        {
                            if (getStanceVar("moving", true))
                            {
                                Utils.tryToGotoAndStop(Stance, "crouching");
                            };
                        };
                    };
                    turnReverse = ((inState(CState.TURN)) || ((inState(CState.RUN)) && (((m_facingForward) && (m_xSpeed < 0)) || ((!(m_facingForward)) && (m_xSpeed > 0)))));
                    absXSpeed = Utils.fastAbs(m_xSpeed);
                    fallOffHeight = ((absXSpeed < 5) ? 10 : (absXSpeed * 2));
                    if (((!(m_xSpeed == 0)) && (!(((this.inPreventFallOffState()) && (m_collision.ground)) && (this.willFallOffRange((m_sprite.x + m_xSpeed), m_sprite.y, fallOffHeight))))))
                    {
                        this.m_attemptToMove(m_xSpeed, 0);
                    };
                    if (((((m_collision.ground) && (!(this.m_runningSpeedLevel))) && (!((inState(CState.ATTACKING)) && ((m_attack.Frame == "a_forward") || (m_attack.IsThrow))))) && (!(inState(CState.GRABBING)))))
                    {
                        this.resetRotation();
                        Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    };
                    if ((((m_collision.ground) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))))
                    {
                        attachToGround();
                    }
                    else
                    {
                        if ((((((((!(m_collision.ground)) && (!(inState(CState.CAUGHT)))) && (!(m_xSpeed == 0))) && (!(inState(CState.ATTACKING)))) && (!(inState(CState.BARREL)))) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.RIGHT))))
                        {
                            if ((!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (inState(CState.ATTACKING)))))
                            {
                                decel(this.m_characterStats.DecelRateAir);
                            };
                        };
                    };
                };
                if (((inState(CState.LEDGE_HANG)) && (this.m_ledgeHangTimer.CurrentTime > 4)))
                {
                    if ((((this.m_pressedControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (m_facingForward)))
                    {
                        m_ySpeed = 0;
                        this.unnattachFromLedge();
                        this.setState(CState.IDLE);
                    };
                    if ((((!(this.m_heldControls.LEFT)) && (this.m_pressedControls.RIGHT)) && (!(m_facingForward))))
                    {
                        m_ySpeed = 0;
                        this.unnattachFromLedge();
                        this.setState(CState.IDLE);
                    };
                };
                this.m_norm_xSpeed = tmpNormRunSpeed;
                this.m_max_xSpeed = tmpMaxRunSpeed;
                this.m_characterStats.MaxJumpSpeed = tmpMaxJumpSpeed;
                if ((((inState(CState.SKID)) && (this.m_skidTimer < 2)) && ((((this.m_heldControls.LEFT) && (wasRunningRight)) && (m_facingForward)) || (((this.m_heldControls.RIGHT) && (!(wasRunningRight))) && (!(m_facingForward))))))
                {
                    this.setState(CState.TURN);
                    Utils.tryToGotoAndStop(Stance, "turn");
                };
            };
            if ((((((m_collision.ground) && ((inState(CState.WALK)) || (inState(CState.RUN)))) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.RIGHT))) && (this.inFreeState(CFreeState.SWALLOWING))))
            {
                if ((((inState(CState.RUN)) && (Utils.fastAbs(m_xSpeed) < this.m_max_xSpeed)) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))
                {
                    this.m_speedLetGo = false;
                    this.resetSpeedLevel();
                    this.m_dashReady = true;
                    this.resetSmashTimers();
                    this.m_dashReady = true;
                    this.setState(CState.SKID);
                }
                else
                {
                    if (((!(this.m_runningSpeedLevel)) || (m_xSpeed == 0)))
                    {
                        this.m_dashReady = true;
                        this.setState(CState.IDLE);
                    };
                };
            }
            else
            {
                if (((inState(CState.RUN)) && (!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT))))
                {
                    if (((this.m_heldControls.RIGHT) && (!(m_facingForward))))
                    {
                        m_faceRight();
                        this.setState(CState.WALK);
                        this.m_runningSpeedLevel = false;
                    };
                    if (((this.m_heldControls.LEFT) && (m_facingForward)))
                    {
                        m_faceLeft();
                        this.setState(CState.WALK);
                        this.m_runningSpeedLevel = false;
                    };
                };
            };
        }

        public function jumpChamber():void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.m_preJumpState = m_state;
            this.m_crouchFrame = -1;
            this.m_jumpStartup.reset();
            this.m_shortHop = false;
            this.m_jumpSpeedBuffer = m_xSpeed;
            if (inState(CState.TURN))
            {
                if (m_facingForward)
                {
                    m_faceLeft();
                }
                else
                {
                    m_faceRight();
                };
            };
            var obj:Object = this.getControls();
            this.setState(CState.JUMP_CHAMBER);
            this.resetBufferedCStick();
            this.m_jumpJustChambered = true;
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.initGroundJump();
            };
        }

        public function initGroundJump():void
        {
            var yPlatformDiff:Number;
            var oldPlatform:Platform = m_currentPlatform;
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            if (((Utils.fastAbs(this.m_jumpSpeedBuffer) > Utils.fastAbs(m_xSpeed)) && (!(this.m_jumpSpeedBuffer == 0))))
            {
                m_xSpeed = this.m_jumpSpeedBuffer;
                this.m_jumpSpeedBuffer = 0;
            };
            var shouldRestart:Boolean;
            this.m_jumpSpeedMidairDelay.reset();
            m_collision.ground = false;
            var amount:int;
            while (((this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1))) && (amount < 40)))
            {
                amount++;
                m_sprite.y--;
            };
            if (amount >= 40)
            {
                m_sprite.y = (m_sprite.y + amount);
            };
            m_yKnockback = 0;
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                m_ySpeed = ((this.m_heldControls.DOWN) ? -(this.m_characterStats.ShortHopSpeed) : -(this.m_characterStats.JumpSpeed));
            }
            else
            {
                m_ySpeed = (((this.m_charIsFull) || (this.m_shortHop)) ? -(this.m_characterStats.ShortHopSpeed) : -(this.m_characterStats.JumpSpeed));
            };
            if (this.m_sizeStatus != 0)
            {
                m_ySpeed = (m_ySpeed * ((this.m_sizeStatus == 1) ? 1.1 : 0.9));
            };
            m_xSpeed = (m_xSpeed + ((m_currentPlatform) ? m_currentPlatform.x_influence : 0));
            if (Utils.fastAbs(m_xSpeed) > this.m_max_xSpeed)
            {
                m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
            };
            this.playCharacterSound("jump");
            this.resetRotation();
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            this.attachJumpEffect();
            this.m_jumpEffectTimer.reset();
            this.m_jumpStartup.reset();
            this.setState(CState.JUMP_RISING);
            if (((Utils.hasLabel(m_sprite.stance, "backflip")) && (((m_facingForward) && (this.m_heldControls.LEFT)) || ((!(m_facingForward)) && (this.m_heldControls.RIGHT)))))
            {
                this.stancePlayFrame("backflip");
            }
            else
            {
                if (((HasStance) && (Utils.hasLabel(m_sprite.stance, "jump"))))
                {
                    this.stancePlayFrame("jump");
                };
            };
            shouldRestart = currentFrameIs("jump");
            if (shouldRestart)
            {
            };
            this.m_ledge = null;
            this.m_lastLedge = null;
            this.m_crouchFrame = -1;
            if (((((this.m_preJumpState === CState.DASH) || (this.m_preJumpState === CState.RUN)) || ((this.m_preJumpState === CState.TURN) && (((this.m_heldControls.RIGHT) && (m_facingForward)) || ((this.m_heldControls.LEFT) && (!(m_facingForward)))))) && (!(this.m_heldControls.RIGHT === this.m_heldControls.LEFT))))
            {
                if (((this.m_heldControls.RIGHT) && (!(m_facingForward))))
                {
                    m_xSpeed = this.m_characterStats.AccelRateAir;
                    if (m_xSpeed > this.m_characterStats.MaxJumpSpeed)
                    {
                        m_xSpeed = this.m_characterStats.MaxJumpSpeed;
                    };
                }
                else
                {
                    if (((this.m_heldControls.LEFT) && (m_facingForward)))
                    {
                        m_xSpeed = -(this.m_characterStats.AccelRateAir);
                        if (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))
                        {
                            m_xSpeed = -(this.m_characterStats.MaxJumpSpeed);
                        };
                    }
                    else
                    {
                        m_xSpeed = (m_xSpeed * this.m_characterStats.GroundToAirMultiplier);
                    };
                };
            }
            else
            {
                m_xSpeed = (m_xSpeed * this.m_characterStats.GroundToAirMultiplier);
            };
            if (((this.m_heldControls.DOWN) && (this.jumpIsHeld())))
            {
                if ((((((this.m_canHover) && (this.m_characterStats.MidAirHover > 0)) && (!(inState(CState.HOVER)))) && (!(inState(CState.ATTACKING)))) && (!(inState(CState.DISABLED)))))
                {
                    this.initHover();
                    this.m_attemptToMove(0, -3);
                };
            };
            this.compactControlsBuffer();
            this.processControlsBuffer();
            this.m_charShield();
            if (((oldPlatform) && (oldPlatform is MovingPlatform)))
            {
                yPlatformDiff = (MovingPlatform(oldPlatform).Y - MovingPlatform(oldPlatform).PreviousY);
                if (MovingPlatform(oldPlatform).conserve_horizontal_momentum)
                {
                    m_xSpeed = (m_xSpeed + (MovingPlatform(oldPlatform).X - MovingPlatform(oldPlatform).PreviousX));
                };
                if (((MovingPlatform(oldPlatform).conserve_upward_momentum) && (yPlatformDiff < 0)))
                {
                    m_ySpeed = (m_ySpeed + yPlatformDiff);
                };
                if (((MovingPlatform(oldPlatform).conserve_downward_momentum) && (yPlatformDiff > 0)))
                {
                    m_ySpeed = (m_ySpeed + yPlatformDiff);
                };
            };
        }

        public function initMidairJump():void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.m_jumpSpeedBuffer = m_xSpeed;
                this.initGroundJump();
                this.m_jumpCount++;
                return;
            };
            var shouldRestart:Boolean;
            this.m_hitLagCanCancelWithJump = false;
            this.m_hitLagCanCancelWithUpB = false;
            this.m_jumpSpeedMidairDelay.reset();
            var originalJumpSpeed:Number = -(this.m_characterStats.JumpSpeedMidAir);
            if (this.m_jumpSpeedList)
            {
                if (this.m_jumpCount < this.m_jumpSpeedList.length)
                {
                    originalJumpSpeed = -(this.m_jumpSpeedList[this.m_jumpCount]);
                }
                else
                {
                    originalJumpSpeed = -(this.m_jumpSpeedList[(this.m_jumpSpeedList.length - 1)]);
                };
            };
            if ((!((this.m_midAirJumpConstantDelay.MaxTime > 0) && (this.m_midAirJumpConstantTime.MaxTime > 0))))
            {
                m_ySpeed = originalJumpSpeed;
            }
            else
            {
                if (m_ySpeed < 0)
                {
                    m_ySpeed = 0;
                };
            };
            if (this.m_sizeStatus != 0)
            {
                m_ySpeed = (m_ySpeed * ((this.m_sizeStatus == 1) ? 1.1 : 0.9));
            };
            if (this.m_heldControls.LEFT === this.m_heldControls.RIGHT)
            {
                m_xSpeed = (m_xSpeed * 0.3);
            }
            else
            {
                if (((!(this.m_heldControls.LEFT === this.m_heldControls.RIGHT)) && (((this.m_heldControls.RIGHT) && (m_xSpeed < 0)) || ((this.m_heldControls.LEFT) && (m_xSpeed > 0)))))
                {
                    m_xSpeed = 0;
                    if (this.m_heldControls.RIGHT)
                    {
                        m_xSpeed = this.m_characterStats.AccelRateAir;
                        if (m_xSpeed > this.m_characterStats.MaxJumpSpeed)
                        {
                            m_xSpeed = this.m_characterStats.MaxJumpSpeed;
                        };
                    }
                    else
                    {
                        if (this.m_heldControls.LEFT)
                        {
                            m_xSpeed = -(this.m_characterStats.AccelRateAir);
                            if (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))
                            {
                                m_xSpeed = -(this.m_characterStats.MaxJumpSpeed);
                            };
                        };
                    };
                };
            };
            m_yKnockback = 0;
            resetKnockbackDecay();
            this.playCharacterSound("jump_midair");
            this.m_multiJumpDelay.reset();
            this.m_jumpCount++;
            this.resetRotation();
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            this.m_lastLedge = null;
            if (this.m_midAirJumpConstantTime.MaxTime > 0)
            {
                this.m_midAirJumpConstantTime.reset();
            };
            if (this.m_midAirJumpConstantDelay.MaxTime > 0)
            {
                this.m_midAirJumpConstantDelay.reset();
            };
            if ((((this.m_characterStats.MidAirTurn) && (this.m_heldControls.RIGHT)) && (!(m_facingForward))))
            {
                m_faceRight();
                m_facingForward = true;
            }
            else
            {
                if ((((this.m_characterStats.MidAirTurn) && (this.m_heldControls.LEFT)) && (m_facingForward)))
                {
                    m_faceLeft();
                    m_facingForward = false;
                };
            };
            if ((!(this.m_characterStats.HoldJump)))
            {
                this.attachJumpMidairEffect();
                this.m_jumpEffectTimer.finish();
            };
            shouldRestart = currentFrameIs("jump_midair");
            if (shouldRestart)
            {
                this.restartStance();
            };
            this.setState(CState.JUMP_MIDAIR_RISING);
        }

        private function initHover():void
        {
            this.resetRotation();
            m_ySpeed = 0;
            this.m_midAirHoverTime.reset();
            this.m_midAirHoverTime.MaxTime = this.m_characterStats.MidAirHover;
            this.m_midAirJumpConstantTime.finish();
            this.m_canHover = false;
            this.setState(CState.HOVER);
        }

        private function m_charJump():void
        {
            var wasJustLetGo:Boolean;
            this.m_multiJumpDelay.tick();
            this.m_jumpSpeedMidairDelay.tick();
            if (((m_collision.ground) && (this.jumpIsPressed())))
            {
                this.m_jumpTimer++;
            }
            else
            {
                wasJustLetGo = ((!(this.m_jumpJustLetGo)) && (!(this.m_jumpTimer == 0)));
                this.m_jumpJustLetGo = (!(this.m_jumpTimer == 0));
                if ((!(wasJustLetGo)))
                {
                    this.m_jumpTimer = 0;
                };
            };
            if (this.jumpIsPressed())
            {
                this.m_jumpTimer = 0;
            };
            if (inState(CState.JUMP_CHAMBER))
            {
                if ((!(this.m_jumpJustChambered)))
                {
                    this.m_jumpStartup.tick();
                };
                if ((!(this.jumpIsHeld())))
                {
                    this.m_shortHop = true;
                };
                if (((!(this.jumpIsHeld())) || (this.m_jumpStartup.IsComplete)))
                {
                    this.m_jumpJustLetGo = true;
                }
                else
                {
                    this.m_jumpJustLetGo = false;
                };
                if (this.m_jumpStartup.IsComplete)
                {
                    this.initGroundJump();
                };
            }
            else
            {
                this.resetBufferedCStick();
            };
            if ((((((((this.inFreeState(((CFreeState.SWALLOWING | CFreeState.TURNING) | CFreeState.SKIDDING))) && (!(inState(CState.DASH_INIT)))) && (!((this.HoldingItem) && (!(this.m_item.CanJumpWith))))) && (this.m_jumpCount < this.m_characterStats.MaxJump)) && ((this.m_jumpSpeedMidairDelay.IsComplete) || (this.m_characterStats.HoldJump))) && (this.jumpIsPressed())) && (m_collision.ground)))
            {
                if (this.m_jumpStartup.MaxTime == 0)
                {
                    this.initGroundJump();
                }
                else
                {
                    this.jumpChamber();
                };
            }
            else
            {
                if (((((((((((((this.jumpIsHeld()) && (this.inFreeState())) && (m_ySpeed > 0)) && ((m_ySpeed - m_gravity) <= 0)) && (this.m_canHover)) && (this.m_characterStats.MidAirHover > 0)) && (!(m_collision.ground))) && (!((this.HoldingItem) && (!(this.m_item.CanJumpWith))))) && (!(this.isLandingOrSkiddingOrChambering()))) && (!(this.m_charIsFull))) && (!(inState(CState.HOVER)))) && (!(inState(CState.DISABLED)))))
                {
                    this.initHover();
                }
                else
                {
                    if (((((((((((this.jumpIsHeld()) && (this.m_heldControls.DOWN)) && (this.inFreeState())) && (this.m_canHover)) && (this.m_characterStats.MidAirHover > 0)) && (!(m_collision.ground))) && (!((this.HoldingItem) && (!(this.m_item.CanJumpWith))))) && (!(this.isLandingOrSkiddingOrChambering()))) && (!(this.m_charIsFull))) && (!(inState(CState.HOVER)))))
                    {
                        this.initHover();
                    }
                    else
                    {
                        if (((((((((((this.jumpIsPressed()) && (!(m_collision.ground))) && (!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (m_ySpeed < 0)))) && (!((this.HoldingItem) && (!(this.m_item.CanJumpWith))))) && (this.m_jumpCount < this.m_characterStats.MaxJump)) && ((this.m_jumpSpeedMidairDelay.IsComplete) || (((this.m_characterStats.HoldJump) && (this.m_jumpCount > 1)) && (getStanceVar("done", true))))) && (this.inFreeState())) && (!(this.isLandingOrSkiddingOrChambering()))) && (!(inState(CState.HOVER)))) && (!((this.m_jumpCount > 2) && (!(this.m_multiJumpDelay.IsComplete))))))
                        {
                            this.initMidairJump();
                        }
                        else
                        {
                            if ((((inState(CState.LEDGE_HANG)) && (this.jumpIsPressed())) && (this.m_ledgeHangTimer.CurrentTime > 4)))
                            {
                                this.m_shortHop = false;
                                this.turnOffInvincibility();
                                this.initGroundJump();
                            };
                        };
                    };
                };
            };
            this.m_jumpJustChambered = false;
        }

        override public function checkMovingPlatforms(mc:MovingPlatform):void
        {
            var x_difference:Number;
            var y_difference:Number;
            var distance:Number;
            if (((((m_collision.ground) && (!(m_currentPlatform == null))) && (m_currentPlatform == mc)) || (((inState(CState.LEDGE_HANG)) && (!(this.m_ledge == null))) && (mc.LedgeList.indexOf(this.m_ledge) >= 0))))
            {
                x_difference = (mc.X - mc.PreviousX);
                y_difference = (mc.Y - mc.PreviousY);
                if (((inState(CState.LEDGE_HANG)) && (Utils.fastAbs(y_difference) > 400)))
                {
                    this.unnattachFromLedge();
                    this.setState(CState.IDLE);
                    this.m_ledge = null;
                    this.m_lastLedge = null;
                    return;
                };
                if (inState(CState.CAUGHT))
                {
                    return;
                };
                if ((!(this.testGroundWithCoord((m_sprite.x + x_difference), (m_sprite.y + y_difference)))))
                {
                    safeMove(0, y_difference);
                    safeMove(x_difference, 0);
                }
                else
                {
                    this.m_attemptToMove(0, y_difference);
                    this.m_attemptToMove(x_difference, 0);
                };
                if ((!(inState(CState.LEDGE_HANG))))
                {
                    this.m_fsGlowHolderMC.x = m_sprite.x;
                    this.m_fsGlowHolderMC.y = m_sprite.y;
                }
                else
                {
                    distance = Point.distance(new Point(this.m_ledge.x, this.m_ledge.y), new Point(m_sprite.x, m_sprite.y));
                    if (distance > 500)
                    {
                        this.unnattachFromLedge();
                        this.setState(CState.IDLE);
                        this.m_ledge = null;
                        this.m_lastLedge = null;
                        return;
                    };
                    m_sprite.x = this.m_ledge.x;
                    m_sprite.y = this.m_ledge.y;
                };
            };
        }

        private function initGrab(tether:Boolean=false):void
        {
            var prevState:uint;
            var wasDashAttack:Boolean;
            if (this.checkItemInterrupt("grab", 1))
            {
                return;
            };
            if (((inState(CState.DASH)) && (!(m_xSpeed == 0))))
            {
                m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
            };
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.clearControlsBuffer();
            m_attack.Frame = "grab";
            prevState = m_state;
            wasDashAttack = ((prevState === CState.ATTACKING) && (m_attack.Frame === "a_forward"));
            this.setState(CState.GRABBING);
            if (prevState == CState.SHIELDING)
            {
                this.m_deactivateShield();
            };
            if (((this.m_characterStats.TetherGrab) && (!(m_collision.ground))))
            {
                this.m_tetherCount++;
                this.stancePlayFrame("tether");
            }
            else
            {
                if ((((((prevState == CState.DASH) || (wasDashAttack)) || (prevState == CState.TURN)) || (prevState == CState.RUN)) && (Utils.hasLabel(m_sprite.stance, "dashgrab"))))
                {
                    this.stancePlayFrame("dashgrab");
                };
            };
            this.resetSpeedLevel();
            this.m_crouchFrame = -1;
            this.m_grabbed = new Vector.<Character>();
            m_attack.importAttackStateData({"isAirAttack":((this.m_characterStats.TetherGrab) && (!(m_collision.ground)))});
            m_attack.AttackID = Utils.getUID();
            if ((!(tether)))
            {
                if (prevState == CState.TURN)
                {
                    flip();
                }
                else
                {
                    if (((((prevState == CState.DASH) || (prevState == CState.RUN)) || (prevState == CState.IDLE)) || (prevState == CState.WALK)))
                    {
                        if (this.m_heldControls.RIGHT)
                        {
                            m_faceRight();
                        }
                        else
                        {
                            if (this.m_heldControls.LEFT)
                            {
                                m_faceLeft();
                            };
                        };
                    };
                };
            };
        }

        private function removeUngrabbedCharacters():void
        {
            var i:int;
            i = 0;
            while (i < this.m_grabbed.length)
            {
                if (this.m_grabbed[i].State != CState.CAUGHT)
                {
                    this.m_grabbed.splice(i, 1);
                    i--;
                };
                i++;
            };
            if (this.m_grabbed.length == 0)
            {
                this.m_strengthGrabLocked = false;
            };
        }

        public function getStrengthScore():Number
        {
            return StrengthSystem.getStrength(this.m_characterStats);
        }

        public function traceStrengthStats():void
        {
            var strength:Number = this.getStrengthScore();
            trace("[STRENGTH] " + this.m_characterStats.LinkageID +
                " weight=" + this.m_characterStats.Weight1 +
                " height=" + this.m_characterStats.Height +
                " score=" + strength +
                " dealt=" + StrengthSystem.getDamageDealtMultiplier(strength) +
                " taken=" + StrengthSystem.getDamageTakenMultiplier(strength) +
                " hitstun=" + StrengthSystem.getHitstunMultiplier(strength) +
                " armor=" + StrengthSystem.getArmorThreshold(strength));
        }

        public function getStrengthCollisionScale(hitBoxType:uint):Point
        {
            var scale:Point = CurrentScale.clone();
            if (inState(CState.GRABBING) &&
                (hitBoxType == HitBoxSprite.GRAB || hitBoxType == HitBoxSprite.MASTER))
            {
                var reach:Number = StrengthSystem.getGrabReachMultiplier(this.getStrengthScore());
                // Expand broad-phase bounds as well, so they cannot hide extended grabs.
                // Do not shrink MASTER: it also covers unrelated attack/hurt boxes.
                scale.x *= (hitBoxType == HitBoxSprite.MASTER) ? Math.max(1.0, reach) : reach;
            }
            return scale;
        }

        private function getStrengthGrabRatio(victim:Character):Number
        {
            return StrengthSystem.getMatchupRatio(this.getStrengthScore(), victim.getStrengthScore());
        }

        private function initializeStrengthGrab(victim:Character, baseLength:int):void
        {
            var ratio:Number = this.getStrengthGrabRatio(victim);
            this.m_strengthGrabLocked = StrengthSystem.isGrabLocked(ratio);
            this.m_grabTimer = StrengthSystem.ENABLED ? Math.max(1, int(Math.round(baseLength *
                StrengthSystem.getGrabDurationMultiplier(ratio, victim.getStrengthScore())))) : baseLength;
            // Strength affects escape, not the vanilla pummel cadence.
            this.m_pummelTimer = Utils.calculatePummelTime(baseLength);
            this.m_justPummeled = false;
        }

        private function isStrengthPummel(victim:Character):Boolean
        {
            return inState(CState.GRABBING) && this.m_justPummeled &&
                this.m_grabbed.indexOf(victim) >= 0 && victim.inState(CState.CAUGHT);
        }

        override public function createTimer(interval:int, repeats:int, func:Function, options:Object=null):void
        {
            // The stock DK cargo movie owns its own escape timer; m_grabTimer is not used.
            // Keep the original callback identity so native throws/escape can destroy it.
            var cargoClip:MovieClip = this.Stance;
            if (StrengthSystem.ENABLED &&
                (this.m_characterStats.StatsName == "donkeykong" || this.m_characterStats.LinkageID == "dkong") &&
                m_attack.Frame == "throw_forward" && this.m_grabbed.length > 0 && cargoClip &&
                "getFree" in cargoClip && "endTimer" in cargoClip && func === cargoClip["getFree"])
            {
                var victim:Character = this.m_grabbed[0];
                var ratio:Number = this.getStrengthGrabRatio(victim);
                cargoClip["endTimer"] = Math.max(1, int(Math.round(Number(cargoClip["endTimer"]) *
                    StrengthSystem.getGrabDurationMultiplier(ratio, victim.getStrengthScore()))));
                if (StrengthSystem.isGrabLocked(ratio))
                {
                    var cargoOptions:Object = {};
                    if (options)
                    {
                        for (var key:String in options)
                        {
                            cargoOptions[key] = options[key];
                        };
                    };
                    // Pause both natural decay and cargo-specific mashing, not movement/throws.
                    cargoOptions.hitStunPause = false;
                    cargoOptions.pauseCondition = function():Boolean { return true; };
                    options = cargoOptions;
                };
            };
            super.createTimer(interval, repeats, func, options);
        }

        private function getStrengthDizzy(attackObj:AttackDamage, attacker:Character, ratio:Number):int
        {
            if (!attacker || attackObj.IsThrow ||
                !attackObj.HasEffect || attackObj.Damage <= 0 || attacker.m_usingSpecialAttack ||
                attacker.isStrengthPummel(this))
            {
                return 0;
            };
            var normalAttack:Boolean = (attackObj.Owner === attacker) ?
                StrengthSystem.isNormalAttackFrame(attackObj.Frame) :
                (attackObj.Owner is Projectile && Projectile(attackObj.Owner).StrengthNormalAttack);
            if (!normalAttack)
            {
                return 0;
            };
            return StrengthSystem.getDizzyDuration(ratio);
        }

        private function applyStrengthDizzy(frames:int):void
        {
            if (frames <= 0 || this.isInvincible() || isIntangible() ||
                this.m_characterStats.StatusEffectImmunity || inState(CState.DEAD) ||
                inState(CState.STAMINA_KO) || inState(CState.BARREL) || inState(CState.CAUGHT) ||
                inState(CState.FROZEN) || inState(CState.EGG))
            {
                return;
            };
            // Apply after every launch/stack/crash calculation, so those cannot overwrite it.
            this.m_strengthDizzyTimer = frames;
            this.m_dizzyTimer = frames;
            this.m_dizzyShield = false;
            this.m_forceTumbleFall = false;
            this.m_forcedCrash = false;
            this.m_hitLagCanCancelWithJump = false;
            this.m_hitLagCanCancelWithUpB = false;
            this.killAllSpeeds();
            this.setState(CState.DIZZY);
            this.stopActionShot();
            this.m_stunCancelTimer.reset();
            this.resetRotation();
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
        }

        private function getStrengthAttacker(attackObj:AttackDamage):Character
        {
            if (attackObj.Owner is Character)
            {
                return Character(attackObj.Owner);
            }
            var owner:InteractiveSprite = attackObj.Owner;
            var depth:int = 0;
            while (owner is Projectile && depth < 8)
            {
                // Reflections retain the original projectile owner; use the credited player.
                if (Projectile(owner).WasReversed)
                {
                    return (attackObj.PlayerID > 0) ? STAGEDATA.getPlayerByID(attackObj.PlayerID) : null;
                }
                owner = Projectile(owner).getOwner();
                depth++;
            }
            return (owner is Character) ? Character(owner) : null;
        }

        public function grabReleaseOpponent():void
        {
            var attackObj:AttackDamage;
            var i:int;
            var _local_3:Character;
            if (((this.m_grabbed.length > 0) && (!(this.m_internalGrabLock))))
            {
                attackObj = new AttackDamage(m_player_id, this);
                attackObj.AttackID = Utils.getUID();
                attackObj.IsForward = m_facingForward;
                attackObj.Damage = 0;
                attackObj.Direction = 60;
                attackObj.XLoc = m_sprite.x;
                attackObj.YLoc = m_sprite.y;
                attackObj.Power = 14;
                attackObj.WeightKB = 40;
                attackObj.KBConstant = 60;
                attackObj.DisableHurtSound = true;
                attackObj.ReversableAngle = false;
                attackObj.BypassHeavyArmor = true;
                attackObj.BypassSuperArmor = true;
                attackObj.BypassLaunchResistance = true;
                i = 0;
                while (i < this.m_grabbed.length)
                {
                    _local_3 = this.m_grabbed[i];
                    _local_3.setState(CState.IDLE);
                    attackObj.AttackRatio = (1 / _local_3.CharacterStats.DamageRatio);
                    _local_3.takeDamage(attackObj);
                    _local_3.setVisibility(true);
                    _local_3.resetMovement();
                    i++;
                };
                this.releaseOpponent();
            };
        }

        public function grabRelease(windBox:Boolean=false):void
        {
            this.m_strengthGrabLocked = false;
            var attackObj:AttackDamage;
            attackObj = new AttackDamage(-1, this);
            attackObj.AttackID = Utils.getUID();
            attackObj.Damage = 0;
            attackObj.Direction = 0;
            attackObj.IsForward = (!(m_facingForward));
            attackObj.XLoc = ((attackObj.IsForward) ? (m_sprite.x + 5) : (m_sprite.x - 5));
            attackObj.YLoc = m_sprite.y;
            attackObj.Power = 7;
            attackObj.WeightKB = 40;
            attackObj.KBConstant = 60;
            attackObj.DisableHurtFallOff = true;
            attackObj.DisableLastHitUpdate = true;
            attackObj.DisableHurtSound = true;
            attackObj.ReversableAngle = false;
            attackObj.BypassHeavyArmor = true;
            attackObj.BypassSuperArmor = true;
            attackObj.BypassLaunchResistance = true;
            attackObj.AttackRatio = (1 / this.m_characterStats.DamageRatio);
            if (windBox)
            {
                attackObj.HasEffect = false;
            }
            else
            {
                this.setState(CState.IDLE);
            };
            this.takeDamage(attackObj);
        }

        private function m_charGrab():void
        {
            var i:int;
            var loss:int;
            var tmpString:String;
            var tmpString2:String;
            if (((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (!(inState(CState.GRABBING)))))
            {
                return;
            };
            i = 0;
            if (((((((((((((inState(CState.SHIELDING)) && ((this.m_pressedControls.BUTTON2) || (this.m_pressedControls.GRAB))) && (this.m_shieldDelayTimer.IsComplete)) || ((((inState(CState.AIR_DODGE)) && (this.m_pressedControls.BUTTON2)) && (this.m_characterStats.TetherGrab)) && (this.shieldIsPressed()))) || ((!(inState(CState.SHIELDING))) && (this.m_pressedControls.GRAB))) && (!(m_actionShot))) && (this.inFreeState(((((CFreeState.ATTACKING | CFreeState.SHIELDING) | CFreeState.DODGING) | CFreeState.TURNING) | CFreeState.JUMP_CHAMBER)))) && ((!(inState(CState.ATTACKING))) || ((this.isInterruptableAttack()) && (!(m_attack.IsThrow))))) && (!((!(m_collision.ground)) && (!(this.m_characterStats.TetherGrab))))) && (this.m_characterStats.CanThrow)) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.SIDESTEP_DODGE)))))
            {
                if (((this.m_characterStats.TetherGrab) && (!(m_collision.ground))))
                {
                    this.initGrab(true);
                }
                else
                {
                    if ((!(inState(CState.AIR_DODGE))))
                    {
                        this.initGrab();
                    };
                };
            }
            else
            {
                if (inState(CState.GRABBING))
                {
                    if (!(((this.m_grabbed.length == 0) && (m_collision.ground)) && (!(m_attack.IsAirAttack))))
                    {
                        if (this.m_grabbed.length > 0)
                        {
                            if ((((inState(CState.GRABBING)) && (currentFrameIs("grab"))) && (currentStanceFrameIs("attack"))))
                            {
                                this.removeUngrabbedCharacters();
                                this.repositionGrabbedCharacter();
                            };
                            if (((!(m_xSpeed == 0)) && (!(checkLinearPathBetweenPoints(this.m_grabbed[0].Location, new Point((m_sprite.x + ((m_facingForward) ? (((m_width / 2) + this.m_grabbed[0].Width) - 5) : (((-(m_width) / 2) - this.m_grabbed[0].Width) + 5))), (m_sprite.y + this.m_characterStats.KneeYOffset)))))))
                            {
                                m_xSpeed = 0;
                            };
                            if (!this.m_strengthGrabLocked)
                            {
                                this.m_grabTimer--;
                            };
                            this.removeUngrabbedCharacters();
                            i = 0;
                            while (i < this.m_grabbed.length)
                            {
                                if (this.m_grabbed[i].State != CState.CAUGHT)
                                {
                                    this.m_grabbed.splice(i, 1);
                                    i--;
                                }
                                else
                                {
                                    if (!this.m_strengthGrabLocked)
                                    {
                                        loss = this.m_grabbed[i].Struggle();
                                        this.m_grabTimer = (this.m_grabTimer - ((loss > 0) ? loss : 0));
                                    };
                                };
                                i++;
                            };
                            if (this.m_grabbed.length == 0)
                            {
                                this.m_strengthGrabLocked = false;
                                this.setState(CState.IDLE);
                                return;
                            };
                            if (getStanceVar("xframe", "attack"))
                            {
                                m_attack.ExecTime++;
                                m_attack.RefreshRateTimer++;
                            };
                            if (getStanceVar("xframe", "attack"))
                            {
                                this.m_pummelTimer--;
                            }
                            else
                            {
                                this.m_justPummeled = false;
                            };
                            if (((HasTouchBox) && (this.m_grabbed.length > 0)))
                            {
                                this.repositionGrabbedCharacter();
                            };
                            if ((((this.m_grabTimer <= 0) && (inState(CState.GRABBING))) && (this.m_grabbed.length > 0)))
                            {
                                this.grabReleaseOpponent();
                                this.grabRelease();
                            };
                            if ((((inState(CState.GRABBING)) && (this.m_grabbed.length > 0)) && (!(currentStanceFrameIs("attack")))))
                            {
                                if ((((this.m_pressedControls.RIGHT) && (!(this.m_pressedControls.LEFT))) || ((this.m_pressedControls.C_RIGHT) && (!(this.m_pressedControls.C_LEFT)))))
                                {
                                    this.resetRotation();
                                    tmpString = "throw_forward";
                                    if ((!(m_facingForward)))
                                    {
                                        tmpString = "throw_back";
                                    };
                                    this.Attack(tmpString, 1);
                                }
                                else
                                {
                                    if ((((this.m_pressedControls.LEFT) && (!(this.m_pressedControls.RIGHT))) || ((this.m_pressedControls.C_LEFT) && (!(this.m_pressedControls.C_RIGHT)))))
                                    {
                                        this.resetRotation();
                                        tmpString2 = "throw_forward";
                                        if (m_facingForward)
                                        {
                                            tmpString2 = "throw_back";
                                        };
                                        this.Attack(tmpString2, 1);
                                    }
                                    else
                                    {
                                        if (((this.m_pressedControls.DOWN) || (this.m_pressedControls.C_DOWN)))
                                        {
                                            this.resetRotation();
                                            this.Attack("throw_down", 1);
                                        }
                                        else
                                        {
                                            if (((this.m_pressedControls.UP) || (this.m_pressedControls.C_UP)))
                                            {
                                                this.resetRotation();
                                                this.Attack("throw_up", 1);
                                            }
                                            else
                                            {
                                                if ((((this.m_pressedControls.BUTTON2) || (this.m_pressedControls.GRAB)) && (getStanceVar("xframe", "grab"))))
                                                {
                                                    this.resetRotation();
                                                    m_attack.AttackID = Utils.getUID();
                                                    this.stancePlayFrame("attack");
                                                    m_attack.ExecTime = 0;
                                                    this.m_justPummeled = true;
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

        private function repositionGrabbedCharacter(index:int=0):void
        {
            var loc:Point;
            var rect:Rectangle;
            var tmpX:Number;
            var tmpY:Number;
            var pushUp:Number;
            if ((((HasTouchBox) && (this.m_grabbed.length > 0)) && (index < this.m_grabbed.length)))
            {
                loc = new Point((HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.TOUCH)[0]).centerx * m_sprite.scaleX), (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.TOUCH)[0]).centery * m_sprite.scaleY));
                rect = new Rectangle(loc.x, loc.y, 1, 1);
                rect = Utils.rotateRectangleAroundOrigin(rect, (360 - m_sprite.rotation));
                loc.x = (m_sprite.x + rect.x);
                loc.y = (m_sprite.y + rect.y);
                tmpX = (loc.x - m_sprite.x);
                tmpY = (loc.y - m_sprite.y);
                pushUp = 0;
                if (checkLinearPathBetweenPoints(this.m_grabbed[index].Location, new Point(loc.x, loc.y)))
                {
                    this.m_grabbed[index].X = loc.x;
                    this.m_grabbed[index].Y = loc.y;
                }
                else
                {
                    this.m_grabbed[index].X = m_sprite.x;
                    this.m_grabbed[index].Y = m_sprite.y;
                    if (((tmpY < 0) && (this.m_grabbed[index].Ground)))
                    {
                        this.m_grabbed[index].unnattachFromGround();
                    };
                    this.m_grabbed[index].moveSprite(tmpX, 0);
                    this.m_grabbed[index].moveSprite(0, tmpY);
                };
            };
        }

        private function m_charCrouch():void
        {
            var doubleTap:Boolean;
            doubleTap = this.checkDoubleTap(1);
            if ((((inState(CState.LEDGE_HANG)) && (this.m_pressedControls.DOWN)) && (this.m_ledgeHangTimer.CurrentTime > 4)))
            {
                m_ySpeed = 0;
                this.unnattachFromLedge();
                this.resetRotation();
                this.m_fallTiltTimer.reset();
                this.setState(CState.IDLE);
                this.setState(CState.JUMP_FALLING);
            }
            else
            {
                if ((((((this.m_heldControls.DOWN) && (this.inFreeState())) && (m_collision.ground)) && (!(this.isLandingOrSkiddingOrChambering()))) && (!((inState(CState.DASH)) && (m_framesSinceLastState < 4)))))
                {
                    if (inState(CState.DASH))
                    {
                        m_xSpeed = ((m_xSpeed > 0) ? Math.min(this.m_max_xSpeed, m_xSpeed) : ((m_xSpeed < 0) ? Math.max(m_xSpeed, -(this.m_max_xSpeed)) : 0));
                    };
                    this.setState(CState.CROUCH);
                }
                else
                {
                    if ((!(inState(CState.ATTACKING))))
                    {
                        this.m_crouchFrame = -1;
                    };
                };
            };
            if ((((((((((this.inFreeState()) && (m_collision.ground)) && (((doubleTap) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) || (((this.m_heldControls.DOWN) && (this.m_crouchLength >= 15)) && (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))))) && (!(m_currentPlatform == null))) && (!(m_currentPlatform.noDropThrough == true))) && (!(this.isLandingOrSkiddingOrChambering()))) && (!((inState(CState.ATTACKING)) && (m_attack.Rocket)))) && (OnPlatform)) && ((this.m_fallthroughPlatform == null) || (!(m_currentPlatform === this.m_fallthroughPlatform)))))
            {
                this.initFallThrough();
                this.m_crouchFrame = -1;
            };
            if (inState(CState.CROUCH))
            {
                this.m_crouchLength++;
                if (((((this.m_pressedControls.BUTTON2) && (this.m_heldControls.DOWN)) && (this.m_attackDelay <= 0)) && (!(inState(CState.JUMP_CHAMBER)))))
                {
                    this.m_crouchFrame = m_sprite.stance.currentFrame;
                    this.Attack("crouch_attack", 1);
                }
                else
                {
                    if ((!(this.m_heldControls.DOWN)))
                    {
                        this.setState(CState.IDLE);
                    };
                };
            }
            else
            {
                if ((!((inState(CState.ATTACKING)) && (m_attack.Frame == "crouch_attack"))))
                {
                    this.m_crouchLength = 0;
                };
            };
        }

        private function initFallThrough():void
        {
            this.m_justFellThroughPlatform = true;
            this.m_fallthroughPlatform = m_currentPlatform;
            this.unnattachFromGround();
            this.m_fallthroughTimer.reset();
            this.setState(CState.JUMP_FALLING);
        }

        private function initShield():void
        {
            this.grabReleaseOpponent();
            if (this.m_shieldPower < 25)
            {
                this.m_shieldPower = 25;
            };
            this.m_shieldTimer = 0;
            this.m_shieldDelay = 0;
            this.m_resizeShield();
            STAGEDATA.playSpecificSound("shield_brawl");
            this.m_shieldStartTimer = 0;
            if (inState(CState.DASH))
            {
                m_xSpeed = 0;
            };
            this.setState(CState.SHIELDING);
        }

        public function initDodgeRoll(right:Boolean=true):void
        {
            var wasFacingForward:Boolean;
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.m_deactivateShield();
            STAGEDATA.playSpecificSound("roll_brawl");
            wasFacingForward = m_facingForward;
            if (right)
            {
                m_faceLeft();
            }
            else
            {
                m_faceRight();
            };
            this.m_rollTimer = Math.max(1, (this.m_characterStats.DodgeStartup + 1));
            this.setState(CState.DODGE_ROLL);
            if ((((wasFacingForward) && (this.m_heldControls.RIGHT)) || ((!(wasFacingForward)) && (this.m_heldControls.LEFT))))
            {
                if (Utils.hasLabel(m_sprite.stance, "forward"))
                {
                    this.stancePlayFrame("forward");
                };
            };
            this.killAllSpeeds();
        }

        private function initSideStepDodge():void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.m_deactivateShield();
            STAGEDATA.playSpecificSound("brawl_dodge");
            this.setState(CState.SIDESTEP_DODGE);
            this.setIntangibility(true);
        }

        public function isPlayer():Boolean
        {
            return (m_player_id > 0);
        }

        private function initAirDodge():void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            STAGEDATA.playSpecificSound("brawl_dodge");
            this.m_midAirJumpConstantTime.finish();
            this.setState(CState.AIR_DODGE);
        }

        private function m_charShield():void
        {
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return;
            };
            if ((((((((((inState(CState.SHIELDING)) && (m_collision.ground)) && (!(isHitStunOrParalysis()))) && (this.m_shieldDelayTimer.IsComplete)) && (OnPlatform)) && (!(m_currentPlatform.noDropThrough))) && (this.m_shieldTimer > this.m_shieldStartFrame)) && (this.m_heldControls.DASH)) && (this.m_heldControls.DOWN)))
            {
                this.m_deactivateShield();
                this.initFallThrough();
            };
            if (((inState(CState.SHIELDING)) && (this.m_shieldTimer == this.m_shieldStartFrame)))
            {
                this.m_activateShield();
            };
            if (((((((((((this.m_justTechedTimer.IsComplete) && (!(m_collision.ground))) && (this.shieldIsPressed())) && (this.inFreeState(CFreeState.ATTACKING))) && (!((this.HoldingItem) && (!(this.m_item.CanShieldWith))))) && (!(this.isLandingOrSkiddingOrChambering()))) && (this.m_characterStats.CanDodge)) && (!(inState(CState.TUMBLE_FALL)))) && (!(this.isNonInterruptableAttack()))) && (!((STAGEDATA.AirDodge.match(/ultimate|solo|vsolo|double|vdouble/)) && (this.m_airDodgeCount > 0)))))
            {
                this.initAirDodge();
            };
            if (((inState(CState.SIDESTEP_DODGE)) && (!(m_collision.ground))))
            {
                this.setState(CState.TUMBLE_FALL);
            };
            if ((((((((this.shieldIsHeld()) && (m_collision.ground)) && (this.inFreeState())) && (!((this.HoldingItem) && (!(this.m_item.CanShieldWith))))) && (!(this.isLandingOrSkiddingOrChambering()))) && (!(inState(CState.TUMBLE_FALL)))) && (this.m_characterStats.CanShield)))
            {
                this.initShield();
            }
            else
            {
                if ((((((!(this.shieldIsHeld())) && (inState(CState.SHIELDING))) && (!(isHitStunOrParalysis()))) && (this.m_shieldDelayTimer.IsComplete)) && (this.m_shieldTimer > this.m_shieldStartFrame)))
                {
                    this.m_deactivateShield();
                    this.m_shieldDropLag.reset();
                    this.setState(CState.SHIELD_DROP);
                };
            };
            if (((((inState(CState.SHIELDING)) || (inState(CState.DODGE_ROLL))) || (inState(CState.AIR_DODGE))) || (inState(CState.SIDESTEP_DODGE))))
            {
                this.m_shieldDelay++;
            };
            if (((inState(CState.SHIELDING)) && (this.m_shieldTimer >= this.m_shieldStartFrame)))
            {
                if ((((((((!((this.HoldingItem) && (!(this.m_item.CanJumpWith)))) && (this.m_jumpCount < this.m_characterStats.MaxJump)) && ((this.m_jumpSpeedMidairDelay.IsComplete) || ((this.m_characterStats.HoldJump) && (getStanceVar("done", true))))) && (this.jumpIsPressed())) && (m_collision.ground)) && (this.m_shieldTimer >= (this.m_shieldStartFrame + 1))) && (this.m_shieldDelayTimer.IsComplete)))
                {
                    this.m_deactivateShield();
                    this.jumpChamber();
                    this.compactControlsBuffer();
                }
                else
                {
                    if ((((((((this.m_pressedControls.LEFT) && (!(this.m_pressedControls.RIGHT))) && (this.m_characterStats.CanDodge)) && (!(this.m_pressedControls.GRAB))) && (this.m_shieldDelayTimer.IsComplete)) && (!(isHitStunOrParalysis()))) && (m_collision.ground)))
                    {
                        this.initDodgeRoll(false);
                    }
                    else
                    {
                        if (((((((((((this.m_pressedControls.RIGHT) && (!(this.m_pressedControls.LEFT))) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.SIDESTEP_DODGE)))) && (this.m_characterStats.CanDodge)) && (!(this.m_pressedControls.GRAB))) && (this.m_shieldDelayTimer.IsComplete)) && (!(isHitStunOrParalysis()))) && (m_collision.ground)))
                        {
                            this.initDodgeRoll(true);
                        }
                        else
                        {
                            if (((((((this.m_pressedControls.DOWN) && (this.m_characterStats.CanDodge)) && (!(this.m_pressedControls.GRAB))) && (this.m_shieldDelayTimer.IsComplete)) && (!(isHitStunOrParalysis()))) && (m_collision.ground)))
                            {
                                this.initSideStepDodge();
                            };
                        };
                    };
                };
            };
            if (inState(CState.SHIELD_DROP))
            {
                this.m_shieldDropLag.tick();
                if (this.m_shieldDropLag.IsComplete)
                {
                    this.setState(CState.IDLE);
                };
            };
            if ((!(inState(CState.SHIELDING))))
            {
                if ((((((this.m_shieldPower < 100) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.SIDESTEP_DODGE)))) && (!(inState(CState.GRABBING)))))
                {
                    this.m_shieldPower = (this.m_shieldPower + (0.14 * 2));
                };
            };
        }

        private function m_activateShield():void
        {
            if ((!(this.m_characterStats.CustomShield)))
            {
                this.m_shieldHolderMC.scaleX = (m_sizeRatio * this.m_characterStats.ShieldScale);
                this.m_shieldHolderMC.scaleY = (m_sizeRatio * this.m_characterStats.ShieldScale);
                this.m_shieldHolderMC.x = ((m_facingForward) ? (m_sprite.x + (this.m_characterStats.ShieldXOffset * m_sizeRatio)) : (m_sprite.x - (this.m_characterStats.ShieldXOffset * m_sizeRatio)));
                this.m_shieldHolderMC.y = ((m_sprite.y - ((m_height / 3) * m_sizeRatio)) + (this.m_characterStats.ShieldYOffset * m_sizeRatio));
                this.m_shield_originalWidth = this.m_shieldHolderMC.width;
                this.m_shield_originalHeight = this.m_shieldHolderMC.height;
                this.m_resizeShield();
                STAGE.addChild(this.m_shieldHolderMC);
            };
        }

        private function m_deactivateShield():void
        {
            if (this.m_shieldHolderMC.parent)
            {
                this.m_shieldHolderMC.parent.removeChild(this.m_shieldHolderMC);
            };
        }

        private function m_resizeShield():void
        {
            var totalFrames:int;
            var targetFrame:int;
            if ((!(this.m_characterStats.CustomShield)))
            {
                this.m_shieldHolderMC.width = (this.m_shield_originalWidth * (((this.m_shieldPower / 100) * (this.m_characterStats.MaxShieldSize - this.m_characterStats.MinShieldSize)) + this.m_characterStats.MinShieldSize));
                this.m_shieldHolderMC.height = (this.m_shield_originalHeight * (((this.m_shieldPower / 100) * (this.m_characterStats.MaxShieldSize - this.m_characterStats.MinShieldSize)) + this.m_characterStats.MinShieldSize));
                this.m_shieldHolderMC.x = ((m_facingForward) ? (m_sprite.x + (this.m_characterStats.ShieldXOffset * m_sizeRatio)) : (m_sprite.x - (this.m_characterStats.ShieldXOffset * m_sizeRatio)));
                this.m_shieldHolderMC.y = ((m_sprite.y - ((m_height / 3) * m_sizeRatio)) + (this.m_characterStats.ShieldYOffset * m_sizeRatio));
            }
            else
            {
                if (this.m_characterStats.CustomShield)
                {
                    if (((currentFrameIs("defend")) && (HasStance)))
                    {
                        totalFrames = m_sprite.stance.totalFrames;
                        targetFrame = 0;
                        if (("startup" in m_sprite.stance))
                        {
                            if (!m_sprite.stance.startup)
                            {
                                targetFrame = ((this.m_characterStats.CustomShieldStartup + 1) + Math.ceil(((1 - (this.m_shieldPower / 100)) * (totalFrames - this.m_characterStats.CustomShieldStartup))));
                                if (((targetFrame >= 1) && (targetFrame <= totalFrames)))
                                {
                                    m_sprite.stance.gotoAndStop(targetFrame);
                                };
                            };
                        }
                        else
                        {
                            targetFrame = Math.ceil(((1 - (this.m_shieldPower / 100)) * totalFrames));
                            if (((targetFrame >= 1) && (targetFrame <= totalFrames)))
                            {
                                m_sprite.stance.gotoAndStop(targetFrame);
                            };
                        };
                    };
                };
            };
        }

        private function m_breakShield():void
        {
            var attackState:AttackDamage;
            this.m_deactivateShield();
            this.setState(CState.IDLE);
            attackState = new AttackDamage(m_player_id, this);
            attackState.importAttackDamageData({
                "power":this.m_characterStats.ShieldBreakPower,
                "kbConstant":this.m_characterStats.ShieldBreakKBConstant,
                "weightKB":this.m_characterStats.ShieldBreakWeightKB,
                "atk_id":-1,
                "isForward":(!(m_facingForward)),
                "direction":90,
                "dizzy":90,
                "xloc":m_sprite.x,
                "yloc":m_sprite.y,
                "hurtSelf":true,
                "bypassHeavyArmor":true
            });
            this.killAllSpeeds();
            this.m_shieldPower = 60;
            this.takeDamage(attackState);
            this.playGlobalSound("shieldbreak");
            this.m_dizzyShield = true;
            this.setInvincibility(true);
            this.m_revivalInvincibility.reset();
            this.m_revivalInvincibility.CurrentTime = (this.m_revivalInvincibility.MaxTime - 15);
        }

        private function removeChargeGlow():void
        {
            var found:Boolean;
            var ob:*;
            if (this.m_chargeGlowHolderMC == null)
            {
                return;
            };
            found = false;
            for (ob in m_attack.ChargedAttacks)
            {
                if (((!(found)) && (this.attackIsCharged(ob))))
                {
                    found = true;
                };
            };
            if ((!(found)))
            {
                toggleEffect(this.m_chargeGlowHolderMC, false);
                this.m_chargeGlowHolderMC = null;
            };
        }

        override public function isInvincible():Boolean
        {
            return (((((((inState(CState.ATTACKING)) && (getStanceVar("canHurt", false))) || (m_invincible)) || ((inState(CState.ATTACKING)) && (m_attack.Invincible))) || (!(this.m_revivalInvincibility.IsComplete))) || (!(this.m_starmanInvincibilityTimer.IsComplete))) ? true : false);
        }

        public function initRoll(toTheRight:Boolean):void
        {
            var wasFacingForward:Boolean;
            STAGEDATA.playSpecificSound("roll_brawl");
            wasFacingForward = m_facingForward;
            if (toTheRight)
            {
                m_faceLeft();
            }
            else
            {
                m_faceRight();
            };
            this.m_rollTimer = Math.max(1, this.m_characterStats.GetupRollDelay);
            this.setState(CState.ROLL);
            if ((((wasFacingForward) && (this.m_heldControls.RIGHT)) || ((!(wasFacingForward)) && (this.m_heldControls.LEFT))))
            {
                if (Utils.hasLabel(m_sprite.stance, "forward"))
                {
                    this.stancePlayFrame("forward");
                };
            };
        }

        private function initTechRoll(toTheRight:Boolean):void
        {
            var wasFacingForward:Boolean;
            this.killAllSpeeds();
            STAGEDATA.playSpecificSound("roll_brawl");
            wasFacingForward = m_facingForward;
            if (toTheRight)
            {
                m_faceLeft();
            }
            else
            {
                m_faceRight();
            };
            this.m_rollTimer = Math.max(1, this.m_characterStats.TechRollDelay);
            this.setState(CState.TECH_ROLL);
            if ((((wasFacingForward) && (this.m_heldControls.RIGHT)) || ((!(wasFacingForward)) && (this.m_heldControls.LEFT))))
            {
                if (Utils.hasLabel(m_sprite.stance, "forward"))
                {
                    this.stancePlayFrame("forward");
                };
            };
            this.m_justTechedTimer.reset();
        }

        private function m_charRoll():void
        {
            var total:Number;
            var tmpDiff:Number;
            if ((((inState(CState.LEDGE_HANG)) && (this.shieldIsPressed())) && (this.m_ledgeHangTimer.CurrentTime > 4)))
            {
                this.m_ledgeHangTimer.reset();
                this.m_rollTimer = Math.max(1, this.m_characterStats.ClimbRollDelay);
                m_sprite.x = (m_sprite.x + ((m_facingForward) ? 4 : -4));
                m_sprite.y = (m_sprite.y + 5);
                total = 0;
                while (((!(testTerrainWithCoord(m_sprite.x, m_sprite.y))) && (total < 10)))
                {
                    m_sprite.x = (m_sprite.x + ((m_facingForward) ? 1 : -1));
                    total++;
                };
                if (total >= 10)
                {
                    m_sprite.x = (m_sprite.x - ((m_facingForward) ? total : -(total)));
                };
                attachToGround();
                this.setState(CState.LEDGE_ROLL);
            }
            else
            {
                if ((((inState(CState.LEDGE_HANG)) && (((m_facingForward) && (this.m_pressedControls.RIGHT)) || ((!(m_facingForward)) && (this.m_pressedControls.LEFT)))) && (this.m_ledgeHangTimer.CurrentTime > 4)))
                {
                    this.m_ledgeHangTimer.reset();
                    m_sprite.x = (m_sprite.x + ((m_facingForward) ? 4 : -4));
                    m_sprite.y = (m_sprite.y + 5);
                    total = 0;
                    while (((!(testTerrainWithCoord(m_sprite.x, m_sprite.y))) && (total < 10)))
                    {
                        m_sprite.x = (m_sprite.x + ((m_facingForward) ? 2 : -2));
                        total++;
                    };
                    if (total >= 10)
                    {
                        m_sprite.x = (m_sprite.x - ((m_facingForward) ? total : -(total)));
                    };
                    m_collision.ground = true;
                    this.m_groundCollisionTest();
                    this.setState(CState.LEDGE_CLIMB);
                }
                else
                {
                    if (((((m_collision.ground) && (inState(CState.CRASH_LAND))) && (!(this.m_pressedControls.RIGHT == this.m_pressedControls.LEFT))) && (this.m_crashTimer.IsComplete)))
                    {
                        this.initRoll(this.m_pressedControls.RIGHT);
                    }
                    else
                    {
                        if ((((inState(CState.LEDGE_ROLL)) || (inState(CState.ROLL))) && (!(isHitStunOrParalysis()))))
                        {
                            attachToGround();
                            this.m_rollTimer--;
                            if (this.m_rollTimer == 0)
                            {
                                m_xSpeed = ((m_facingForward) ? this.m_characterStats.RollSpeed : -(this.m_characterStats.RollSpeed));
                                this.m_currentRollSpeed = m_xSpeed;
                                if (inState(CState.ROLL))
                                {
                                    m_xSpeed = (m_xSpeed * -1);
                                    this.m_currentRollSpeed = m_xSpeed;
                                };
                            }
                            else
                            {
                                if (this.m_rollTimer < 0)
                                {
                                    m_xSpeed = this.m_currentRollSpeed;
                                    if (m_currentPlatform)
                                    {
                                        m_xSpeed = ((m_xSpeed < 0) ? -(Math.abs(((-(m_xSpeed) * this.m_characterStats.RollDecay) * m_currentPlatform.accel_friction))) : ((m_xSpeed * this.m_characterStats.RollDecay) * m_currentPlatform.accel_friction));
                                    }
                                    else
                                    {
                                        m_xSpeed = ((m_xSpeed < 0) ? -(Math.abs((-(m_xSpeed) * this.m_characterStats.RollDecay))) : (m_xSpeed * this.m_characterStats.RollDecay));
                                    };
                                    this.m_currentRollSpeed = m_xSpeed;
                                    this.m_currentRollSpeed = (Math.round((m_xSpeed * 10)) / 10);
                                    if (((inState(CState.ROLL)) && (Utils.fastAbs(this.m_currentRollSpeed) < 0.5)))
                                    {
                                        m_xSpeed = 0;
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (((inState(CState.TECH_ROLL)) && (!(isHitStunOrParalysis()))))
                            {
                                attachToGround();
                                this.m_rollTimer--;
                                if (this.m_rollTimer == 0)
                                {
                                    m_xSpeed = ((m_facingForward) ? -(this.m_characterStats.RollSpeed) : this.m_characterStats.RollSpeed);
                                    this.m_currentRollSpeed = m_xSpeed;
                                }
                                else
                                {
                                    m_xSpeed = this.m_currentRollSpeed;
                                    if (m_currentPlatform)
                                    {
                                        m_xSpeed = ((m_xSpeed < 0) ? -(Math.abs(((-(m_xSpeed) * this.m_characterStats.RollDecay) * m_currentPlatform.accel_friction))) : ((m_xSpeed * this.m_characterStats.RollDecay) * m_currentPlatform.accel_friction));
                                    }
                                    else
                                    {
                                        m_xSpeed = ((m_xSpeed < 0) ? -(Math.abs((-(m_xSpeed) * this.m_characterStats.RollDecay))) : (m_xSpeed * this.m_characterStats.RollDecay));
                                    };
                                    this.m_currentRollSpeed = m_xSpeed;
                                    this.m_currentRollSpeed = (Math.round((m_xSpeed * 10)) / 10);
                                    if (Utils.fastAbs(this.m_currentRollSpeed) < 0.5)
                                    {
                                        m_xSpeed = 0;
                                    };
                                };
                            }
                            else
                            {
                                if (((inState(CState.DODGE_ROLL)) && (!(isHitStunOrParalysis()))))
                                {
                                    attachToGround();
                                    this.m_rollTimer--;
                                    if (this.m_rollTimer == 0)
                                    {
                                        m_xSpeed = ((m_facingForward) ? -(this.m_characterStats.DodgeSpeed) : this.m_characterStats.DodgeSpeed);
                                        this.m_currentRollSpeed = m_xSpeed;
                                    }
                                    else
                                    {
                                        if (this.m_characterStats.DodgeDecel > 0)
                                        {
                                            this.m_currentRollSpeed = ((this.m_currentRollSpeed < 0) ? -(Math.abs((-(this.m_currentRollSpeed) * this.m_characterStats.DodgeDecel))) : (this.m_currentRollSpeed * this.m_characterStats.DodgeDecel));
                                        }
                                        else
                                        {
                                            if (this.m_characterStats.DodgeDecel < 0)
                                            {
                                                if (this.m_currentRollSpeed !== 0)
                                                {
                                                    tmpDiff = ((this.m_currentRollSpeed > 0) ? this.m_characterStats.DodgeDecel : -(this.m_characterStats.DodgeDecel));
                                                    this.m_currentRollSpeed = (this.m_currentRollSpeed + tmpDiff);
                                                    if ((((this.m_currentRollSpeed < 0) && ((this.m_currentRollSpeed - tmpDiff) > 0)) || ((this.m_currentRollSpeed > 0) && ((this.m_currentRollSpeed - tmpDiff) < 0))))
                                                    {
                                                        this.m_currentRollSpeed = 0;
                                                    };
                                                };
                                            };
                                        };
                                        m_xSpeed = this.m_currentRollSpeed;
                                        this.m_currentRollSpeed = (Math.round((m_xSpeed * 10)) / 10);
                                        if (Utils.fastAbs(this.m_currentRollSpeed) < 0.5)
                                        {
                                            m_xSpeed = 0;
                                        };
                                        if ((((((inState(CState.DODGE_ROLL)) && (this.m_rollTimer > -9)) && (this.m_rollTimer < 0)) && ((((((this.m_pressedControls.GRAB) || ((this.shieldIsHeld()) && (this.m_pressedControls.BUTTON2))) || (this.m_pressedControls.C_UP)) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_RIGHT)) || (this.m_pressedControls.C_LEFT))) && (this.m_item)))
                                        {
                                            this.toToss();
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

        private function initLedgeGrab(ledge:MovieClip):void
        {
            var ledgeFrame:String;
            this.attackCollisionTest();
            m_attackCollisionTestsPreProcessed = true;
            ledgeFrame = null;
            this.m_jumpSpeedBuffer = 0;
            if (inState(CState.ATTACKING))
            {
                ledgeFrame = m_attack.LedgeFrame;
                this.forceEndAttack();
            };
            m_attack.Rocket = false;
            this.m_ledge = ledge;
            this.m_ledgeDelay.reset();
            this.m_glideReady = true;
            this.playGlobalSound("common_cliffcatch");
            this.playCharacterSound("ledge_grab");
            setBrightness(0);
            this.resetRotation();
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            if (inState(CState.SHIELDING))
            {
                this.m_deactivateShield();
            };
            if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
            {
                STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
            };
            this.m_jumpCount = 0;
            this.m_airDodgeCount = 0;
            this.m_wallJumpCount = 0;
            this.m_wallStickTime.MaxTime = this.m_characterStats.WallStick;
            this.m_midAirJumpConstantTime.finish();
            this.m_canHover = true;
            this.grabReleaseOpponent();
            m_currentPlatform = null;
            m_collision.ground = false;
            this.resetMovement();
            this.clearControlsBuffer();
            this.setIntangibility(true);
            this.setState(CState.LEDGE_HANG);
            if (ledgeFrame)
            {
                this.stancePlayFrame(ledgeFrame);
            };
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_LEDGE_GRAB, {"caller":this.APIInstance.instance}));
        }

        private function attachToLedge(left:Boolean):void
        {
            var distance:Number;
            if (this.m_ledge)
            {
                distance = Point.distance(new Point(this.m_ledge.x, this.m_ledge.y), new Point(m_sprite.x, m_sprite.y));
                if (distance > 500)
                {
                    this.unnattachFromLedge();
                    this.setState(CState.IDLE);
                    this.m_ledge = null;
                    this.m_lastLedge = null;
                    return;
                };
                m_sprite.x = this.m_ledge.x;
                m_sprite.y = this.m_ledge.y;
                if (this.m_chargeGlowHolderMC != null)
                {
                    this.m_chargeGlowHolderMC.x = m_sprite.x;
                    this.m_chargeGlowHolderMC.y = (m_sprite.y + m_height);
                };
                if (this.HasFinalSmash)
                {
                    this.m_fsGlowHolderMC.x = m_sprite.x;
                    this.m_fsGlowHolderMC.y = (m_sprite.y + m_height);
                };
                this.m_ledgeHangTimer.reset();
                this.killAllSpeeds();
                if (left)
                {
                    m_faceRight();
                }
                else
                {
                    m_faceLeft();
                };
                this.m_midAirJumpConstantTime.finish();
            };
        }

        private function m_charHang():void
        {
            var i:int;
            var j:int;
            var taken:Boolean;
            if (((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) || (!(this.m_characterStats.CanGrabLedges))))
            {
                return;
            };
            i = 0;
            j = 0;
            var k:int;
            taken = false;
            if (((((!(inState(CState.LEDGE_HANG))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.LEDGE_CLIMB)))) && (!(this.m_ledgeDelay.IsComplete))))
            {
                this.m_ledgeDelay.tick();
                if (this.m_ledgeDelay.IsComplete)
                {
                    this.m_lastLedge = null;
                };
            };
            if ((((((((!(this.m_heldControls.DOWN)) && (this.m_ledgeDelay.IsComplete)) && (!(m_collision.ground))) && (!(this.m_standby))) && (!((this.HoldingItem) && (!(this.m_item.CanHangWith))))) && (this.inFreeState((CFreeState.ATTACKING | CFreeState.DISABLED)))) && (!((!(inState(CState.ATTACKING))) && (m_ySpeed < 0)))))
            {
                i = 0;
                while (((i < this.m_ledges[0].length) && (!(inState(CState.LEDGE_HANG)))))
                {
                    taken = false;
                    j = 0;
                    while (((j < STAGEDATA.Characters.length) && (!(taken))))
                    {
                        if (STAGEDATA.Characters[j].Ledge == this.m_ledges[0][i])
                        {
                            taken = true;
                        };
                        j++;
                    };
                    if ((((((!(taken)) && ((m_sprite.x < this.m_ledges[0][i].x) || ((inState(CState.ATTACKING)) && (m_attack.CanGrabInverseLedges)))) && (!(this.m_lastLedge == this.m_ledges[0][i]))) && (!((inState(CState.GRABBING)) && (!(m_facingForward))))) && (!((((inState(CState.ATTACKING)) && (!(m_facingForward))) && (m_attack.FacedLedgesOnly)) && (m_sprite.x > this.m_ledges[0][i].x)))))
                    {
                        if (((HasHand) && (HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAND), HitBoxAnimation(this.m_ledges[0][i].hitBoxAnim).getHitBoxes(1, HitBoxSprite.LEDGE), Location, new Point(this.m_ledges[0][i].x, this.m_ledges[0][i].y), (!(m_facingForward)), false, CurrentScale, new Point(1, 1), CurrentRotation, 0).length > 0)))
                        {
                            this.initLedgeGrab(this.m_ledges[0][i]);
                            i = (i - 1);
                        };
                    };
                    i++;
                };
                if (inState(CState.LEDGE_HANG))
                {
                    this.attachToLedge(true);
                }
                else
                {
                    i = 0;
                    while (((i < this.m_ledges[1].length) && (!(inState(CState.LEDGE_HANG)))))
                    {
                        taken = false;
                        j = 0;
                        while (((j < STAGEDATA.Characters.length) && (!(taken))))
                        {
                            if (STAGEDATA.Characters[j].Ledge == this.m_ledges[1][i])
                            {
                                taken = true;
                            };
                            j++;
                        };
                        if ((((((!(taken)) && ((m_sprite.x > this.m_ledges[1][i].x) || ((inState(CState.ATTACKING)) && (m_attack.CanGrabInverseLedges)))) && (!(this.m_lastLedge == this.m_ledges[1][i]))) && (!((inState(CState.GRABBING)) && (m_facingForward)))) && (!((((inState(CState.ATTACKING)) && (m_facingForward)) && (m_attack.FacedLedgesOnly)) && (m_sprite.x < this.m_ledges[1][i].x)))))
                        {
                            if (((HasHand) && (HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAND), HitBoxAnimation(this.m_ledges[1][i].hitBoxAnim).getHitBoxes(1, HitBoxSprite.LEDGE), Location, new Point(this.m_ledges[1][i].x, this.m_ledges[1][i].y), (!(m_facingForward)), false, CurrentScale, new Point(1, 1), CurrentRotation, 0).length > 0)))
                            {
                                this.initLedgeGrab(this.m_ledges[1][i]);
                                i = (i - 1);
                            };
                        };
                        i++;
                    };
                    if (inState(CState.LEDGE_HANG))
                    {
                        this.attachToLedge(false);
                    };
                };
            };
        }

        override public function unnattachFromGround():void
        {
            var oldPlatform:Platform;
            var yPlatformDiff:Number;
            oldPlatform = m_currentPlatform;
            super.unnattachFromGround();
            if (((oldPlatform) && (oldPlatform is MovingPlatform)))
            {
                yPlatformDiff = (MovingPlatform(oldPlatform).Y - MovingPlatform(oldPlatform).PreviousY);
                if (MovingPlatform(oldPlatform).conserve_horizontal_momentum)
                {
                    m_xSpeed = (m_xSpeed + (MovingPlatform(oldPlatform).X - MovingPlatform(oldPlatform).PreviousX));
                };
                if (((MovingPlatform(oldPlatform).conserve_upward_momentum) && (yPlatformDiff < 0)))
                {
                    m_ySpeed = (m_ySpeed + yPlatformDiff);
                };
                if (((MovingPlatform(oldPlatform).conserve_downward_momentum) && (yPlatformDiff > 0)))
                {
                    m_ySpeed = (m_ySpeed + yPlatformDiff);
                };
            };
        }

        private function unnattachFromLedge():void
        {
            if (this.m_ledge != null)
            {
                m_sprite.y = (m_sprite.y + ((m_height * 1.25) * m_sizeRatio));
                m_sprite.x = (m_sprite.x + ((m_facingForward) ? (-(m_width) * m_sizeRatio) : (m_width * m_sizeRatio)));
                this.m_lastLedge = this.m_ledge;
                this.m_ledge = null;
            };
        }

        private function m_checkTeching():void
        {
            var wasDone:Boolean;
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return;
            };
            if (this.m_canTech)
            {
                if (this.m_techReady)
                {
                    wasDone = this.m_techTimer.IsComplete;
                    this.m_techTimer.tick();
                    if (((this.m_techTimer.IsComplete) && (wasDone)))
                    {
                        this.m_techReady = false;
                    }
                    else
                    {
                        if (((this.m_techLetGo) && (this.shieldIsPressed())))
                        {
                            this.m_techReady = false;
                            this.m_canTech = false;
                            this.m_techDelay.reset();
                            this.m_techLetGo = false;
                        };
                    };
                    if (((this.m_techReady) && (!(this.shieldIsPressed()))))
                    {
                        this.m_techLetGo = true;
                    };
                }
                else
                {
                    if (this.m_techDelay.IsComplete)
                    {
                        if (((this.m_techLetGo) && (this.shieldIsPressed())))
                        {
                            this.m_techLetGo = false;
                            this.m_techReady = true;
                            this.m_techTimer.reset();
                            this.m_techDelay.reset();
                        }
                        else
                        {
                            if ((!(this.shieldIsPressed())))
                            {
                                this.m_techLetGo = true;
                            };
                        };
                    }
                    else
                    {
                        this.m_techDelay.tick();
                    };
                };
            }
            else
            {
                this.m_techDelay.tick();
                if (this.m_techDelay.IsComplete)
                {
                    this.m_canTech = true;
                    this.m_techDelay.reset();
                };
            };
        }

        override public function willFallOffRange(x_loc:Number, y_loc:Number, range:int=5, angleTolerance:int=85):Boolean
        {
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return (false);
            };
            return (super.willFallOffRange(x_loc, y_loc, range, angleTolerance));
        }

        override protected function decel_knockback():void
        {
            var wasRight:Boolean;
            var wasUp:Boolean;
            if (((m_xKnockback == 0) && (m_yKnockback == 0)))
            {
                return;
            };
            wasRight = (m_xKnockback > 0);
            wasUp = (m_yKnockback < 0);
            if (m_xKnockback != 0)
            {
                m_xKnockback = (m_xKnockback + m_xKnockbackDecay);
            };
            if (m_yKnockback != 0)
            {
                m_yKnockback = (m_yKnockback + m_yKnockbackDecay);
            };
            if (((((wasRight) && (m_xKnockback < 0)) || ((!(wasRight)) && (m_xKnockback > 0))) || (Utils.fastAbs(m_xKnockback) < 0.0001)))
            {
                m_xKnockback = 0;
            };
            if (((((wasUp) && (m_yKnockback > 0)) || ((!(wasUp)) && (m_yKnockback < 0))) || (Utils.fastAbs(m_yKnockback) < 0.0001)))
            {
                m_yKnockback = 0;
            };
        }

        protected function playHurtFrame(frame:String=null):void
        {
            if (((inState(CState.INJURED)) || (inState(CState.CAUGHT))))
            {
                if (frame)
                {
                    this.stancePlayFrame(frame);
                }
                else
                {
                    this.stancePlayFrame(("hurt" + Utils.randomInteger(1, this.m_characterStats.HurtFrames)));
                };
            };
        }

        override protected function m_forces():void
        {
            var angle:Number;
            var tmpAng:Number;
            var xs:Number;
            var ys:Number;
            var tmpMC:MovieClip;
            if (((((!(inState(CState.CAUGHT))) && (!(inState(CState.BARREL)))) && (!(isHitStunOrParalysis()))) && (!(inState(CState.DEAD)))))
            {
                if ((((inKnockback()) && (m_collision.ground)) && (m_yKnockback > 0)))
                {
                    m_yKnockback = 0;
                };
                if (((!((((m_collision.ground) && ((inState(CState.FLYING)) || (inState(CState.INJURED)))) && (this.m_disableHurtFallOff)) && (this.willFallOffRange((m_sprite.x + m_xKnockback), m_sprite.y)))) && (!((((inState(CState.ATTACKING)) && (!(m_attack.CanFallOff))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (this.willFallOffRange((m_sprite.x + m_xKnockback), m_sprite.y))))))
                {
                    this.m_attemptToMove(m_xKnockback, 0);
                };
                this.m_attemptToMove(0, m_yKnockback);
                this.decel_knockback();
                if (Main.FRAMERATE == 30)
                {
                    if (((!((((m_collision.ground) && ((inState(CState.FLYING)) || (inState(CState.INJURED)))) && (this.m_disableHurtFallOff)) && (this.willFallOffRange((m_sprite.x + m_xKnockback), m_sprite.y)))) && (!((((inState(CState.ATTACKING)) && (!(m_attack.CanFallOff))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (this.willFallOffRange((m_sprite.x + m_xKnockback), m_sprite.y))))))
                    {
                        this.m_attemptToMove(m_xKnockback, 0);
                    };
                    this.m_attemptToMove(0, m_yKnockback);
                    this.decel_knockback();
                };
                if (((inState(CState.FLYING)) || (inState(CState.INJURED))))
                {
                    if (((!(isHitStunOrParalysis())) && (inState(CState.INJURED))))
                    {
                        this.m_hitLagLandDelay.tick();
                    };
                    if (((this.netYSpeed(false, false) >= 0) && (!(this.m_hasArced))))
                    {
                        this.m_dustTimer.finish();
                        this.m_hasArced = true;
                    };
                    if ((((inState(CState.FLYING)) && (this.m_calcAngles)) && (currentFrameIs("flying"))))
                    {
                        angle = Utils.getAngleBetween(new Point(0, 0), new Point(this.netXSpeed(), this.netYSpeed()));
                        tmpAng = Utils.forceBase360(((!(m_facingForward)) ? -(angle) : (-(angle) + 180)));
                        m_sprite.rotation = tmpAng;
                    };
                    if ((((this.m_hitLag <= 0) && (!(isHitStunOrParalysis()))) && (!(((inState(CState.INJURED)) && (!(this.m_hitLagLandDelay.IsComplete))) && (!(this.m_forceTumbleFall))))))
                    {
                        if (((this.m_forceTumbleFall) && (m_collision.ground)))
                        {
                            this.initiateCrash();
                        }
                        else
                        {
                            if ((((inState(CState.FLYING)) || (this.m_forceTumbleFall)) && (!(m_collision.ground))))
                            {
                                this.resetRotation();
                                this.m_fallTiltTimer.reset();
                                this.setState(CState.TUMBLE_FALL);
                            }
                            else
                            {
                                this.setState(CState.IDLE);
                            };
                        };
                        this.resetRotation();
                        this.m_hitLagLandDelay.reset();
                    };
                };
                if (((((inState(CState.FLYING)) && (inKnockback())) && (this.m_starKOTimer.IsComplete)) && (!(this.m_dustTimer.IsComplete))))
                {
                    xs = this.netXSpeed();
                    ys = this.netYSpeed();
                    this.m_dustTimer.tick();
                    if (((STAGEDATA.getQualitySettings().knockback_smoke) && (Math.sqrt((Math.pow(ys, 2) + Math.pow(xs, 2))) >= 2)))
                    {
                        tmpMC = STAGEDATA.attachEffectOverlay("dust");
                        tmpMC.width = (tmpMC.width * m_sizeRatio);
                        tmpMC.height = (tmpMC.height * m_sizeRatio);
                        if (Utils.safeRandom() > 0.5)
                        {
                            tmpMC.scaleX = (tmpMC.scaleX * -1);
                        };
                        tmpMC.x = (OverlayX + Utils.safeRandomInteger(-8, 8));
                        tmpMC.y = (OverlayY + Utils.safeRandomInteger(-8, 8));
                        tmpMC.rotation = Utils.safeRandomInteger(0, 360);
                        tmpMC.alpha = 0.5;
                    };
                };
            };
        }

        public function isLandingOrSkiddingOrChambering():Boolean
        {
            return (((((this.isLanding()) || (this.isSkidding())) || (this.isJumpChambering())) || (inState(CState.TECH_GROUND))) || (inState(CState.TECH_ROLL)));
        }

        public function isLanding():Boolean
        {
            return ((inState(CState.LAND)) || (inState(CState.HEAVY_LAND)));
        }

        public function isSkidding():Boolean
        {
            return (inState(CState.SKID));
        }

        public function isJumpChambering():Boolean
        {
            return (inState(CState.JUMP_CHAMBER));
        }

        public function isStandby():Boolean
        {
            return (this.m_standby);
        }

        public function releaseLedge():void
        {
            if (inState(CState.LEDGE_HANG))
            {
                this.unnattachFromLedge();
                this.setState(CState.IDLE);
            };
            this.m_ledge = null;
            this.m_lastLedge = null;
        }

        public function releaseOpponent(index:int=-1):void
        {
            var i:int;
            if (this.m_internalGrabLock)
            {
                return;
            };
            if (this.m_grabbed.length > 0)
            {
                if (index >= 0)
                {
                    this.m_grabbed[index].Uncapture();
                    this.m_grabbed[index].setVisibility(true);
                    this.m_grabbed.splice(index, 1);
                    this.m_justReleased = false;
                }
                else
                {
                    i = 0;
                    while (i < this.m_grabbed.length)
                    {
                        if (((this.m_grabbed[i].Caught()) && (!(this.m_grabbed[i].StandBy))))
                        {
                            this.m_grabbed[i].Uncapture();
                            this.m_grabbed[i].setVisibility(true);
                        };
                        i++;
                    };
                    this.m_justReleased = false;
                    while (this.m_grabbed.length > 0)
                    {
                        this.m_grabbed.splice(0, 1);
                    };
                };
            };
            if (this.m_grabbed.length == 0)
            {
                this.m_strengthGrabLocked = false;
                if (inState(CState.GRABBING))
                {
                    this.setState(CState.IDLE);
                };
            };
        }

        public function shootOutOpponent():void
        {
            var i:int;
            var opponent:Character;
            if (this.m_grabbed.length > 0)
            {
                i = 0;
                while (i < this.m_grabbed.length)
                {
                    opponent = this.m_grabbed[i];
                    opponent.setVisibility(true);
                    opponent.Uncapture();
                    if (this.m_characterStats.LinkageID == "kirby")
                    {
                        opponent.shootingStar(m_facingForward, m_uid);
                        opponent.dealDamage((10 * Math.min(this.totalMoveDecay("kirby_star_spit"), 10)));
                        this.queueMove("kirby_star_spit");
                    };
                    i++;
                };
                this.m_grabbed = new Vector.<Character>();
            };
        }

        public function shootingStar(shootRight:Boolean, otherPlayerID:Number):void
        {
            this.m_starTimer = 6;
            this.playFrame("star");
            this.resetSpeedLevel();
            m_sprite.rotation = 0;
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            if ((!(shootRight)))
            {
                m_faceRight();
            }
            else
            {
                m_faceLeft();
            };
            this.killAllSpeeds();
            m_attack.simpleReset();
            m_attack.importAttackStateData({
                "refreshRate":50,
                "canFallOff":true,
                "isForward":(!(m_facingForward))
            });
            m_attack.IsAirAttack = (!(m_collision.ground));
            m_attack.AttackType = 1;
            m_attack.Frame = "star";
            this.setIntangibility(true);
            this.checkLinkedProjectiles();
            this.setState(CState.KIRBY_STAR);
            this.setVisibility(false);
            toggleEffect(this.m_kirbyStarMC, true);
            this.m_kirbyStarMC.x = m_sprite.x;
            this.m_kirbyStarMC.y = m_sprite.y;
            updateAttackBoxStats(1, {
                "team_id":STAGEDATA.getCharacterByUID(otherPlayerID).Team,
                "otherPlayerID":otherPlayerID
            });
            STAGEDATA.getCharacterByUID(otherPlayerID).stackAttackID(m_attack.AttackID);
            createTimer(1, 6, function ():void
            {
                setXSpeed(((m_facingForward) ? -15 : 15));
            });
            addEventListener(SSF2Event.ATTACK_HIT, function (e:*):void
            {
                setIntangibility(false);
                endAttack();
                killAllSpeeds(false, false);
                setXSpeed(0);
                unnattachFromGround();
                setYSpeed(-12);
                toggleEffect(m_kirbyStarMC, false);
                setVisibility(true);
                resetRotation();
                m_fallTiltTimer.reset();
                setState(CState.JUMP_FALLING);
            });
        }

        private function m_charFall():void
        {
            var oldYSpeed:Number;
            if (((((((((((((((((!(m_collision.ground)) && (!(isHitStunOrParalysis()))) && (!(inState(CState.LEDGE_HANG)))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.ROLL)))) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.KIRBY_STAR)))) && (!(inState(CState.GLIDING)))) && (!((inState(CState.ATTACKING)) && (m_attack.Rocket)))) && (this.m_starKOTimer.IsComplete)) && (!(inState(CState.WALL_CLING)))) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.DEAD)))) && (!((STAGEDATA.AirDodge.match(/melee|solo|vsolo|double|vdouble/)) && (inState(CState.AIR_DODGE))))))
            {
                oldYSpeed = m_ySpeed;
                if (((!(inState(CState.FLYING))) && (!(inState(CState.INJURED)))))
                {
                    if (m_ySpeed < m_max_ySpeed)
                    {
                        if ((!(((inState(CState.HOVER)) || (this.m_attackHovering)) || (!(this.m_midAirJumpConstantTime.IsComplete)))))
                        {
                            if (inState(CState.EGG))
                            {
                                m_ySpeed = (m_ySpeed + (m_gravity * 0.75));
                            }
                            else
                            {
                                m_ySpeed = (m_ySpeed + m_gravity);
                            };
                            if (m_ySpeed >= m_max_ySpeed)
                            {
                                m_ySpeed = m_max_ySpeed;
                            };
                        };
                    };
                }
                else
                {
                    if (m_ySpeed < m_max_ySpeed)
                    {
                        m_ySpeed = Math.min((m_ySpeed + m_gravity), m_max_ySpeed);
                    };
                };
                if (((((((((((((((((((!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))) && (!(this.m_justFellThroughPlatform))) && (this.m_pressedControls.DOWN)) && (m_ySpeed < this.m_characterStats.FastFallSpeed)) && ((m_ySpeed > 0) || (this.netYSpeed(true, false) > 0))) && (!((inState(CState.ATTACKING)) && (!(m_attack.AllowFastFall))))) && (!(inState(CState.HOVER)))) && (!(this.m_attackHovering))) && (this.m_midAirJumpConstantTime.IsComplete)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.WALL_CLING)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (!(inState(CState.EGG)))))
                {
                    m_ySpeed = this.m_characterStats.FastFallSpeed;
                    if ((!((((((inState(CState.ATTACKING)) && (m_attack.AirEase >= 0)) && (!(inState(CState.HOVER)))) && (!(this.m_attackHovering))) && (!(inState(CState.HOVER)))) && (this.m_midAirJumpConstantTime.IsComplete))))
                    {
                        attachEffect("effect_fastFall");
                    };
                };
                if (((((((inState(CState.ATTACKING)) && (m_attack.AirEase >= 0)) && (!(inState(CState.HOVER)))) && (!(this.m_attackHovering))) && (!(inState(CState.HOVER)))) && (this.m_midAirJumpConstantTime.IsComplete)))
                {
                    if (m_ySpeed >= m_attack.AirEase)
                    {
                        m_ySpeed = m_attack.AirEase;
                    };
                };
                if (((((((inState(CState.ATTACKING)) && (this.m_justHit)) && (!(m_attack.HitEase == 0))) && (!(this.m_attackHovering))) && (!(inState(CState.HOVER)))) && (this.m_midAirJumpConstantTime.IsComplete)))
                {
                    if (((m_attack.HitEase > 0) && (m_ySpeed > m_attack.HitEase)))
                    {
                        m_ySpeed = m_attack.HitEase;
                    }
                    else
                    {
                        if (((m_attack.HitEase < 0) && (m_ySpeed > m_attack.HitEase)))
                        {
                            m_ySpeed = m_attack.HitEase;
                        };
                    };
                };
                if (inState(CState.EGG))
                {
                    if (m_ySpeed > (m_max_ySpeed * 0.5))
                    {
                        m_ySpeed = (m_max_ySpeed * 0.5);
                    };
                };
                if (((((((((this.m_canHover) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (this.m_characterStats.MidAirHover > 0)) && (this.inFreeState())) && (!(inState(CState.HOVER)))) && ((oldYSpeed < 0) && (m_ySpeed >= 0))) && (this.jumpIsHeld())))
                {
                    this.initHover();
                };
                this.m_attemptToMove(0, m_ySpeed);
                if (inState(CState.SHIELDING))
                {
                    this.m_deactivateShield();
                    this.m_crouchFrame = -1;
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                    this.setState(CState.TUMBLE_FALL);
                };
                if (inState(CState.DISABLED))
                {
                    this.m_blinkTimer++;
                    if (this.m_blinkTimer > 5)
                    {
                        this.alternateBlink();
                    };
                };
                if (((((((((((this.m_glideReady) && (!(inState(CState.DISABLED)))) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (this.jumpIsPressed())) && (this.m_jumpCount > 0)) && (!(inState(CState.ATTACKING)))) && (this.m_characterStats.GlideSpeed > 0)) && (!(inState(CState.GLIDING)))) && (m_ySpeed > 0)))
                {
                    this.startGlide();
                };
            }
            else
            {
                if (((((((!(inState(CState.FLYING))) && (!(inState(CState.INJURED)))) && (!(inState(CState.ATTACKING)))) && (!(isHitStunOrParalysis()))) && (!(inState(CState.GLIDING)))) && (this.m_midAirJumpConstantTime.IsComplete)))
                {
                    m_ySpeed = 0;
                };
            };
        }

        public function startGlide():void
        {
            if (((((((((((((((!(m_collision.ground)) && (!(isHitStunOrParalysis()))) && (!(inState(CState.LEDGE_HANG)))) && (!(this.m_usingSpecialAttack))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.TECH_GROUND)))) && (!(inState(CState.TECH_ROLL)))) && (!(inState(CState.ROLL)))) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (!(inState(CState.GLIDING)))))
            {
                this.forceEndAttack();
                this.m_glideMaxHeight = m_sprite.y;
                this.m_glideAngle = 20;
                this.m_glideDelay = 0;
                this.m_glideReady = false;
                this.setState(CState.GLIDING);
                this.stancePlayFrame("glide");
            };
        }

        private function m_charGlide():void
        {
            var previousX:Number;
            var previousY:Number;
            if (inState(CState.GLIDING))
            {
                if (this.m_glideDelay < 10)
                {
                    this.m_glideDelay++;
                };
                if (this.m_glideDelay >= 10)
                {
                    if ((((this.m_heldControls.UP) && (!(this.m_heldControls.DOWN))) && (this.m_glideAngle > -70)))
                    {
                        this.m_glideAngle = (this.m_glideAngle - 10);
                    }
                    else
                    {
                        if ((((this.m_heldControls.DOWN) && (!(this.m_heldControls.UP))) && (this.m_glideAngle < 70)))
                        {
                            this.m_glideAngle = (this.m_glideAngle + 10);
                        };
                    };
                };
                previousX = m_sprite.x;
                previousY = m_sprite.y;
                m_xSpeed = (((m_facingForward) ? this.m_characterStats.GlideSpeed : -(this.m_characterStats.GlideSpeed)) * Math.cos(((this.m_glideAngle * Math.PI) / 180)));
                m_ySpeed = (this.m_characterStats.GlideSpeed * Math.sin(((this.m_glideAngle * Math.PI) / 180)));
                this.m_attemptToMove(m_xSpeed, 0);
                this.m_attemptToMove(0, m_ySpeed);
                if (Utils.fastAbs((m_sprite.x - previousX)) < 0.5)
                {
                    this.m_glideDelay++;
                };
                m_sprite.rotation = ((m_facingForward) ? this.m_glideAngle : -(this.m_glideAngle));
                if (((m_sprite.y < this.m_glideMaxHeight) || (this.m_glideDelay > 40)))
                {
                    m_sprite.y = previousY;
                    m_ySpeed = 0;
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.setState(CState.JUMP_FALLING);
                    if (this.m_jumpCount >= this.m_characterStats.MaxJump)
                    {
                        this.setState(CState.DISABLED);
                    };
                };
            };
        }

        private function m_charWallCling():void
        {
            var i:int;
            var rect:Rectangle;
            var hitTest1:Boolean;
            this.m_wallClingDelay.tick();
            this.m_wallClingDelay.reset();
            if (inState(CState.WALL_CLING))
            {
                if ((((this.jumpIsPressed()) || ((this.m_heldControls.RIGHT) && (m_facingForward))) || ((this.m_heldControls.LEFT) && (!(m_facingForward)))))
                {
                    if (this.m_characterStats.WallJump)
                    {
                        m_ySpeed = -(this.m_characterStats.JumpSpeedMidAir);
                        this.m_wallStickTime.MaxTime = (this.m_wallStickTime.MaxTime - Math.round((this.m_wallStickTime.MaxTime / 2)));
                        if (this.m_wallStickTime.MaxTime < 1)
                        {
                            this.m_wallStickTime.MaxTime = 1;
                        };
                        if (m_facingForward)
                        {
                            m_xSpeed = (this.m_characterStats.MaxJumpSpeed / 2);
                        }
                        else
                        {
                            m_xSpeed = (-(this.m_characterStats.MaxJumpSpeed) / 2);
                        };
                        this.setState(CState.JUMP_MIDAIR_RISING);
                    }
                    else
                    {
                        this.setState(CState.JUMP_FALLING);
                    };
                    this.m_wallClingDelay.reset();
                }
                else
                {
                    this.m_wallStickTime.tick();
                    if (this.m_wallStickTime.IsComplete)
                    {
                        this.m_wallStickTime.MaxTime = (this.m_wallStickTime.MaxTime - Math.round((this.m_wallStickTime.MaxTime / 2)));
                        this.setState(CState.JUMP_FALLING);
                        this.m_wallClingDelay.reset();
                    };
                };
            }
            else
            {
                if ((((this.inFreeState()) && ((this.m_characterStats.WallJump) || (this.m_characterStats.WallStick > 0))) && (HasHitBox)))
                {
                    i = 0;
                    while (i < this.m_walls.length)
                    {
                        rect = BoundsRect;
                        hitTest1 = this.m_walls[i].hitTestRect(BoundsRect);
                        if (((hitTest1) && (((this.m_characterStats.WallStick > 0) || ((((m_sprite.x > this.m_walls[i].X) && (this.jumpIsPressed())) || (this.m_heldControls.RIGHT)) && (m_xSpeed <= 0))) || ((m_sprite.x < (this.m_walls[i].X + this.m_walls[i].Width)) && (((this.jumpIsPressed()) || (this.m_heldControls.LEFT)) && (m_xSpeed <= 0))))))
                        {
                            if ((((this.m_characterStats.WallStick <= 0) && (this.m_characterStats.WallJump)) && (m_ySpeed >= 0)))
                            {
                                m_ySpeed = (-(this.m_characterStats.JumpSpeedMidAir) * Math.pow(0.9, this.m_wallJumpCount));
                                if (this.m_characterStats.WallStick == 0)
                                {
                                    this.m_wallJumpCount++;
                                };
                                if (((m_sprite.x > this.m_walls[i].X) && ((this.jumpIsPressed()) || (this.m_heldControls.RIGHT))))
                                {
                                    m_xSpeed = (this.m_characterStats.MaxJumpSpeed / 2);
                                    m_faceRight();
                                }
                                else
                                {
                                    m_xSpeed = (-(this.m_characterStats.MaxJumpSpeed) / 2);
                                    m_faceLeft();
                                };
                                this.setState(CState.JUMP_MIDAIR_RISING);
                                break;
                            };
                            if ((((this.m_characterStats.WallStick > 0) && (((m_sprite.x > this.m_walls[i].X) && (this.m_heldControls.LEFT)) || ((m_sprite.x < (this.m_walls[i].X + this.m_walls[i].Width)) && (this.m_heldControls.RIGHT)))) && (this.m_wallClingDelay.IsComplete)))
                            {
                                if (m_sprite.x > this.m_walls[i].X)
                                {
                                    m_faceRight();
                                }
                                else
                                {
                                    m_faceLeft();
                                };
                                this.setState(CState.WALL_CLING);
                                this.m_wallStickTime.reset();
                                break;
                            };
                        };
                        i++;
                    };
                };
            };
        }

        private function resetSmashTimers():void
        {
            this.m_smashTimer = 0;
            this.m_smashTimerUp = 0;
            this.m_smashTimerDown = 0;
            this.m_smashTimerSide = 0;
            this.m_upSpecialTimer = 0;
        }

        private function killSmashTimers():void
        {
            this.m_smashTimer = 99;
            this.m_smashTimerUp = 99;
            this.m_smashTimerDown = 99;
            this.m_smashTimerSide = 99;
            this.m_upSpecialTimer = 99;
        }

        private function neutralSpecialFlipCheck(atkName:String):void
        {
            if ((((((!(this.m_specialTurnTimer.IsComplete)) && (atkName)) && (m_attackData.getAttack(atkName))) && (!(m_attackData.getAttack(atkName).IsDisabled))) && (m_attackData.getAttack(atkName).Enabled)))
            {
                if (((!(m_facingForward)) && (this.m_specialTurnRight)))
                {
                    m_faceRight();
                }
                else
                {
                    if (((m_facingForward) && (!(this.m_specialTurnRight))))
                    {
                        m_faceLeft();
                    };
                };
            };
        }

        private function attackFlipCheck(atkName:String):void
        {
            if (((((atkName) && (m_attackData.getAttack(atkName))) && (!(m_attackData.getAttack(atkName).IsDisabled))) && (m_attackData.getAttack(atkName).Enabled)))
            {
                if (((this.m_heldControls.RIGHT) && (!(m_facingForward))))
                {
                    m_faceRight();
                }
                else
                {
                    if (((this.m_heldControls.LEFT) && (m_facingForward)))
                    {
                        m_faceLeft();
                    };
                };
            };
        }

        private function attackButtonsHeld():Boolean
        {
            return ((((this.m_heldControls.BUTTON2) || (this.m_heldControls.GRAB)) && (m_attack.AttackType == 1)) || ((this.m_heldControls.BUTTON1) && (m_attack.AttackType == 2)));
        }

        private function attackButtonsPressed():Boolean
        {
            return ((((this.m_heldControls.BUTTON2) || (this.m_heldControls.GRAB)) && (m_attack.AttackType == 1)) || ((this.m_pressedControls.BUTTON1) && (m_attack.AttackType == 2)));
        }

        private function m_charAttack():void
        {
            var i:int;
            var k:int;
            var tmpX:Number;
            var tmpY:Number;
            var i2:int;
            var opponent:Character;
            var tmpCentX:Number;
            var tmpCentY:Number;
            var oldPlat:Platform;
            var centCollision:Boolean;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var tempX:Number;
            var tempY:Number;
            var tempX2:Number;
            var tempY2:Number;
            var glob:Point;
            var tmpPoint:Point;
            var tPoint:Point;
            i = 0;
            var j:int;
            var wasAttacking:Boolean = inState(CState.ATTACKING);
            if (((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)))
            {
                this.m_specialTurnRight = (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) ? true : (((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) ? false : this.m_specialTurnRight));
                this.m_specialTurnTimer.reset();
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.killSmashTimers();
            };
            if (this.m_finalSmashCutinMC)
            {
                if ((!(this.m_finalSmashCutinMC.parent)))
                {
                    this.m_finalSmashCutinMC = null;
                    STAGEDATA.CamRef.deleteForcedTarget(m_sprite);
                    STAGEDATA.FSCutins--;
                };
            };
            if (((((!((this.HoldingItem) && (!(this.m_item.CanAttackWith)))) && (this.m_charIsFull)) && (this.m_attackDelay <= 0)) && (!(this.isLandingOrSkiddingOrChambering()))))
            {
                if (this.m_pressedControls.BUTTON2)
                {
                    this.m_charIsFull = false;
                    this.m_justReleased = true;
                    this.Attack("b", 1);
                }
                else
                {
                    if ((((this.m_pressedControls.BUTTON1) || (this.m_pressedControls.DOWN)) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))
                    {
                        this.m_charIsFull = false;
                        this.m_justReleased = true;
                        this.Attack("b", 2);
                    };
                };
            }
            else
            {
                if (((((((inState(CState.ATTACKING)) && (this.m_grabbed.length > 0)) && (this.m_currentPower == null)) && (this.m_characterStats.LinkageID == "kirby")) && ((m_attack.Frame == "b") || (m_attack.Frame == "b_air"))) && (this.m_justReleased)))
                {
                    if (currentStanceFrameIs("sucking"))
                    {
                        if (m_attack.AttackType == 2)
                        {
                            this.setStanceVar("power", this.m_grabbed[0].KirbyPower);
                            k = 0;
                            while (k < this.m_grabbed.length)
                            {
                                this.m_grabbed[k].dealDamage(6);
                                k++;
                            };
                            this.stancePlayFrame("swallow");
                        }
                        else
                        {
                            this.stancePlayFrame("spit");
                        };
                    };
                };
            };
            if (((this.HoldingItem) && (currentFrameIs("a"))))
            {
            };
            if ((((((this.inFreeState(((CFreeState.ATTACKING | CFreeState.GLIDING) | CFreeState.JUMP_CHAMBER))) && (!(m_delayPlayback))) && (!(this.isNonInterruptableAttack()))) && (this.m_attackDelay <= 0)) && (!((this.HoldingItem) && (!(this.m_item.CanAttackWith))))))
            {
                if (m_collision.ground)
                {
                    if (((inState(CState.CROUCH)) && (!(this.m_heldControls.UP))))
                    {
                        if (((this.m_pressedControls.BUTTON2) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON2))))
                        {
                            if ((((((((this.m_heldControls.DOWN) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.DOWN))) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.RIGHT))) && (this.m_smashTimer < 4)) && (this.m_crouchLength < 3)) && (Utils.fastAbs(m_xSpeed) < 0.5)))
                            {
                                this.Attack("a_down", 1);
                            };
                        }
                        else
                        {
                            if ((((this.m_pressedControls.BUTTON1) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON1))) && (!(inState(CState.JUMP_CHAMBER)))))
                            {
                                if (this.m_heldControls.LEFT !== this.m_heldControls.RIGHT)
                                {
                                    if (this.m_heldControls.UP)
                                    {
                                        this.attackFlipCheck("b_up");
                                        this.Attack("b_up", 2);
                                    }
                                    else
                                    {
                                        if (this.m_heldControls.DOWN)
                                        {
                                            this.attackFlipCheck("b_down");
                                            this.Attack("b_down", 2);
                                        }
                                        else
                                        {
                                            this.attackFlipCheck("b_forward");
                                            this.Attack("b_forward", 2);
                                        };
                                    };
                                }
                                else
                                {
                                    if (this.m_heldControls.DOWN)
                                    {
                                        this.Attack("b_down", 2);
                                    }
                                    else
                                    {
                                        if ((((this.HasFinalSmash) && (!(this.m_transformingSpecial))) && (!(STAGEDATA.ItemsRef.PlayerUsingSmashBall))))
                                        {
                                            this.m_useFinalSmash();
                                        }
                                        else
                                        {
                                            this.Attack("b", 2);
                                        };
                                    };
                                };
                            }
                            else
                            {
                                if ((((((this.m_pressedControls.C_UP) && (!(this.m_pressedControls.C_DOWN))) || ((this.m_pressedControls.C_DOWN) && (!(this.m_pressedControls.C_UP)))) || ((this.m_pressedControls.C_LEFT) && (!(this.m_pressedControls.C_RIGHT)))) || ((this.m_pressedControls.C_RIGHT) && (!(this.m_pressedControls.C_LEFT)))))
                                {
                                    if (this.m_pressedControls.C_UP)
                                    {
                                        this.Attack("a_up", 1, true);
                                    }
                                    else
                                    {
                                        if (this.m_pressedControls.C_LEFT)
                                        {
                                            if (inState(CState.DASH))
                                            {
                                                m_xSpeed = 0;
                                            };
                                            m_faceLeft();
                                            this.Attack("a_forwardsmash", 1, true);
                                        }
                                        else
                                        {
                                            if (this.m_pressedControls.C_RIGHT)
                                            {
                                                if (inState(CState.DASH))
                                                {
                                                    m_xSpeed = 0;
                                                };
                                                m_faceRight();
                                                this.Attack("a_forwardsmash", 1, true);
                                            }
                                            else
                                            {
                                                if (this.m_pressedControls.C_DOWN)
                                                {
                                                    this.Attack("a_down", 1, true);
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    }
                    else
                    {
                        if (((this.m_pressedControls.BUTTON2) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON2))))
                        {
                            if ((((this.m_heldControls.UP) && (!((inState(CState.JUMP_CHAMBER)) && ((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT))))) && (this.m_smashTimer < 4)))
                            {
                                if (((inState(CState.DASH)) && (Utils.fastAbs(m_xSpeed) > this.m_max_xSpeed)))
                                {
                                    m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
                                };
                                this.Attack("a_up", 1);
                            }
                            else
                            {
                                if (this.m_heldControls.UP)
                                {
                                    if (((inState(CState.DASH)) && (!(m_xSpeed == 0))))
                                    {
                                        m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
                                    };
                                    this.Attack("a_up_tilt", 1);
                                }
                                else
                                {
                                    if (((((!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT)) && (this.m_smashTimer < 5)) && ((!(inState(CState.DASH))) || (m_framesSinceLastState <= 2))) && (!(inState(CState.JUMP_CHAMBER)))))
                                    {
                                        if (inState(CState.DASH))
                                        {
                                            m_xSpeed = 0;
                                        };
                                        this.attackFlipCheck("a_forwardsmash");
                                        this.Attack("a_forwardsmash", 1);
                                    }
                                    else
                                    {
                                        if (((!(inState(CState.JUMP_CHAMBER))) && ((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (!(m_facingForward))) || (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) && (m_facingForward)))))
                                        {
                                            if (((!(this.m_runningSpeedLevel)) && (!(inState(CState.DASH)))))
                                            {
                                                this.Attack("a_forward_tilt", 1);
                                            }
                                            else
                                            {
                                                if (((this.m_runningSpeedLevel) || (inState(CState.DASH))))
                                                {
                                                    this.Attack("a_forward", 1);
                                                };
                                            };
                                        }
                                        else
                                        {
                                            if (((((this.m_smashTimer < 4) && (this.m_heldControls.DOWN)) && (!(inState(CState.DASH)))) && (!(inState(CState.JUMP_CHAMBER)))))
                                            {
                                                this.Attack("a_down", 1);
                                            }
                                            else
                                            {
                                                if ((!(inState(CState.DASH))))
                                                {
                                                    if ((!(inState(CState.JUMP_CHAMBER))))
                                                    {
                                                        if (this.m_heldControls.LEFT != this.m_heldControls.RIGHT)
                                                        {
                                                            if (this.m_heldControls.LEFT)
                                                            {
                                                                faceLeft();
                                                            }
                                                            else
                                                            {
                                                                faceRight();
                                                            };
                                                            this.Attack("a_forward_tilt", 1);
                                                        }
                                                        else
                                                        {
                                                            if (this.m_heldControls.DOWN)
                                                            {
                                                                this.Attack("crouch_attack", 1);
                                                            }
                                                            else
                                                            {
                                                                this.Attack("a", 1);
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        }
                        else
                        {
                            if ((((this.m_pressedControls.BUTTON1) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON1))) && (!(inState(CState.JUMP_CHAMBER)))))
                            {
                                if (this.m_heldControls.LEFT !== this.m_heldControls.RIGHT)
                                {
                                    if (this.m_heldControls.UP)
                                    {
                                        if (((inState(CState.DASH)) && (!(m_xSpeed == 0))))
                                        {
                                            m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
                                        };
                                        this.attackFlipCheck("b_up");
                                        this.Attack("b_up", 2);
                                    }
                                    else
                                    {
                                        if (((this.m_heldControls.DOWN) && (!(inState(CState.DASH)))))
                                        {
                                            this.attackFlipCheck("b_down");
                                            this.Attack("b_down", 2);
                                        }
                                        else
                                        {
                                            if (inState(CState.DASH))
                                            {
                                                m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : ((m_xSpeed < 0) ? -(this.m_max_xSpeed) : 0));
                                            };
                                            this.attackFlipCheck("b_forward");
                                            this.Attack("b_forward", 2);
                                        };
                                    };
                                }
                                else
                                {
                                    if ((((this.m_heldControls.DOWN) && (!(this.m_heldControls.UP))) && (!(inState(CState.DASH)))))
                                    {
                                        this.Attack("b_down", 2);
                                    }
                                    else
                                    {
                                        if ((((this.m_heldControls.UP) && (!(this.m_heldControls.DOWN))) && (!(inState(CState.DASH)))))
                                        {
                                            this.Attack("b_up", 2);
                                        }
                                        else
                                        {
                                            if ((((this.HasFinalSmash) && (!(this.m_transformingSpecial))) && (!(STAGEDATA.ItemsRef.PlayerUsingSmashBall))))
                                            {
                                                this.m_useFinalSmash();
                                            }
                                            else
                                            {
                                                if ((!(inState(CState.DASH))))
                                                {
                                                    this.Attack("b", 2);
                                                };
                                            };
                                        };
                                    };
                                };
                            }
                            else
                            {
                                if ((((this.m_pressedControls.BUTTON1) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON1))) && (inState(CState.JUMP_CHAMBER))))
                                {
                                    if (this.m_heldControls.UP)
                                    {
                                        this.attackFlipCheck("b_up");
                                        this.Attack("b_up", 2);
                                    };
                                }
                                else
                                {
                                    if (((((this.m_pressedControls.C_UP) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT)))
                                    {
                                        if ((((!(inState(CState.DASH))) || (m_framesSinceLastState <= 2)) && (!(inState(CState.RUN)))))
                                        {
                                            if (((this.m_pressedControls.C_LEFT) && (!(inState(CState.JUMP_CHAMBER)))))
                                            {
                                                if (inState(CState.DASH))
                                                {
                                                    this.Attack("a_forward", 1);
                                                }
                                                else
                                                {
                                                    m_xSpeed = 0;
                                                    m_faceLeft();
                                                    this.Attack("a_forwardsmash", 1, true);
                                                };
                                            }
                                            else
                                            {
                                                if (((this.m_pressedControls.C_RIGHT) && (!(inState(CState.JUMP_CHAMBER)))))
                                                {
                                                    if (inState(CState.DASH))
                                                    {
                                                        this.Attack("a_forward", 1);
                                                    }
                                                    else
                                                    {
                                                        m_xSpeed = 0;
                                                        m_faceRight();
                                                        this.Attack("a_forwardsmash", 1, true);
                                                    };
                                                }
                                                else
                                                {
                                                    if (this.m_pressedControls.C_UP)
                                                    {
                                                        if (((inState(CState.DASH)) && (Utils.fastAbs(m_xSpeed) > this.m_max_xSpeed)))
                                                        {
                                                            m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
                                                        };
                                                        this.Attack("a_up", 1, true);
                                                    }
                                                    else
                                                    {
                                                        if (((this.m_pressedControls.C_DOWN) && (!(inState(CState.JUMP_CHAMBER)))))
                                                        {
                                                            if (inState(CState.DASH))
                                                            {
                                                                this.Attack("a_forward", 1);
                                                            }
                                                            else
                                                            {
                                                                this.Attack("a_down", 1, true);
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        }
                                        else
                                        {
                                            if (((((((this.m_runningSpeedLevel) || (inState(CState.DASH))) && (this.m_pressedControls.C_UP)) && (!(this.m_pressedControls.C_LEFT))) && (!(this.m_pressedControls.C_DOWN))) && (!(this.m_pressedControls.C_RIGHT))))
                                            {
                                                if (((inState(CState.DASH)) && (Utils.fastAbs(m_xSpeed) > this.m_max_xSpeed)))
                                                {
                                                    m_xSpeed = ((m_xSpeed > 0) ? this.m_max_xSpeed : -(this.m_max_xSpeed));
                                                };
                                                this.Attack("a_up", 1, true);
                                            }
                                            else
                                            {
                                                if ((((this.m_runningSpeedLevel) || (inState(CState.DASH))) && (((this.m_pressedControls.C_RIGHT) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_DOWN))))
                                                {
                                                    this.Attack("a_forward", 1);
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                }
                else
                {
                    if ((((((this.m_pressedControls.BUTTON2) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON2))) || ((this.m_pressedControls.GRAB) && (!(this.m_characterStats.TetherGrab)))) && (!(this.m_pressedControls.BUTTON1))) || (((this.m_c_buffered_down) || (this.m_c_buffered_left)) || (this.m_c_buffered_right))))
                    {
                        if (((((this.m_heldControls.DOWN) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) || (this.m_c_buffered_down)))
                        {
                            this.Attack("a_air_down", 1);
                        }
                        else
                        {
                            if ((((((((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) && (!(this.m_c_buffered_down))) || ((inState(CState.GLIDING)) && (!(m_facingForward)))) || ((this.m_c_buffered_left) && (!(m_facingForward)))) && (!(m_facingForward))) || ((((((((!(this.m_heldControls.LEFT)) && (this.m_heldControls.RIGHT)) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) && (!(this.m_c_buffered_down))) || ((inState(CState.GLIDING)) && (m_facingForward))) || ((this.m_c_buffered_right) && (m_facingForward))) && (m_facingForward))))
                            {
                                this.Attack("a_air_forward", 1);
                            }
                            else
                            {
                                if ((((((((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (m_facingForward)) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) && (!(this.m_c_buffered_down))) || ((((((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) && (!(m_facingForward))) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) && (!(this.m_c_buffered_down)))) || ((this.m_c_buffered_left) && (m_facingForward))) || ((this.m_c_buffered_right) && (!(m_facingForward)))))
                                {
                                    this.Attack("a_air_backward", 1);
                                }
                                else
                                {
                                    if (((((this.m_heldControls.UP) && (!(this.m_c_buffered_left))) && (!(this.m_c_buffered_right))) && (!(this.m_c_buffered_down))))
                                    {
                                        this.Attack("a_air_up", 1);
                                    }
                                    else
                                    {
                                        this.Attack("a_air", 1);
                                    };
                                };
                            };
                        };
                    }
                    else
                    {
                        if ((((this.m_pressedControls.BUTTON1) || ((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (this.m_heldControls.BUTTON1))) && (!(inState(CState.GLIDING)))))
                        {
                            if ((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) || ((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT)))))
                            {
                                if (this.m_heldControls.UP)
                                {
                                    this.attackFlipCheck("b_up_air");
                                    this.Attack("b_up_air", 2);
                                }
                                else
                                {
                                    if (this.m_heldControls.DOWN)
                                    {
                                        this.attackFlipCheck("b_down_air");
                                        this.Attack("b_down_air", 2);
                                    }
                                    else
                                    {
                                        this.attackFlipCheck("b_forward_air");
                                        this.Attack("b_forward_air", 2);
                                    };
                                };
                            }
                            else
                            {
                                if (this.m_heldControls.DOWN)
                                {
                                    this.Attack("b_down_air", 2);
                                }
                                else
                                {
                                    if (this.m_heldControls.UP)
                                    {
                                        this.Attack("b_up_air", 2);
                                    }
                                    else
                                    {
                                        if (((((this.HasFinalSmash) && (!(this.m_transformingSpecial))) && (m_attackData.getAttack("special").CanUseInAir)) && (!(STAGEDATA.ItemsRef.PlayerUsingSmashBall))))
                                        {
                                            this.m_useFinalSmash();
                                        }
                                        else
                                        {
                                            this.neutralSpecialFlipCheck("b_air");
                                            this.Attack("b_air", 2);
                                        };
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (((((this.m_pressedControls.C_UP) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT)))
                            {
                                if ((((!(inState(CState.JUMP_CHAMBER))) && (!(inState(CState.DASH)))) && (!(inState(CState.RUN)))))
                                {
                                    if (((this.m_pressedControls.C_LEFT) && (!(this.m_pressedControls.C_RIGHT))))
                                    {
                                        if (m_facingForward)
                                        {
                                            this.Attack("a_air_backward", 1, true);
                                        }
                                        else
                                        {
                                            this.Attack("a_air_forward", 1, true);
                                        };
                                    }
                                    else
                                    {
                                        if (((!(this.m_pressedControls.C_LEFT)) && (this.m_pressedControls.C_RIGHT)))
                                        {
                                            if (m_facingForward)
                                            {
                                                this.Attack("a_air_forward", 1, true);
                                            }
                                            else
                                            {
                                                this.Attack("a_air_backward", 1, true);
                                            };
                                        }
                                        else
                                        {
                                            if (((this.m_pressedControls.C_UP) && (!(this.m_pressedControls.C_DOWN))))
                                            {
                                                this.Attack("a_air_up", 1, true);
                                            }
                                            else
                                            {
                                                if (((!(this.m_pressedControls.C_UP)) && (this.m_pressedControls.C_DOWN)))
                                                {
                                                    this.Attack("a_air_down", 1, true);
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
            if (inState(CState.ATTACKING))
            {
                if (((inState(CState.ATTACKING)) && (m_attackData.getAttack(m_attack.Frame).ChargeRetain)))
                {
                    if (((((((this.attackIsCharged(m_attack.Frame)) || ((((this.attackButtonsPressed()) && (m_attack.ExecTime > 0)) && (!(m_attack.MustCharge))) || ((!(m_attackData.getAttack(m_attack.Frame).ChargeInAir)) && (m_attack.IsAirAttack)))) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && (!(currentStanceFrameIs(undefined)))))
                    {
                        m_attack.ChargeTime = m_attackData.getAttack(m_attack.Frame).ChargeTime;
                        this.playFrame(m_attack.Frame);
                        if (m_attack.Frame == "item")
                        {
                            this.updateItemHolding();
                        };
                        if (this.attackIsCharged(m_attack.Frame))
                        {
                            if (!((this.HoldingItem) && (currentFrameIs("item"))))
                            {
                                this.stancePlayFrame(((Utils.hasLabel(m_sprite.stance, "attack2")) ? "attack2" : "attack"));
                            };
                        }
                        else
                        {
                            if (!((this.HoldingItem) && (currentFrameIs("item"))))
                            {
                                this.stancePlayFrame("attack");
                            };
                        };
                        this.unsetCharge(m_attack.Frame);
                        this.removeChargeGlow();
                        if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                        {
                            STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                        };
                    }
                    else
                    {
                        if (((((((m_attackData.getAttack(m_attack.Frame).ChargeTime < m_attackData.getAttack(m_attack.Frame).ChargeTimeMax) && (!(this.attackIsCharged(m_attack.Frame)))) && (currentStanceFrameIs("charging"))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && (!((!(m_attackData.getAttack(m_attack.Frame).ChargeInAir)) && (m_attack.IsAirAttack)))))
                        {
                            this.incrementCharge(m_attack.Frame, m_attack.LinkCharge);
                            if (((!(STAGEPARENT.getChildByName(("energy" + m_player_id)) == null)) && (!(MovieClip(STAGEPARENT.getChildByName(("energy" + m_player_id))).percentage == null))))
                            {
                                MovieClip(STAGEPARENT.getChildByName(("energy" + m_player_id))).percentage.scaleX = (m_attackData.getAttack(m_attack.Frame).ChargeTime / m_attackData.getAttack(m_attack.Frame).ChargeTimeMax);
                                STAGEPARENT.getChildByName(("energy" + m_player_id)).x = (m_sprite.x + STAGE.x);
                                STAGEPARENT.getChildByName(("energy" + m_player_id)).y = (m_sprite.y + STAGE.y);
                            };
                        };
                    };
                    if (((((((inState(CState.ATTACKING)) && (m_attackData.getAttack(m_attack.Frame).ChargeTime >= m_attackData.getAttack(m_attack.Frame).ChargeTimeMax)) && (!(this.attackIsCharged(m_attack.Frame)))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && (!((!(m_attackData.getAttack(m_attack.Frame).ChargeInAir)) && (m_attack.IsAirAttack)))))
                    {
                        this.setCharge(m_attack.Frame, m_attack.LinkCharge);
                        if ((!(m_attackData.getAttack(m_attack.Frame).ForceUseAtMaxCharge)))
                        {
                            if (this.m_chargeGlowHolderMC == null)
                            {
                                if (m_attackData.getAttack(m_attack.Frame).CustomChargeGlow != null)
                                {
                                    this.m_chargeGlowHolderMC = ResourceManager.getLibraryMC(((m_attackData.getAttack(m_attack.Frame).CustomChargeGlow != null) ? m_attackData.getAttack(m_attack.Frame).CustomChargeGlow : "charge_glow"));
                                }
                                else
                                {
                                    this.m_chargeGlowHolderMC = new MovieClip();
                                };
                                this.m_chargeGlowHolderMC.x = m_sprite.x;
                                this.m_chargeGlowHolderMC.y = m_sprite.y;
                                toggleEffect(this.m_chargeGlowHolderMC, true);
                            };
                        };
                        if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                        {
                            STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                        };
                        this.endAttack();
                    }
                    else
                    {
                        if ((((((inState(CState.ATTACKING)) && (this.shieldIsPressed())) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && (inState(CState.ATTACKING))))
                        {
                            if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                            {
                                STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                            };
                            this.endAttack();
                        }
                        else
                        {
                            if (((((((inState(CState.ATTACKING)) && (!(this.m_pressedControls.LEFT == this.m_pressedControls.RIGHT))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && (inState(CState.ATTACKING))) && (m_collision.ground)))
                            {
                                this.endAttack();
                                if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                                {
                                    STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                                };
                                this.initDodgeRoll(this.m_pressedControls.RIGHT);
                            };
                        };
                    };
                }
                else
                {
                    if (((inState(CState.ATTACKING)) && (m_attackData.getAttack(m_attack.Frame).ChargeTimeMax > 0)))
                    {
                        if ((((((m_attackData.getAttack(m_attack.Frame).ChargeTime <= 3) && (this.m_cStickUse)) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))) && ((((this.m_heldControls.BUTTON2) && (m_attack.AttackType == 1)) || ((this.m_heldControls.BUTTON1) && (m_attack.AttackType == 2))) || (this.m_heldControls.GRAB))))
                        {
                            this.playGlobalSound("chargeclick");
                            this.m_cStickUse = false;
                        };
                        if ((((((((m_attackData.getAttack(m_attack.Frame).ChargeTime >= m_attackData.getAttack(m_attack.Frame).ChargeTimeMax) || (((!(this.attackButtonsHeld())) && (currentStanceFrameIs("charging"))) && (!(this.m_cStickUse)))) || ((this.m_cStickUse) && (currentStanceFrameIs("charging")))) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))) && (!(((m_attack.HoldRepeat) && (this.attackButtonsHeld())) && (!(m_attackData.getAttack(m_attack.Frame).ForceUseAtMaxCharge))))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))))
                        {
                            if (((((this.HoldingItem) && (currentFrameIs("item"))) && (!(currentStanceFrameIs("finish")))) && (!(currentStanceFrameIs("attack")))))
                            {
                                m_attack.ChargeTime = m_attackData.getAttack(m_attack.Frame).ChargeTime;
                            }
                            else
                            {
                                if ((((!(currentStanceFrameIs("attack"))) && (!(currentStanceFrameIs("attack2")))) && (!(currentStanceFrameIs("finish")))))
                                {
                                    m_attack.ChargeTime = m_attackData.getAttack(m_attack.Frame).ChargeTime;
                                    if (((m_attackData.getAttack(m_attack.Frame).ChargeTime >= m_attackData.getAttack(m_attack.Frame).ChargeTimeMax) && (Utils.hasLabel(m_sprite.stance, "attack2"))))
                                    {
                                        this.stancePlayFrame("attack2");
                                    }
                                    else
                                    {
                                        this.stancePlayFrame("attack");
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (((((m_attackData.getAttack(m_attack.Frame).ChargeTime < m_attackData.getAttack(m_attack.Frame).ChargeTimeMax) && (currentStanceFrameIs("charging"))) && (!(currentStanceFrameIs("attack")))) && (!(currentStanceFrameIs("attack2")))))
                            {
                                this.incrementCharge(m_attack.Frame, m_attack.LinkCharge);
                            };
                        };
                        if (((m_attackData.getAttack(m_attack.Frame).ComboMax >= 1) && (currentStanceFrameIs("attack"))))
                        {
                            if (m_attackData.getAttack(m_attack.Frame).ComboMax >= 1)
                            {
                                if (m_attack.ComboTotal < m_attack.ComboMax)
                                {
                                    if ((((!(m_attack.ForceComboContinue)) && ((this.attackButtonsPressed()) || ((m_attack.HoldRepeat) && (this.attackButtonsHeld())))) && (getStanceVar("handled", false))))
                                    {
                                        m_attack.ComboTotal++;
                                        this.setStanceVar("continuePlaying", true);
                                        this.setStanceVar("handled", true);
                                    }
                                    else
                                    {
                                        if ((((m_attack.ForceComboContinue) && (this.attackButtonsPressed())) && (getStanceVar("handled", false))))
                                        {
                                            m_attack.ComboTotal++;
                                            this.setStanceVar("continuePlaying", true);
                                            this.setStanceVar("handled", true);
                                            if (m_attack.NextComboFrame != null)
                                            {
                                                this.stancePlayFrame(m_attack.NextComboFrame);
                                            }
                                            else
                                            {
                                                this.stancePlayFrame(("combo" + m_attack.ComboTotal));
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    }
                    else
                    {
                        if (((inState(CState.ATTACKING)) && (m_attackData.getAttack(m_attack.Frame).ComboMax >= 1)))
                        {
                            if ((((!(m_attack.ForceComboContinue)) && ((this.attackButtonsPressed()) || ((m_attack.HoldRepeat) && (this.attackButtonsHeld())))) && (getStanceVar("handled", false))))
                            {
                                m_attack.ComboTotal++;
                                if (this.m_pressedControls.DOWN)
                                {
                                };
                                this.setStanceVar("continuePlaying", true);
                                this.setStanceVar("handled", true);
                            }
                            else
                            {
                                if ((((m_attack.ForceComboContinue) && (this.attackButtonsPressed())) && (getStanceVar("handled", false))))
                                {
                                    m_attack.ComboTotal++;
                                    this.setStanceVar("continuePlaying", true);
                                    this.setStanceVar("handled", true);
                                    if (m_attack.NextComboFrame != null)
                                    {
                                        this.stancePlayFrame(m_attack.NextComboFrame);
                                    }
                                    else
                                    {
                                        this.stancePlayFrame(("combo" + m_attack.ComboTotal));
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (inState(CState.ATTACKING))
                            {
                                if (((!(m_attack.SecondaryAttack == null)) && (((!(m_attack.HoldRepeat)) && (this.attackButtonsPressed())) || ((m_attack.HoldRepeat) && (this.attackButtonsPressed())))))
                                {
                                    this.stancePlayFrame(m_attack.SecondaryAttack);
                                    m_attack.SecondaryAttack = null;
                                };
                            };
                        };
                    };
                };
            };
            if (((inState(CState.ATTACKING)) && (this.m_usingSpecialAttack)))
            {
                if (this.m_characterStats.SpecialType == 1)
                {
                    if (HasTouchBox)
                    {
                        i = 0;
                        while (i < this.m_grabbed.length)
                        {
                            this.repositionGrabbedCharacter(i);
                            i++;
                        };
                    };
                }
                else
                {
                    if (((this.m_characterStats.SpecialType == 2) || (this.m_characterStats.SpecialType == 3)))
                    {
                        if (m_attack.ExecTime == 1)
                        {
                            tmpX = m_sprite.x;
                            tmpY = m_sprite.y;
                            i2 = 0;
                            while (i2 < STAGEDATA.Characters.length)
                            {
                                opponent = STAGEDATA.Characters[i2];
                                if (opponent === this)
                                {
                                }
                                else
                                {
                                    tmpCentX = ((m_sprite.x + opponent.X) / 2);
                                    tmpCentY = (((m_sprite.y - m_height) + opponent.Y) / 2);
                                    oldPlat = m_currentPlatform;
                                    centCollision = (!(this.testGroundWithCoord(tmpCentX, tmpCentY) == null));
                                    collisionRect = null;
                                    m_currentPlatform = oldPlat;
                                    if (((((((((((((((HasRange) && (!(opponent.StandBy))) && (!(opponent.IsCaught))) && (!(opponent.inState(CState.CRASH_GETUP)))) && (!(opponent.inState(CState.CRASH_LAND)))) && (!(opponent.Invincible))) && (!(opponent.Dead))) && (!(opponent.Hanging))) && (!(opponent.AirDodge))) && (!(opponent.SidestepDodge))) && ((collisionRect = HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.RANGE), opponent.CurrentAnimation.getHitBoxes(opponent.CurrentFrameNum, HitBoxSprite.HIT), Location, opponent.Location, (!(m_facingForward)), (!(opponent.FacingForward)), CurrentScale, opponent.CurrentScale, CurrentRotation, opponent.CurrentRotation)).length > 0)) && (!((opponent.Team == m_team_id) && (m_team_id > 0)))) && (!(centCollision))) && (!(opponent.UsingFinalSmash))))
                                    {
                                        opponent.Capture(m_uid);
                                        this.m_grabbed.push(opponent);
                                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_GRAB, {
                                            "caller":this.APIInstance.instance,
                                            "grabbed":opponent.APIInstance.instance
                                        }));
                                        tempX = m_sprite.x;
                                        tempY = m_sprite.y;
                                        tempX = (tempX * m_sizeRatio);
                                        tempY = (tempY * m_sizeRatio);
                                        if (((this.m_characterStats.FSMagnet) && (((m_facingForward) && (m_sprite.x < opponent.X)) || ((!(m_facingForward)) && (m_sprite.x > opponent.X)))))
                                        {
                                            tmpX = opponent.X;
                                            tmpY = opponent.Y;
                                        };
                                        opponent.MC.x = (opponent.MC.x + (((m_sprite.x + tempX) - opponent.X) / 10));
                                        opponent.MC.y = (opponent.MC.y + (((m_sprite.y + tempY) - opponent.Y) / 10));
                                    };
                                };
                                i2++;
                            };
                            if (this.m_characterStats.FSMagnet)
                            {
                                m_sprite.x = tmpX;
                                m_sprite.y = tmpY;
                                i = 0;
                                while (i < this.m_grabbed.length)
                                {
                                    this.m_grabbed[i].X = m_sprite.x;
                                    this.m_grabbed[i].Y = m_sprite.y;
                                    i++;
                                };
                            };
                            if (this.m_grabbed.length > 0)
                            {
                                m_xSpeed = 0;
                                m_ySpeed = 0;
                            };
                        }
                        else
                        {
                            if (m_attack.ExecTime > 1)
                            {
                                i = 0;
                                while (i < this.m_grabbed.length)
                                {
                                    if (((!(HasTouchBox)) && (Math.sqrt((Math.pow((m_sprite.x - this.m_grabbed[i].X), 2) + Math.pow((m_sprite.y - this.m_grabbed[i].Y), 2))) > 2)))
                                    {
                                        tempX2 = 0;
                                        tempY2 = 0;
                                        tempX2 = (tempX2 * m_sizeRatio);
                                        tempY2 = (tempY2 * m_sizeRatio);
                                        this.m_grabbed[i].MC.x = (this.m_grabbed[i].MC.x + (((m_sprite.x + tempX2) - this.m_grabbed[i].X) / 10));
                                        this.m_grabbed[i].MC.y = (this.m_grabbed[i].MC.y + (((m_sprite.y + tempY2) - this.m_grabbed[i].Y) / 10));
                                    }
                                    else
                                    {
                                        this.repositionGrabbedCharacter(i);
                                    };
                                    i++;
                                };
                            };
                        };
                    }
                    else
                    {
                        if (this.m_characterStats.SpecialType == 4)
                        {
                            this.m_transformLimit--;
                            if (this.m_transformLimit > 0)
                            {
                                if (getStanceVar("canTarget", true))
                                {
                                    if (this.m_attachedReticule == null)
                                    {
                                        this.m_attachedReticule = STAGEDATA.attachUniqueMovieHUD((this.m_characterStats.LinkageID + "_targetreticule"));
                                        tmpPoint = new Point((Main.Width / 2), (Main.Height / 2));
                                        this.m_attachedReticule.x = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint).x;
                                        this.m_attachedReticule.y = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint).y;
                                    };
                                    if ((!(m_attackData.getAttack("special").LockXTarget)))
                                    {
                                        if (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))))
                                        {
                                            this.m_attachedReticule.x = (this.m_attachedReticule.x + 8);
                                        }
                                        else
                                        {
                                            if (((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))))
                                            {
                                                this.m_attachedReticule.x = (this.m_attachedReticule.x - 8);
                                            };
                                        };
                                    };
                                    if ((!(m_attackData.getAttack("special").LockYTarget)))
                                    {
                                        if (((this.m_heldControls.UP) && (!(this.m_heldControls.DOWN))))
                                        {
                                            this.m_attachedReticule.y = (this.m_attachedReticule.y - 8);
                                        }
                                        else
                                        {
                                            if (((this.m_heldControls.DOWN) && (!(this.m_heldControls.UP))))
                                            {
                                                this.m_attachedReticule.y = (this.m_attachedReticule.y + 8);
                                            };
                                        };
                                    };
                                    glob = STAGEDATA.HudForegroundRef.localToGlobal(new Point(this.m_attachedReticule.x, this.m_attachedReticule.y));
                                    if (glob.x < 0)
                                    {
                                        glob.x = 0;
                                    };
                                    if (glob.x > Main.Width)
                                    {
                                        glob.x = Main.Width;
                                    };
                                    if (glob.y < 0)
                                    {
                                        glob.y = 0;
                                    };
                                    if (glob.y > Main.Height)
                                    {
                                        glob.y = Main.Height;
                                    };
                                    glob = STAGEDATA.HudForegroundRef.globalToLocal(glob);
                                    this.m_attachedReticule.x = glob.x;
                                    this.m_attachedReticule.y = glob.y;
                                };
                                if (getStanceVar("canShoot", true))
                                {
                                    tPoint = new Point(this.m_attachedReticule.x, this.m_attachedReticule.y);
                                    if (this.m_heldControls.BUTTON2)
                                    {
                                        this.stancePlayFrame("standard_attack");
                                        Utils.tryToGotoAndStop(this.m_attachedFPS, "standard_attack");
                                        tPoint = STAGEDATA.HudForegroundRef.localToGlobal(tPoint);
                                        tPoint = STAGE.globalToLocal(tPoint);
                                        this.fireProjectile("fs_proj_1", tPoint.x, tPoint.y, true);
                                    }
                                    else
                                    {
                                        if (this.m_heldControls.BUTTON1)
                                        {
                                            this.stancePlayFrame("special_attack");
                                            Utils.tryToGotoAndStop(this.m_attachedFPS, "special_attack");
                                            tPoint = STAGEDATA.HudForegroundRef.localToGlobal(tPoint);
                                            tPoint = STAGE.globalToLocal(tPoint);
                                            this.fireProjectile("fs_proj_2", tPoint.x, tPoint.y, true);
                                        };
                                    };
                                };
                            }
                            else
                            {
                                if (this.m_attachedReticule != null)
                                {
                                    this.stancePlayFrame("end");
                                    Utils.tryToGotoAndStop(this.m_attachedFPS, "end");
                                    this.m_attachedFPS = null;
                                    if (this.m_attachedReticule.parent)
                                    {
                                        STAGEDATA.HudForegroundRef.removeChild(this.m_attachedReticule);
                                    };
                                    this.m_attachedReticule = null;
                                    STAGEDATA.brightenCamera();
                                };
                            };
                        }
                        else
                        {
                            if (this.m_characterStats.SpecialType == 5)
                            {
                                this.m_transformLimit--;
                            }
                            else
                            {
                                if (this.m_characterStats.SpecialType == 6)
                                {
                                    if (STAGEDATA.FSCutscene)
                                    {
                                        this.m_transformLimit--;
                                        if (this.m_transformLimit < 0)
                                        {
                                            this.killFSCutscene();
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
            this.performAttackChecks();
        }

        private function updateCutscenePlaceholders():void
        {
            var playerSlotIndex:int;
            var holder:MovieClip;
            var g:int;
            playerSlotIndex = 0;
            holder = null;
            if (((this.m_attachedFPS) && (this.m_attachedFPS["p1"])))
            {
                g = 0;
                while (g < this.m_grabbed.length)
                {
                    if (this.m_attachedFPS.initialized)
                    {
                        holder = this.m_attachedFPS[(("p" + (playerSlotIndex + 1)) + "holder")];
                        holder.gotoAndStop(this.m_grabbed[g].CurrentFrame);
                        if (holder.stance)
                        {
                            holder.stance.gotoAndStop(this.m_grabbed[g].Stance.currentFrame);
                        };
                        this.m_grabbed[g].applyPalette(holder);
                        if (this.m_grabbed[g].PaletteSwapData)
                        {
                            Utils.replacePalette(holder, this.m_grabbed[g].PaletteSwapData, 2);
                        };
                    }
                    else
                    {
                        if (this.m_grabbed[g].HasStance)
                        {
                            holder = ResourceManager.getLibraryMC(this.m_grabbed[g].LinkageName);
                            holder.uid = this.m_grabbed[g].UID;
                            holder.gotoAndStop(this.m_grabbed[g].CurrentFrame);
                            if (holder.stance)
                            {
                                holder.stance.gotoAndStop(this.m_grabbed[g].Stance.currentFrame);
                            };
                            this.m_grabbed[g].applyPalette(holder);
                            if (this.m_grabbed[g].PaletteSwapData)
                            {
                                Utils.replacePalette(holder, this.m_grabbed[g].PaletteSwapData, 2);
                            };
                            holder.bypassTicker = true;
                            if (this.m_attachedFPS[("p" + (playerSlotIndex + 1))])
                            {
                                this.m_attachedFPS[("p" + (playerSlotIndex + 1))].addChild(holder);
                            }
                            else
                            {
                                this.m_attachedFPS["p1"].addChild(holder);
                            };
                            this.m_attachedFPS[(("p" + (playerSlotIndex + 1)) + "holder")] = holder;
                        };
                    };
                    g++;
                    playerSlotIndex = ((playerSlotIndex + 1) % 4);
                };
                this.m_attachedFPS.initialized = true;
            };
        }

        public function triggerFSCutscene():void
        {
            var tmpPoint2:Point;
            var ch:int;
            if ((!(STAGEDATA.FSCutscene)))
            {
                this.m_attachedFPS = (STAGEDATA.CutsceneRef.addChild(ResourceManager.getLibraryMC((this.m_characterStats.LinkageID + "_hud"))) as MovieClip);
                this.m_attachedFPS.stop();
                Utils.recursiveMovieClipPlay(this.m_attachedFPS, false);
                STAGEDATA.FSCutscene = this.m_attachedFPS;
                this.m_attachedFPS.uid = m_uid;
                tmpPoint2 = new Point((Main.Width / 2), Main.Height);
                this.m_attachedFPS.x = STAGEDATA.CutsceneRef.globalToLocal(tmpPoint2).x;
                this.m_attachedFPS.y = STAGEDATA.CutsceneRef.globalToLocal(tmpPoint2).y;
                this.unnattachFromGround();
                this.updateCutscenePlaceholders();
                if (this.m_grabbed.length > 0)
                {
                    ch = 0;
                    while (ch < this.m_grabbed.length)
                    {
                        this.repositionGrabbedCharacter(ch);
                        ch++;
                    };
                };
            };
        }

        public function killFSCutscene():void
        {
            if (STAGEDATA.FSCutscene)
            {
                STAGEDATA.FSCutscene = null;
                if (((this.m_attachedFPS) && (this.m_attachedFPS.parent)))
                {
                    this.m_attachedFPS.parent.removeChild(this.m_attachedFPS);
                };
                this.m_attachedFPS = null;
            };
        }

        private function performAttackChecks():void
        {
            var i:int;
            var intitialXSpeed:Number;
            var rangle:Number;
            var wasRunningRight:Boolean;
            var tmpCharge:Number;
            var tmpFrameLink:String;
            var tmpXFrame:String;
            var tmpCharge2:Number;
            var tmpFrameLink2:String;
            var tmpXFrame2:String;
            var anyCStick:Boolean;
            var tmpUp:Boolean;
            var tmpDown:Boolean;
            var tmpLeft:Boolean;
            var tmpRight:Boolean;
            var lastDistance:Number;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var opponent:Character;
            var item:Item;
            var target:TargetTestTarget;
            i = 0;
            intitialXSpeed = m_xSpeed;
            if ((((inState(CState.ATTACKING)) && ((currentFrameIs("stand")) || (currentFrameIs("fall")))) && (m_attack.ExecTime > 1)))
            {
                this.forceEndAttack();
            };
            if (((((inState(CState.ATTACKING)) && (!(m_collision.ground))) && (m_attack.CancelWhenAirborne)) && ((!(m_attack.IsAirAttack)) || ((m_attack.IsAirAttack) && (m_attack.HasLanded)))))
            {
                this.forceEndAttack();
            };
            if (((inState(CState.ATTACKING)) && (m_attack.Rotate)))
            {
                rangle = Utils.getAngleBetween(new Point(), new Point(m_xSpeed, m_ySpeed));
                rangle = Utils.forceBase360(((m_facingForward) ? -(rangle) : (-(rangle) + 180)));
                m_sprite.rotation = rangle;
            };
            if (((inState(CState.ATTACKING)) && ((((!(m_collision.ground)) && (m_attack.AllowControl)) || (((m_collision.ground) && (m_attack.AllowControl)) && (m_attack.AllowControlGround))) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))
            {
                if (m_collision.ground)
                {
                    if (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))))
                    {
                        if (m_attack.XSpeedAccel != 0)
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? m_attack.XSpeedAccel : 0));
                        }
                        else
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                        };
                        if (((!(m_xSpeed === intitialXSpeed)) && (m_xSpeed > Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))))
                        {
                            m_xSpeed = Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed);
                        }
                        else
                        {
                            if (m_xSpeed > Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))
                            {
                                if (m_attack.XSpeedDecay == 0)
                                {
                                    decel(this.m_characterStats.DecelRate);
                                }
                                else
                                {
                                    decel(m_attack.XSpeedDecay);
                                };
                            };
                        };
                        if ((!((((m_collision.ground) && (!(m_attack.CanFallOff))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (!(this.willFallOffRange((m_sprite.x + m_xSpeed), m_sprite.y))))))
                        {
                            this.m_attemptToMove(m_xSpeed, 0);
                        };
                    }
                    else
                    {
                        if (((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))))
                        {
                            if (m_attack.XSpeedAccel != 0)
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? m_attack.XSpeedAccel : 0));
                            }
                            else
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                            };
                            if (((!(m_xSpeed === intitialXSpeed)) && (m_xSpeed < -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)))))
                            {
                                m_xSpeed = -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed));
                            }
                            else
                            {
                                if (m_xSpeed < -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)))
                                {
                                    if (m_attack.XSpeedDecay == 0)
                                    {
                                        decel(this.m_characterStats.DecelRate);
                                    }
                                    else
                                    {
                                        decel(m_attack.XSpeedDecay);
                                    };
                                };
                            };
                            if ((!((((m_collision.ground) && (!(m_attack.CanFallOff))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (!(this.willFallOffRange((m_sprite.x + m_xSpeed), m_sprite.y))))))
                            {
                                this.m_attemptToMove(m_xSpeed, 0);
                            };
                        };
                    };
                }
                else
                {
                    if (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))))
                    {
                        if (m_attack.XSpeedAccelAir != 0)
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? m_attack.XSpeedAccelAir : 0));
                        }
                        else
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? this.m_characterStats.AccelRateAir : 0));
                        };
                        if (((!(m_xSpeed === intitialXSpeed)) && (m_xSpeed > Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))))
                        {
                            m_xSpeed = Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed);
                        }
                        else
                        {
                            if (m_xSpeed > Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))
                            {
                                if (m_attack.XSpeedDecayAir != 0)
                                {
                                    decel(m_attack.XSpeedDecayAir);
                                };
                            };
                        };
                    }
                    else
                    {
                        if (((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))))
                        {
                            if (m_attack.XSpeedAccelAir != 0)
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? m_attack.XSpeedAccelAir : 0));
                            }
                            else
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? this.m_characterStats.AccelRateAir : 0));
                            };
                            if (((!(m_xSpeed === intitialXSpeed)) && (m_xSpeed < -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)))))
                            {
                                m_xSpeed = -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed));
                            }
                            else
                            {
                                if (m_xSpeed < -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)))
                                {
                                    if (m_attack.XSpeedDecayAir != 0)
                                    {
                                        decel(m_attack.XSpeedDecayAir);
                                    };
                                };
                            };
                        };
                    };
                };
                if (((m_attack.XSpeedCap >= 0) && (Utils.fastAbs(m_xSpeed) > m_attack.XSpeedCap)))
                {
                    m_xSpeed = ((m_xSpeed > 0) ? m_attack.XSpeedCap : -(m_attack.XSpeedCap));
                };
            };
            if ((((((inState(CState.ATTACKING)) && (m_collision.ground)) && ((m_attack.AllowJump) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && ((this.jumpIsPressed()) || (this.m_bufferedAttackJump))) && (!(isHitStunOrParalysis()))))
            {
                if (((m_attack.JumpCancelAttack) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))))
                {
                    this.clearControlsBuffer();
                    this.forceEndAttack();
                    this.resetSmashTimers();
                    this.jumpChamber();
                }
                else
                {
                    this.unnattachFromGround();
                    m_ySpeed = ((this.m_heldControls.DOWN) ? (-(this.m_characterStats.JumpSpeed) * 0.6) : -(this.m_characterStats.JumpSpeed));
                    if (this.m_charIsFull)
                    {
                        m_ySpeed = (m_ySpeed / 2);
                    };
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.attachJumpEffect();
                    this.m_jumpEffectTimer.reset();
                };
            }
            else
            {
                if ((((((((inState(CState.ATTACKING)) && (!(m_collision.ground))) && (this.m_jumpSpeedMidairDelay.IsComplete)) && (m_attack.AllowDoubleJump)) && (this.m_jumpCount < this.m_characterStats.MaxJump)) && ((this.jumpIsPressed()) || (this.m_bufferedAttackJump))) && (!(isHitStunOrParalysis()))))
                {
                    this.m_jumpSpeedMidairDelay.reset();
                    this.m_jumpCount++;
                    this.unnattachFromGround();
                    m_ySpeed = -(this.m_characterStats.JumpSpeedMidAir);
                    if (this.m_charIsFull)
                    {
                        m_ySpeed = (m_ySpeed / 2);
                    };
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    if (this.m_midAirJumpConstantTime.MaxTime > 0)
                    {
                        this.m_midAirJumpConstantTime.reset();
                    };
                    if (((m_attack.DoubleJumpCancelAttack) && (!((this.m_jumpCount > 2) && (!(this.m_multiJumpDelay.IsComplete))))))
                    {
                        this.clearControlsBuffer();
                        this.forceEndAttack();
                        this.initMidairJump();
                    };
                };
            };
            if ((((((((inState(CState.ATTACKING)) && (this.jumpIsPressed())) && (m_actionShot)) && (!(m_paralysis))) && (m_attack.AllowJump)) && (m_collision.ground)) && (this.m_jumpCount < this.m_characterStats.MaxJump)))
            {
                this.m_bufferedAttackJump = true;
            };
            if (((inState(CState.ATTACKING)) && (m_attack.AllowRun)))
            {
                if ((((m_collision.ground) && (getStanceVar("action", "standing"))) && ((!(m_xSpeed == 0)) || (!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT)))))
                {
                    this.stancePlayFrame("moving");
                }
                else
                {
                    if ((((m_collision.ground) && (getStanceVar("action", "moving"))) && (m_xSpeed == 0)))
                    {
                        this.stancePlayFrame("standing");
                    }
                    else
                    {
                        if ((((m_attack.AllowJump) && (!(m_collision.ground))) && (m_attack.IsAirAttack)))
                        {
                            if (((getStanceVar("action", "rising")) && (m_ySpeed > 0)))
                            {
                                this.stancePlayFrame("falling");
                            };
                        };
                    };
                };
                wasRunningRight = (m_xSpeed > 0);
                if (((!(m_collision.ground)) && (!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT))))
                {
                    if (this.m_heldControls.RIGHT)
                    {
                        if (m_attack.XSpeedAccelAir != 0)
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? m_attack.XSpeedAccelAir : 0));
                        }
                        else
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? this.m_characterStats.AccelRateAir : 0));
                        };
                    }
                    else
                    {
                        if (m_attack.XSpeedAccelAir != 0)
                        {
                            m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? m_attack.XSpeedAccelAir : 0));
                        }
                        else
                        {
                            m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? this.m_characterStats.AccelRateAir : 0));
                        };
                    };
                }
                else
                {
                    if (((m_collision.ground) && (!(this.m_heldControls.RIGHT == this.m_heldControls.LEFT))))
                    {
                        if (m_attack.XSpeedAccel != 0)
                        {
                            if (this.m_heldControls.RIGHT)
                            {
                                m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? m_attack.XSpeedAccel : 0));
                            }
                            else
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? m_attack.XSpeedAccel : 0));
                            };
                        }
                        else
                        {
                            if (this.m_heldControls.RIGHT)
                            {
                                m_xSpeed = (m_xSpeed + ((m_xSpeed < Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed)) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                            }
                            else
                            {
                                m_xSpeed = (m_xSpeed - ((m_xSpeed > -(Utils.getSpeedCap(m_attack.XSpeedCap, this.m_characterStats.MaxJumpSpeed))) ? (this.m_characterStats.AccelRate * m_currentPlatform.accel_friction) : 0));
                            };
                        };
                        if ((((!(wasRunningRight)) && (m_xSpeed > 0)) || ((wasRunningRight) && (m_xSpeed < 0))))
                        {
                            m_xSpeed = ((this.m_heldControls.RIGHT) ? (this.m_characterStats.AccelStart * this.m_norm_xSpeed) : (this.m_characterStats.AccelStart * -(this.m_norm_xSpeed)));
                            if (((Utils.hasLabel(m_sprite.stance, "turn")) && (!(m_sprite.stance.currentLabel == "turn"))))
                            {
                                this.stancePlayFrame("turn");
                            };
                        };
                    };
                };
                if (((m_attack.XSpeedCap >= 0) && (Utils.fastAbs(m_xSpeed) > m_attack.XSpeedCap)))
                {
                    m_xSpeed = ((m_xSpeed > 0) ? m_attack.XSpeedCap : -(m_attack.XSpeedCap));
                }
                else
                {
                    if (Utils.fastAbs(m_xSpeed) > m_attack.XSpeedCap)
                    {
                        m_xSpeed = ((m_xSpeed > 0) ? m_attack.XSpeedCap : -(m_attack.XSpeedCap));
                    };
                };
                this.resetRotation();
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                if ((((m_collision.ground) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))))
                {
                    attachToGround();
                };
            };
            if (((inState(CState.ATTACKING)) && (!((!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT)) && (((((!(m_collision.ground)) && (m_attack.AllowControl)) || (((m_collision.ground) && (m_attack.AllowControl)) && (m_attack.AllowControlGround))) || (m_attack.AllowRun)) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))))
            {
                if (m_collision.ground)
                {
                    if (m_attack.XSpeedDecay == 0)
                    {
                        decel(this.m_characterStats.DecelRate);
                    }
                    else
                    {
                        decel(m_attack.XSpeedDecay);
                    };
                }
                else
                {
                    if ((!((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)) && (inState(CState.ATTACKING)))))
                    {
                        if (m_attack.XSpeedDecayAir == 0)
                        {
                            decel(this.m_characterStats.DecelRateAir);
                        }
                        else
                        {
                            decel(m_attack.XSpeedDecayAir);
                        };
                    };
                };
            };
            if (((inState(CState.ATTACKING)) && (((m_attack.AllowTurn) && (!(m_sprite.stance.currentLabel == "turn"))) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))))
            {
                if ((((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) && (!(m_facingForward))))
                {
                    m_faceRight();
                    m_attack.IsForward = true;
                    if (((Utils.hasLabel(m_sprite.stance, "turn")) && (!(m_sprite.stance.currentLabel == "turn"))))
                    {
                        this.stancePlayFrame("turn");
                    };
                    if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                    {
                        this.forceEndAttack();
                    };
                }
                else
                {
                    if ((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (m_facingForward)))
                    {
                        m_faceLeft();
                        m_attack.IsForward = false;
                        if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                        {
                            this.forceEndAttack();
                        };
                    };
                };
            };
            if (((inState(CState.ATTACKING)) && (m_attack.LinkFrames)))
            {
                if (((!(m_collision.ground)) && (!(m_attack.IsAirAttack))))
                {
                    m_attack.IsAirAttack = true;
                    tmpCharge = m_attackData.getAttack(m_attack.Frame).ChargeTime;
                    m_attack.Frame = (m_attack.Frame + "_air");
                    m_attackData.getAttack(m_attack.Frame).OverrideMap.clear();
                    m_attackData.setAttackVar(m_attack.Frame, "chargetime", tmpCharge);
                    m_attack.LinkCharge = m_attackData.getAttack(m_attack.Frame).LinkCharge;
                    tmpFrameLink = ((HasStance) ? ((m_sprite.stance.xframeLink) || (null)) : null);
                    tmpXFrame = ((HasStance) ? ((m_sprite.stance.xframe) || (null)) : null);
                    this.playFrame(m_attack.Frame);
                    if (((HasStance) && (!(tmpFrameLink == null))))
                    {
                        this.stancePlayFrame(tmpFrameLink);
                    };
                    if (((tmpXFrame) && (HasStance)))
                    {
                        m_sprite.stance.xframe = tmpXFrame;
                    };
                }
                else
                {
                    if (((m_collision.ground) && (m_attack.IsAirAttack)))
                    {
                        m_attack.IsAirAttack = false;
                        tmpCharge2 = m_attackData.getAttack(m_attack.Frame).ChargeTime;
                        m_attack.Frame = m_attack.Frame.substring(0, m_attack.Frame.lastIndexOf("_"));
                        m_attackData.getAttack(m_attack.Frame).OverrideMap.clear();
                        m_attackData.setAttackVar(m_attack.Frame, "chargetime", tmpCharge2);
                        m_attack.LinkCharge = m_attackData.getAttack(m_attack.Frame).LinkCharge;
                        tmpFrameLink2 = ((HasStance) ? m_sprite.stance.xframeLink : null);
                        tmpXFrame2 = ((HasStance) ? ((m_sprite.stance.xframe) || (null)) : null);
                        this.playFrame(m_attack.Frame);
                        if (((HasStance) && (!(tmpFrameLink2 == null))))
                        {
                            this.stancePlayFrame(tmpFrameLink2);
                        };
                        if (((tmpXFrame2) && (HasStance)))
                        {
                            m_sprite.stance.xframe = tmpXFrame2;
                        };
                    };
                };
            };
            if (inState(CState.ATTACKING))
            {
                m_attack.XLoc = MC.x;
                m_attack.YLoc = MC.y;
                if ((((m_attack.Cancel) && (this.attackButtonsPressed())) && (getStanceVar("waiting", true))))
                {
                    m_ySpeed = ((m_collision.ground) ? 0 : -4);
                    m_attack.Cancel = false;
                    m_attack.WasCancelled = true;
                    this.stancePlayFrame("finish");
                };
                if ((((m_attack.AirCancel) && ((((((this.m_pressedControls.BUTTON2) || (this.m_pressedControls.C_UP)) || (this.m_pressedControls.GRAB)) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT))) && (!(m_collision.ground))))
                {
                    anyCStick = ((((this.m_heldControls.C_UP) || (this.m_heldControls.C_DOWN)) || (this.m_heldControls.C_LEFT)) || (this.m_heldControls.C_RIGHT));
                    tmpUp = (((this.m_heldControls.UP) && (!(anyCStick))) || (this.m_heldControls.C_UP));
                    tmpDown = (((this.m_heldControls.DOWN) && (!(anyCStick))) || (this.m_heldControls.C_DOWN));
                    tmpLeft = (((this.m_heldControls.LEFT) && (!(anyCStick))) || (this.m_heldControls.C_LEFT));
                    tmpRight = (((this.m_heldControls.RIGHT) && (!(anyCStick))) || (this.m_heldControls.C_RIGHT));
                    if (((((tmpLeft) && (!(tmpRight))) && (!(m_facingForward))) || (((tmpRight) && (!(tmpLeft))) && (m_facingForward))))
                    {
                        if (m_attack.DisableJump)
                        {
                            this.m_jumpCount = this.m_characterStats.MaxJump;
                        };
                        this.Attack("a_air_forward", 1);
                    }
                    else
                    {
                        if (((((tmpLeft) && (!(tmpRight))) && (m_facingForward)) || (((tmpRight) && (!(tmpLeft))) && (!(m_facingForward)))))
                        {
                            if (m_attack.DisableJump)
                            {
                                this.m_jumpCount = this.m_characterStats.MaxJump;
                            };
                            this.Attack("a_air_backward", 1);
                        }
                        else
                        {
                            if (tmpDown)
                            {
                                if (m_attack.DisableJump)
                                {
                                    this.m_jumpCount = this.m_characterStats.MaxJump;
                                };
                                this.Attack("a_air_down", 1);
                            }
                            else
                            {
                                if (tmpUp)
                                {
                                    if (m_attack.DisableJump)
                                    {
                                        this.m_jumpCount = this.m_characterStats.MaxJump;
                                    };
                                    this.Attack("a_air_up", 1);
                                }
                                else
                                {
                                    if (m_attack.DisableJump)
                                    {
                                        this.m_jumpCount = this.m_characterStats.MaxJump;
                                    };
                                    this.Attack("a_air", 1);
                                };
                            };
                        };
                    };
                }
                else
                {
                    if ((((m_attack.AirCancelSpecial) && (this.m_pressedControls.BUTTON1)) && (!(m_collision.ground))))
                    {
                        if (((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (!(m_facingForward))) || (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) && (m_facingForward))))
                        {
                            if (m_attack.DisableJump)
                            {
                                this.m_jumpCount = this.m_characterStats.MaxJump;
                            };
                            this.Attack("b_forward_air", 2);
                        }
                        else
                        {
                            if (((((this.m_heldControls.LEFT) && (!(this.m_heldControls.RIGHT))) && (m_facingForward)) || (((this.m_heldControls.RIGHT) && (!(this.m_heldControls.LEFT))) && (!(m_facingForward)))))
                            {
                                if (m_facingForward)
                                {
                                    m_faceLeft();
                                }
                                else
                                {
                                    m_faceRight();
                                };
                                if (m_attack.DisableJump)
                                {
                                    this.m_jumpCount = this.m_characterStats.MaxJump;
                                };
                                this.Attack("b_forward_air", 2);
                            }
                            else
                            {
                                if (this.m_heldControls.DOWN)
                                {
                                    if (m_attack.DisableJump)
                                    {
                                        this.m_jumpCount = this.m_characterStats.MaxJump;
                                    };
                                    this.Attack("b_down_air", 2);
                                }
                                else
                                {
                                    if (this.m_heldControls.UP)
                                    {
                                        if (m_attack.DisableJump)
                                        {
                                            this.m_jumpCount = this.m_characterStats.MaxJump;
                                        };
                                        this.Attack("b_up_air", 2);
                                    }
                                    else
                                    {
                                        if (m_attack.DisableJump)
                                        {
                                            this.m_jumpCount = this.m_characterStats.MaxJump;
                                        };
                                        this.neutralSpecialFlipCheck("b_air");
                                        this.Attack("b_air", 2);
                                    };
                                };
                            };
                        };
                    };
                };
                if (HasHoming)
                {
                    if (m_attack.HomingTarget == null)
                    {
                        lastDistance = 99999999;
                        collisionRect = null;
                        opponent = null;
                        item = null;
                        target = null;
                        m_attack.HomingTarget = null;
                        i = 0;
                        while (((i < STAGEDATA.ItemsRef.MAXITEMS) && (m_attack.HomingTarget == null)))
                        {
                            item = STAGEDATA.ItemsRef.ItemsInUse[i];
                            if (((((!(item == null)) && (!(item.MC.hitBox == null))) && (item.IsSmashBall)) && ((collisionRect = HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HOMING), item.CurrentAnimation.getHitBoxes(item.CurrentFrameNum, HitBoxSprite.HIT), Location, item.Location, (!(m_facingForward)), (!(item.FacingForward)), CurrentScale, item.CurrentScale, CurrentRotation, item.CurrentRotation)).length > 0)))
                            {
                                m_attack.HomingTarget = item;
                                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                                    "caller":this.APIInstance.instance,
                                    "target":item.APIInstance.instance,
                                    "type":"Item"
                                }));
                            };
                            i++;
                        };
                        i = 0;
                        while (i < STAGEDATA.Characters.length)
                        {
                            opponent = STAGEDATA.Characters[i];
                            if ((((((((((!(opponent == this)) && (!(opponent.StandBy))) && (!(opponent.Revival))) && (!(opponent.AirDodge))) && (opponent.HasHitBox)) && (!(opponent.Dead))) && (!(opponent.Invincible))) && ((m_attack.HomingTarget == null) || (this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y) < lastDistance))) && ((collisionRect = HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HOMING), opponent.CurrentAnimation.getHitBoxes(opponent.CurrentFrameNum, HitBoxSprite.HIT), Location, opponent.Location, (!(m_facingForward)), (!(opponent.FacingForward)), CurrentScale, opponent.CurrentScale, CurrentRotation, opponent.CurrentRotation)).length > 0)))
                            {
                                m_attack.HomingTarget = opponent;
                                lastDistance = this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y);
                                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                                    "caller":this.APIInstance.instance,
                                    "target":opponent.APIInstance.instance,
                                    "type":"Character"
                                }));
                            };
                            i++;
                        };
                        i = 0;
                        while (i < STAGEDATA.Targets.length)
                        {
                            target = STAGEDATA.Targets[i];
                            if ((((target.inState(TState.IDLE)) && ((m_attack.HomingTarget == null) || (this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y) < lastDistance))) && ((collisionRect = HitBoxSprite.hitTestArray(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HOMING), target.CurrentAnimation.getHitBoxes(target.CurrentFrameNum, HitBoxSprite.HIT), Location, target.Location, (!(m_facingForward)), (!(target.FacingForward)), CurrentScale, target.CurrentScale, CurrentRotation, target.CurrentRotation)).length > 0)))
                            {
                                m_attack.HomingTarget = target;
                                lastDistance = this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y);
                                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                                    "caller":this,
                                    "target":target,
                                    "type":"Target"
                                }));
                            };
                            i++;
                        };
                    };
                };
                if (((inState(CState.ATTACKING)) && (m_attack.Frame == "item")))
                {
                    this.updateItemHolding();
                };
            };
        }

        private function attachCeilingBounceEffect(flip:Boolean, diagonal:Boolean):void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("ground_bounce");
                tmpMC.rotation = 180;
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.x = OverlayX;
                tmpMC.y = (OverlayY - m_height);
                if (diagonal)
                {
                    tmpMC.rotation = (tmpMC.rotation + ((flip) ? 45 : -45));
                };
            };
        }

        private function attachGroundBounceEffect():void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("ground_bounce");
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.x = OverlayX;
                tmpMC.y = OverlayY;
            };
        }

        private function attachWallBounceEffect(flip:Boolean, diagonal:Boolean):void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("ground_bounce");
                tmpMC.rotation = ((!(flip)) ? 90 : 270);
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.x = (OverlayX + ((!(this.m_flyingRight)) ? ((-(m_width) / 2) * m_sizeRatio) : ((m_width / 2) * m_sizeRatio)));
                tmpMC.y = (OverlayY - (m_height / 2));
                if (diagonal)
                {
                    tmpMC.rotation = (tmpMC.rotation + ((flip) ? 45 : -45));
                };
            };
        }

        private function attachJumpEffect():void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("effect_jump");
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.alpha = 0.75;
                if ((!(m_facingForward)))
                {
                    tmpMC.scaleX = -(Utils.fastAbs(tmpMC.scaleX));
                };
                tmpMC.x = OverlayX;
                tmpMC.y = OverlayY;
            };
        }

        private function attachJumpMidairEffect():void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("effect_doublejump");
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.alpha = 0.75;
                if ((!(m_facingForward)))
                {
                    tmpMC.scaleX = -(Utils.fastAbs(tmpMC.scaleX));
                };
                tmpMC.x = OverlayX;
                tmpMC.y = OverlayY;
            };
        }

        private function attachRunEffect():void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("effect_run");
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.alpha = 0.75;
                if ((!(m_facingForward)))
                {
                    tmpMC.scaleX = (tmpMC.scaleX * -1);
                };
                tmpMC.x = OverlayX;
                tmpMC.y = OverlayY;
            };
        }

        private function attachLandEffect():void
        {
            var tmpMC:MovieClip;
            if (STAGEDATA.getQualitySettings().global_effects)
            {
                tmpMC = STAGEDATA.attachEffectOverlay("effect_land");
                tmpMC.width = (tmpMC.width * m_sizeRatio);
                tmpMC.height = (tmpMC.height * m_sizeRatio);
                tmpMC.alpha = 0.75;
                if ((!(m_facingForward)))
                {
                    tmpMC.scaleX = (tmpMC.scaleX * -1);
                };
                tmpMC.x = OverlayX;
                tmpMC.y = OverlayY;
            };
        }

        private function forceEndAttack():void
        {
            var originalState:uint;
            var targetState:uint;
            var attackObj:AttackObject;
            var i:int;
            if ((!(this.m_safeToEndAttack)))
            {
                return;
            };
            this.m_safeToEndAttack = false;
            if (((((inState(CState.SHIELDING)) || (inState(CState.SHIELD_DROP))) || (inState(CState.DODGE_ROLL))) || (inState(CState.SIDESTEP_DODGE))))
            {
                this.m_deactivateShield();
                this.setIntangibility(false);
            };
            originalState = m_state;
            targetState = CState.IDLE;
            attackObj = m_attackData.getAttack(m_attack.Frame);
            this.turnOffInvincibility();
            if (inState(CState.ATTACKING))
            {
                if (attackObj)
                {
                    attackObj.OverrideMap.clear();
                };
                this.killSmashTimers();
                if ((!(m_collision.ground)))
                {
                    if (this.m_attackHovering)
                    {
                        targetState = CState.HOVER;
                    }
                    else
                    {
                        targetState = CState.JUMP_FALLING;
                    };
                }
                else
                {
                    this.m_attackHovering = false;
                };
                if (this.m_usingSpecialAttack)
                {
                    this.killFSCutscene();
                    if (this.m_item2 != null)
                    {
                        this.m_item2.destroy();
                        this.m_item2 = null;
                    };
                    if ((!(this.m_transformedSpecial)))
                    {
                        this.FinalSmashMeterCharge = 0;
                        this.m_finalSmashMeterReady = false;
                    };
                    this.releaseOpponent();
                    STAGEDATA.brightenCamera();
                };
                this.m_justReleased = false;
                if (m_attack.Rocket)
                {
                    m_attack.Rocket = false;
                };
                if (((m_attack.Frame == "item") && (!(this.m_item == null))))
                {
                    this.m_item.CurrentAttackState.IsAttacking = false;
                };
                if ((!(this.m_charIsFull)))
                {
                    this.releaseOpponent();
                };
                this.m_attackDelay = m_attack.AttackDelay;
                if (((!(m_collision.ground)) && (m_attack.DisableJump)))
                {
                    this.m_jumpCount = this.m_characterStats.MaxJump;
                };
                m_attack.Frame = null;
                if (((this.m_usingSpecialAttack) && ((this.m_characterStats.SpecialType == 2) || (this.m_characterStats.SpecialType == 3))))
                {
                    this.releaseOpponent();
                };
                this.m_usingSpecialAttack = false;
                if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                {
                    STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                };
                m_attack.Rocket = false;
                if (m_attack.CancelSoundOnEnd)
                {
                    this.stopSoundID(this.m_lastSFX);
                    this.m_lastSFX = -1;
                };
                if (m_attack.CancelVoiceOnEnd)
                {
                    this.stopSoundID(this.m_lastVFX);
                    this.m_lastVFX = -1;
                };
            };
            this.resetRotation();
            if (inState(CState.SHIELDING))
            {
                this.m_deactivateShield();
            };
            if (inState(CState.LEDGE_ROLL))
            {
                i = 0;
                while (((i < 10) && (!(m_collision.ground))))
                {
                    m_sprite.y++;
                    m_collision.ground = (!((m_currentPlatform = this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1))) == null));
                    i++;
                };
                if ((!(m_collision.ground)))
                {
                    m_sprite.y = (m_sprite.y - 10);
                };
            }
            else
            {
                if ((((inState(CState.ROLL)) || (inState(CState.DODGE_ROLL))) || (inState(CState.LEDGE_ROLL))))
                {
                    m_xSpeed = 0;
                };
            };
            if (inState(CState.ITEM_TOSS))
            {
                if (((this.m_attackHovering) && (!(m_collision.ground))))
                {
                    targetState = CState.HOVER;
                }
                else
                {
                    this.m_attackHovering = false;
                    targetState = CState.IDLE;
                };
            };
            if (((inState(CState.CRASH_GETUP)) && (this.m_dizzyTimer > 0)))
            {
                targetState = CState.DIZZY;
            };
            this.m_attackHovering = false;
            this.m_ledge = null;
            this.m_lastLedge = null;
            this.resetCameraBox();
            m_sprite.camOverride = null;
            if ((((originalState === CState.CAUGHT) && (this.m_grabberID)) && (STAGEDATA.getCharacterByUID(this.m_grabberID))))
            {
                STAGEDATA.getCharacterByUID(this.m_grabberID).grabRelease();
            };
            if (((originalState === CState.ATTACKING) || (originalState === CState.ITEM_TOSS)))
            {
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ATTACK_COMPLETE, {"caller":this.APIInstance.instance}));
            };
            if (m_state === originalState)
            {
                if (((STAGEDATA.AirDodge.match(/melee/)) && (inState(CState.AIR_DODGE))))
                {
                    this.setState(CState.DISABLED);
                }
                else
                {
                    if ((((((!(inState(CState.DISABLED))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.STUNNED)))) && (!(this.m_attackHovering))))
                    {
                        this.setState(targetState);
                    };
                };
            };
            this.m_safeToEndAttack = true;
        }

        private function getDistanceFrom(xpos:Number, ypos:Number):Number
        {
            return (Math.sqrt((Math.pow((xpos - m_sprite.x), 2) + Math.pow((ypos - m_sprite.y), 2))));
        }

        private function checkLinkedProjectiles():void
        {
            var i:int;
            i = 0;
            while (i < this.m_projectile.length)
            {
                if (this.m_projectile[i] != null)
                {
                    if (((!(this.m_projectile[i].Dead)) && (this.m_projectile[i].ProjectileAttackObj.LinkAttackID)))
                    {
                        this.m_projectile[i].Attack.AttackID = m_attack.AttackID;
                    };
                };
                i++;
            };
        }

        private function checkSyncedProjectiles():void
        {
            var i:int;
            i = 0;
            while (((i < this.m_projectile.length) && (HasPLockBox)))
            {
                if (this.m_projectile[i] != null)
                {
                    if (((!(this.m_projectile[i].Dead)) && (this.m_projectile[i].ProjectileAttackObj.LockTrajectory)))
                    {
                        this.m_projectile[i].syncPosition();
                    };
                };
                i++;
            };
        }

        private function checkDeadProjectiles():void
        {
            var i:int;
            i = 0;
            while (i < this.m_projectile.length)
            {
                if (((!(this.m_projectile[i] == null)) && (this.m_projectile[i].Dead)))
                {
                    this.m_projectile[i] = null;
                };
                i++;
            };
        }

        public function destroyAllProjectiles():void
        {
            var i:int;
            i = 0;
            while (((i < this.m_characterStats.MaxProjectile) && (i < this.m_projectile.length)))
            {
                if (this.m_projectile[i] != null)
                {
                    this.m_projectile[i].destroy();
                    this.m_projectile[i] = null;
                };
                i++;
            };
        }

        private function getIndexOfOldestProjectile(statsName:String):int
        {
            var oldest:int;
            var i:int;
            oldest = -1;
            i = 0;
            while (((i < this.m_characterStats.MaxProjectile) && (i < this.m_projectile.length)))
            {
                if ((((!(this.m_projectile[i] == null)) && (this.m_projectile[i].ProjectileAttackObj.StatsName == statsName)) && ((oldest < 0) || (this.m_projectile[i].Time > this.m_projectile[oldest].Time))))
                {
                    oldest = i;
                };
                i++;
            };
            return (oldest);
        }

        public function fireProjectile(proj:*, xOverride:Number=0, yOverride:Number=0, absolute:Boolean=false, options:Object=null):Projectile
        {
            var success:Projectile;
            var n:ProjectileAttack;
            var i:int;
            var old:int;
            var rep:int;
            success = null;
            n = null;
            i = 0;
            if ((proj as String))
            {
                n = m_attackData.getProjectile(proj);
            }
            else
            {
                n = new ProjectileAttack();
                n.importData(proj);
            };
            if ((!(options)))
            {
                options = {};
            };
            if (n != null)
            {
                i = 0;
                while ((((i < this.m_characterStats.MaxProjectile) && (i < this.m_projectile.length)) && (!(success))))
                {
                    if ((((((this.m_projectile[i] == null) || (this.m_projectile[i].inState(PState.DEAD))) || (n.LimitOverwrite)) && (!(n.StatsName == null))) && ((this.getProjectileLimit(n.StatsName) < n.Limit) || (n.LimitOverwrite))))
                    {
                        old = i;
                        if (((n.LimitOverwrite) && (this.getProjectileLimit(n.StatsName) >= n.Limit)))
                        {
                            i = this.getIndexOfOldestProjectile(n.StatsName);
                            if (i < 0)
                            {
                                return (null);
                            };
                            this.m_projectile[i].destroy();
                            this.m_projectile[i] = null;
                        }
                        else
                        {
                            if (n.LimitOverwrite)
                            {
                                i = this.getIndexOfOldestProjectile(n.StatsName);
                                rep = 0;
                                while (rep < this.m_projectile.length)
                                {
                                    if (this.m_projectile[rep] == null)
                                    {
                                        i = rep;
                                        break;
                                    };
                                    rep++;
                                };
                                if (i < 0)
                                {
                                    return (null);
                                };
                                if (this.m_projectile[i])
                                {
                                    this.m_projectile[i].destroy();
                                };
                            };
                        };
                        this.m_projectile[i] = new Projectile({
                            "owner":this,
                            "player_id":m_player_id,
                            "x_start":m_sprite.x,
                            "y_start":m_sprite.y,
                            "sizeRatio":m_sizeRatio,
                            "facingForward":m_facingForward,
                            "chargetime":((options.chargetime) || (m_attack.ChargeTime)),
                            "chargetime_max":((options.chargetime_max) || (m_attack.ChargeTimeMax)),
                            "frame":(n.StatsName + "_proj"),
                            "staleMultiplier":this.totalMoveDecay((n.StatsName + "_proj")),
                            "sizeStatus":this.m_sizeStatus,
                            "terrains":m_terrains,
                            "platforms":m_platforms,
                            "team_id":m_team_id,
                            "volume_sfx":this.m_characterStats.VolumeSFX,
                            "volume_vfx":this.m_characterStats.VolumeVFX
                        }, n, STAGEDATA);
                        success = this.m_projectile[i];
                        this.checkLinkedProjectiles();
                        this.m_lastProjectile = i;
                        if (((!(xOverride == 0)) || (!(yOverride == 0))))
                        {
                            if (absolute)
                            {
                                this.m_projectile[i].X = xOverride;
                                this.m_projectile[i].Y = yOverride;
                                this.m_projectile[i].safeMove(0, (n.YOffset * m_sizeRatio));
                                this.m_projectile[i].safeMove(((m_facingForward) ? (n.XOffset * m_sizeRatio) : (-(n.XOffset) * m_sizeRatio)), 0);
                            }
                            else
                            {
                                this.m_projectile[i].safeMove(0, (yOverride * m_sizeRatio));
                                this.m_projectile[i].safeMove(((m_facingForward) ? xOverride : -(xOverride)), 0);
                                this.m_projectile[i].safeMove(0, (n.YOffset * m_sizeRatio));
                                this.m_projectile[i].safeMove(((m_facingForward) ? (n.XOffset * m_sizeRatio) : (-(n.XOffset) * m_sizeRatio)), 0);
                            };
                        }
                        else
                        {
                            this.m_projectile[i].safeMove(0, (n.YOffset * m_sizeRatio));
                            this.m_projectile[i].safeMove(((m_facingForward) ? (n.XOffset * m_sizeRatio) : (-(n.XOffset) * m_sizeRatio)), 0);
                        };
                        break;
                    };
                    i++;
                };
            };
            return (success);
        }

        public function rocketCharacter(speed:Number, angle:Number, decay:Number, rotate:Boolean):void
        {
            if (this.m_characterStats.StatsName == "samus")
            {
                if (((((((inState(CState.LEDGE_CLIMB)) || (inState(CState.LEDGE_HANG))) || (inState(CState.LEDGE_ROLL))) || (inState(CState.GRABBING))) || (inState(CState.INJURED))) || (inState(CState.FLYING))))
                {
                    return;
                };
                if (((!(inState(CState.ATTACKING))) || (m_attack.Frame.indexOf("b_down") >= 0)))
                {
                    if (((angle > 180) && (angle < 360)))
                    {
                        angle = Utils.forceBase360((90 + (270 - angle)));
                    };
                    if (inState(CState.SHIELDING))
                    {
                        this.m_deactivateShield();
                        this.setState(CState.IDLE);
                    }
                    else
                    {
                        if (((inState(CState.DODGE_ROLL)) || (inState(CState.SIDESTEP_DODGE))))
                        {
                            this.setState(CState.IDLE);
                        };
                    };
                    if ((!(this.forceAttack("b_down_air"))))
                    {
                        return;
                    };
                }
                else
                {
                    return;
                };
            }
            else
            {
                if (this.m_characterStats.StatsName == "ness")
                {
                    this.endAttack();
                    this.setState(CState.IDLE);
                    if ((!(this.forceAttack("b_up_air"))))
                    {
                        return;
                    };
                };
            };
            if (inState(CState.SHIELDING))
            {
                this.m_deactivateShield();
            };
            angle = Utils.forceBase360(angle);
            this.m_rocketSpeed = speed;
            this.m_rocketAngle = angle;
            this.m_rocketRotation = rotate;
            this.m_rocketDecay = decay;
            if (((m_collision.ground) && ((this.m_rocketAngle >= 260) && (this.m_rocketAngle <= 280))))
            {
                this.endAttack();
                this.resetRotation();
                this.toBounce();
            }
            else
            {
                if (((m_collision.ground) && ((this.m_rocketAngle > 180) && (this.m_rocketAngle < 360))))
                {
                    this.m_rocketAngle = ((this.m_rocketAngle < 270) ? 180 : 0);
                    this.resetRotation();
                };
                m_attack.Rocket = true;
                if (rotate)
                {
                    if ((((this.m_rocketAngle <= 90) && (this.m_rocketAngle >= 0)) || ((this.m_rocketAngle >= 270) && (this.m_rocketAngle < 360))))
                    {
                        m_faceRight();
                    }
                    else
                    {
                        m_faceLeft();
                    };
                };
                if (((this.m_rocketAngle < 180) && (this.m_rocketAngle > 0)))
                {
                    this.unnattachFromGround();
                };
                if (Utils.hasLabel(Stance, "rocket"))
                {
                    this.stancePlayFrame("rocket");
                };
                m_xSpeed = Utils.calculateXSpeed(this.m_rocketSpeed, this.m_rocketAngle);
                m_ySpeed = -(Utils.calculateYSpeed(this.m_rocketSpeed, this.m_rocketAngle));
            };
        }

        private function fixRocketRotation():void
        {
            var angle:Number;
            if (this.m_rocketRotation)
            {
                angle = this.m_rocketAngle;
                angle = Utils.forceBase360(((m_facingForward) ? -(this.m_rocketAngle) : (-(this.m_rocketAngle) + 180)));
                m_sprite.rotation = angle;
            };
        }

        private function checkRocket():void
        {
            var oldXSpeed:Number;
            var oldYSpeed:Number;
            if (((inState(CState.ATTACKING)) && (m_attack.Rocket)))
            {
                this.fixRocketRotation();
                this.m_attemptToMove(m_xSpeed, 0);
                this.m_attemptToMove(0, m_ySpeed);
                if (this.m_rocketDecay >= 0)
                {
                    decel(Utils.fastAbs(Utils.calculateXSpeed(this.m_rocketDecay, this.m_rocketAngle)));
                    decel_air(Utils.fastAbs(Utils.calculateYSpeed(this.m_rocketDecay, this.m_rocketAngle)));
                }
                else
                {
                    decel(-(Utils.fastAbs(Utils.calculateXSpeed(this.m_rocketDecay, this.m_rocketAngle))));
                    decel_air(-(Utils.fastAbs(Utils.calculateYSpeed(this.m_rocketDecay, this.m_rocketAngle))));
                };
                if (this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1)))
                {
                    if (((this.m_rocketAngle > 200) && (this.m_rocketAngle < 340)))
                    {
                        m_attack.Rocket = false;
                        oldXSpeed = m_xSpeed;
                        oldYSpeed = m_ySpeed;
                        this.toBounce();
                        m_xSpeed = (oldXSpeed / 2);
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ROCKET_COMPLETE, {"caller":this.APIInstance.instance}));
                    }
                    else
                    {
                        if (((this.m_rocketAngle >= 160) && ((this.m_rocketAngle >= 340) || (this.m_rocketAngle <= 20))))
                        {
                            this.resetRotation();
                        };
                    };
                };
            };
        }

        private function resetItemDamageCounter():void
        {
            this.m_itemDamageCounter = 36;
        }

        private function m_checkItem():void
        {
            var item:Item;
            var i:int;
            if (((this.m_transformedSpecial) && (!(this.m_item2 == null))))
            {
                this.m_item2.destroy();
                this.m_item2 = null;
            };
            var foundAny:Boolean;
            if (((!(this.m_item2 == null)) && (this.m_item2.Dead)))
            {
                this.m_item2.destroy();
                this.m_item2 = null;
            };
            this.m_itemJustPickedUp = false;
            item = null;
            if ((!(((m_bypassCollisionTesting) || (!(m_hitBoxManager.HasHitBoxes))) || (this.m_standby))))
            {
                i = 0;
                while (i < STAGEDATA.ItemsRef.MAXITEMS)
                {
                    item = STAGEDATA.ItemsRef.getItemData(i);
                    if (((!(item == null)) && (!((item.PickedUp) && (item.PlayerID == m_player_id)))))
                    {
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.PICKUP, HitBoxSprite.CATCH, this.reactionCatch, null, true);
                    };
                    i++;
                };
            };
        }

        public function checkItemDeath():void
        {
            if (((!(this.m_item == null)) && (this.m_item.Dead)))
            {
                this.m_item = null;
                this.updateItemHolding();
            };
        }

        public function tossItem(angle:Number):void
        {
            var weak:Boolean;
            var speed:Number;
            var damageOverride:Number;
            var tossPosition:Point;
            var wasSkewed:Boolean;
            var xspeed:Number;
            var yspeed:Number;
            var hitboxes:Array;
            var itemBox:HitBoxSprite;
            if (((!(this.m_item)) || (!(this.m_item.ItemStats.CanToss))))
            {
                return;
            };
            weak = false;
            speed = (this.m_item.TossSpeed * this.m_characterStats.TiltTossMultiplier);
            damageOverride = -1;
            tossPosition = new Point(0, 0);
            wasSkewed = (m_sprite.stance.transform.matrix.a < 0);
            if (HasItemBox)
            {
                hitboxes = this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM);
                if (hitboxes.length > 0)
                {
                    itemBox = hitboxes[0];
                    tossPosition.x = (itemBox.xreg * m_sprite.scaleX);
                    tossPosition.y = (itemBox.yreg * m_sprite.scaleY);
                };
            };
            if ((!(m_facingForward)))
            {
                angle = Utils.forceBase360((180 - angle));
            };
            if (inState(CState.HOVER))
            {
                this.m_attackHovering = true;
            };
            if (this.m_lastFrameInterrupt)
            {
                if (getStanceVar("backToss", true))
                {
                    angle = ((m_facingForward) ? 105 : 75);
                    weak = true;
                    speed = (this.m_item.TossSpeed * this.m_characterStats.TiltTossMultiplier);
                    if ((!(m_collision.ground)))
                    {
                        speed = 0;
                    };
                }
                else
                {
                    if ((((this.m_lastFrameInterruptState === CState.DASH_INIT) || (this.m_lastFrameInterruptState === CState.DASH)) || ((this.m_lastFrameInterruptSmashTimer < 4) && (["a_air", "a"].indexOf(this.m_lastFrameInterrupt) < 0))))
                    {
                        speed = (this.m_item.TossSpeed * this.m_characterStats.SmashTossMultiplier);
                        damageOverride = (((this.m_item.getAttackBoxStat(1, "damage")) || (-3)) + 2);
                    };
                };
            };
            if (m_sprite.stance.currentLabel === "toss_back")
            {
                if (m_facingForward)
                {
                    this.m_item.faceLeft();
                }
                else
                {
                    this.m_item.faceRight();
                };
            }
            else
            {
                if (m_facingForward)
                {
                    this.m_item.faceRight();
                }
                else
                {
                    this.m_item.faceLeft();
                };
            };
            xspeed = Utils.calculateXSpeed(speed, angle);
            yspeed = -(Utils.calculateYSpeed(speed, angle));
            if ((((angle <= 45) || (angle >= 315)) && (m_xSpeed > 0)))
            {
                angle = Utils.getAngleBetween(new Point(), new Point((xspeed + m_xSpeed), yspeed));
                speed = Utils.calculateSpeed((xspeed + m_xSpeed), yspeed);
            }
            else
            {
                if ((((angle >= 135) && (angle <= 225)) && (m_xSpeed < 0)))
                {
                    angle = Utils.getAngleBetween(new Point(), new Point((xspeed + m_xSpeed), yspeed));
                    speed = Utils.calculateSpeed((xspeed + m_xSpeed), yspeed);
                }
                else
                {
                    if ((((angle > 45) && (angle < 135)) && (m_ySpeed < 0)))
                    {
                        angle = Utils.getAngleBetween(new Point(), new Point(xspeed, (yspeed + m_ySpeed)));
                        speed = Utils.calculateSpeed(xspeed, (yspeed + m_ySpeed));
                    }
                    else
                    {
                        if ((((angle > 225) && (angle < 315)) && (m_ySpeed > 0)))
                        {
                            angle = Utils.getAngleBetween(new Point(), new Point(xspeed, (yspeed + m_ySpeed)));
                            speed = Utils.calculateSpeed(xspeed, (yspeed + m_ySpeed));
                        };
                    };
                };
            };
            this.m_item.Toss((m_sprite.x + tossPosition.x), (m_sprite.y + tossPosition.y), speed, angle, weak);
            if (damageOverride > 0)
            {
                this.m_item.updateAttackBoxStats(1, {"damage":damageOverride});
            };
            this.resetSpeedLevel();
            if (wasSkewed)
            {
                this.m_item.MC.scaleX = (this.m_item.MC.scaleX * -1);
                this.m_item.MC.scaleY = (this.m_item.MC.scaleY * -1);
            };
            this.m_item = null;
            this.playGlobalSound(((weak) ? "itemdrop" : "item_throw"));
        }

        public function tossItemOld(speed:Number, angle:Number, weak:Boolean=false):void
        {
            var tossPosition:Point;
            var wasSkewed:Boolean;
            var hitboxes:Array;
            var itemBox:HitBoxSprite;
            if (((!(this.m_item)) || (!(this.m_item.ItemStats.CanToss))))
            {
                return;
            };
            tossPosition = new Point(0, 0);
            wasSkewed = (m_sprite.stance.transform.matrix.a < 0);
            if (HasItemBox)
            {
                hitboxes = this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM);
                if (hitboxes.length > 0)
                {
                    itemBox = hitboxes[0];
                    tossPosition.x = (itemBox.xreg * m_sprite.scaleX);
                    tossPosition.y = (itemBox.yreg * m_sprite.scaleY);
                };
            };
            if ((!(weak)))
            {
                if (((angle < 90) || (angle > 270)))
                {
                    m_faceRight();
                }
                else
                {
                    if (((angle > 90) && (angle < 270)))
                    {
                        m_faceLeft();
                    };
                };
            };
            if ((!(m_facingForward)))
            {
                angle = Utils.forceBase360((180 - angle));
            };
            if (inState(CState.HOVER))
            {
                this.m_attackHovering = true;
            };
            this.m_item.Toss((m_sprite.x + tossPosition.x), (m_sprite.y + tossPosition.y), (((weak) && (!(m_collision.ground))) ? 0 : speed), angle, weak);
            this.resetSpeedLevel();
            if (wasSkewed)
            {
                this.m_item.MC.scaleX = (this.m_item.MC.scaleX * -1);
                this.m_item.MC.scaleY = (this.m_item.MC.scaleY * -1);
            };
            this.m_item = null;
            this.playGlobalSound(((weak) ? "itemdrop" : "item_throw"));
        }

        private function m_useFinalSmash():void
        {
            var tmpPoint:Point;
            var tmpPoint2:Point;
            if (((this.m_characterStats.SpecialType == 0) && (!(this.m_transformedSpecial))))
            {
                if (this.m_item2 != null)
                {
                    this.m_item2.destroy();
                    this.m_item2 = null;
                };
                if (m_healthBoxMC)
                {
                    m_healthBoxMC.fsmeter.bar.gotoAndPlay("empty");
                    m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                };
                this.m_transformingSpecial = true;
                this.playFrame("special");
                toggleEffect(this.m_fsGlowHolderMC, false);
                this.SpecialAttack();
            }
            else
            {
                if (((this.m_characterStats.SpecialType == 0) && (this.m_transformedSpecial)))
                {
                    if (this.m_item2 != null)
                    {
                        this.m_item2.destroy();
                        this.m_item2 = null;
                    };
                    if (m_healthBoxMC)
                    {
                        m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                        m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                    };
                }
                else
                {
                    if ((((this.m_characterStats.SpecialType == 1) || (this.m_characterStats.SpecialType == 2)) || (this.m_characterStats.SpecialType == 3)))
                    {
                        if (this.m_item2 != null)
                        {
                            this.m_item2.destroy();
                            this.m_item2 = null;
                        };
                        if (m_healthBoxMC)
                        {
                            m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                            m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                        };
                        toggleEffect(this.m_fsGlowHolderMC, false);
                        this.SpecialAttack();
                    }
                    else
                    {
                        if (this.m_characterStats.SpecialType == 4)
                        {
                            if (this.m_item2 != null)
                            {
                                this.m_item2.destroy();
                                this.m_item2 = null;
                            };
                            if (m_healthBoxMC)
                            {
                                m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                                m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                            };
                            this.m_attachedReticule = null;
                            this.playFrame("special");
                            toggleEffect(this.m_fsGlowHolderMC, false);
                            this.m_transformLimit = this.m_characterStats.FSTimer;
                            this.SpecialAttack();
                            this.m_attachedFPS = STAGEDATA.attachUniqueMovieHUD((this.m_characterStats.LinkageID + "_hud"));
                            this.m_attachedFPS.stop();
                            Utils.recursiveMovieClipPlay(this.m_attachedFPS, false);
                            this.m_attachedFPS.uid = m_uid;
                            tmpPoint = new Point((Main.Width / 2), Main.Height);
                            this.m_attachedFPS.x = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint).x;
                            this.m_attachedFPS.y = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint).y;
                            this.unnattachFromGround();
                        }
                        else
                        {
                            if (this.m_characterStats.SpecialType == 5)
                            {
                                if (this.m_item2 != null)
                                {
                                    this.m_item2.destroy();
                                    this.m_item2 = null;
                                };
                                if (m_healthBoxMC)
                                {
                                    m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                                    m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                                };
                                this.playFrame("special");
                                toggleEffect(this.m_fsGlowHolderMC, false);
                                this.m_transformLimit = this.m_characterStats.FSTimer;
                                this.SpecialAttack();
                                this.m_attachedFPS = STAGEDATA.attachUniqueMovieHUD((this.m_characterStats.LinkageID + "_hud"));
                                this.m_attachedFPS.stop();
                                Utils.recursiveMovieClipPlay(this.m_attachedFPS, false);
                                this.m_attachedFPS.uid = m_uid;
                                tmpPoint2 = new Point((Main.Width / 2), Main.Height);
                                this.m_attachedFPS.x = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint2).x;
                                this.m_attachedFPS.y = STAGEDATA.HudForegroundRef.globalToLocal(tmpPoint2).y;
                                this.unnattachFromGround();
                            }
                            else
                            {
                                if (this.m_characterStats.SpecialType == 6)
                                {
                                    if (this.m_item2 != null)
                                    {
                                        this.m_item2.destroy();
                                        this.m_item2 = null;
                                    };
                                    if (m_healthBoxMC)
                                    {
                                        m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                                        m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                                    };
                                    this.playFrame("special");
                                    toggleEffect(this.m_fsGlowHolderMC, false);
                                    this.m_transformLimit = this.m_characterStats.FSTimer;
                                    this.SpecialAttack();
                                };
                            };
                        };
                    };
                };
            };
        }

        private function updateItemHolding():void
        {
            var rect:Rectangle;
            var rotationAmount:Number;
            rect = new Rectangle(0, 0, 1, 1);
            rotationAmount = 0;
            if (this.HoldingItem)
            {
                if (HasItemBox)
                {
                    this.m_item.setVisibility(m_sprite.visible);
                    this.m_item.MC.x = (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).xreg * m_sprite.scaleX);
                    this.m_item.MC.y = (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).yreg * m_sprite.scaleY);
                    this.m_item.MC.scaleX = 1;
                    this.m_item.MC.scaleY = 1;
                    if (m_facingForward)
                    {
                        this.m_item.faceRight();
                    }
                    else
                    {
                        this.m_item.faceLeft();
                    };
                    rotationAmount = ((m_facingForward) ? HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).rotation : -(HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).rotation));
                    this.m_item.MC.scaleX = (this.m_item.MC.scaleX * HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).scaleX);
                    this.m_item.MC.scaleY = (this.m_item.MC.scaleY * HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).scaleY);
                    this.m_item.MC.rotation = ((rotationAmount + m_sprite.stance.rotation) + m_sprite.rotation);
                    if (HasStance)
                    {
                        if (m_sprite.stance.transform.matrix.a < 0)
                        {
                            this.m_item.MC.scaleX = (this.m_item.MC.scaleX * -1);
                            this.m_item.MC.scaleY = (this.m_item.MC.scaleY * -1);
                        };
                    };
                    rect.x = this.m_item.MC.x;
                    rect.y = this.m_item.MC.y;
                    rect = Utils.rotateRectangleAroundOrigin(rect, (360 - m_sprite.rotation));
                    this.m_item.MC.x = (m_sprite.x + rect.x);
                    this.m_item.MC.y = (m_sprite.y + rect.y);
                    if (((HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).depth == 0) && (Depth < this.m_item.Depth)))
                    {
                        Utils.swapDepths(m_sprite, this.m_item.MC);
                    }
                    else
                    {
                        if (((!(HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).depth == 0)) && (Depth > this.m_item.Depth)))
                        {
                            Utils.swapDepths(m_sprite, this.m_item.MC);
                        };
                    };
                    this.m_item.MC.alpha = m_sprite.alpha;
                }
                else
                {
                    this.m_item.X = m_sprite.x;
                    this.m_item.Y = (m_sprite.y - (m_height / 2));
                };
            };
            if (((!(this.m_currentPower == null)) && (HasHatBox)))
            {
                if (this.m_hatHolder == null)
                {
                    this.m_hatHolder = ResourceManager.getLibraryMC(("hat_" + this.m_currentPower));
                    if (this.m_hatHolder)
                    {
                        while (this.m_hatMC.numChildren > 0)
                        {
                            this.m_hatMC.removeChildAt(0);
                        };
                        this.m_hatMC.addChild(this.m_hatHolder);
                        STAGE.addChild(this.m_hatMC);
                    };
                };
                if ((!(this.m_hatHolder)))
                {
                    return;
                };
                this.m_hatMC.x = (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).xreg * m_sprite.scaleX);
                this.m_hatMC.y = (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).yreg * m_sprite.scaleY);
                this.m_hatMC.scaleX = m_sprite.scaleX;
                this.m_hatMC.scaleY = m_sprite.scaleY;
                this.m_hatMC.rotation = m_sprite.rotation;
                rotationAmount = ((m_facingForward) ? HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).rotation : -(HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).rotation));
                this.m_hatMC.scaleX = (this.m_hatMC.scaleX * HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).scaleX);
                this.m_hatMC.scaleY = (this.m_hatMC.scaleY * HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).scaleY);
                this.m_hatMC.rotation = ((rotationAmount + m_sprite.stance.rotation) + m_sprite.stance.rotation);
                if (HasStance)
                {
                    this.m_hatMC.scaleX = (this.m_hatMC.scaleX * m_sprite.stance.scaleX);
                    this.m_hatMC.scaleY = (this.m_hatMC.scaleY * m_sprite.stance.scaleY);
                    if (m_sprite.stance.transform.matrix.a < 0)
                    {
                        this.m_hatMC.scaleX = (this.m_hatMC.scaleX * -1);
                        this.m_hatMC.scaleY = (this.m_hatMC.scaleY * -1);
                    };
                };
                if (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).transform.a < 0)
                {
                    this.m_hatMC.scaleY = (this.m_hatMC.scaleY * -1);
                };
                rect.x = this.m_hatMC.x;
                rect.y = this.m_hatMC.y;
                rect = Utils.rotateRectangleAroundOrigin(rect, (360 - m_sprite.rotation));
                this.m_hatMC.x = (m_sprite.x + rect.x);
                this.m_hatMC.y = (m_sprite.y + rect.y);
                if ((!(this.m_hatMC.parent)))
                {
                    STAGE.addChild(this.m_hatMC);
                };
                if (((HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).depth == 0) && (Depth < this.m_hatMC.parent.getChildIndex(this.m_hatMC))))
                {
                    Utils.swapDepths(m_sprite, this.m_hatMC);
                }
                else
                {
                    if (((!(HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.HAT)[0]).depth == 0)) && (Depth > this.m_hatMC.parent.getChildIndex(this.m_hatMC))))
                    {
                        Utils.swapDepths(m_sprite, this.m_hatMC);
                    };
                };
            }
            else
            {
                if (((this.m_currentPower == null) || (!(HasHatBox))))
                {
                    if (this.m_hatHolder)
                    {
                        while (this.m_hatMC.numChildren > 0)
                        {
                            this.m_hatMC.removeChildAt(0);
                        };
                        this.m_hatHolder = null;
                    };
                };
            };
        }

        public function killItem(itemID:Number):void
        {
            if (this.m_item != null)
            {
                STAGEDATA.ItemsRef.killItem(this.m_item.Slot);
                this.m_item = null;
            };
        }

        public function dropItem(zDropped:Boolean=false):void
        {
            var wasSkewed:Boolean;
            if (this.m_item != null)
            {
                wasSkewed = (m_sprite.stance.transform.matrix.a < 0);
                this.m_item.Drop(zDropped);
                if (wasSkewed)
                {
                    this.m_item.MC.scaleX = (this.m_item.MC.scaleX * -1);
                    this.m_item.MC.scaleY = (this.m_item.MC.scaleY * -1);
                };
                this.m_item = null;
            };
        }

        override public function updatePaletteSwap():void
        {
            super.updatePaletteSwap();
            if (((m_paletteSwapData) && (HasStance)))
            {
                Utils.replacePalette(this.m_starKOMC, m_paletteSwapData, 2);
                Utils.replacePalette(this.m_screenKOHolder, m_paletteSwapData);
                Utils.replacePalette(m_reflectionEffect, m_paletteSwapData);
            };
            this.updateLivesDisplay();
        }

        override public function setPaletteSwap(normalData:Object, PADAta:Object):void
        {
            this.m_lastLivesTextNum = -1;
            super.setPaletteSwap(normalData, PADAta);
        }

        override public function updateColorFilterAPI(settings:Object):void
        {
            if (settings == null)
            {
                settings = Utils.getCostumeObject();
            };
            super.updateColorFilterAPI(settings);
            if (((!(settings == null)) && (this.m_starKOMC)))
            {
                Utils.setColorFilter(this.m_starKOMC, settings);
                this.redrawHealthBox();
            };
        }

        public function replaceCharacter(statData:String, frame:String=null, jumpFrame:String=null):void
        {
            var stats:CharacterData;
            var origFrame:String;
            var tempX:Number;
            var tempY:Number;
            var self:Vector.<MovieClip>;
            var hasTargets:Boolean;
            var wasVisible:Boolean;
            var oldFilters:Array;
            var tmpMC:MovieClip;
            this.setIntangibility(false);
            if (this.m_sizeStatus != 0)
            {
                this.setSizeStatus(0);
            };
            stats = Stats.getStats(statData, this.m_expansion_id);
            origFrame = m_sprite.xframe;
            if (this.m_grabbed.length > 0)
            {
                this.grabReleaseOpponent();
                this.grabRelease();
            };
            tempX = m_sprite.x;
            tempY = m_sprite.y;
            self = new Vector.<MovieClip>();
            self.push(m_sprite);
            hasTargets = CAM.hasTargets(self);
            if (hasTargets)
            {
                CAM.deleteTargets(self);
            };
            wasVisible = m_sprite.visible;
            oldFilters = m_sprite.filters;
            m_sprite.filters = null;
            m_sprite.parent.removeChild(m_sprite);
            tmpMC = ResourceManager.getLibraryMC(stats.LinkageID);
            tmpMC.name = ("p" + m_player_id);
            tmpMC.player_id = m_player_id;
            tmpMC.character_id = m_uid;
            tmpMC.ACTIVE = true;
            m_sprite = MovieClip(STAGE.addChild(tmpMC));
            m_sprite.filters = oldFilters;
            Utils.hasLabel(m_sprite, "edgelean", true);
            if (hasTargets)
            {
                self = new Vector.<MovieClip>();
                self.push(m_sprite);
                CAM.addTargets(self);
            };
            m_sprite.x = tempX;
            m_sprite.y = tempY;
            if (inState(CState.CAUGHT))
            {
                this.setVisibility(wasVisible);
            };
            this.resetChargedAttacks();
            m_attack.Rocket = false;
            m_attackData.resetCharges();
            toggleEffect(this.m_chargeGlowHolderMC, false);
            this.m_chargeGlowHolderMC = null;
            if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
            {
                STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
            };
            this.setStats(stats);
            if ((!(m_facingForward)))
            {
                m_faceLeft();
            }
            else
            {
                m_faceRight();
            };
            if (((!(origFrame == null)) && (frame == null)))
            {
                this.playFrame(origFrame);
                m_attack.Frame = origFrame;
                if (jumpFrame != null)
                {
                    this.stancePlayFrame(jumpFrame);
                };
            }
            else
            {
                if (frame != null)
                {
                    this.playFrame(frame);
                    m_attack.Frame = frame;
                    if (jumpFrame != null)
                    {
                        this.stancePlayFrame(jumpFrame);
                    };
                };
            };
            if (HasStance)
            {
            };
            this.m_deactivateShield();
            if ((!(inState(CState.ATTACKING))))
            {
                this.setState(((m_collision.ground) ? CState.IDLE : CState.JUMP_FALLING));
            };
            this.applySpecialModeEffects();
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_TRANSFORM, {"caller":this.APIInstance.instance}));
        }

        public function activateFinalForm():void
        {
            var wasMetal:Boolean;
            var stats:CharacterData;
            var tempX:Number;
            var tempY:Number;
            var self:Vector.<MovieClip>;
            var hasTargets:Boolean;
            var wasVisible:Boolean;
            var tmpMC:MovieClip;
            if (this.m_transformingSpecial)
            {
                this.setIntangibility(false);
                if (this.m_sizeStatus != 0)
                {
                    this.setSizeStatus(0);
                };
                wasMetal = this.m_isMetal;
                this.setMetalStatus(false);
                stats = Stats.getStats(this.m_characterStats.SpecialStatsID, this.m_expansion_id);
                this.releaseOpponent();
                STAGEDATA.brightenCamera();
                if (this.m_item2 != null)
                {
                    this.m_item2.destroy();
                    this.m_item2 = null;
                };
                this.m_transformingSpecial = false;
                this.m_transformedSpecial = true;
                this.m_transformTime = 0;
                this.m_transformLimit = this.m_characterStats.FSTimer;
                this.m_finalSmashMeterReady = false;
                if (m_healthBoxMC)
                {
                    m_healthBoxMC.fsmeter.visible = true;
                };
                tempX = m_sprite.x;
                tempY = m_sprite.y;
                self = new Vector.<MovieClip>();
                self.push(m_sprite);
                hasTargets = CAM.hasTargets(self);
                if (hasTargets)
                {
                    CAM.deleteTargets(self);
                };
                wasVisible = m_sprite.visible;
                m_sprite.parent.removeChild(m_sprite);
                tmpMC = ResourceManager.getLibraryMC(stats.LinkageID);
                tmpMC.name = ("p" + m_player_id);
                tmpMC.player_id = m_player_id;
                tmpMC.character_id = m_uid;
                tmpMC.ACTIVE = true;
                m_sprite = MovieClip(STAGE.addChild(tmpMC));
                Utils.hasLabel(m_sprite, "edgelean", true);
                if (hasTargets)
                {
                    self = new Vector.<MovieClip>();
                    self.push(m_sprite);
                    CAM.addTargets(self);
                };
                m_sprite.x = tempX;
                m_sprite.y = tempY;
                this.setSizeStatus(0);
                if (inState(CState.CAUGHT))
                {
                    this.setVisibility(wasVisible);
                };
                this.playFrame("special");
                this.resetChargedAttacks();
                m_attackData.resetCharges();
                toggleEffect(this.m_chargeGlowHolderMC, false);
                this.m_chargeGlowHolderMC = null;
                toggleEffect(this.m_fsGlowHolderMC, false);
                this.setStats(stats);
                if ((!(m_facingForward)))
                {
                    m_faceLeft();
                }
                else
                {
                    m_faceRight();
                };
                if (((wasMetal) && (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.METAL))))
                {
                    this.setMetalStatus(true);
                };
            };
        }

        private function redrawHealthBox():void
        {
            if (m_healthBoxMC)
            {
                this.attachHealthBox(((this.m_playerSettings.name) ? this.m_playerSettings.name.toUpperCase() : this.m_characterStats.DisplayName.toUpperCase()), this.m_characterStats.Thumbnail, this.m_characterStats.SeriesIcon, m_team_id, this.CostumeName, this.CostumeID);
            };
        }

        override protected function syncStats():void
        {
            m_attack.AttackRatio = this.m_characterStats.AttackRatio;
            m_gravity = this.m_characterStats.Gravity;
            m_max_ySpeed = this.m_characterStats.MaxYSpeed;
            this.m_max_xSpeed = this.m_characterStats.MaxXSpeed;
            this.m_norm_xSpeed = this.m_characterStats.NormalXSpeed;
            if (m_healthBoxMC)
            {
                if (((!(this.m_characterStats.FinalSmashMeter)) && (!(this.m_transformedSpecial))))
                {
                    m_healthBoxMC.fsmeter.visible = false;
                }
                else
                {
                    m_healthBoxMC.fsmeter.visible = true;
                };
            };
        }

        private function setStats(stats:CharacterData):void
        {
            var oldStamina:Number;
            var oldFinalSmashMeter:Boolean;
            var jumpListStr:String;
            var tmpList:Array;
            var sindex:int;
            var metalCostume:Object;
            oldStamina = this.m_characterStats.Stamina;
            oldFinalSmashMeter = this.m_characterStats.FinalSmashMeter;
            if (stats !== this.m_characterStats)
            {
                this.m_characterStats.importData(stats.exportData());
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.m_characterStats.importData({
                    "accel_start":0.5,
                    "accel_start_dash":-1,
                    "accel_rate":0.8,
                    "accel_rate_air":0.5,
                    "decel_rate":-0.5,
                    "decel_rate_air":-0.5
                });
            };
            this.m_characterStats.importData({
                "attackRatio":this.m_playerSettings.attackRatio,
                "damageRatio":this.m_playerSettings.damageRatio,
                "unlimitedFinal":this.m_playerSettings.unlimitedFinal,
                "startDamage":this.m_playerSettings.startDamage,
                "stamina":oldStamina,
                "finalSmashMeter":oldFinalSmashMeter
            });
            this.resetStaleMoves();
            this.m_jumpStartup.MaxTime = stats.JumpStartup;
            this.m_jumpStartup.reset();
            jumpListStr = stats.JumpSpeedList;
            while (((jumpListStr) && (jumpListStr.indexOf(" ") >= 0)))
            {
                jumpListStr = jumpListStr.replace(" ", "");
            };
            tmpList = ((stats.JumpSpeedList) ? jumpListStr.split(",") : null);
            this.m_jumpSpeedList = null;
            this.m_jumpSpeedList = new Array();
            sindex = 0;
            while (((!(tmpList == null)) && (sindex < tmpList.length)))
            {
                tmpList[sindex] = ((isNaN(parseFloat(tmpList[sindex]))) ? 0 : parseFloat(tmpList[sindex]));
                sindex++;
            };
            this.m_jumpSpeedList = tmpList;
            m_gravity = stats.Gravity;
            this.m_norm_xSpeed = stats.NormalXSpeed;
            this.m_max_xSpeed = stats.MaxXSpeed;
            m_max_ySpeed = stats.MaxYSpeed;
            m_attackData = stats.Attacks;
            m_attackData.Owner = this;
            buildHitBoxData(stats.LinkageID);
            if (Main.DEBUG)
            {
                verifiyHitBoxData();
            };
            this.generatePummelData();
            if (((m_attackData.getAttack("grab")) && (m_attackData.getAttack("grab").AttackBoxes.length > 0)))
            {
                m_attackData.getAttack("grab").AttackBoxes[0].importAttackData({
                    "team_id":m_team_id,
                    "refreshRate":3,
                    "damage":stats.GrabDamage,
                    "hasEffect":false,
                    "bypassNonGrabbed":true,
                    "effectSound":stats.Sounds["pummel"],
                    "staleMultiplier":this.totalMoveDecay("grab")
                });
            };
            this.m_wallStickTime.MaxTime = stats.WallStick;
            this.m_forceTransformTime = new FrameTimer(stats.ForceTransformTime);
            if (Stats.getStats(stats.ForceTransformID, this.m_expansion_id) == null)
            {
                this.m_forceTransformTime.MaxTime = 0;
            };
            this.m_midAirHoverTime.MaxTime = stats.MidAirHover;
            this.m_midAirJumpConstantTime.MaxTime = stats.MidAirJumpConstant;
            this.m_midAirJumpConstantDelay.MaxTime = stats.MidAirJumpConstantDelay;
            this.m_damageIncreaseInterval.MaxTime = stats.DamageIncreaseInterval;
            m_sprite.scaleX = ((m_sprite.scaleX > 0) ? m_sizeRatio : -(m_sizeRatio));
            m_sprite.scaleY = ((m_sprite.scaleY > 0) ? m_sizeRatio : -(m_sizeRatio));
            m_width = stats.Width;
            m_height = stats.Height;
            this.resetCameraBox();
            m_sprite.camOverride = null;
            if (((!(this.m_item == null)) && (!(stats.CanHoldItems))))
            {
                this.m_item.destroy();
            };
            m_attackData.resetDisabledAttacks();
            this.redrawHealthBox();
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.LIGHT))
            {
                m_gravity = (m_gravity / 2);
                m_max_ySpeed = (m_max_ySpeed / 2);
            }
            else
            {
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.HEAVY))
                {
                    m_gravity = (m_gravity * 2);
                    m_max_ySpeed = (m_max_ySpeed * 2);
                };
            };
            if ((!(this.m_human)))
            {
                this.CPU.refreshRecoveryAttackList();
                this.CPU.refreshDisabledAttackList();
            };
            if (this.m_isMetal)
            {
                metalCostume = ResourceManager.getMetalCostume(this.m_characterStats.StatsName);
                Utils.setColorFilter(m_sprite, metalCostume);
                if (metalCostume)
                {
                    this.setPaletteSwap(((metalCostume.paletteSwap) || (null)), ((metalCostume.paletteSwapPA) || (null)));
                };
            };
            this.syncStats();
        }

        private function checkItemInterrupt(frame:String, Atktype:Number, cStick:Boolean=false):Boolean
        {
            var stateWas:uint;
            var isAerial:Boolean;
            stateWas = m_state;
            if (((this.m_item) && (!(this.m_item.FrameInterrupt == null))))
            {
                isAerial = (["a_air", "a_air_up", "a_air_down", "a_air_forward", "a_air_backward"].indexOf(frame) >= 0);
                if (((!((isAerial) && (this.m_itemJustPickedUp))) && (this.m_item.FrameInterrupt({
                    "cStick":cStick,
                    "targetFrame":frame,
                    "zair":(((this.m_pressedControls.GRAB) && (!(this.m_characterStats.TetherGrab))) && (isAerial)),
                    "character":this.APIInstance.instance
                }))))
                {
                    this.m_lastFrameInterrupt = frame;
                    this.m_lastFrameInterruptState = stateWas;
                    this.m_lastFrameInterruptSmashTimer = this.m_smashTimer;
                    return (true);
                };
            };
            return (false);
        }

        public function Attack(frame:String, Atktype:Number, cStick:Boolean=false):void
        {
            var wasAttacking:Boolean;
            var atkObj:AttackObject;
            var tmpMC:MovieClip;
            if (((Atktype === 2) && (!(this.m_characterStats.CanUseSpecials))))
            {
                return;
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                if (Atktype === 2)
                {
                    return;
                };
                if (((frame === "a") || (frame === "a_air")))
                {
                    frame = ((frame === "a") ? "b" : "b_air");
                    Atktype = 2;
                    cStick = false;
                };
            };
            wasAttacking = false;
            atkObj = m_attackData.getAttack(frame);
            this.clearControlsBuffer();
            if (atkObj.IsDisabled)
            {
                return;
            };
            if ((((!(inState(CState.HOVER))) && (!((this.m_itemJustPickedUp) && ((frame === "a_forward") || (frame === "a_air"))))) && (this.checkItemInterrupt(frame, 1, cStick))))
            {
                return;
            };
            if (inState(CState.ATTACKING))
            {
                if (this.isInterruptableAttack())
                {
                    if ((((frame === this.m_lastAttackUsedTurbo) || ((frame + "_air") === this.m_lastAttackUsedTurbo)) || (frame === (this.m_lastAttackUsedTurbo + "_air"))))
                    {
                        return;
                    };
                    if (m_attack.Rocket)
                    {
                        m_attack.Rocket = false;
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ROCKET_COMPLETE, {"caller":this.APIInstance.instance}));
                        this.resetRotation();
                    };
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ATTACK_CANCELLED, {"caller":this.APIInstance.instance}));
                    m_actionShot = false;
                    this.grabReleaseOpponent();
                };
                flushTimers();
                removeAllTempEvents();
                wasAttacking = true;
            };
            this.m_cStickUse = cStick;
            var wasOnGround:Boolean = m_collision.ground;
            if (((!(atkObj.IsDisabled)) && (atkObj.Enabled)))
            {
                if (atkObj != null)
                {
                    atkObj.LastUsedPrevious = atkObj.LastUsed;
                    atkObj.LastUsed = 0;
                    if (((frame == "b") || (frame == "b_air")))
                    {
                        m_attackData.getAttack(((frame == "b") ? "b_air" : "b")).LastUsedPrevious = m_attackData.getAttack(((frame == "b") ? "b_air" : "b")).LastUsed;
                        m_attackData.getAttack(((frame == "b") ? "b_air" : "b")).LastUsed = 0;
                    }
                    else
                    {
                        if (((frame == "b_up") || (frame == "b_up_air")))
                        {
                            m_attackData.getAttack(((frame == "b_up") ? "b_up_air" : "b_up")).LastUsedPrevious = m_attackData.getAttack(((frame == "b_up") ? "b_up_air" : "b_up")).LastUsed;
                            m_attackData.getAttack(((frame == "b_up") ? "b_up_air" : "b_up")).LastUsed = 0;
                        }
                        else
                        {
                            if (((frame == "b_forward") || (frame == "b_forward_air")))
                            {
                                m_attackData.getAttack(((frame == "b_forward") ? "b_forward_air" : "b")).LastUsedPrevious = m_attackData.getAttack(((frame == "b_forward") ? "b_forward_air" : "b")).LastUsed;
                                m_attackData.getAttack(((frame == "b_forward") ? "b_forward_air" : "b")).LastUsed = 0;
                            }
                            else
                            {
                                if (((frame == "b_down") || (frame == "b_down_air")))
                                {
                                    m_attackData.getAttack(((frame == "b_down") ? "b_down_air" : "b_down")).LastUsedPrevious = m_attackData.getAttack(((frame == "b_down") ? "b_down_air" : "b_down")).LastUsed;
                                    m_attackData.getAttack(((frame == "b_down") ? "b_down_air" : "b_down")).LastUsed = 0;
                                };
                            };
                        };
                    };
                };
                if ((((!(this.jumpIsPressed())) && (!((this.jumpIsHeld()) || ((this.m_tap_jump) && (this.m_heldControls.UP))))) && ((m_ySpeed < 0) || ((this.m_midAirJumpConstantTime.MaxTime > 0) && (!(this.m_midAirJumpConstantTime.IsComplete))))))
                {
                    if ((((atkObj.JumpCancel) && (this.m_jumpCount == 0)) && (!(m_collision.ground))))
                    {
                        m_ySpeed = 0;
                        this.m_midAirJumpConstantTime.finish();
                    }
                    else
                    {
                        if ((((atkObj.DoubleJumpCancel) && (this.m_jumpCount > 0)) && (!(m_collision.ground))))
                        {
                            if (m_ySpeed < 0)
                            {
                                this.m_midAirJumpConstantDelay.finish();
                                this.m_midAirJumpConstantTime.finish();
                            }
                            else
                            {
                                m_ySpeed = 0;
                                this.m_midAirJumpConstantTime.finish();
                            };
                        };
                    };
                };
                m_attack.RefreshRateTimer = 1;
                m_attack.RefreshRateReady = false;
                m_attack.SizeStatus = this.m_sizeStatus;
                this.m_attackIDIncremented = true;
                m_attack.ForceFallThrough = atkObj.ForceFallThrough;
                m_attack.MaintainSpeed = atkObj.MaintainSpeed;
                m_attack.FacedLedgesOnly = atkObj.FacedLedgesOnly;
                m_attack.LedgeFrame = atkObj.LedgeFrame;
                m_attack.IgnorePlatformInfluence = atkObj.IgnorePlatformInfluence;
                m_attack.IASA = atkObj.IASA;
                m_attack.GrabBehind = atkObj.GrabBehind;
                atkObj.OverrideMap.clear();
                atkObj.ReenableTimerCount = atkObj.ReenableTimer;
                if (((m_collision.ground) && (!(m_attack.MaintainSpeed))))
                {
                    this.resetSpeedLevel();
                };
                if (((atkObj.ChargeClick) && (!(this.m_cStickUse))))
                {
                    this.playGlobalSound("chargeclick");
                };
                if (atkObj.Flip)
                {
                    if (m_facingForward)
                    {
                        m_faceLeft();
                    }
                    else
                    {
                        m_faceRight();
                    };
                };
                m_attack.IsTurning = false;
                m_attack.IsAccelerating = false;
                m_attack.HoldRepeat = atkObj.HoldRepeat;
                m_attack.AttackType = Atktype;
                if ((!(atkObj.ConserveJumpConstant)))
                {
                    if ((!(this.m_midAirJumpConstantTime.IsComplete)))
                    {
                        m_ySpeed = 0;
                    };
                    this.m_midAirJumpConstantTime.finish();
                };
                this.m_bufferedAttackJump = false;
                m_attack.AirEase = atkObj.AirEase;
                m_attack.XSpeedCap = atkObj.XSpeedCap;
                m_attack.IsForward = m_facingForward;
                m_attack.StaleMultiplier = this.totalMoveDecay(frame);
                m_attack.Invincible = atkObj.Invincible;
                m_attack.SuperArmor = atkObj.SuperArmor;
                m_attack.HeavyArmor = atkObj.HeavyArmor;
                m_attack.LaunchResistance = atkObj.LaunchResistance;
                m_attack.XSpeedAccel = atkObj.XSpeedAccel;
                m_attack.XSpeedAccelAir = atkObj.XSpeedAccelAir;
                m_attack.XSpeedDecay = atkObj.XSpeedDecay;
                m_attack.XSpeedDecayAir = atkObj.XSpeedDecayAir;
                m_attack.ComboTotal = 0;
                m_attack.ComboMax = atkObj.ComboMax;
                m_attack.ForceComboContinue = atkObj.ForceComboContinue;
                m_attack.ForceGrabbable = atkObj.ForceGrabbable;
                m_attack.NextComboFrame = null;
                m_attack.AttackID = Utils.getUID();
                m_attack.ID = Utils.getUID();
                this.checkLinkedProjectiles();
                m_attack.Frame = frame;
                m_attack.ExecTime = 0;
                m_attack.SecondaryAttack = atkObj.SecondaryAttack;
                m_attack.HasClanked = false;
                m_attack.RefreshRate = atkObj.RefreshRate;
                m_attack.HomingSpeed = atkObj.HomingSpeed;
                m_attack.HomingTarget = null;
                m_attack.ChargeTimeMax = atkObj.ChargeTimeMax;
                m_attack.LinkCharge = atkObj.LinkCharge;
                m_attack.AllowControl = atkObj.AllowControl;
                m_attack.AllowControlGround = atkObj.AllowControlGround;
                m_attack.AllowJump = atkObj.AllowJump;
                m_attack.AllowFastFall = atkObj.AllowFastFall;
                m_attack.AllowRun = atkObj.AllowRun;
                m_attack.AllowTurn = atkObj.AllowTurn;
                m_attack.AllowFullInterrupt = atkObj.AllowFullInterrupt;
                m_attack.AllowDoubleJump = atkObj.AllowDoubleJump;
                m_attack.LinkFrames = atkObj.LinkFrames;
                m_attack.Cancel = atkObj.Cancel;
                m_attack.CancelWhenAirborne = atkObj.CancelWhenAirborne;
                m_attack.HasLanded = m_collision.ground;
                m_attack.Rotate = atkObj.Rotate;
                m_attack.CancelSoundOnEnd = atkObj.CancelSoundOnEnd;
                m_attack.CancelVoiceOnEnd = atkObj.CancelVoiceOnEnd;
                m_attack.WasCancelled = false;
                m_attack.XLoc = MC.x;
                m_attack.YLoc = MC.y;
                m_attack.DisableJump = atkObj.DisableJump;
                m_attack.JumpCancelAttack = atkObj.JumpCancelAttack;
                m_attack.DoubleJumpCancelAttack = atkObj.DoubleJumpCancelAttack;
                m_attack.AttackDelay = atkObj.AttackDelay;
                m_attack.IsThrow = (frame.substring(0, 6) == "throw_");
                m_attack.ChargeInAir = atkObj.ChargeInAir;
                m_attack.MustCharge = atkObj.MustCharge;
                m_attack.CanFallOff = atkObj.CanFallOff;
                m_attack.CanGrabInverseLedges = atkObj.CanGrabInverseLedges;
                m_attack.CanBeAbsorbed = atkObj.CanBeAbsorbed;
                m_attack.AirCancel = atkObj.AirCancel;
                m_attack.AirCancelSpecial = atkObj.AirCancelSpecial;
                m_attack.IsAirAttack = (!(m_collision.ground));
                this.resetRotation();
                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                if (atkObj.ResetMovement)
                {
                    m_xSpeed = 0;
                    m_ySpeed = 0;
                };
                if ((!(atkObj.ChargeRetain)))
                {
                    atkObj.ChargeTime = 0;
                }
                else
                {
                    if (((atkObj.UseChargeBar) && (STAGEPARENT.getChildByName(("energy" + m_player_id)) == null)))
                    {
                        tmpMC = ResourceManager.getLibraryMC("energy");
                        tmpMC.name = ("energy" + m_player_id);
                        STAGEPARENT.addChild(tmpMC);
                        STAGEPARENT.getChildByName(("energy" + m_player_id)).x = (m_sprite.x + STAGE.x);
                        STAGEPARENT.getChildByName(("energy" + m_player_id)).y = (m_sprite.y + STAGE.y);
                        STAGEPARENT.getChildByName(("energy" + m_player_id)).width = (STAGEPARENT.getChildByName(("energy" + m_player_id)).width * m_sizeRatio);
                        STAGEPARENT.getChildByName(("energy" + m_player_id)).height = (STAGEPARENT.getChildByName(("energy" + m_player_id)).height * m_sizeRatio);
                    };
                };
                this.m_attackHovering = (((inState(CState.HOVER)) && (m_attack.IsAirAttack)) && (Atktype == 1));
                this.setState(CState.ATTACKING);
                if (wasAttacking)
                {
                    this.playFrame(frame);
                };
                if (atkObj.JumpFrame != null)
                {
                    this.stancePlayFrame(atkObj.JumpFrame);
                }
                else
                {
                    if ((((HasStance) && (!(Stance.currentFrame === 1))) && (m_previousAnimation === m_currentAnimationID)))
                    {
                        this.stancePlayFrame(1);
                    };
                };
                this.m_previousAttack = m_attack.Frame;
                if (((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.TURBO)) && (!(m_attack.Frame === "special"))))
                {
                    addEventListener(SSF2Event.ATTACK_HIT, this.allowTurboCancel);
                    addEventListener(SSF2Event.ATTACK_HIT_SHIELD, this.allowTurboCancel);
                    addEventListener(SSF2Event.ATTACK_HIT_POWER_SHIELD, this.allowTurboCancel);
                    addEventListener(SSF2Event.CHAR_GRAB, this.allowTurboCancel);
                };
            };
            if (wasAttacking)
            {
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ATTACK_CHANGED, {"caller":this.APIInstance.instance}));
            };
        }

        private function SpecialAttack():void
        {
            var atkObj:AttackObject;
            var tmpMC:MovieClip;
            var cutinHolder:MovieClip;
            var cutin:MovieClip;
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.m_forceTransformTime.MaxTime = 0;
            m_attack.SizeStatus = this.m_sizeStatus;
            var wasOnGround:Boolean = m_collision.ground;
            m_attack.Frame = "special";
            atkObj = m_attackData.getAttack(m_attack.Frame);
            m_attack.IsAirAttack = (!(m_collision.ground));
            MC.rotation = 0;
            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
            this.m_attackIDIncremented = true;
            if (atkObj.Flip)
            {
                if (m_facingForward)
                {
                    m_faceLeft();
                }
                else
                {
                    m_faceRight();
                };
            };
            if ((((!(this.jumpIsPressed())) && (!((this.jumpIsHeld()) || ((this.m_tap_jump) && (this.m_heldControls.UP))))) && ((m_ySpeed < 0) || ((this.m_midAirJumpConstantTime.MaxTime > 0) && (!(this.m_midAirJumpConstantTime.IsComplete))))))
            {
                if (((atkObj.JumpCancel) && (this.m_jumpCount == 0)))
                {
                    m_ySpeed = 0;
                    this.m_midAirJumpConstantTime.finish();
                }
                else
                {
                    if ((((atkObj.DoubleJumpCancel) && (this.m_jumpCount > 0)) && (!(m_collision.ground))))
                    {
                        m_ySpeed = 0;
                        this.m_midAirJumpConstantTime.finish();
                    };
                };
            };
            this.m_bufferedAttackJump = false;
            m_attack.FacedLedgesOnly = atkObj.FacedLedgesOnly;
            m_attack.LedgeFrame = atkObj.LedgeFrame;
            m_attack.IgnorePlatformInfluence = atkObj.IgnorePlatformInfluence;
            m_attack.IASA = atkObj.IASA;
            m_attack.GrabBehind = atkObj.GrabBehind;
            m_attack.ComboTotal = 0;
            m_attack.ChargeTime = atkObj.ChargeTime;
            m_attack.ChargeTimeMax = atkObj.ChargeTimeMax;
            m_attack.LinkCharge = atkObj.LinkCharge;
            m_attack.ComboMax = atkObj.ComboMax;
            m_attack.ForceComboContinue = atkObj.ForceComboContinue;
            m_attack.IsThrow = false;
            atkObj.OverrideMap.clear();
            atkObj.ReenableTimerCount = atkObj.ReenableTimer;
            m_attack.ForceFallThrough = atkObj.ForceFallThrough;
            m_attack.MaintainSpeed = atkObj.MaintainSpeed;
            m_attack.IsForward = m_facingForward;
            m_attack.Rocket = false;
            STAGEDATA.ItemsRef.SmashBallReady.reset();
            STAGEDATA.ItemsRef.SmashBallReady.MaxTime = this.m_characterStats.FSTimer;
            m_attack.RefreshRateTimer = 1;
            m_attack.RefreshRateReady = false;
            m_attack.IsTurning = false;
            m_attack.IsAccelerating = false;
            m_attack.Invincible = atkObj.Invincible;
            m_attack.SuperArmor = atkObj.SuperArmor;
            m_attack.HeavyArmor = atkObj.HeavyArmor;
            m_attack.LaunchResistance = atkObj.LaunchResistance;
            m_attack.XSpeedAccel = atkObj.XSpeedAccel;
            m_attack.XSpeedAccelAir = atkObj.XSpeedAccelAir;
            m_attack.XSpeedDecay = atkObj.XSpeedDecay;
            m_attack.XSpeedDecayAir = atkObj.XSpeedDecayAir;
            m_attack.HoldRepeat = false;
            m_attack.AttackType = 2;
            m_attack.AttackID = Utils.getUID();
            m_attack.ID = Utils.getUID();
            this.checkLinkedProjectiles();
            m_attack.HomingTarget = null;
            m_attack.HomingSpeed = atkObj.HomingSpeed;
            m_attack.DisableJump = atkObj.DisableJump;
            m_attack.JumpCancelAttack = atkObj.JumpCancelAttack;
            m_attack.DoubleJumpCancelAttack = atkObj.DoubleJumpCancelAttack;
            m_attack.ChargeInAir = atkObj.ChargeInAir;
            m_attack.AirEase = atkObj.AirEase;
            m_attack.XSpeedCap = atkObj.XSpeedCap;
            m_attack.RefreshRate = atkObj.RefreshRate;
            m_attack.ExecTime = -1;
            m_attack.SecondaryAttack = atkObj.SecondaryAttack;
            m_attack.HasClanked = false;
            m_attack.AllowControl = atkObj.AllowControl;
            m_attack.AllowControlGround = atkObj.AllowControlGround;
            m_attack.AllowJump = atkObj.AllowJump;
            m_attack.AllowFastFall = atkObj.AllowFastFall;
            m_attack.AllowRun = atkObj.AllowRun;
            m_attack.AllowTurn = atkObj.AllowTurn;
            m_attack.AllowFullInterrupt = atkObj.AllowFullInterrupt;
            m_attack.AllowDoubleJump = atkObj.AllowDoubleJump;
            m_attack.LinkFrames = atkObj.LinkFrames;
            m_attack.Cancel = atkObj.Cancel;
            m_attack.CancelWhenAirborne = atkObj.CancelWhenAirborne;
            m_attack.HasLanded = m_collision.ground;
            m_attack.CancelSoundOnEnd = atkObj.CancelSoundOnEnd;
            m_attack.CancelVoiceOnEnd = atkObj.CancelVoiceOnEnd;
            m_attack.Rotate = atkObj.Rotate;
            m_attack.WasCancelled = false;
            m_attack.XLoc = MC.x;
            m_attack.YLoc = MC.y;
            m_attack.AttackDelay = atkObj.AttackDelay;
            this.m_usingSpecialAttack = true;
            m_attack.CanFallOff = atkObj.CanFallOff;
            m_attack.CanGrabInverseLedges = atkObj.CanGrabInverseLedges;
            m_attack.CanBeAbsorbed = atkObj.CanBeAbsorbed;
            m_attack.AirCancel = atkObj.AirCancel;
            m_attack.AirCancelSpecial = atkObj.AirCancelSpecial;
            STAGEDATA.darkenCamera();
            if (atkObj.ResetMovement)
            {
                m_xSpeed = 0;
                m_ySpeed = 0;
            };
            if ((!(atkObj.ChargeRetain)))
            {
                atkObj.ChargeTime = 0;
            }
            else
            {
                if (((atkObj.UseChargeBar) && (STAGEPARENT.getChildByName(("energy" + m_player_id)) == null)))
                {
                    tmpMC = ResourceManager.getLibraryMC("energy");
                    tmpMC.name = ("energy" + m_player_id);
                    STAGEPARENT.addChild(tmpMC);
                    STAGEPARENT.getChildByName(("energy" + m_player_id)).x = (m_sprite.x + STAGE.x);
                    STAGEPARENT.getChildByName(("energy" + m_player_id)).y = (m_sprite.y + STAGE.y);
                    STAGEPARENT.getChildByName(("energy" + m_player_id)).width = (STAGEPARENT.getChildByName(("energy" + m_player_id)).width * m_sizeRatio);
                    STAGEPARENT.getChildByName(("energy" + m_player_id)).height = (STAGEPARENT.getChildByName(("energy" + m_player_id)).height * m_sizeRatio);
                };
            };
            this.m_previousAttack = m_attack.Frame;
            if (this.m_characterStats.FinalSmashCutin)
            {
                cutinHolder = ResourceManager.getLibraryMC("finalsmash_cutin");
                if (cutinHolder)
                {
                    cutinHolder.x = (1.65 - 320);
                    cutinHolder.y = (10 - 180);
                    cutin = ((this.m_characterStats.FinalSmashCutin) ? ResourceManager.getLibraryMC(this.m_characterStats.FinalSmashCutin) : null);
                    if (cutin)
                    {
                        STAGEDATA.HudForegroundRef.addChild(cutinHolder);
                        if ((!(this.m_human)))
                        {
                            cutinHolder.cutinbox.gotoAndStop("cpu");
                        }
                        else
                        {
                            if (m_player_id > 0)
                            {
                                cutinHolder.cutinbox.gotoAndStop(("p" + m_player_id));
                            }
                            else
                            {
                                cutinHolder.cutinbox.gotoAndStop("cpu");
                            };
                        };
                        cutinHolder.cutinbox.pa.placeholder.addChild(cutin);
                        STAGEDATA.CamRef.addForcedTarget(m_sprite);
                        STAGEDATA.FSCutins++;
                        this.m_finalSmashCutinMC = cutinHolder;
                        if (m_paletteSwapData)
                        {
                            Utils.replacePalette(cutin, m_paletteSwapPAData, 2);
                        };
                    };
                };
            };
            this.setState(CState.ATTACKING);
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.TURBO))
            {
                addEventListener(SSF2Event.ATTACK_HIT, this.allowTurboCancel);
                addEventListener(SSF2Event.ATTACK_HIT_SHIELD, this.allowTurboCancel);
                addEventListener(SSF2Event.ATTACK_HIT_POWER_SHIELD, this.allowTurboCancel);
                addEventListener(SSF2Event.CHAR_GRAB, this.allowTurboCancel);
            };
        }

        private function allowTurboCancel(e:SSF2Event):void
        {
            var attack:AttackObject;
            var frame:String;
            attack = m_attackData.getAttack(m_attack.Frame);
            if ((!(attack)))
            {
                return;
            };
            frame = ((attack.ParentAttack) || (m_attack.Frame));
            if ((((((!(this.m_lastAttackUsedTurbo == frame)) && (!((this.m_lastAttackUsedTurbo + "_air") == frame))) && (!(this.m_lastAttackUsedTurbo == (frame + "_air")))) && (!(inState(CState.GRABBING)))) && (!(((e.data) && (e.data.attackBoxData)) && (!(e.data.attackBoxData.allowTurboInterrupt))))))
            {
                this.setAttackEnabled(true, this.m_lastAttackUsedTurbo);
                this.setAttackEnabled(false, frame);
                updateAttackStats({
                    "allowJump":true,
                    "allowDoubleJump":true,
                    "airCancel":true,
                    "airCancelSpecial":true,
                    "allowFullInterrupt":true,
                    "jumpCancelAttack":true,
                    "doubleJumpCancelAttack":true
                });
                removeEventListener(SSF2Event.ATTACK_HIT, this.allowTurboCancel);
                removeEventListener(SSF2Event.ATTACK_HIT_SHIELD, this.allowTurboCancel);
                removeEventListener(SSF2Event.ATTACK_HIT_POWER_SHIELD, this.allowTurboCancel);
                addEventListener(SSF2Event.CHAR_ATTACK_COMPLETE, this.reenableOnEnd);
                addEventListener(SSF2Event.CHAR_HURT, this.reenableOnEnd);
                addEventListener(SSF2Event.CHAR_GRABBED, this.reenableOnEnd);
                this.m_lastAttackUsedTurbo = frame;
            };
        }

        private function reenableOnEnd(e:*=null):void
        {
            if (this.m_lastAttackUsedTurbo)
            {
                this.setAttackEnabled(true, this.m_lastAttackUsedTurbo);
            };
            if (((inState(CState.ATTACKING)) && (m_attack.IsThrow)))
            {
                this.grabReleaseOpponent();
            };
            this.m_lastAttackUsedTurbo = null;
        }

        private function checkTurbo():void
        {
            if (((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.TURBO)) && (this.m_lastAttackUsedTurbo)))
            {
                this.setAttackEnabled(true, this.m_lastAttackUsedTurbo);
                this.m_lastAttackUsedTurbo = null;
            };
        }

        public function hitBoxAttackTest(animation:String, hBoxName:String):AttackDamage
        {
            var attackDamage:AttackDamage;
            var attack:AttackObject;
            attackDamage = new AttackDamage(m_player_id, this);
            attack = m_attackData.getAttack(animation);
            if (attack)
            {
                if (attack.AttackBoxes[hBoxName])
                {
                    attackDamage.importAttackDamageData(attack.AttackBoxes[hBoxName]);
                    attackDamage.importAttackDamageData({
                        "id":m_attack.ID,
                        "atk_id":m_attack.AttackID,
                        "team_id":m_team_id
                    });
                };
            };
            return (attackDamage);
        }

        override public function reactionShield(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            attackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if ((otherSprite as Character))
            {
                if (((attackDamage.BypassShield) && (otherSprite.takeDamage(attackDamage, hBoxResult.OverlapHitBox))))
                {
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CONNECT, {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage.exportAttackDamageData()
                    }));
                    this.handleHit(otherSprite, attackDamage, hBoxResult);
                    return (true);
                };
                if (Character(otherSprite).takeShieldDamage(attackDamage, hBoxResult.OverlapHitBox))
                {
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CONNECT_SHIELD, {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage.exportAttackDamageData()
                    }));
                    this.m_smashDISelf = true;
                    startActionShot(Utils.calculateSelfHitStun(attackDamage.SelfHitStun, Utils.calculateChargeDamage(attackDamage)));
                    m_attack.RefreshRateReady = true;
                    m_eventManager.dispatchEvent(new SSF2Event(((Character(otherSprite).PerfectShield) ? SSF2Event.ATTACK_HIT_POWER_SHIELD : SSF2Event.ATTACK_HIT_SHIELD), {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage.exportAttackDamageData()
                    }));
                    return (true);
                };
            };
            return (false);
        }

        override public function reactionShieldAttack(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            attackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if ((((attackDamage.Priority < 7) && (attackDamage.Priority > -1)) && (otherSprite.validateHit(attackDamage, true))))
            {
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                this.endAttack();
                otherSprite.pushBackSlightly((otherSprite.X > m_sprite.x));
                return (true);
            };
            return (false);
        }

        override public function reactionAbsorb(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            attackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if ((((m_attack.CanBeAbsorbed) && (otherSprite.HasAbsorbBox)) && (otherSprite.validateHit(attackDamage, true))))
            {
                if (otherSprite.recover(Utils.calculateChargeDamage(attackDamage, attackDamage.AbsorbDamage)))
                {
                    otherSprite.stackAttackID(attackDamage.AttackID);
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ABSORB, {
                        "caller":this.APIInstance.instance,
                        "projectile":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage.exportAttackDamageData()
                    }));
                    return (true);
                };
            };
            return (false);
        }

        override public function reactionGrab(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var opponent:Character;
            var tempX1:Number;
            var tempY1:Number;
            var tempX:Number;
            var tempY:Number;
            opponent = null;
            if (((((((((inState(CState.CAUGHT)) || (inState(CState.INJURED))) || (inState(CState.FLYING))) || (inState(CState.LEDGE_HANG))) || ((otherSprite.inState(CState.CAUGHT)) || (otherSprite.isIntangible()))) || (this.m_grabCancelled)) || (inState(CState.LAND))) || (inState(CState.HEAVY_LAND))))
            {
                return (false);
            };
            if (((inState(CState.GRABBING)) && (otherSprite as Character)))
            {
                opponent = Character(otherSprite);
                if (!StrengthSystem.canGrab(this.getStrengthGrabRatio(opponent)))
                {
                    return (false);
                };
                if ((((((((((((((((((this.m_grabbed.length <= 0) && ((!(opponent.Invincible)) || ((opponent.inState(CState.ATTACKING)) && (opponent.AttackStateData.ForceGrabbable)))) && (!(opponent.Dead))) && (!(opponent.Revival))) && (!(opponent.Caught()))) && (!(opponent.Grabbed.length > 0))) && (!(opponent.Frozen))) && (!(((opponent.Team == m_team_id) && (m_team_id > 0)) && (!(STAGEDATA.TeamDamage))))) && (!(opponent.UsingFinalSmash))) && (!(opponent.StandBy))) && (!(opponent.inState(CState.CRASH_LAND)))) && (!(opponent.inState(CState.KIRBY_STAR)))) && (!(opponent.Egg))) && (!(opponent.Frozen))) && (!(opponent.Pitfall))) && (!((!(m_attack.GrabBehind)) && ((((m_sprite.x + 20) < opponent.X) && (!(m_facingForward))) || (((m_sprite.x - 20) > opponent.X) && (m_facingForward)))))) && (checkLinearPathBetweenPoints(new Point(m_sprite.x, (m_sprite.y - (m_sprite.height / 2))), new Point(opponent.X, (opponent.Y - (opponent.Height / 2)))))))
                {
                    if (((opponent.inState(CState.CRASH_LAND)) || (!(opponent.Capture(m_uid)))))
                    {
                        return (false);
                    };
                    this.playGlobalSound("grab");
                    this.stancePlayFrame("grabbed");
                    m_attack.AttackID = Utils.getUID();
                    m_attack.ID = Utils.getUID();
                    this.checkLinkedProjectiles();
                    this.m_grabbed = new Vector.<Character>();
                    this.m_grabbed.push(opponent);
                    this.initializeStrengthGrab(opponent, ((opponent.CharacterStats.Stamina > 0) ? Utils.calculateGrabLength((opponent.CharacterStats.Stamina - opponent.getDamage())) : Utils.calculateGrabLength(opponent.getDamage())));
                    opponent.FaceForward((!(m_facingForward)));
                    if (HasTouchBox)
                    {
                        this.repositionGrabbedCharacter();
                    };
                    if (opponent.Depth > this.Depth)
                    {
                        swapDepths(opponent);
                    };
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_GRAB, {
                        "caller":this.APIInstance.instance,
                        "grabbed":opponent.APIInstance.instance
                    }));
                    return (true);
                };
            }
            else
            {
                if (((!(inState(CState.GRABBING))) && (otherSprite as Character)))
                {
                    opponent = Character(otherSprite);
                    if ((((((((((((((((((this.m_grabbed.length == 0) || ((this.m_usingSpecialAttack) && ((this.m_characterStats.SpecialType == 6) || (this.m_characterStats.SpecialType === 1)))) && (!((!(m_attack.GrabBehind)) && (((m_sprite.x < opponent.X) && (!(m_facingForward))) || ((m_sprite.x > opponent.X) && (m_facingForward)))))) && (!((!(this.m_usingSpecialAttack)) && (!(checkLinearPathBetweenPoints(new Point(m_sprite.x, (m_sprite.y - (m_height / 2))), new Point(otherSprite.X, (otherSprite.Y - (otherSprite.Height / 2))))))))) && (!(((this.m_usingSpecialAttack) && ((this.m_characterStats.SpecialType == 2) || (this.m_characterStats.SpecialType == 3))) && (!(checkLinearPathBetweenPoints(new Point(m_sprite.x, (m_sprite.y - (m_height / 2))), new Point(otherSprite.X, (otherSprite.Y - (otherSprite.Height / 2))))))))) && ((!(opponent.Invincible)) || ((opponent.inState(CState.ATTACKING)) && (opponent.AttackStateData.ForceGrabbable)))) && (!(opponent.Dead))) && (!(opponent.Revival))) && (!(opponent.Caught()))) && (!(opponent.Frozen))) && (!(((opponent.Team == m_team_id) && (m_team_id > 0)) && (!(STAGEDATA.TeamDamage))))) && (!(opponent.UsingFinalSmash))) && (!(opponent.StandBy))) && (!(opponent.inState(CState.CRASH_LAND)))) && (!(opponent.inState(CState.KIRBY_STAR)))) && (!(opponent.Egg))) && (!(opponent.Pitfall))))
                    {
                        if (((opponent.inState(CState.CRASH_LAND)) || (!(opponent.Capture(m_uid)))))
                        {
                            return (false);
                        };
                        this.m_grabbed.push(opponent);
                        tempX1 = m_sprite.x;
                        tempY1 = m_sprite.y;
                        tempX1 = (tempX1 * m_sizeRatio);
                        tempY1 = (tempY1 * m_sizeRatio);
                        if ((((this.m_characterStats.LinkageID == "kirby") && ((m_attack.Frame == "b") || (m_attack.Frame == "b_air"))) && (this.m_currentPower == null)))
                        {
                            this.m_kirbyLastGrabbed = opponent.UID;
                            tempX = m_sprite.x;
                            tempY = m_sprite.y;
                            tempX = (tempX * m_sizeRatio);
                            tempY = (tempY * m_sizeRatio);
                            this.m_grabbed[0].MC.x = (this.m_grabbed[0].MC.x + (((m_sprite.x + tempX) - this.m_grabbed[0].X) / 6));
                            this.m_grabbed[0].MC.y = m_sprite.y;
                            this.updateItemHolding();
                            this.m_charIsFull = true;
                            this.m_holdTimer = 60;
                            this.m_grabbed[0].setVisibility(false);
                            if (inState(CState.ATTACKING))
                            {
                                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ATTACK_COMPLETE, {"caller":this.APIInstance.instance}));
                                flushTimers();
                                removeAllTempEvents();
                            };
                            this.setState(CState.IDLE);
                        };
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_GRAB, {
                            "caller":this.APIInstance.instance,
                            "grabbed":opponent.APIInstance.instance
                        }));
                        return (true);
                    };
                };
            };
            return (false);
        }

        public function reactionGrabClank(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (((((((inState(CState.GRABBING)) && (otherSprite.inState(CState.GRABBING))) && (otherSprite is Character)) && (!(attackIDArrayContains(otherSprite.AttackStateData.AttackID)))) && (!(otherSprite.attackIDArrayContains(m_attack.AttackID)))) && ((((m_facingForward) && (!(otherSprite.FacingForward))) && (m_sprite.x < otherSprite.X)) || (((!(m_facingForward)) && (otherSprite.FacingForward)) && (m_sprite.x > otherSprite.X)))))
            {
                stackAttackID(otherSprite.AttackStateData.AttackID);
                otherSprite.stackAttackID(m_attack.AttackID);
                this.dealDamage(2);
                Character(otherSprite).dealDamage(2);
                initDelayPlayback(true);
                otherSprite.initDelayPlayback(true);
                this.GrabCancelled = true;
                Character(otherSprite).GrabCancelled = true;
                startActionShot(2);
                otherSprite.startActionShot(2);
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                CAM.shake(15);
                this.grabRelease();
                Character(otherSprite).grabRelease();
                return (true);
            };
            return (false);
        }

        override public function reactionReverse(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (((otherSprite as Projectile) || (otherSprite as Item)))
            {
                if (otherSprite.reverse(m_player_id, m_team_id, m_facingForward))
                {
                    otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.REVERSE, {
                        "caller":otherSprite.APIInstance.instance,
                        "opponent":this.APIInstance.instance,
                        "attackBoxData":null
                    }));
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.REVERSE_HIT, {
                        "caller":this.APIInstance.instance,
                        "opponent":otherSprite.APIInstance.instance,
                        "attackBoxData":null
                    }));
                };
            };
            return (false);
        }

        override public function reactionClank(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage1:AttackDamage;
            var attackDamage2:AttackDamage;
            var totalDamage1:Number;
            var totalDamage2:Number;
            var nonDamagingReverseBox:Boolean;
            var nonDamagingProjectileHitStun:Boolean;
            if ((!((otherSprite as Character) && ((((this.m_usingSpecialAttack) && (this.m_characterStats.SpecialType == 3)) && (m_attack.ExecTime > 1)) && (Character(otherSprite).Caught())))))
            {
                attackDamage1 = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
                attackDamage2 = otherSprite.AttackDataObj.getAttackBoxData(otherSprite.AttackStateData.Frame, hBoxResult.SecondHitBox.Name).syncState(otherSprite.AttackCache);
                totalDamage1 = Utils.calculateChargeDamage(attackDamage1);
                totalDamage2 = Utils.calculateChargeDamage(attackDamage2);
                nonDamagingReverseBox = (((((attackDamage1.Damage === 0) && (attackDamage1.ReverseProjectile)) && (otherSprite is Projectile)) || (((attackDamage1.Damage === 0) && (attackDamage1.ReverseItem)) && (otherSprite is Item))) || (((attackDamage1.Damage === 0) && (attackDamage1.ReverseCharacter)) && (otherSprite is Character)));
                nonDamagingProjectileHitStun = (((attackDamage1.Damage === 0) && (attackDamage1.HitStunProjectile)) && (otherSprite is Projectile));
                if ((((((((((((((((((((!(attackDamage1.HasEffect)) || (!(attackDamage2.HasEffect))) || (attackDamage1.IsAirAttack)) || (attackDamage2.IsAirAttack)) || (this.isInvincible())) || (otherSprite.isInvincible())) || (attackDamage1.IsThrow)) || (attackDamage2.IsThrow)) || (!(m_collision.ground))) || (m_attack.HasClanked)) || (m_skipAttackProcessing)) || ((otherSprite is Character) && (!(otherSprite.CollisionObj.ground)))) || (((attackDamage1.Owner) && (attackDamage2.Owner)) && (attackDamage1.Owner.ID === attackDamage2.Owner.ID))) || ((((attackDamage1.Owner) && (attackDamage2.Owner)) && (attackDamage1.Owner.Team === attackDamage2.Owner.Team)) && (STAGEDATA.TeamDamage))) || (!(this.validateHit(attackDamage2)))) || ((!(otherSprite is Projectile)) && (!(otherSprite.validateHit(attackDamage1))))) || ((otherSprite is Projectile) && (!(Projectile(otherSprite).validateHitClank(attackDamage1))))) || (nonDamagingReverseBox)) || (nonDamagingProjectileHitStun)))
                {
                    return (false);
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_COLLIDE, {
                    "caller":this.APIInstance.instance,
                    "receiver":otherSprite.APIInstance.instance,
                    "callerAttackBoxData":attackDamage1.exportAttackDamageData(),
                    "receiverAttackBoxData":attackDamage2.exportAttackDamageData()
                }));
                otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_COLLIDE, {
                    "caller":otherSprite.APIInstance.instance,
                    "receiver":this.APIInstance.instance,
                    "callerAttackBoxData":attackDamage2.exportAttackDamageData(),
                    "receiverAttackBoxData":attackDamage1.exportAttackDamageData()
                }));
                if ((((Utils.fastAbs((totalDamage1 - totalDamage2)) < 8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
                {
                    if ((((otherSprite.SkipAttackProcessing) || (otherSprite.AttackStateData.HasClanked)) || ((otherSprite is Item) && (!(Item(otherSprite).PickedUp)))))
                    {
                        return (false);
                    };
                    if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                        "target":((otherSprite.APIInstance) ? otherSprite.APIInstance.instance : null),
                        "attackBoxData":attackDamage2,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    if (((!(otherSprite.HurtInterrupt == null)) && (otherSprite.HurtInterrupt({
                        "target":((m_apiInstance) ? m_apiInstance.instance : null),
                        "attackBoxData":attackDamage1,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CLANK, {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "callerAttackBoxData":attackDamage1.exportAttackDamageData(),
                        "receiverAttackBoxData":attackDamage2.exportAttackDamageData()
                    }));
                    otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CLANK, {
                        "caller":otherSprite.APIInstance.instance,
                        "receiver":this.APIInstance.instance,
                        "callerAttackBoxData":attackDamage2.exportAttackDamageData(),
                        "receiverAttackBoxData":attackDamage1.exportAttackDamageData()
                    }));
                    this.playReflectSound();
                    attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                    CAM.shake(15);
                    if ((otherSprite is Character))
                    {
                        this.clang(attackDamage2, hBoxResult);
                    }
                    else
                    {
                        startActionShot(Utils.calculateSelfHitStun(attackDamage1.SelfHitStun, Utils.calculateChargeDamage(attackDamage1)));
                        this.m_smashDISelf = true;
                        m_attack.HasClanked = true;
                    };
                    otherSprite.clang(attackDamage1, hBoxResult);
                    return (true);
                };
                if (((((totalDamage1 - totalDamage2) >= 8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
                {
                    if (((otherSprite.SkipAttackProcessing) || (otherSprite.AttackStateData.HasClanked)))
                    {
                        return (false);
                    };
                    if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                        "target":((otherSprite.APIInstance) ? otherSprite.APIInstance.instance : null),
                        "attackBoxData":attackDamage2,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    if (((!(otherSprite.HurtInterrupt == null)) && (otherSprite.HurtInterrupt({
                        "target":((m_apiInstance) ? m_apiInstance.instance : null),
                        "attackBoxData":attackDamage1,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    otherSprite.attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                    otherSprite.cancelAttack(attackDamage1, hBoxResult);
                    return (true);
                };
                if (((((totalDamage1 - totalDamage2) <= -8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
                {
                    if (((otherSprite.SkipAttackProcessing) || (otherSprite.AttackStateData.HasClanked)))
                    {
                        return (false);
                    };
                    if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                        "target":((otherSprite.APIInstance) ? otherSprite.APIInstance.instance : null),
                        "attackBoxData":attackDamage2,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    if (((!(otherSprite.HurtInterrupt == null)) && (otherSprite.HurtInterrupt({
                        "target":((m_apiInstance) ? m_apiInstance.instance : null),
                        "attackBoxData":attackDamage1,
                        "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                    }))))
                    {
                        return (false);
                    };
                    if ((otherSprite is Projectile))
                    {
                        return (false);
                    };
                    this.cancelAttack(attackDamage2, hBoxResult);
                    return (true);
                };
            };
            return (false);
        }

        override public function clang(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            var totalDamage1:Number;
            initDelayPlayback(true);
            m_skipAttackCollisionTests = true;
            resetKnockback();
            m_xSpeed = 0;
            m_ySpeed = 0;
            stackAttackID(attackBoxData.AttackID);
            startActionShot(Utils.calculateSelfHitStun(attackBoxData.HitStun, attackBoxData.Damage));
            m_attack.HasClanked = true;
            totalDamage1 = Utils.calculateChargeDamage(attackBoxData);
            this.cancelAttack(attackBoxData, hBoxResult);
            if (attackBoxData.Rebound)
            {
                this.grabRelease(true);
                this.m_hitLag = Utils.calculateRebound(totalDamage1);
            };
        }

        override public function handleHit(otherSprite:InteractiveSprite, attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            m_attack.RefreshRateReady = true;
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_HIT, {
                "caller":this.APIInstance.instance,
                "receiver":otherSprite.APIInstance.instance,
                "attackBoxData":attackBoxData.exportAttackDamageData()
            }));
            this.incrementHitsDealtCounter();
            if (((!(attackBoxData.IsThrow)) && (otherSprite.Depth > this.Depth)))
            {
                swapDepths(otherSprite);
            };
            if ((otherSprite is Character))
            {
                if ((!(staleIDArrayContains(attackBoxData.ID))))
                {
                    this.queueMove(attackBoxData.Frame);
                    stackStaleID(attackBoxData.ID);
                };
                attackBoxData.StaleMultiplier = this.totalMoveDecay(attackBoxData.Frame);
                this.increaseComboCount(attackBoxData, otherSprite.UID);
            };
            m_attack.HomingTarget = null;
            this.m_smashDISelf = true;
            if ((!(inState(CState.GRABBING))))
            {
                startActionShot(Utils.calculateSelfHitStun(attackBoxData.SelfHitStun, Utils.calculateChargeDamage(attackBoxData)));
            };
            if (((((attackBoxData.ReverseCharacter) && (otherSprite as Character)) || ((attackBoxData.ReverseProjectile) && (otherSprite as Projectile))) || ((attackBoxData.ReverseItem) && (otherSprite as Item))))
            {
                if (otherSprite.reverse(attackBoxData.PlayerID, attackBoxData.TeamID, attackBoxData.IsForward))
                {
                    otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.REVERSE, {
                        "caller":otherSprite.APIInstance.instance,
                        "opponent":this.APIInstance.instance,
                        "attackBoxData":attackBoxData.exportAttackDamageData()
                    }));
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.REVERSE_HIT, {
                        "caller":this.APIInstance.instance,
                        "opponent":otherSprite.APIInstance.instance,
                        "attackBoxData":attackBoxData.exportAttackDamageData()
                    }));
                };
            };
            this.resetJustHitTimer();
        }

        override public function cancelAttack(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            this.toIdle();
            this.grabRelease();
            m_skipAttackCollisionTests = true;
            m_skipAttackProcessing = true;
            m_attack.HasClanked = true;
        }

        override public function reactionAttackReverse(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            attackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if ((((attackDamage.ReverseProjectile) && (otherSprite as Projectile)) && (otherSprite.reverse(m_player_id, m_team_id, m_facingForward))))
            {
                otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.REVERSE, {
                    "caller":otherSprite.APIInstance.instance,
                    "opponent":this.APIInstance.instance,
                    "attackBoxData":null
                }));
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.REVERSE_HIT, {
                    "caller":this.APIInstance.instance,
                    "opponent":otherSprite.APIInstance.instance,
                    "attackBoxData":null
                }));
            }
            else
            {
                if ((((attackDamage.ReverseItem) && (otherSprite as Item)) && (otherSprite.reverse(m_player_id, m_team_id, m_facingForward))))
                {
                    otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.REVERSE, {
                        "caller":otherSprite.APIInstance.instance,
                        "opponent":this.APIInstance.instance,
                        "attackBoxData":null
                    }));
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.REVERSE_HIT, {
                        "caller":this.APIInstance.instance,
                        "opponent":otherSprite.APIInstance.instance,
                        "attackBoxData":null
                    }));
                };
            };
            return (false);
        }

        override public function reactionHit(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            if ((((otherSprite as Character) && (otherSprite.inState(CState.EGG))) && (hBoxResult.SecondHitBox.Type == HitBoxSprite.HIT)))
            {
                return (false);
            };
            if ((((otherSprite as Character) && (otherSprite.inState(CState.FROZEN))) && (hBoxResult.SecondHitBox.Type == HitBoxSprite.HIT)))
            {
                return (false);
            };
            attackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if (otherSprite.takeDamage(attackDamage, hBoxResult.OverlapHitBox))
            {
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CONNECT, {
                    "caller":this.APIInstance.instance,
                    "receiver":otherSprite.APIInstance.instance,
                    "attackBoxData":attackDamage.exportAttackDamageData()
                }));
                this.handleHit(otherSprite, attackDamage, hBoxResult);
                return (true);
            };
            if (((otherSprite.validateHit(attackDamage, true)) && (otherSprite.isInvincible())))
            {
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CONNECT, {
                    "caller":this.APIInstance.instance,
                    "receiver":otherSprite.APIInstance.instance,
                    "attackBoxData":attackDamage.exportAttackDamageData()
                }));
                m_attack.RefreshRateReady = true;
                otherSprite.stackAttackID(m_attack.AttackID);
                this.m_smashDISelf = true;
                startActionShot(Utils.calculateSelfHitStun(attackDamage.SelfHitStun, Utils.calculateChargeDamage(attackDamage)));
                m_attack.HomingTarget = null;
                if (((otherSprite as Character) && (!(Character(otherSprite).DizzyShield))))
                {
                    otherSprite.attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                };
                return (true);
            };
            return (false);
        }

        override public function reactionCounter(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage;
            attackDamage = otherSprite.AttackDataObj.getAttackBoxData(otherSprite.AttackStateData.Frame, hBoxResult.SecondHitBox.Name).syncState(otherSprite.AttackCache);
            if (((attackDamage.Damage > 0) && (this.validateHit(attackDamage, true))))
            {
                m_counterAttackData = attackDamage.exportAttackDamageData();
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_COUNTER, {
                    "caller":this.APIInstance.instance,
                    "receiver":otherSprite.APIInstance.instance,
                    "attackBoxData":m_counterAttackData
                }));
                return (true);
            };
            return (false);
        }

        override public function reactionCatch(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var otherReasons:Boolean;
            var catchButtonPressed:Boolean;
            if ((!(otherSprite as Item)))
            {
                return (false);
            };
            otherReasons = ((((this.inFreeState((CFreeState.ATTACKING | CFreeState.DODGING))) && (this.m_characterStats.CanHoldItems)) && (!(inState(CState.DODGE_ROLL)))) && (!(inState(CState.ITEM_PICKUP))));
            catchButtonPressed = (((this.m_pressedControls.BUTTON2) || ((this.shieldIsPressed()) && (inState(CState.AIR_DODGE)))) || ((inState(CState.AIR_DODGE)) && (m_framesSinceLastState <= 1)));
            this.m_itemPrePickup = Item(otherSprite);
            if ((((((((!(this.m_itemJustPickedUp)) && (!(this.m_itemPrePickup.Dead))) && (this.m_itemPrePickup.CanPickup)) && (this.m_item == null)) && (!(this.m_itemPrePickup.PickedUp))) && (catchButtonPressed)) && (otherReasons)))
            {
                return (this.itemPickupAnimationCheck());
            };
            return (false);
        }

        private function itemPickupAnimationCheck():Boolean
        {
            if (((m_collision.ground) && (this.inFreeState())))
            {
                if (((((((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.C_LEFT)) || (this.m_heldControls.C_RIGHT)) && (this.m_pressedControls.BUTTON2)) && ((this.m_runningSpeedLevel) || (inState(CState.DASH)))))
                {
                    this.Attack("a_forward", 1);
                    return (this.pickupItem());
                };
                this.setState(CState.ITEM_PICKUP);
                return (false);
            };
            return (this.pickupItem());
        }

        public function pickupItem():Boolean
        {
            var catchButtonPressed:Boolean;
            if (((((!(this.m_itemPrePickup)) || (this.m_itemPrePickup.Dead)) || (this.m_itemPrePickup.PickedUp)) || (!(this.m_itemPrePickup.CanPickup))))
            {
                return (false);
            };
            catchButtonPressed = ((inState(CState.ITEM_PICKUP)) || (((this.m_pressedControls.BUTTON2) || ((this.shieldIsPressed()) && (inState(CState.AIR_DODGE)))) || ((inState(CState.AIR_DODGE)) && (m_framesSinceLastState <= 1))));
            if (((this.m_itemPrePickup.ItemStats.Type === "carryable") && (!(((this.m_itemPrePickup.ReleaseTimer < 7) && (this.m_itemPrePickup.PreviousHolder === this)) && (this.m_itemPrePickup.WasZDropped)))))
            {
                this.m_item = this.m_itemPrePickup;
                this.m_item.PickedUp = true;
                this.m_item.resetTime();
                this.resetItemDamageCounter();
                this.m_item.CurrentAttackState.IsAttacking = false;
                this.m_item.SetPlayer(m_uid);
                this.updateItemHolding();
                this.playGlobalSound("pickup");
                this.updateItemHolding();
                this.m_itemJustPickedUp = true;
                if ((((m_collision.ground) && (!(inState(CState.ITEM_PICKUP)))) && (this.inFreeState())))
                {
                    if (((((((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.C_LEFT)) || (this.m_heldControls.C_RIGHT)) && (this.m_pressedControls.BUTTON2)) && ((this.m_runningSpeedLevel) || (inState(CState.DASH)))))
                    {
                        this.Attack("a_forward", 1);
                    }
                    else
                    {
                        if ((!(inState(CState.ITEM_PICKUP))))
                        {
                            this.setState(CState.ITEM_PICKUP);
                        };
                    };
                };
                return (true);
            };
            if (((((this.m_itemPrePickup.ItemStats.Type === "consumable") && (catchButtonPressed)) && (this.m_itemPrePickup.FrameInterrupt)) && (this.m_itemPrePickup.FrameInterrupt({"character":this.APIInstance.instance}))))
            {
                this.m_itemJustPickedUp = true;
                if ((((m_collision.ground) && (!(inState(CState.ITEM_PICKUP)))) && (this.inFreeState())))
                {
                    if (((((((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.C_LEFT)) || (this.m_heldControls.C_RIGHT)) && (this.m_pressedControls.BUTTON2)) && ((this.m_runningSpeedLevel) || (inState(CState.DASH)))))
                    {
                        this.Attack("a_forward", 1);
                    }
                    else
                    {
                        if ((!(inState(CState.ITEM_PICKUP))))
                        {
                            this.setState(CState.ITEM_PICKUP);
                        };
                    };
                };
                return (true);
            };
            return (false);
        }

        override public function attackCollisionTest():void
        {
            var i:int;
            var opponent:Character;
            var enemy:Enemy;
            var item:Item;
            var target:TargetTestTarget;
            var projectile:Projectile;
            if (((((m_bypassCollisionTesting) || (!(m_hitBoxManager.HasHitBoxes))) || (this.m_standby)) || (m_attackCollisionTestsPreProcessed)))
            {
                return;
            };
            i = 0;
            opponent = null;
            enemy = null;
            item = null;
            target = null;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var cindex:int;
            var nonAttack:Boolean;
            var hBoxArr:Array;
            projectile = null;
            if (((!(inState(CState.ATTACKING))) && (m_attackData.getAttack(m_currentAnimationID))))
            {
                m_attack.Frame = m_currentAnimationID;
            };
            if (this.m_justHit)
            {
                this.m_justHitTimer--;
                if (this.m_justHitTimer == 0)
                {
                    this.m_justHit = false;
                };
            };
            m_attackCache.syncState(m_attack);
            i = 0;
            while (i < STAGEDATA.ItemsRef.MAXITEMS)
            {
                item = STAGEDATA.ItemsRef.getItemData(i);
                if (((!(item == null)) && (!((item.PickedUp) && (item.PlayerID == m_player_id)))))
                {
                    if ((!(InteractiveSprite.hitTest(this, item, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                    {
                    }
                    else
                    {
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionAttackReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.REVERSE, HitBoxSprite.HIT, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.REVERSE, HitBoxSprite.ATTACK, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.CATCH, HitBoxSprite.HIT, this.reactionCatch, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.CATCH, HitBoxSprite.CATCH, this.reactionCatch, STAGEDATA.HitBoxProcessorInstance);
                    };
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Characters.length)
            {
                opponent = STAGEDATA.Characters[i];
                if ((((((((!(opponent == null)) && (!(opponent == this))) && (!(opponent.StandBy))) && (!(opponent.Dead))) && (!(opponent.inState(CState.STAR_KO)))) && (!(opponent.inState(CState.SCREEN_KO)))) && (!(opponent.inState(CState.REVIVAL)))))
                {
                    InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.SHIELD, this.reactionShield, STAGEDATA.HitBoxProcessorInstance);
                    if ((!(InteractiveSprite.hitTest(this, opponent, HitBoxSprite.MASTER, HitBoxSprite.MASTER).length)))
                    {
                    }
                    else
                    {
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionClank, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.GRAB, HitBoxSprite.GRAB, this.reactionGrabClank, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.SHIELDATTACK, this.reactionShieldAttack, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.STAR, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.EGG, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.FREEZE, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.GRAB, HitBoxSprite.HIT, this.reactionGrab, STAGEDATA.HitBoxProcessorInstance);
                    };
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Enemies.length)
            {
                enemy = STAGEDATA.Enemies[i];
                if (enemy != null)
                {
                    if ((!(InteractiveSprite.hitTest(this, enemy, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                    {
                    }
                    else
                    {
                        InteractiveSprite.hitTest(this, enemy, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, enemy, HitBoxSprite.STAR, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, enemy, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                    };
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Targets.length)
            {
                target = STAGEDATA.Targets[i];
                if (target != null)
                {
                    InteractiveSprite.hitTest(this, target, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Projectiles.length)
            {
                projectile = STAGEDATA.Projectiles[i];
                if (projectile != null)
                {
                    if ((!(InteractiveSprite.hitTest(this, projectile, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                    {
                    }
                    else
                    {
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionAttackReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionClank, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.STAR, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.REVERSE, HitBoxSprite.ATTACK, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, projectile, HitBoxSprite.REVERSE, HitBoxSprite.HIT, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                    };
                };
                i++;
            };
            this.removeUngrabbedCharacters();
            if (((inState(CState.ATTACKING)) && (this.m_grabbed.length > 0)))
            {
                i = 0;
                while (i < this.m_grabbed.length)
                {
                    this.repositionGrabbedCharacter(i);
                    i++;
                };
            };
            if (HasMC)
            {
                m_sprite.stop();
                Utils.recursiveMovieClipPlay(m_sprite, false);
            };
        }

        public function setLivesEnabled(enabled:Boolean):void
        {
            this.m_usingLives = enabled;
            if (this.m_usingLives)
            {
                this.m_lastLivesTextNum = -1;
                this.updateLivesDisplay();
            }
            else
            {
                m_healthBoxMC.lives.text = "";
            };
        }

        public function grantFinalSmash():Boolean
        {
            var smashball:Item;
            if ((!(this.m_item2)))
            {
                smashball = STAGEDATA.ItemsRef.generateItemObj(STAGEDATA.ItemsRef.getItemByLinkage("smashball"), m_sprite.x, m_sprite.y, true);
                return (this.grantSmashBall(smashball));
            };
            return (false);
        }

        public function grantSmashBall(i:Item):Boolean
        {
            if ((!(this.m_item2)))
            {
                if (this.m_finalSmashMeterReady)
                {
                    i.destroy();
                    return (false);
                };
                this.m_item2 = i;
                this.m_item2.SetPlayer(m_uid);
                this.m_item2.PickedUp = true;
                this.m_fsGlowHolderMC.scaleX = m_sizeRatio;
                this.m_fsGlowHolderMC.scaleY = m_sizeRatio;
                this.m_fsGlowHolderMC.x = m_sprite.x;
                this.m_fsGlowHolderMC.y = m_sprite.y;
                toggleEffect(this.m_fsGlowHolderMC, true);
                if (this.m_characterStats.FinalSmashMeter)
                {
                    this.m_finalSmashMeterCharge = 1;
                };
                return (true);
            };
            return (false);
        }

        public function releaseSmashBall():Boolean
        {
            if (this.m_item2)
            {
                this.m_item2.PickedUp = false;
                this.m_item2 = null;
                toggleEffect(this.m_fsGlowHolderMC, false);
                if (this.m_characterStats.FinalSmashMeter)
                {
                    this.FinalSmashMeterCharge = 0;
                };
                return (true);
            };
            return (false);
        }

        public function giveItem(i:Item):void
        {
            if (this.m_item != null)
            {
                this.m_item.destroy();
            };
            this.m_item = i;
            this.m_item.SetPlayer(m_uid);
        }

        public function resetJustHitTimer():void
        {
            this.m_justHit = true;
            this.m_justHitTimer = 5;
        }

        public function resetJumps():void
        {
            this.m_jumpCount = 0;
        }

        public function getPlayerSettings():PlayerSetting
        {
            return (this.m_playerSettings);
        }

        public function getCPULevel():int
        {
            return (this.m_playerSettings.level);
        }

        public function getCPUAction():int
        {
            if ((!(this.CPU)))
            {
                return (-1);
            };
            return (this.CPU.Action);
        }

        public function getCPUForcedAction():int
        {
            if ((!(this.CPU)))
            {
                return (-1);
            };
            return (this.CPU.ForcedAction);
        }

        public function getCPUTargetAPI():*
        {
            if ((((this.m_human) || (!(this.CPU))) || (!(this.CPU.CurrentTarget))))
            {
                return (null);
            };
            return ((this.CPU.CurrentTarget.PlayerSprite) ? this.CPU.CurrentTarget.PlayerSprite.APIInstance.instance : null);
        }

        public function setCPUAttackQueue(str:String):void
        {
            if (((this.m_human) || (!(this.CPU))))
            {
                return;
            };
            this.CPU.addToAttackQueue(str);
        }

        public function importCPUControls(array:Array):void
        {
            if (this.CPU)
            {
                this.CPU.importControlOverrides(array);
            };
        }

        public function resetCPUControls():void
        {
            if (this.CPU)
            {
                this.CPU.resetControlOverrides();
            };
        }

        public function usingCPUControls():Boolean
        {
            return ((((!(this.m_human)) && (this.CPU)) && (this.CPU.ControlOverrides)) && (this.CPU.ControlOverrides.length > 0));
        }

        public function isForcedCrash():Boolean
        {
            return (this.m_forcedCrash);
        }

        public function isRecovering():Boolean
        {
            return (this.m_recoveryAmount > 0);
        }

        override public function forceAttack(value:String, toFrame:*=null, isSpecial:Boolean=false):Boolean
        {
            if (((this.inFreeState((CFreeState.ATTACKING | CFreeState.GRABBING))) && (!(value == null))))
            {
                disableDelayPlayback();
                if (value === "special")
                {
                    if (this.m_characterStats.SpecialType === 0)
                    {
                        this.m_transformingSpecial = true;
                    };
                    this.SpecialAttack();
                }
                else
                {
                    this.Attack(value, ((isSpecial) ? 2 : 1));
                };
                if (inState(CState.ATTACKING))
                {
                    if (toFrame !== null)
                    {
                        this.stancePlayFrame(toFrame);
                    };
                    if (((!(HasTouchBox)) && (this.m_grabbed.length > 0)))
                    {
                        this.releaseOpponent();
                    }
                    else
                    {
                        if (this.m_grabbed.length > 0)
                        {
                            this.repositionGrabbedCharacter();
                        };
                    };
                    return (true);
                };
            };
            return (false);
        }

        public function getSizeStatus():int
        {
            return (this.m_sizeStatus);
        }

        public function getCurrentKirbyPower():String
        {
            return (this.m_currentPower);
        }

        public function getExecTime():int
        {
            return (m_attack.ExecTime);
        }

        public function getCurrentAttackFrame():String
        {
            return (m_attack.Frame);
        }

        public function stealStock():void
        {
            this.m_lives--;
            this.updateLivesDisplay();
        }

        public function getLives():int
        {
            return (this.m_lives);
        }

        public function setLives(lives:int):void
        {
            this.m_lives = lives;
            this.updateLivesDisplay();
        }

        public function getControls(inputsOnly:Boolean=false):Object
        {
            var controls:Object;
            controls = {};
            controls["UP"] = ((inputsOnly) ? this.m_pressedControls.UP : this.m_heldControls.UP);
            controls["DOWN"] = ((inputsOnly) ? this.m_pressedControls.DOWN : this.m_heldControls.DOWN);
            controls["LEFT"] = ((inputsOnly) ? this.m_pressedControls.LEFT : this.m_heldControls.LEFT);
            controls["RIGHT"] = ((inputsOnly) ? this.m_pressedControls.RIGHT : this.m_heldControls.RIGHT);
            controls["JUMP"] = ((inputsOnly) ? this.jumpIsPressed() : this.jumpIsHeld());
            controls["BUTTON1"] = ((inputsOnly) ? this.m_pressedControls.BUTTON1 : this.m_heldControls.BUTTON1);
            controls["BUTTON2"] = ((inputsOnly) ? this.m_pressedControls.BUTTON2 : this.m_heldControls.BUTTON2);
            controls["GRAB"] = ((inputsOnly) ? this.m_pressedControls.GRAB : this.m_heldControls.GRAB);
            controls["START"] = ((inputsOnly) ? this.m_pressedControls.START : this.m_heldControls.START);
            controls["TAUNT"] = ((inputsOnly) ? this.m_pressedControls.TAUNT : this.m_heldControls.TAUNT);
            controls["SHIELD"] = ((inputsOnly) ? this.m_pressedControls.SHIELD : this.shieldIsHeld());
            controls["JUMP2"] = ((inputsOnly) ? this.m_pressedControls.JUMP2 : this.m_heldControls.JUMP2);
            controls["C_UP"] = ((inputsOnly) ? this.m_pressedControls.C_UP : this.m_heldControls.C_UP);
            controls["C_DOWN"] = ((inputsOnly) ? this.m_pressedControls.C_DOWN : this.m_heldControls.C_DOWN);
            controls["C_LEFT"] = ((inputsOnly) ? this.m_pressedControls.C_LEFT : this.m_heldControls.C_LEFT);
            controls["C_RIGHT"] = ((inputsOnly) ? this.m_pressedControls.C_RIGHT : this.m_heldControls.C_RIGHT);
            controls["DASH"] = ((inputsOnly) ? this.m_pressedControls.DASH : this.m_heldControls.DASH);
            controls["TAP_JUMP"] = this.m_tap_jump;
            controls["AUTO_DASH"] = this.m_auto_dash;
            controls["DT_DASH"] = this.m_dt_dash;
            controls["SHIELD2"] = ((inputsOnly) ? this.m_pressedControls.SHIELD2 : this.m_heldControls.SHIELD2);
            controls["JUMP3"] = ((inputsOnly) ? this.m_pressedControls.JUMP3 : this.m_heldControls.JUMP3);
            return (controls);
        }

        public function getControlBitsAPI(inputsOnly:Boolean=false):int
        {
            return ((inputsOnly) ? this.m_pressedControls.controls : this.m_heldControls.controls);
        }

        public function getLastUsed(str:String=null):int
        {
            if (m_attackData.getAttack(((str != null) ? str : m_attack.Frame)) != null)
            {
                return (m_attackData.getAttack(((str != null) ? str : m_attack.Frame)).LastUsedPrevious);
            };
            return (-1);
        }

        public function getHitsDealtCounter():int
        {
            return (this.m_hitsDealtCounter);
        }

        public function resetHitsDealtCounter():void
        {
            this.m_hitsDealtCounter = 0;
        }

        public function getHitsReceivedCounter():int
        {
            return (this.m_hitsReceivedCounter);
        }

        public function resetHitsReceivedCounter():void
        {
            this.m_hitsReceivedCounter = 0;
        }

        public function generateItem(itemID:String, hold:Boolean=false, isCustom:Boolean=true, forceGenerate:Boolean=false):Item
        {
            var i:int;
            var tmpItem:Item;
            var targetSpawn:Point;
            var opponent:Character;
            i = 0;
            targetSpawn = new Point(m_sprite.x, (m_sprite.y - 10));
            if (HasItemBox)
            {
                targetSpawn.x = (m_sprite.x + (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).xreg * m_sprite.scaleX));
                targetSpawn.y = (m_sprite.y + (HitBoxSprite(this.CurrentAnimation.getHitBoxes(CurrentFrameNum, HitBoxSprite.ITEM)[0]).yreg * m_sprite.scaleY));
            };
            if (isCustom)
            {
                if (((this.m_characterStats.StatsName === "kirby") && (this.m_currentPower)))
                {
                    i = 0;
                    while (i < STAGEDATA.Players.length)
                    {
                        opponent = STAGEDATA.Players[i];
                        if (((opponent) && (opponent.StatsName === this.m_currentPower)))
                        {
                            tmpItem = STAGEDATA.ItemsRef.generateItemObj(opponent.AttackDataObj.getItem(itemID), targetSpawn.x, targetSpawn.y);
                            break;
                        };
                        i++;
                    };
                };
                tmpItem = ((tmpItem) || (STAGEDATA.ItemsRef.generateItemObj(m_attackData.getItem(itemID), targetSpawn.x, targetSpawn.y)));
            }
            else
            {
                if (itemID === "random")
                {
                    tmpItem = STAGEDATA.ItemsRef.makeItem(targetSpawn.x, targetSpawn.y);
                }
                else
                {
                    tmpItem = STAGEDATA.ItemsRef.generateItemObj(STAGEDATA.ItemsRef.getItemByLinkage(itemID, (!(forceGenerate))), targetSpawn.x, targetSpawn.y);
                };
            };
            if (tmpItem != null)
            {
                tmpItem.OriginalPlayerID = m_player_id;
                if (((hold) && (this.m_item == null)))
                {
                    this.m_item = tmpItem;
                    this.m_item.PickedUp = true;
                    this.m_item.SetPlayer(m_uid);
                    this.m_item.inheritPalette();
                    this.updateItemHolding();
                };
            };
            return (tmpItem);
        }

        public function removeItem():void
        {
            if (this.m_item != null)
            {
                STAGEDATA.ItemsRef.killItem(this.m_item.Slot);
                this.m_item = null;
            };
        }

        public function maxOutJumps():void
        {
            this.m_jumpCount = this.m_characterStats.MaxJump;
        }

        public function setAttackEnabled(enabled:Boolean, atkName:String=null, reenableTimer:int=-1):void
        {
            if (((atkName == null) && (inState(CState.ATTACKING))))
            {
                atkName = m_attack.Frame;
            };
            if (((!(atkName == null)) && (!(m_attackData.getAttack(atkName) == null))))
            {
                m_attackData.getAttack(atkName).IsDisabled = (!(enabled));
                if ((!(enabled)))
                {
                    m_attackData.getAttack(atkName).ReenableTimerCount = ((reenableTimer < 0) ? m_attackData.getAttack(atkName).ReenableTimer : reenableTimer);
                };
            };
        }

        public function setLastUsed(str:String, frames:int):void
        {
            if (((!(str == null)) && (!(m_attackData.getAttack(str) == null))))
            {
                m_attackData.getAttack(str).LastUsedPrevious = frames;
                m_attackData.getAttack(str).LastUsed = frames;
            };
        }

        override public function setXSpeed(amount:Number, absolute:Boolean=true):void
        {
            if (((inState(CState.STAR_KO)) || (inState(CState.SCREEN_KO))))
            {
                return;
            };
            super.setXSpeed(amount, absolute);
        }

        override public function setYSpeed(amount:Number):void
        {
            if (((inState(CState.STAR_KO)) || (inState(CState.SCREEN_KO))))
            {
                return;
            };
            if (amount != 0)
            {
                this.m_attackHovering = false;
            };
            super.setYSpeed(amount);
        }

        public function setSizeStatus(value:int):void
        {
            if (this.m_characterStats.StatusEffectImmunity)
            {
                return;
            };
            if (this.m_sizeStatusPermanent)
            {
                return;
            };
            if (this.m_sizeStatus == 1)
            {
                if (value == 1)
                {
                    this.m_sizeStatusTimer.reset();
                    return;
                };
                if (value == -1)
                {
                    value = 0;
                };
            }
            else
            {
                if (this.m_sizeStatus == -1)
                {
                    if (value == -1)
                    {
                        this.m_sizeStatusTimer.reset();
                        return;
                    };
                    if (value == 1)
                    {
                        value = 0;
                    };
                };
            };
            if (value == 1)
            {
                m_sizeRatio = (this.m_originalSizeRatio * 2);
                m_sprite.scaleX = ((m_sprite.scaleX > 0) ? m_sizeRatio : -(m_sizeRatio));
                m_sprite.scaleY = ((m_sprite.scaleY > 0) ? m_sizeRatio : -(m_sizeRatio));
                this.m_sizeStatus = value;
                m_attack.SizeStatus = this.m_sizeStatus;
                this.m_sizeStatusTimer.reset();
                if (this.m_grabbed.length > 0)
                {
                    this.grabReleaseOpponent();
                    this.grabRelease();
                };
                if ((((!(inState(CState.ENTRANCE))) && (!(this.m_usingSpecialAttack))) && (!(this.isGrabbedByFinalSmash()))))
                {
                    this.endAttack();
                };
                this.killAllSpeeds();
            }
            else
            {
                if (value == -1)
                {
                    m_sizeRatio = (this.m_originalSizeRatio / 2);
                    m_sprite.scaleX = ((m_sprite.scaleX > 0) ? m_sizeRatio : -(m_sizeRatio));
                    m_sprite.scaleY = ((m_sprite.scaleY > 0) ? m_sizeRatio : -(m_sizeRatio));
                    this.m_sizeStatus = value;
                    this.m_sizeStatusTimer.reset();
                    m_attack.SizeStatus = this.m_sizeStatus;
                    if (this.m_grabbed.length > 0)
                    {
                        this.grabReleaseOpponent();
                        this.grabRelease();
                    };
                    if ((((!(inState(CState.ENTRANCE))) && (!(this.m_usingSpecialAttack))) && (!(this.isGrabbedByFinalSmash()))))
                    {
                        this.endAttack();
                    };
                    this.killAllSpeeds();
                }
                else
                {
                    if (value == 0)
                    {
                        m_sizeRatio = this.m_originalSizeRatio;
                        m_sprite.scaleX = ((m_sprite.scaleX > 0) ? m_sizeRatio : -(m_sizeRatio));
                        m_sprite.scaleY = ((m_sprite.scaleY > 0) ? m_sizeRatio : -(m_sizeRatio));
                        this.m_sizeStatus = value;
                        this.m_sizeStatusTimer.finish();
                        m_attack.SizeStatus = this.m_sizeStatus;
                    };
                };
            };
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_SIZE_CHANGE, {
                "caller":this.APIInstance.instance,
                "sizeStatus":this.m_sizeStatus
            }));
        }

        override public function removeFromCamera():void
        {
        }

        public function getInvincibility():Boolean
        {
            return (m_invincible);
        }

        public function getIntangibility():Boolean
        {
            return (m_intangible);
        }

        public function setInvisibilityTimer(value:int):void
        {
            this.m_invisibleTimer.reset();
            this.m_invisibleTimer.MaxTime = value;
            this.setVisibility(false);
        }

        override public function setInvincibility(value:Boolean):void
        {
            super.setInvincibility(value);
            if (((!(value)) && (!(m_intangible))))
            {
                this.turnOffInvincibility();
            };
        }

        override public function setIntangibility(value:Boolean):void
        {
            super.setIntangibility(value);
            if (((!(value)) && (!(m_invincible))))
            {
                this.turnOffInvincibility();
            };
        }

        public function getShieldPower():Number
        {
            return (this.m_shieldPower / 100);
        }

        public function getSmashTimer():int
        {
            return (this.m_smashTimer);
        }

        public function getGrabbedOpponentAPI():*
        {
            return ((this.m_grabbed.length == 0) ? null : this.m_grabbed[0].APIInstance.instance);
        }

        public function getItemAPI():*
        {
            return ((this.m_item) ? this.m_item.APIInstance.instance : null);
        }

        public function getTeammates():Array
        {
            var list:Array;
            var i:int;
            list = new Array();
            i = 0;
            while (i < STAGEDATA.Characters.length)
            {
                if ((((m_team_id > 0) && (m_team_id == STAGEDATA.Characters[i].Team)) && (!(STAGEDATA.Characters[i] == this))))
                {
                    list.push(STAGEDATA.Characters[i]);
                };
                i++;
            };
            return (list);
        }

        public function getTeammatesAPI():Array
        {
            var list:Array;
            var i:int;
            list = new Array();
            i = 0;
            while (i < STAGEDATA.Characters.length)
            {
                if ((((m_team_id > 0) && (m_team_id == STAGEDATA.Characters[i].Team)) && (!(STAGEDATA.Characters[i] == this))))
                {
                    list.push(STAGEDATA.Characters[i].APIInstance.instance);
                };
                i++;
            };
            return (list);
        }

        private function getBike():Item
        {
            var bikeType:String;
            var i:int;
            bikeType = "wario_bike";
            if (this.m_characterStats.LinkageID == "kirby")
            {
                bikeType = "kirby_bike";
            };
            i = 0;
            while (i < STAGEDATA.ItemsRef.ItemsInUse.length)
            {
                if ((((!(STAGEDATA.ItemsRef.ItemsInUse[i] == null)) && (STAGEDATA.ItemsRef.ItemsInUse[i].OriginalPlayerID == m_player_id)) && (STAGEDATA.ItemsRef.ItemsInUse[i].LinkageID == bikeType)))
                {
                    return (STAGEDATA.ItemsRef.ItemsInUse[i]);
                };
                i++;
            };
            return (null);
        }

        public function bikeExists():Boolean
        {
            return (Boolean((!(this.getBike() == null))));
        }

        public function gotoGrabbedCharacter():void
        {
            if (this.m_grabbed.length > 0)
            {
                m_sprite.x = this.m_grabbed[0].X;
                m_sprite.y = this.m_grabbed[0].Y;
            };
        }

        public function damageSelf(amount:int):void
        {
            this.dealDamage(amount);
        }

        public function isRocketing():Boolean
        {
            return ((inState(CState.ATTACKING)) && (m_attack.Rocket));
        }

        override public function forceHitStun(num:int, sdiDistance:Number=-1):void
        {
            if (sdiDistance > 0)
            {
                this.m_smashDIAmount = (this.SDI_BASE * sdiDistance);
            };
            startActionShot(num);
        }

        public function forceGrabbedHurtFrame(frame:String):void
        {
            var i:int;
            if (this.m_grabbed.length > 0)
            {
                i = 0;
                while (i < this.m_grabbed.length)
                {
                    if (((this.m_grabbed[i].HasStance) && (Utils.hasLabel(this.m_grabbed[i].MC.stance, frame))))
                    {
                        this.m_grabbed[i].playHurtFrame(frame);
                    };
                    i++;
                };
                this.updateCutscenePlaceholders();
            };
        }

        public function shakeCamera(num:int):void
        {
            CAM.shake(num);
        }

        public function swapDepthsWithGrabbedOpponent(onTop:Boolean):void
        {
            if (((this.m_grabbed.length > 0) && (this.m_grabbed[0].IsCaught)))
            {
                if (((onTop) && (Depth < this.m_grabbed[0].Depth)))
                {
                    swapDepths(this.m_grabbed[0]);
                }
                else
                {
                    if (((!(onTop)) && (Depth > this.m_grabbed[0].Depth)))
                    {
                        swapDepths(this.m_grabbed[0]);
                    };
                };
            };
        }

        public function resetMovement(e:*=null):void
        {
            m_xSpeed = 0;
            m_ySpeed = 0;
            if (((e) && (e is SSF2Event)))
            {
                m_eventManager.removeEventListener(SSF2Event(e).type, this.resetMovement);
            };
        }

        public function isCPU():Boolean
        {
            return (!(this.m_human));
        }

        public function switchAttackData(attackName:String, nextSwitchID:String, b:*=null):void
        {
            if (((inState(CState.ATTACKING)) && (!(m_attackData.getAttack(nextSwitchID) == null))))
            {
                m_attackData.setAttack(attackName, m_attackData.getAttack(nextSwitchID).Clone());
                if ((!(this.m_human)))
                {
                    this.CPU.refreshRecoveryAttackList();
                    this.CPU.refreshDisabledAttackList();
                };
            };
        }

        public function switchAttack(targetFrame:String, toFrame:*=null):void
        {
            if (((!(targetFrame == null)) && (!(m_attackData.getAttack(targetFrame) == null))))
            {
                m_attack.Frame = targetFrame;
                m_attackData.getAttack(targetFrame).OverrideMap.clear();
                this.playFrame(m_attack.Frame);
                if (toFrame !== null)
                {
                    this.stancePlayFrame(toFrame);
                };
            };
        }

        public function clearAttackControlsArr():void
        {
            while (this.m_attackControlsArr.length > 0)
            {
                this.m_attackControlsArr.splice(0, 1);
            };
        }

        public function endAttack(targetFrame:String=null, targetFrameLabel:String=null):void
        {
            var toState:uint;
            var str:String;
            var i:int;
            var validFrames:Array;
            if ((((((m_player_id == 1) && (inState(CState.ATTACKING))) && (Main.DEBUG)) && (MenuController.debugConsole)) && (MenuController.debugConsole.ControlsCapture)))
            {
                str = "[ ";
                i = 0;
                while (i < this.m_attackControlsArr.length)
                {
                    if (i != 0)
                    {
                        str = (str + ", ");
                    };
                    str = (str + ("" + this.m_attackControlsArr[i]));
                    i++;
                };
                str = (str + " ]");
                MenuController.debugConsole.writeEndAttackControls(str);
                this.clearAttackControlsArr();
            };
            toState = CState.IDLE;
            if (targetFrame != null)
            {
                validFrames = new Array();
                validFrames["stand"] = CState.IDLE;
                validFrames["walk"] = CState.WALK;
                validFrames["run"] = CState.RUN;
                validFrames["jump"] = CState.JUMP_RISING;
                validFrames["jump_midair"] = CState.JUMP_MIDAIR_RISING;
                validFrames["fall"] = CState.JUMP_FALLING;
                validFrames["land"] = CState.LAND;
                validFrames["crouch"] = CState.CROUCH;
                validFrames["falling"] = CState.TUMBLE_FALL;
                if ((!(validFrames[targetFrame])))
                {
                    toState = validFrames[targetFrame];
                }
                else
                {
                    targetFrame = null;
                };
            }
            else
            {
                targetFrame = null;
            };
            if (m_collision.ground)
            {
                this.forceEndAttack();
                if (targetFrame)
                {
                    this.setState(toState);
                };
                this.m_checkTaunt();
                if (((HasStance) && (!(targetFrameLabel == null))))
                {
                    this.stancePlayFrame(targetFrameLabel);
                };
            }
            else
            {
                this.forceEndAttack();
                if (((HasStance) && (!(targetFrameLabel == null))))
                {
                    this.stancePlayFrame(targetFrameLabel);
                };
            };
            this.checkEdgeLean();
            this.updateTint();
            this.m_lastFrameInterrupt = null;
        }

        public function endFinalForm():void
        {
            var tmpPower:String;
            var tmpVisible:Boolean;
            if (this.m_transformedSpecial)
            {
                this.m_transformTime = this.m_transformLimit;
                STAGEDATA.ItemsRef.SmashBallReady.CurrentTime = STAGEDATA.ItemsRef.SmashBallReady.MaxTime;
                if (((m_healthBoxMC) && (!(this.m_characterStats.FinalSmashMeter))))
                {
                    m_healthBoxMC.fsmeter.visible = false;
                };
                tmpPower = this.m_characterStats.Power;
                tmpVisible = m_sprite.visible;
                if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                {
                    STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                };
                this.setState(CState.IDLE);
                this.m_transformedSpecial = false;
                this.replaceCharacter(this.m_characterStats.NormalStatsID, null, null);
                this.setVisibility(tmpVisible);
                if (this.m_characterStats.FinalSmashMeter)
                {
                    this.FinalSmashMeterCharge = 0;
                    this.m_finalSmashMeterReady = false;
                    if (m_healthBoxMC)
                    {
                        m_healthBoxMC.fsmeter.bar.gotoAndPlay("fill");
                        m_healthBoxMC.fsmeter.fullcharge.gotoAndPlay("off");
                    };
                };
            };
        }

        public function transformTimerExtend(amount:Number):void
        {
            this.m_transformTime = (this.m_transformTime - amount);
        }

        override public function stopActionShot(hitstun:Boolean=true, paralysis:Boolean=true):void
        {
            var currentSpeed:Number;
            var currentAngle:Number;
            var angle:Number;
            if (((!(hitstun)) && (!(paralysis))))
            {
                return;
            };
            if (isHitStunOrParalysis())
            {
                if (hitstun)
                {
                    m_actionShot = false;
                };
                if (paralysis)
                {
                    if (m_paralysis)
                    {
                        m_maxParalysisTime.reset();
                    };
                    m_paralysis = false;
                };
                this.m_controlFrames();
                if (((inState(CState.FLYING)) || (inState(CState.INJURED))))
                {
                    currentSpeed = Utils.calculateSpeed(m_xKnockback, m_yKnockback);
                    currentAngle = Utils.getAngleBetween(new Point(0, 0), new Point(m_xKnockback, m_yKnockback));
                    angle = this.calculateDI(currentAngle);
                    m_xKnockback = Utils.calculateXSpeed(currentSpeed, angle);
                    m_yKnockback = -(Utils.calculateYSpeed(currentSpeed, angle));
                    resetKnockbackDecay();
                };
            };
        }

        public function playReflectSound():void
        {
            this.playGlobalSound("reflected");
        }

        public function queueMove(atkName:String):void
        {
            var i:int;
            i = (this.m_staleMovesArr.length - 1);
            while (i > 0)
            {
                if (i > 0)
                {
                    this.m_staleMovesArr[i] = this.m_staleMovesArr[(i - 1)];
                };
                i--;
            };
            this.m_staleMovesArr[0] = atkName;
        }

        public function resetStaleMoves():void
        {
            var i:int;
            i = 0;
            while (i < this.m_staleMovesArr.length)
            {
                this.m_staleMovesArr[i] = null;
                i++;
            };
        }

        public function totalMoveDecay(atkName:String):Number
        {
            var s:Number;
            var lastIndex:Number;
            var i:int;
            if (ModeFeatures.hasFeature(ModeFeatures.IGNORE_STALE_DECAY, STAGEDATA.GameRef.GameMode))
            {
                return (1);
            };
            s = 0;
            lastIndex = 0;
            i = 0;
            while (i != -1)
            {
                i = this.m_staleMovesArr.indexOf(atkName, lastIndex);
                if (i >= 0)
                {
                    lastIndex = (i + 1);
                    s = (s + this.m_staleMoveVals[i]);
                };
            };
            if (s == 0)
            {
                return (1.05);
            };
            return (1 - s);
        }

        override public function reverse(pid:int, team_id:int, isForward:Boolean):Boolean
        {
            if (this.m_forceTimer <= 0)
            {
                if (inState(CState.ATTACKING))
                {
                    m_attack.IsForward = (!(m_attack.IsForward));
                };
                m_xSpeed = (m_xSpeed * -1);
                this.m_jumpSpeedBuffer = (this.m_jumpSpeedBuffer * -1);
                m_xKnockback = (m_xKnockback * -1);
                resetKnockbackDecay();
                this.m_flyingRight = (!(this.m_flyingRight));
                if (m_facingForward)
                {
                    m_faceLeft();
                }
                else
                {
                    m_faceRight();
                };
                if (((!(inState(CState.ATTACKING))) && (!(m_xSpeed == 0))))
                {
                    this.m_forceRight = m_facingForward;
                    this.m_forceTimer = 8;
                };
                return (true);
            };
            return (false);
        }

        public function calculateHitLag(knockback:Number, hitLagVal:Number):int
        {
            /*
            if (this.m_hitLagHack != Number.MAX_VALUE)
            {
                return (Utils.calculateHitlag(knockback, this.m_hitLagHack));
            };
            */
            return (Utils.calculateHitlag(knockback, hitLagVal));
        }

        override protected function validateBypass(attackObj:AttackDamage):Boolean
        {
            if (((attackObj.BypassGrabbed) && (inState(CState.CAUGHT))))
            {
                return (false);
            };
            if (((attackObj.BypassNonGrabbed) && (!(inState(CState.CAUGHT)))))
            {
                return (false);
            };
            if (((((attackObj.Owner as Projectile) && (attackObj.BypassNonLatched)) && (Projectile(attackObj.Owner).Latched)) && (Projectile(attackObj.Owner).LatchID == this)))
            {
                return (false);
            };
            return (true);
        }

        override public function validateHit(attackObj:AttackDamage, ignoreInvincible:Boolean=false, ignoreIntangible:Boolean=false):Boolean
        {
            if (((((((((!(super.validateHit(attackObj, ignoreInvincible, ignoreIntangible))) || (inState(CState.REVIVAL))) || (inState(CState.KIRBY_STAR))) || (this.m_standby)) || (inState(CState.BARREL))) || (((((inState(CState.CAUGHT)) && (!(attackObj.HasEffect))) && (this.m_grabberID > 0)) && (attackObj.Owner)) && (!(STAGEDATA.getCharacterByUID(this.m_grabberID).ID === attackObj.Owner.ID)))) || (this.m_usingSpecialAttack)) || ((((this.m_usingSpecialAttack) && (this.m_characterStats.SpecialType == 3)) && (m_attack.ExecTime > 1)) && (!((attackObj.Owner as Character) && (Character(attackObj.Owner).Caught()))))))
            {
                return (false);
            };
            return (true);
        }

        private function calculateDIOld(speed:Number, angle:Number):Number
        {
            var diangle:Number;
            var ctrlAngle:Number;
            var ctrlAngleCStick:Number;
            var combinedAngle:Number;
            var xs:Number;
            var ys:Number;
            var origX:Number;
            var origY:Number;
            if ((!(this.m_canDI)))
            {
                return (angle);
            };
            diangle = angle;
            ctrlAngle = Utils.getControlsAngle(this.getControls());
            ctrlAngleCStick = Utils.getControlsAngle({
                "UP":this.m_pressedControls.C_UP,
                "DOWN":this.m_pressedControls.C_DOWN,
                "LEFT":this.m_pressedControls.C_LEFT,
                "RIGHT":this.m_pressedControls.C_RIGHT
            });
            combinedAngle = (((ctrlAngle >= 0) && (ctrlAngleCStick >= 0)) ? (ctrlAngle + (ctrlAngleCStick / 2)) : ((ctrlAngle >= 0) ? ctrlAngle : ((ctrlAngleCStick >= 0) ? ctrlAngleCStick : -1)));
            if (((Utils.forceBase360((diangle - combinedAngle)) >= (180 - this.MAX_DI_CHANGE)) && (Utils.forceBase360((diangle - combinedAngle)) <= (180 + this.MAX_DI_CHANGE))))
            {
                return (diangle);
            };
            if (combinedAngle >= 0)
            {
                xs = ((speed * 0.325) * Math.cos(((combinedAngle * Math.PI) / 180)));
                ys = ((speed * 0.325) * Math.sin(((combinedAngle * Math.PI) / 180)));
                origX = (speed * Math.cos(((angle * Math.PI) / 180)));
                origY = (speed * Math.sin(((angle * Math.PI) / 180)));
                diangle = ((Math.atan2((origY + ys), (origX + xs)) * 180) / Math.PI);
            };
            return (diangle);
        }

        private function calculateDI(BaseAngle:Number):Number
        {
            var ctrlAngle:Number;
            var ctrlAngleCStick:Number;
            var DIAngle:Number;
            if (this.m_canDI)
            {
                ctrlAngle = Utils.getControlsAngle(this.getControls());
                ctrlAngleCStick = Utils.getControlsAngle({
                    "UP":this.m_pressedControls.C_UP,
                    "DOWN":this.m_pressedControls.C_DOWN,
                    "LEFT":this.m_pressedControls.C_LEFT,
                    "RIGHT":this.m_pressedControls.C_RIGHT
                });
                DIAngle = (((ctrlAngle >= 0) && (ctrlAngleCStick >= 0)) ? (ctrlAngle - ((ctrlAngle - ctrlAngleCStick) / 2)) : ((ctrlAngle >= 0) ? ctrlAngle : ((ctrlAngleCStick >= 0) ? ctrlAngleCStick : -1)));
                if (DIAngle >= 0)
                {
                    while ((BaseAngle - DIAngle) <= -180)
                    {
                        DIAngle = (DIAngle - 360);
                    };
                    while ((BaseAngle - DIAngle) >= 180)
                    {
                        DIAngle = (DIAngle + 360);
                    };
                    if ((BaseAngle - DIAngle) < -90)
                    {
                        return (BaseAngle + Math.min(((((BaseAngle - DIAngle) + 180) / 90) * this.MAX_DI_CHANGE), this.DI_CAP));
                    };
                    if ((BaseAngle - DIAngle) > 90)
                    {
                        return (BaseAngle - Math.min((-(((BaseAngle - DIAngle) - 180) / 90) * this.MAX_DI_CHANGE), this.DI_CAP));
                    };
                    return (BaseAngle - ((((BaseAngle - DIAngle) >= 0) ? 1 : -1) * Math.min(Utils.fastAbs((((BaseAngle - DIAngle) / 90) * this.MAX_DI_CHANGE)), this.DI_CAP)));
                };
                return (BaseAngle);
            };
            return (BaseAngle);
        }

        public function killAllSpeeds(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):void
        {
            if ((!(ignoreNormal)))
            {
                m_xSpeed = 0;
                m_ySpeed = 0;
            };
            if ((!(ignoreKnockback)))
            {
                m_xKnockback = 0;
                m_yKnockback = 0;
            };
        }

        override public function netXSpeed(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):Number
        {
            var xspeed:Number;
            xspeed = 0;
            if ((!(ignoreNormal)))
            {
                xspeed = (xspeed + m_xSpeed);
            };
            if ((!(ignoreKnockback)))
            {
                xspeed = (xspeed + m_xKnockback);
                if (((Main.FRAMERATE == 30) && (!(m_xKnockback == 0))))
                {
                    xspeed = (xspeed + (m_xKnockback - m_xKnockbackDecay));
                };
            };
            return (xspeed);
        }

        override public function netYSpeed(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):Number
        {
            var yspeed:Number;
            yspeed = 0;
            if ((!(ignoreNormal)))
            {
                yspeed = (yspeed + m_ySpeed);
            };
            if ((!(ignoreKnockback)))
            {
                yspeed = (yspeed + m_yKnockback);
                if (((Main.FRAMERATE == 30) && (!(m_yKnockback == 0))))
                {
                    yspeed = (yspeed + (m_yKnockback - m_yKnockbackDecay));
                };
            };
            return (yspeed);
        }

        public function getPoison():Object
        {
            return ({
                "damage":this.m_poisonIncrease,
                "interval":this.m_poisonIncreaseInterval.MaxTime,
                "length":this.m_poisonIncreaseTime.MaxTime,
                "remaining":(this.m_poisonIncreaseTime.MaxTime - this.m_poisonIncreaseTime.CurrentTime)
            });
        }

        public function setPoison(damage:int, interval:int=15, length:int=300):void
        {
            var existingPoisonDamage:Number;
            var eventualPoisonDamage:Number;
            existingPoisonDamage = 0;
            eventualPoisonDamage = 0;
            if (this.m_poisonIncrease > 0)
            {
                existingPoisonDamage = (this.m_poisonIncrease * Math.floor(((this.m_poisonIncreaseTime.MaxTime - this.m_poisonIncreaseTime.CurrentTime) / this.m_poisonIncreaseInterval.MaxTime)));
                eventualPoisonDamage = (damage * Math.floor((length / interval)));
            };
            if (damage === 0)
            {
                this.m_poisonIncreaseTime.reset();
                this.m_poisonIncrease = 0;
                toggleEffect(this.m_poisonEffect, false);
            }
            else
            {
                if (((existingPoisonDamage <= 0) || (eventualPoisonDamage > existingPoisonDamage)))
                {
                    this.m_poisonIncrease = damage;
                    this.m_poisonIncreaseInterval.MaxTime = interval;
                    this.m_poisonIncreaseTime.MaxTime = length;
                    this.m_poisonTintTimer.reset();
                    toggleEffect(this.m_poisonEffect, true);
                    this.m_poisonEffect.gotoAndStop(1);
                    this.m_poisonEffect.x = m_sprite.x;
                    this.m_poisonEffect.y = m_sprite.y;
                };
            };
        }

        public function isGrabbedByFinalSmash():Boolean
        {
            return ((((inState(CState.CAUGHT)) && (this.m_grabberID > 0)) && (STAGEDATA.getCharacterByUID(this.m_grabberID))) && (STAGEDATA.getCharacterByUID(this.m_grabberID).UsingFinalSmash));
        }

        override public function takeDamage(attackObj:AttackDamage, collisionHitBox:HitBoxSprite=null):Boolean
        {
            var tmpChar:Character;
            var grabbedDuringFinalSmash:Boolean;
            var attackedByFinalSmash:Boolean;
            var prevState:uint;
            var stacked:Boolean;
            var tempDamage:Number;
            var oldDamage:Number;
            var tempVelocity:Number;
            var tempKnockback:Number;
            var oldXVector:Number;
            var oldYVector:Number;
            var oldVelocity:Number;
            var flipSuperArmor:Boolean;
            var tmpHasEffect:Boolean;
            var tmpPower:Number;
            var tmpKB:Number;
            var sizeMultiplier:Number;
            var weight1Multiplier:Number;
            var wasInFlyingState:Boolean;
            var preDamage:Number;
            var preKBVelocity:Number;
            var preWindKnockbackSpeed:Number;
            var tmpLaunchResistance:Number;
            var tmpLaunchResistanceDiff:Number;
            var tmpHeavyArmor:Number;
            var angle:Number;
            var wasDizzy:Boolean;
            var wasPitfall:Boolean;
            var wasCrashLand:Boolean;
            var calculatedHitlag:Number;
            var previousHitStun:Number;
            var previousSelfHitStun:Number;
            var x_component:Number;
            var y_component:Number;
            var effect1MC:MovieClip;
            var tempMC:MovieClip;
            var extraX:Number;
            var extraY:Number;
            var appliedWind:Boolean;
            var effect2MC:MovieClip;
            if ((!(this.validateHit(attackObj, false, true))))
            {
                return (false);
            };
            tmpChar = null;
            grabbedDuringFinalSmash = ((this.isGrabbedByFinalSmash()) && (!(attackObj.Owner.UID === this.m_grabberID)));
            attackedByFinalSmash = ((((attackObj.Owner) && (attackObj.Owner is Character)) && (attackObj.Owner.inState(CState.ATTACKING))) && (Character(attackObj.Owner).AttackStateData.Frame === "special"));
            prevState = m_state;
            var i:int;
            stacked = true;
            tempDamage = 0;
            oldDamage = m_damage;
            tempVelocity = 0;
            tempKnockback = 0;
            oldXVector = m_xKnockback;
            oldYVector = m_yKnockback;
            oldVelocity = Utils.calculateSpeed(oldXVector, oldYVector);
            flipSuperArmor = false;
            tmpHasEffect = true;
            tmpPower = 0;
            tmpKB = 0;
            sizeMultiplier = ((attackObj.SizeStatus == 0) ? 1 : ((attackObj.SizeStatus > 0) ? 2 : 0.5));
            weight1Multiplier = ((this.m_isMetal) ? 2.8 : 1);
            wasInFlyingState = inState(CState.FLYING);
            if (((!(grabbedDuringFinalSmash)) && (!(attackedByFinalSmash))))
            {
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.FREEZE))
                {
                    attackObj.Freeze = 90;
                }
                else
                {
                    if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.EGG))
                    {
                        attackObj.Egg = true;
                    };
                };
            };
            var strengthAttacker:Character = this.getStrengthAttacker(attackObj);
            var victimStrength:Number = this.getStrengthScore();
            var attackerStrength:Number = strengthAttacker ? strengthAttacker.getStrengthScore() : 1.0;
            var strengthRatio:Number = StrengthSystem.getMatchupRatio(attackerStrength, victimStrength);
            var strengthMatchupArmored:Boolean = strengthAttacker != null && !attackObj.IsThrow &&
                !inState(CState.CAUGHT) && attackObj.Damage > 0 &&
                StrengthSystem.hasMatchupArmor(strengthRatio);
            var strengthDizzy:int = strengthMatchupArmored ? 0 : attackObj.Dizzy;
            var strengthDizzyBonus:int = strengthMatchupArmored ? 0 :
                this.getStrengthDizzy(attackObj, strengthAttacker, strengthRatio);
            var strengthDamageMultiplier:Number = 1.0;
            if (attackObj.Damage > 0)
            {
                strengthDamageMultiplier = StrengthSystem.getDamageTakenMultiplier(victimStrength);
                if (strengthAttacker)
                {
                    strengthDamageMultiplier *= StrengthSystem.getDamageDealtMultiplier(attackerStrength);
                    strengthDamageMultiplier *= StrengthSystem.getWeakAttackDamageMultiplier(strengthRatio);
                    if (!attackObj.IsThrow && attackObj.Owner === strengthAttacker &&
                        strengthAttacker.isStrengthPummel(this))
                    {
                        strengthDamageMultiplier *= StrengthSystem.getPummelMultiplier(strengthRatio);
                    };
                };
            };
            var strengthThrowMultiplier:Number = (attackObj.IsThrow && strengthAttacker) ?
                StrengthSystem.getThrowMultiplier(strengthRatio) : 1.0;
            var strengthHitstun:Number = (attackObj.Damage > 0) ? victimStrength : 1.0;
            preDamage = ((attackObj.Damage <= 0) ? 0 : Utils.calculateChargeDamage(attackObj));
            preKBVelocity = ((m_baseStats.Stamina > 0) ? Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), ((inState(CState.ATTACKING)) && ((currentStanceFrameIs("charging")) && (m_attack.AttackType === 1))), this.m_characterStats.DamageRatio, attackObj.AttackRatio)) : Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, preDamage, oldDamage, (this.m_characterStats.Weight1 * weight1Multiplier), ((inState(CState.ATTACKING)) && ((currentStanceFrameIs("charging")) && (m_attack.AttackType === 1))), this.m_characterStats.DamageRatio, attackObj.AttackRatio)));
            if (this.m_sizeStatus != 0)
            {
                preKBVelocity = (preKBVelocity * ((this.m_sizeStatus == 1) ? 0.75 : 1.5));
            };
            if (((HasStance) && (m_sprite.stance.heavyArmor)))
            {
                tmpHeavyArmor = m_sprite.stance.heavyArmor;
            };
            preWindKnockbackSpeed = Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, 0, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), false, 1, 1));
            tmpLaunchResistance = ((attackObj.BypassLaunchResistance) ? 0 : (((this.m_isMetal) && (attackObj.IsThrow)) ? 0 : (((inState(CState.ATTACKING)) && (m_attack.LaunchResistance > 0)) ? m_attack.LaunchResistance : ((this.m_characterStats.LaunchResistance > 0) ? this.m_characterStats.LaunchResistance : ((this.m_isMetal) ? 5 : 0)))));
            tmpLaunchResistanceDiff = ((tmpLaunchResistance > 0) ? (preKBVelocity - tmpLaunchResistance) : 0);
            tmpHeavyArmor = (((this.m_isMetal) && (attackObj.IsThrow)) ? 0 : ((tmpLaunchResistance > 0) ? -(tmpLaunchResistance) : this.m_characterStats.HeavyArmor));
            if ((((((m_paralysis) || ((((((inState(CState.CAUGHT)) && (this.m_grabberID >= 0)) && (attackObj.Owner)) && (attackObj.Owner.UID == this.m_grabberID)) && (STAGEDATA.getCharacterByUID(this.m_grabberID).Grabbed.indexOf(this) >= 0)) && (!(attackObj.Owner is Character)))) || (((((((inState(CState.CAUGHT)) && (this.m_grabberID >= 0)) && (attackObj.Owner)) && (!(attackObj.Owner.UID == this.m_grabberID))) && (STAGEDATA.getCharacterByUID(this.m_grabberID).Grabbed.indexOf(this) >= 0)) && (preKBVelocity < Character.HEAVY_KNOCKBACK_THRESHOLD)) && (!((STAGEDATA.getCharacterByUID(this.m_grabberID).UsingFinalSmash) && (STAGEDATA.getCharacterByUID(this.m_grabberID).SpecialType == 6))))) || (inState(CState.PITFALL))) && (!(attackObj.ForceTumbleFall))))
            {
                tmpHeavyArmor = -(Character.HEAVY_KNOCKBACK_THRESHOLD);
            };
            var strengthArmorThreshold:Number = StrengthSystem.getArmorThreshold(victimStrength);
            var strengthArmored:Boolean = !isIntangible() && (strengthMatchupArmored ||
                (!attackObj.IsThrow && !attackObj.BypassHeavyArmor && !inState(CState.CAUGHT) &&
                preDamage > 0 && strengthArmorThreshold > 0 &&
                preDamage * attackObj.StaleMultiplier * strengthDamageMultiplier <= strengthArmorThreshold));
            if (strengthArmored || (((((attackObj.Paralysis > 0) && (m_paralysis)) || (inState(CState.EGG))) || ((inState(CState.ATTACKING)) && (((m_attack.SuperArmor) && (!(attackObj.BypassSuperArmor))) || ((((!(m_attack.HeavyArmor == 0)) && (!(attackObj.BypassHeavyArmor))) && (!((attackObj.IsThrow) && (this.m_isMetal)))) && (((m_attack.HeavyArmor > 0) && (preDamage <= m_attack.HeavyArmor)) || ((m_attack.HeavyArmor < 0) && (preKBVelocity <= -(m_attack.HeavyArmor)))))))) || ((((!(tmpHeavyArmor == 0)) && (!(attackObj.BypassHeavyArmor))) && (!((attackObj.IsThrow) && (this.m_isMetal)))) && (((tmpHeavyArmor > 0) && (preDamage <= tmpHeavyArmor)) || ((tmpHeavyArmor < 0) && (preKBVelocity <= -(tmpHeavyArmor)))))))
            {
                if (strengthArmored || ((tmpLaunchResistance <= 0) || ((tmpLaunchResistance > 0) && (tmpLaunchResistanceDiff <= 0))))
                {
                    flipSuperArmor = true;
                    tmpHasEffect = attackObj.HasEffect;
                    tmpPower = attackObj.Power;
                    tmpKB = attackObj.KBConstant;
                    attackObj.Power = 0;
                    attackObj.KBConstant = 0;
                    attackObj.HasEffect = false;
                };
            };
            if (((attackObj.HasEffect) && (!(isIntangible()))))
            {
                if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                    "target":(((attackObj.Owner) && (attackObj.Owner.APIInstance)) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }))))
                {
                    if (flipSuperArmor)
                    {
                        attackObj.HasEffect = tmpHasEffect;
                        attackObj.Power = tmpPower;
                        attackObj.KBConstant = tmpKB;
                    };
                    return (false);
                };
                if ((((!(inState(CState.INJURED))) && (!(inState(CState.FLYING)))) && (!(inState(CState.CAUGHT)))))
                {
                    initDelayPlayback(false);
                };
                this.m_disableHurtFallOff = attackObj.DisableHurtFallOff;
                setBrightness(0);
                if ((!(this.m_human)))
                {
                    this.CPU.resetControlOverrides();
                };
                this.m_hitsReceivedCounter++;
                this.resetSmashTimers();
                this.m_usingSpecialAttack = false;
                angle = 0;
                if (this.m_grabbed.length > 0)
                {
                    this.grabReleaseOpponent();
                };
                if (attackObj.IsThrow)
                {
                    this.Uncapture();
                    this.unnattachFromGround();
                };
                this.m_hitLagStunTimer.reset();
                if (STAGEPARENT.getChildByName(("energy" + m_player_id)) != null)
                {
                    STAGEPARENT.removeChild(STAGEPARENT.getChildByName(("energy" + m_player_id)));
                };
                if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                {
                    this.setVisibility(true);
                };
                if (((((prevState === CState.CAUGHT) && (this.m_grabberID >= 0)) && (STAGEDATA.getCharacterByUID(this.m_grabberID))) && (!(grabbedDuringFinalSmash))))
                {
                    tmpChar = STAGEDATA.getCharacterByUID(this.m_grabberID);
                    if (tmpChar.Grabbed.indexOf(this) >= 0)
                    {
                        tmpChar.releaseOpponent(tmpChar.Grabbed.indexOf(this));
                        if ((((!(attackObj.IsThrow)) && (!(attackObj.Owner === tmpChar))) && (!(((attackObj.Owner is Projectile) && (Projectile(attackObj.Owner).getOwner() === tmpChar)) && (!(Projectile(attackObj.Owner).WasReversed))))))
                        {
                            tmpChar.grabRelease();
                        };
                    };
                };
                if (inState(CState.SHIELDING))
                {
                    this.m_deactivateShield();
                };
                this.m_smashDIAmount = (this.SDI_BASE * attackObj.SDIDistance);
                this.m_jumpStartup.reset();
                this.m_charIsFull = false;
                this.m_justReleased = false;
                if (inState(CState.LEDGE_HANG))
                {
                    this.unnattachFromLedge();
                };
                this.m_ledge = null;
                this.m_lastLedge = null;
                wasDizzy = inState(CState.DIZZY);
                this.m_dizzyTimer = 0;
                wasPitfall = inState(CState.PITFALL);
                toggleEffect(this.m_pitfallEffect, false);
                this.m_stunTimer = 0;
                this.m_sleepingTimer = 0;
                this.m_midAirJumpConstantTime.finish();
                if (m_attack.CancelSoundOnEnd)
                {
                    this.stopSoundID(this.m_lastSFX);
                    this.m_lastSFX = -1;
                };
                if (m_attack.CancelVoiceOnEnd)
                {
                    this.stopSoundID(this.m_lastVFX);
                    this.m_lastVFX = -1;
                };
                if (((inState(CState.ATTACKING)) && (m_attackData.getAttack(m_attack.Frame).ChargeRetain)))
                {
                    m_attackData.getAttack(m_attack.Frame).ChargeTime = 0;
                };
                if ((((inState(CState.ATTACKING)) && (!(m_collision.ground))) && (m_attack.DisableJump)))
                {
                    this.m_jumpCount = this.m_characterStats.MaxJump;
                };
                m_attack.Rocket = false;
                if (inState(CState.LEDGE_HANG))
                {
                };
                this.m_crouchFrame = -1;
                this.m_canWallTech = true;
                tempVelocity = 0;
                tempDamage = ((attackObj.Damage <= 0) ? 0 : Utils.calculateChargeDamage(attackObj));
                tempDamage = (tempDamage * attackObj.StaleMultiplier);
                tempDamage *= strengthDamageMultiplier;
                if (inState(CState.FROZEN))
                {
                    tempDamage = (tempDamage / 2);
                };
                if (((attackObj.Damage > 0) && (tempDamage <= 0)))
                {
                    tempDamage = 1;
                };
                if (tempDamage != 0)
                {
                    throbDamageCounter();
                };
                if ((!(STAGEDATA.GameEnded)))
                {
                    this.m_matchResults.DamageTaken = (this.m_matchResults.DamageTaken + tempDamage);
                };
                if (this.m_recoveryAmount > 0)
                {
                    this.m_recoveryAmount = (this.m_recoveryAmount - tempDamage);
                    if (this.m_recoveryAmount <= 0)
                    {
                        tempDamage = -(this.m_recoveryAmount);
                        this.m_recoveryAmount = 0;
                    }
                    else
                    {
                        tempDamage = 0;
                    };
                };
                if (this.m_characterStats.CanReceiveDamage)
                {
                    this.dealDamage(tempDamage);
                };
                this.m_kirbyDamageCounter = (this.m_kirbyDamageCounter - tempDamage);
                this.m_itemDamageCounter = (this.m_itemDamageCounter - tempDamage);
                if ((!(m_attack.DisableLastHitUpdate)))
                {
                    m_lastHitID = attackObj.PlayerID;
                    m_lastHitObject = attackObj;
                };
                if (m_lastHitID > 0)
                {
                    STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().DamageGiven = (STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().DamageGiven + tempDamage);
                    STAGEDATA.getPlayerByID(m_lastHitID).resetDroughtTimer();
                    if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.VAMPIRE))
                    {
                        STAGEDATA.getPlayerByID(m_lastHitID).recover((tempDamage / 2));
                    }
                    else
                    {
                        if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.VENGEANCE))
                        {
                            STAGEDATA.getPlayerByID(m_lastHitID).dealDamage((tempDamage / 2));
                            STAGEDATA.getPlayerByID(m_lastHitID).throbDamageCounter();
                        };
                    };
                };
                if (((((attackObj.Owner is Character) && (Character(attackObj.Owner).CharacterStats.FinalSmashMeter)) && (!(Character(attackObj.Owner).UsingFinalSmash))) && (!(Character(attackObj.Owner).TransformedSpecial))))
                {
                    Character(attackObj.Owner).FinalSmashMeterCharge = (Character(attackObj.Owner).FinalSmashMeterCharge + (tempDamage / 500));
                }
                else
                {
                    if ((((attackObj.Owner is Projectile) && (Projectile(attackObj.Owner).getOwner() is Character)) && (Character(Projectile(attackObj.Owner).getOwner()).CharacterStats.FinalSmashMeter)))
                    {
                        Character(Projectile(attackObj.Owner).getOwner()).FinalSmashMeterCharge = (Character(Projectile(attackObj.Owner).getOwner()).FinalSmashMeterCharge + (tempDamage / 500));
                    };
                };
                if (attackObj.AttackID != -1)
                {
                    stackAttackID(attackObj.AttackID);
                };
                this.m_smashDISelf = false;
                if (m_paralysis)
                {
                    this.stopActionShot(false, true);
                    startActionShot(StrengthSystem.scaleHitstun(Utils.calculateHitStun(attackObj.HitStun, tempDamage, attackObj.Shock, (prevState == CState.CROUCH)), strengthHitstun));
                }
                else
                {
                    startActionShot(StrengthSystem.scaleHitstun(Utils.calculateHitStun(attackObj.HitStun, tempDamage, attackObj.Shock, (prevState == CState.CROUCH)), strengthHitstun), attackObj.Paralysis);
                    this.m_lastHitStun = m_actionTimer;
                };
                this.checkDI();
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                {
                    tempKnockback = (m_damage * 1.1);
                }
                else
                {
                    if (this.m_characterStats.Stamina > 0)
                    {
                        tempKnockback = Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), ((inState(CState.ATTACKING)) && ((currentStanceFrameIs("charging")) && (m_attack.AttackType === 1))), this.m_characterStats.DamageRatio, attackObj.AttackRatio);
                    }
                    else
                    {
                        tempKnockback = Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, preDamage, oldDamage, (this.m_characterStats.Weight1 * weight1Multiplier), ((inState(CState.ATTACKING)) && ((currentStanceFrameIs("charging")) && (m_attack.AttackType === 1))), this.m_characterStats.DamageRatio, attackObj.AttackRatio);
                    };
                };
                if (inState(CState.FROZEN))
                {
                    tempKnockback = (tempKnockback / 4);
                };
                tempKnockback *= strengthThrowMultiplier;
                tempVelocity = ((tmpLaunchResistanceDiff > 0) ? tmpLaunchResistanceDiff : Utils.calculateVelocity(tempKnockback));
                if (tmpLaunchResistanceDiff > 0)
                {
                    tempVelocity *= strengthThrowMultiplier;
                };
                tempKnockback = ((tmpLaunchResistanceDiff > 0) ? Utils.calculateKnockbackFromVelocity(tempVelocity) : tempKnockback);
                if ((!(this.m_characterStats.CanReceiveKnockback)))
                {
                    tempVelocity = 0;
                };
                if (this.m_sizeStatus != 0)
                {
                    tempVelocity = (tempVelocity * ((this.m_sizeStatus == 1) ? 0.75 : 1.5));
                };
                wasCrashLand = inState(CState.CRASH_LAND);
                this.m_forceTumbleFall = ((!(inState(CState.CRASH_LAND))) && ((tempVelocity >= Character.HEAVY_KNOCKBACK_THRESHOLD) || (attackObj.ForceTumbleFall)));
                calculatedHitlag = this.calculateHitLag(tempKnockback, attackObj.HitLag);
                this.m_hitLag = (((this.m_hitLag <= 0) || (calculatedHitlag > this.m_hitLag)) ? calculatedHitlag : this.m_hitLag);
                if (this.m_forceTumbleFall)
                {
                    this.m_hitLagLandDelay.finish();
                };
                if (((tempVelocity < Character.HEAVY_KNOCKBACK_THRESHOLD) || (this.m_hitLag < Character.HEAVY_KNOCKBACK_HITLAG_THRESHOLD)))
                {
                    if ((!(attackObj.DisableHurtSound)))
                    {
                        if (((!(inState(CState.CAUGHT))) && (Utils.random() > 0.6)))
                        {
                            this.playCharacterSound("hurt");
                        };
                    };
                    if ((((!(inState(CState.FROZEN))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.STAMINA_KO)))))
                    {
                        this.setState(CState.INJURED);
                    };
                    if (attackObj.Power >= 1000)
                    {
                        CAM.shake(6);
                    };
                }
                else
                {
                    if ((!(attackObj.DisableHurtSound)))
                    {
                        if ((((!(inState(CState.CAUGHT))) && (!(inState(CState.FLYING)))) && (tempVelocity > 24)))
                        {
                            this.playCharacterSound("hurtBad");
                        }
                        else
                        {
                            this.playCharacterSound("hurt");
                        };
                    };
                    if ((!(inState(CState.FLYING))))
                    {
                        this.m_ricochetTimer.reset();
                        this.m_ricochetCount.reset();
                        this.m_ricochetX.finish();
                        this.m_ricochetY.finish();
                    };
                    if ((((!(inState(CState.FROZEN))) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))))
                    {
                        this.setState(CState.FLYING);
                    };
                    if (((m_damage >= 100) && (inState(CState.FLYING))))
                    {
                        this.m_crowdAwe = true;
                    };
                    if (((tempVelocity > 35) && (!(inState(CState.CAUGHT)))))
                    {
                        STAGEDATA.lightFlash(false);
                    };
                    CAM.shake(12);
                };
                if (((this.m_item) && ((this.m_itemDamageCounter <= 0) || (((tempVelocity >= Character.HEAVY_KNOCKBACK_THRESHOLD) && (inState(CState.FLYING))) && (Utils.random() < 0.25)))))
                {
                    this.dropItem(true);
                };
                if (attackObj.CamShake > 0)
                {
                    CAM.shake(attackObj.CamShake);
                };
                if (((SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.DRAMATIC)) && (tempVelocity > (Character.HEAVY_KNOCKBACK_THRESHOLD / 4))))
                {
                    previousHitStun = Utils.calculateHitStun(attackObj.HitStun, Utils.calculateChargeDamage(attackObj), attackObj.Shock, (prevState == CState.CROUCH));
                    previousSelfHitStun = Utils.calculateSelfHitStun(attackObj.SelfHitStun, Utils.calculateChargeDamage(attackObj));
                    attackObj.HitStun = (previousHitStun + (2 * previousHitStun));
                    attackObj.SelfHitStun = (previousSelfHitStun + (2 * previousSelfHitStun));
                    if ((attackObj.Owner is Character))
                    {
                        STAGEDATA.CamRef.addZoomFocus(attackObj.Owner.MC, attackObj.SelfHitStun);
                    };
                    STAGEDATA.CamRef.forceTarget();
                    startActionShot(StrengthSystem.scaleHitstun(attackObj.HitStun, strengthHitstun));
                    this.m_lastHitStun = m_actionTimer;
                };
                angle = Utils.calculateReversedAngle(Utils.calculateAttackDirection(attackObj, this), attackObj, this);
                if (m_collision.ground)
                {
                    if (((angle > 180) && (angle < 360)))
                    {
                        if ((!((attackObj.ForceTumbleFall) && (!(attackObj.MeteorBounce)))))
                        {
                            if (((angle >= 260) && (angle <= 280)))
                            {
                                this.m_hitLag = Math.round((this.m_hitLag * 1.2));
                                if ((((inState(CState.FLYING)) && (!(attackObj.IsThrow))) && (attackObj.MeteorSFX)))
                                {
                                    STAGEDATA.playSpecificSound(attackObj.MeteorSFX);
                                };
                            };
                            angle = (360 - angle);
                        };
                        this.attachGroundBounceEffect();
                    };
                };
                angle = Utils.forceBase360(angle);
                if ((((inState(CState.FLYING)) || (inState(CState.INJURED))) && (attackObj.HitStun == 0)))
                {
                    angle = this.calculateDI(angle);
                };
                this.m_canDI = attackObj.CanDI;
                if ((((((((((wasCrashLand) && (!(inState(CState.STAMINA_KO)))) && (inState(CState.INJURED))) && (tempDamage < 7)) && (attackObj.Pitfall <= 0)) && (attackObj.Sleep <= 0)) && (attackObj.Stun <= 0)) && (attackObj.Dizzy <= 0)) && (this.m_jabResets < 3)))
                {
                    this.initiateCrash();
                    this.m_forcedCrash = true;
                    this.m_jabResets++;
                    this.m_jabResetTimer.reset();
                    this.m_crashTimer.reset();
                    this.m_getUpTimer.reset();
                    this.stancePlayFrame(1);
                    x_component = Utils.calculateXSpeed(tempVelocity, angle);
                    y_component = -(Utils.calculateYSpeed(tempVelocity, angle));
                    x_component = (x_component / 2);
                    y_component = 0;
                    angle = Utils.getAngleBetween(new Point(0, 0), new Point(x_component, y_component));
                    tempVelocity = Utils.calculateSpeed(x_component, y_component);
                };
                if (((attackObj.Direction >= 250) && (attackObj.Direction <= 290)))
                {
                    if (m_collision.ground)
                    {
                        this.m_hitLagCanCancelWithJump = false;
                        this.m_hitLagCanCancelWithUpB = false;
                        tempVelocity = (tempVelocity * 0.8);
                    }
                    else
                    {
                        this.m_hitLagCanCancelWithJump = true;
                        this.m_hitLagCanCancelWithUpB = true;
                        this.m_hitLagCancelTimer.reset();
                    };
                }
                else
                {
                    this.m_hitLagCanCancelWithJump = false;
                    this.m_hitLagCanCancelWithUpB = false;
                };
                if (((((((!(m_collision.ground)) && (inState(CState.FLYING))) && (angle >= 200)) && (angle <= 340)) && (!(attackObj.IsThrow))) && (attackObj.MeteorSFX)))
                {
                    STAGEDATA.playSpecificSound(attackObj.MeteorSFX);
                };
                this.killAllSpeeds();
                if (((strengthDizzyBonus > 0) || (((!strengthMatchupArmored && strengthDizzy > 0)) && ((wasDizzy) || (!(m_collision.ground))))) && (!(this.m_characterStats.StatusEffectImmunity)))
                {
                    tempVelocity = 0;
                };
                applyKnockbackSpeed(tempVelocity, angle);
                if (((MenuController.debugConsole) && (MenuController.debugConsole.AttackStateCapture)))
                {
                    MenuController.debugConsole.writeTextData((((((((((((((((((((((((((((attackObj.AttackBoxName + ": { weight1: ") + (this.m_characterStats.Weight1 * weight1Multiplier)) + ", angle: ") + angle) + ", attackDamage: ") + attackObj.Damage) + ", receiverDamage: ") + oldDamage) + ", calculatedDamage: ") + tempDamage) + ", kbc: ") + attackObj.KBConstant) + ", power: ") + attackObj.Power) + ", weightKB: ") + attackObj.WeightKB) + ", knockback: ") + tempKnockback) + ", velocity: ") + tempVelocity) + ", hitlag: ") + this.m_hitLag) + ", chargetime: ") + attackObj.ChargeTime) + ", chargetime_max: ") + attackObj.ChargeTimeMax) + " }"));
                };
                if (((!(inState(CState.CAUGHT))) && (!(wasCrashLand))))
                {
                    if (Utils.fastAbs(m_xKnockback) > 0.01)
                    {
                        if ((((!(m_facingForward)) && (angle > 90)) && (angle < 270)))
                        {
                            m_faceRight();
                        }
                        else
                        {
                            if (((m_facingForward) && (((angle >= 0) && (angle < 90)) || ((angle > 270) && (angle <= 360)))))
                            {
                                m_faceLeft();
                            };
                        };
                    }
                    else
                    {
                        if (attackObj.IsForward)
                        {
                            m_faceLeft();
                        }
                        else
                        {
                            m_faceRight();
                        };
                    };
                };
                if (((((!(wasCrashLand)) && (!(inState(CState.STAMINA_KO)))) && ((m_collision.ground) && (m_yKnockback >= 0))) && (!((attackObj.ForceTumbleFall) && (!(attackObj.MeteorBounce))))))
                {
                    if (((((m_actionShot) && (!(m_paralysis))) && (inState(CState.FLYING))) && (!(grabbedDuringFinalSmash))))
                    {
                        this.m_forcedCrash = false;
                        this.setState(CState.CRASH_LAND);
                        this.stancePlayFrame("dead");
                        this.m_canWallTech = false;
                    };
                };
                if (((((((((((((!strengthMatchupArmored && attackObj.Pitfall > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(wasPitfall))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (m_collision.ground)) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.m_pitfallTimer = (attackObj.Pitfall + (0.6 * m_damage));
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds();
                    if ((((inState(CState.CAUGHT)) && (!(inState(CState.STAMINA_KO)))) && (this.m_grabberID >= 0)))
                    {
                        STAGEDATA.getCharacterByUID(this.m_grabberID).setState(CState.IDLE);
                    };
                    this.setState(CState.PITFALL);
                    this.stopActionShot();
                    toggleEffect(this.m_pitfallEffect, true);
                    this.m_pitfallEffect.x = m_sprite.x;
                    this.m_pitfallEffect.y = m_sprite.y;
                };
                if ((((((!(wasCrashLand)) && (m_yKnockback < 0)) && (m_collision.ground)) && (!(inState(CState.PITFALL)))) && (!(inState(CState.CAUGHT)))))
                {
                    this.unnattachFromGround();
                };
                this.m_canBounce = ((attackObj.MeteorBounce) && ((angle >= 200) && (angle <= 340)));
                this.m_hasBounced = false;
                if (attackObj.EffectSound != null)
                {
                    this.playGlobalSound(attackObj.EffectSound);
                };
                if (((((((((((((!strengthMatchupArmored && attackObj.Stun > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.setState(CState.STUNNED);
                    this.m_stunCancelTimer.reset();
                    this.m_stunTimer = attackObj.Stun;
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds(false, true);
                };
                if ((((((((((((((!strengthMatchupArmored && strengthDizzy > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!((wasDizzy) && (!(m_collision.ground))))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.setState(CState.DIZZY);
                    this.m_stunCancelTimer.reset();
                    this.m_dizzyTimer = (strengthDizzy + (0.6 * m_damage));
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds(false, true);
                    this.m_dizzyShield = (((attackObj.Owner) && (attackObj.Owner is Character)) && (Character(attackObj.Owner).UsingFinalSmash));
                };
                if (((((((((((!strengthMatchupArmored && attackObj.Freeze > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.freeze(true, attackObj.Freeze);
                };
                if (((((((((((((!strengthMatchupArmored && attackObj.Sleep > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.setState(CState.SLEEP);
                    this.m_stunCancelTimer.reset();
                    this.m_sleepingTimer = (attackObj.Sleep + (2 * m_damage));
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds(false, true);
                };
                if (((((((((((!strengthMatchupArmored && attackObj.Egg > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.egg(true);
                };
                if (((attackObj.Poison > 0) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.setPoison(attackObj.Poison, attackObj.PoisonInterval, attackObj.PoisonLength);
                };
                if (inState(CState.FROZEN))
                {
                    if (Utils.fastAbs(m_xKnockback) > 5)
                    {
                        m_xKnockback = ((m_xKnockback > 0) ? 5 : -5);
                    };
                    if (m_yKnockback > 10)
                    {
                        m_yKnockback = 10;
                    };
                };
                if ((((!(attackObj.EffectID == null)) && (!(attackObj.EffectID == null))) && (STAGEDATA.getQualitySettings().hit_effects)))
                {
                    effect1MC = attachHurtEffect(attackObj.EffectID, collisionHitBox, {
                        "scaleX":((0.25 + (0.75 * Math.min((attackObj.Damage / 16), 1))) * sizeMultiplier),
                        "scaleY":((0.25 + (0.75 * Math.min((attackObj.Damage / 16), 1))) * sizeMultiplier)
                    });
                    if (effect1MC)
                    {
                        effect1MC.rotation = ((attackObj.IsForward) ? (180 - angle) : -(angle));
                    };
                };
                if ((((this.m_characterStats.LinkageID == "kirby") && (!(this.m_currentPower == null))) && (this.m_kirbyDamageCounter <= 0)))
                {
                    this.playGlobalSound("kirby_losepower");
                    this.resetChargedAttacks();
                    m_attackData.resetCharges();
                    this.removeChargeGlow();
                    this.m_currentPower = null;
                    tempMC = STAGEDATA.attachEffectOverlay("kirby_powerstar");
                    if (HasHatBox)
                    {
                        m_sprite.stance.hatBox.visible = false;
                    };
                    tempMC.width = (tempMC.width * m_sizeRatio);
                    tempMC.height = (tempMC.height * m_sizeRatio);
                    if ((!(m_facingForward)))
                    {
                        tempMC.scaleX = (tempMC.scaleX * -1);
                    };
                    tempMC.x = OverlayX;
                    tempMC.y = (OverlayY - (10 * m_sizeRatio));
                };
                if (((inState(CState.INJURED)) || ((isHitStunOrParalysis()) && (!(wasCrashLand)))))
                {
                    if (attackObj.Shock)
                    {
                        this.resetRotation();
                        Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                        if (HasStance)
                        {
                            this.playHurtFrame("shock");
                        }
                        else
                        {
                            this.playHurtFrame();
                        };
                        this.m_shockEffectTimer.reset();
                    }
                    else
                    {
                        if (attackObj.Burn)
                        {
                            this.resetRotation();
                            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                            this.playHurtFrame();
                            this.m_burnSmokeTimer.reset();
                            if (this.m_burnSmoke.parent == null)
                            {
                                toggleEffect(this.m_burnSmoke, true);
                                this.m_burnSmoke.x = m_sprite.x;
                                this.m_burnSmoke.y = m_sprite.y;
                            };
                        }
                        else
                        {
                            if (attackObj.Darkness)
                            {
                                this.resetRotation();
                                Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                this.playHurtFrame();
                                this.m_darknessSmokeTimer.reset();
                                if (this.m_darknessSmoke.parent == null)
                                {
                                    toggleEffect(this.m_darknessSmoke, true);
                                    this.m_darknessSmoke.x = m_sprite.x;
                                    this.m_darknessSmoke.y = m_sprite.y;
                                };
                            }
                            else
                            {
                                if (attackObj.Aura)
                                {
                                    this.resetRotation();
                                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                    this.playHurtFrame();
                                    this.m_auraSmokeTimer.reset();
                                    if (this.m_auraSmoke.parent == null)
                                    {
                                        toggleEffect(this.m_auraSmoke, true);
                                        this.m_auraSmoke.x = m_sprite.x;
                                        this.m_auraSmoke.y = m_sprite.y;
                                    };
                                }
                                else
                                {
                                    this.resetRotation();
                                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                    if (((!(inState(CState.CRASH_LAND))) && (!(inState(CState.CRASH_GETUP)))))
                                    {
                                        this.playHurtFrame();
                                    };
                                };
                            };
                        };
                    };
                    this.updateItemHolding();
                };
                if (flipSuperArmor)
                {
                    attackObj.HasEffect = tmpHasEffect;
                    attackObj.Power = tmpPower;
                    attackObj.KBConstant = tmpKB;
                };
                if (m_yKnockback < 0)
                {
                    this.m_hasArced = false;
                }
                else
                {
                    this.m_hasArced = true;
                };
                if (((((this.m_forceTumbleFall) && (inState(CState.INJURED))) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))))
                {
                    this.setState(CState.FLYING);
                };
                if (((m_lastHitID > 0) && (Utils.fastAbs(tempVelocity) > STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().FastestPitch)))
                {
                    STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().FastestPitch = Utils.fastAbs(tempVelocity);
                };
                if (((Utils.fastAbs(tempVelocity) > this.m_matchResults.TopSpeed) && (!(STAGEDATA.GameEnded))))
                {
                    this.m_matchResults.TopSpeed = Utils.fastAbs(tempVelocity);
                };
                this.m_dustTimer.reset();
                this.m_dustTimer.MaxTime = this.calculateHitLag(tempKnockback, -0.9);
                this.m_injureFlashTimer.reset();
                setTint(0.8, 0.8, 0.8, 1, 51, 51, 51, 0);
                stacked = false;
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                {
                    extraX = Utils.calculateXSpeed(tempVelocity, angle);
                    extraY = -(Utils.calculateYSpeed(tempVelocity, angle));
                    m_xKnockback = (m_xKnockback + extraX);
                    m_yKnockback = extraY;
                    this.m_hitLag = calculatedHitlag;
                }
                else
                {
                    if ((((!(oldVelocity === 0)) && (attackObj.StackKnockback)) && (((m_knockbackStackingTimer.IsComplete) || (m_knockbackStacked)) || (attackObj.IgnoreKnockbackStackingTimer))))
                    {
                        stacked = true;
                        stackKnockback(tempVelocity, angle, oldXVector, oldYVector);
                        if (((tempVelocity >= Character.HEAVY_KNOCKBACK_THRESHOLD) || (this.m_hitLag >= Character.HEAVY_KNOCKBACK_HITLAG_THRESHOLD)))
                        {
                            if ((((!(inState(CState.FROZEN))) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))))
                            {
                                this.setState(CState.FLYING);
                            };
                        };
                    }
                    else
                    {
                        this.m_hitLag = calculatedHitlag;
                    };
                };
                m_knockbackStacked = true;
                resetKnockbackDecay();
                m_knockbackStackingTimer.reset();
                this.m_ricochetX.finish();
                this.m_ricochetY.finish();
                if (((MenuController.debugConsole) && (MenuController.debugConsole.KnockbackCapture)))
                {
                    MenuController.debugConsole.writeTextData((((((((((attackObj.AttackBoxName + ": { xKnockbackVelocity: ") + m_xKnockback) + ", yKnockbackVelocity: ") + m_yKnockback) + ", angle: ") + Utils.getAngleBetween(new Point(), new Point(m_xKnockback, m_yKnockback))) + ", stacked: ") + stacked) + " }"));
                };
                if (((m_lastHitID > 0) && (!(attackObj.Owner is Enemy))))
                {
                    if (((((STAGEDATA.getPlayerByID(m_lastHitID).getDamage() >= 100) && (inState(CState.FLYING))) && (Utils.random() > 0.5)) && (netSpeed() > 35)))
                    {
                        STAGEDATA.startCrowdChant(m_lastHitID);
                    };
                };
                if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.INVISIBLE))
                {
                    this.m_invisiblePulseCount = 8;
                    this.m_invisiblePulseToggle = true;
                    this.m_invisiblePulseTimer.reset();
                    this.m_invisiblePulseTimer.MaxTime = Utils.randomInteger(1, 8);
                };
                if ((((netSpeed(true) > CROWD_AWE_KNOCKBACK_THRESHOLD) && (inState(CState.FLYING))) && (!(wasInFlyingState))))
                {
                    STAGEDATA.playSpecificVoice("crowd_cheer");
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_HURT, {
                    "caller":this.APIInstance.instance,
                    "opponent":((attackObj.Owner) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }));
                if ((((attackObj.Burn) && (attackObj.Freeze <= 0)) && (inState(CState.FROZEN))))
                {
                    this.freeze(false);
                    attachEffect("freeze_break");
                };
                this.applyStrengthDizzy(strengthDizzyBonus);
                return (true);
            };
            if (strengthArmored || (((((((!(attackObj.HasEffect)) && (!(inState(CState.LEDGE_HANG)))) && (!(inState(CState.LEDGE_CLIMB)))) && (!(inState(CState.LEDGE_ROLL)))) && (!((inState(CState.ATTACKING)) && (m_attack.Frame == "ledge_attack")))) && (!((isIntangible()) && (attackObj.Damage > 0)))) && (!((this.m_characterStats.WindArmor > 0) && (preWindKnockbackSpeed <= this.m_characterStats.WindArmor)))))
            {
                if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                    "target":(((attackObj.Owner) && (attackObj.Owner.APIInstance)) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }))))
                {
                    if (flipSuperArmor)
                    {
                        attackObj.HasEffect = tmpHasEffect;
                        attackObj.Power = tmpPower;
                        attackObj.KBConstant = tmpKB;
                    };
                    return (false);
                };
                if (!strengthMatchupArmored)
                {
                    startActionShot(-1, attackObj.Paralysis);
                };
                this.m_windBoxHit = true;
                tempDamage = ((((attackObj.Damage <= 0) || (this.isInvincible())) || (isIntangible())) ? 0 : Utils.calculateChargeDamage(attackObj));
                tempDamage = (tempDamage * attackObj.StaleMultiplier);
                tempDamage *= strengthDamageMultiplier;
                if (inState(CState.FROZEN))
                {
                    tempDamage = (tempDamage / 2);
                };
                if (((attackObj.Damage > 0) && (tempDamage <= 0)))
                {
                };
                if (tempDamage != 0)
                {
                    throbDamageCounter();
                };
                if ((!(STAGEDATA.GameEnded)))
                {
                    this.m_matchResults.DamageTaken = (this.m_matchResults.DamageTaken + tempDamage);
                };
                if (this.m_recoveryAmount > 0)
                {
                    this.m_recoveryAmount = (this.m_recoveryAmount - tempDamage);
                    if (this.m_recoveryAmount <= 0)
                    {
                        tempDamage = -(this.m_recoveryAmount);
                        this.m_recoveryAmount = 0;
                    }
                    else
                    {
                        tempDamage = 0;
                    };
                };
                if (this.m_characterStats.CanReceiveDamage)
                {
                    this.dealDamage(tempDamage);
                };
                if ((!(m_attack.DisableLastHitUpdate)))
                {
                    m_lastHitID = attackObj.PlayerID;
                    m_lastHitObject = attackObj;
                };
                if (m_lastHitID > 0)
                {
                    STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().DamageGiven = (STAGEDATA.getPlayerByID(m_lastHitID).getMatchResults().DamageGiven + tempDamage);
                    STAGEDATA.getPlayerByID(m_lastHitID).resetDroughtTimer();
                    if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.VAMPIRE))
                    {
                        STAGEDATA.getPlayerByID(m_lastHitID).recover((tempDamage / 2));
                    }
                    else
                    {
                        if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.VENGEANCE))
                        {
                            STAGEDATA.getPlayerByID(m_lastHitID).dealDamage((tempDamage / 2));
                            STAGEDATA.getPlayerByID(m_lastHitID).throbDamageCounter();
                        };
                    };
                };
                if (attackObj.AttackID != -1)
                {
                    stackAttackID(attackObj.AttackID);
                };
                if (attackObj.EffectSound != null)
                {
                    this.playGlobalSound(attackObj.EffectSound);
                };
                appliedWind = false;
                if ((((((((!(inState(CState.LEDGE_HANG))) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.LEDGE_HANG)))) && (!(attackObj.Power == 0))) && (!(inState(CState.PITFALL)))) && (!((inState(CState.ATTACKING)) && (m_attack.IsThrow)))) && (!(inState(CState.CAUGHT)))))
                {
                    appliedWind = true;
                    angle = Utils.calculateReversedAngle(Utils.calculateAttackDirection(attackObj, this), attackObj, this);
                    if (m_collision.ground)
                    {
                        if (((angle > 180) && (angle < 360)))
                        {
                            angle = (360 - angle);
                        };
                    };
                    angle = Utils.forceBase360(angle);
                    tempKnockback = Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, 0, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), false, 1, 1);
                    if (inState(CState.FROZEN))
                    {
                        tempKnockback = (tempKnockback / 4);
                    };
                    tempVelocity = Utils.calculateVelocity(tempKnockback);
                    m_xKnockback = Utils.calculateXSpeed(tempVelocity, angle);
                    m_yKnockback = -(Utils.calculateYSpeed(tempVelocity, angle));
                    if (((MenuController.debugConsole) && (MenuController.debugConsole.AttackStateCapture)))
                    {
                        MenuController.debugConsole.writeTextData((((((((((((((((((((((((((((attackObj.AttackBoxName + " (wind): { weight1: ") + (this.m_characterStats.Weight1 * weight1Multiplier)) + ", angle: ") + angle) + ", attackDamage: ") + attackObj.Damage) + ", receiverDamage: ") + oldDamage) + ", calculatedDamage: ") + tempDamage) + ", kbc: ") + attackObj.KBConstant) + ", power: ") + attackObj.Power) + ", weightKB: ") + attackObj.WeightKB) + ", knockback: ") + tempKnockback) + ", velocity: ") + tempVelocity) + ", hitlag: ") + this.m_hitLag) + ", chargetime: ") + attackObj.ChargeTime) + ", chargetime_max: ") + attackObj.ChargeTimeMax) + " }"));
                    };
                    if (((m_collision.ground) && (m_yKnockback < -(Utils.calculateVelocity(20)))))
                    {
                        this.unnattachFromGround();
                    };
                    if (this.m_sizeStatus != 0)
                    {
                        tempVelocity = (tempVelocity * ((this.m_sizeStatus == 1) ? 0.75 : 1.5));
                    };
                    this.m_forceTumbleFall = attackObj.ForceTumbleFall;
                };
                if ((((((((((((((!(this.isInvincible())) && (!(isIntangible()))) && ((!strengthMatchupArmored && attackObj.Stun > 0))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    if (this.m_grabbed.length > 0)
                    {
                        this.grabReleaseOpponent();
                    };
                    this.setState(CState.STUNNED);
                    this.m_stunCancelTimer.reset();
                    this.m_stunTimer = attackObj.Stun;
                    this.resetRotation();
                    this.killAllSpeeds(false, true);
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                };
                if ((((((((((((((!(this.isInvincible())) && (!(isIntangible()))) && ((!strengthMatchupArmored && strengthDizzy > 0))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    if (this.m_grabbed.length > 0)
                    {
                        this.grabReleaseOpponent();
                    };
                    this.setState(CState.DIZZY);
                    this.m_stunCancelTimer.reset();
                    this.m_dizzyTimer = (strengthDizzy + (0.6 * m_damage));
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds(false, true);
                    this.m_dizzyShield = (((attackObj.Owner) && (attackObj.Owner is Character)) && (Character(attackObj.Owner).UsingFinalSmash));
                };
                if (((((((((((((!(this.isInvincible())) && (!(isIntangible()))) && ((!strengthMatchupArmored && attackObj.Freeze > 0))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    this.freeze(true, attackObj.Freeze);
                };
                if (((((((((((((!strengthMatchupArmored && attackObj.Sleep > 0)) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.BARREL)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    if (this.m_grabbed.length > 0)
                    {
                        this.grabReleaseOpponent();
                    };
                    this.setState(CState.SLEEP);
                    this.m_stunCancelTimer.reset();
                    this.m_sleepingTimer = (attackObj.Sleep + (2 * m_damage));
                    this.resetRotation();
                    this.killAllSpeeds(false, true);
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                };
                if (((((((((((((!(this.isInvincible())) && (!(isIntangible()))) && ((!strengthMatchupArmored && attackObj.Egg > 0))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    this.egg(true);
                };
                if ((((((((((((((!(this.isInvincible())) && (!(isIntangible()))) && ((!strengthMatchupArmored && attackObj.Pitfall > 0))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.PITFALL)))) && (!(inState(CState.SLEEP)))) && (!(inState(CState.EGG)))) && (m_collision.ground)) && (!(inState(CState.STAMINA_KO)))) && (!(grabbedDuringFinalSmash))) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    if (this.m_grabbed.length > 0)
                    {
                        this.grabReleaseOpponent();
                    };
                    if (((prevState === CState.CAUGHT) && (this.m_hitForceVisible)))
                    {
                        this.setVisibility(true);
                    };
                    if (((inState(CState.CAUGHT)) && (this.m_grabberID >= 0)))
                    {
                        STAGEDATA.getCharacterByUID(this.m_grabberID).setState(CState.IDLE);
                    };
                    this.setState(CState.PITFALL);
                    this.m_pitfallTimer = (attackObj.Pitfall + (0.6 * m_damage));
                    this.resetRotation();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.killAllSpeeds();
                    this.stopActionShot();
                    toggleEffect(this.m_pitfallEffect, true);
                    this.m_pitfallEffect.x = m_sprite.x;
                    this.m_pitfallEffect.y = m_sprite.y;
                };
                if (((((!(this.isInvincible())) && (!(isIntangible()))) && (attackObj.Poison > 0)) && (!(this.m_characterStats.StatusEffectImmunity))))
                {
                    this.setPoison(attackObj.Poison, attackObj.PoisonInterval, attackObj.PoisonLength);
                };
                if ((((!(attackObj.EffectID == null)) && (!(attackObj.EffectID == null))) && (STAGEDATA.getQualitySettings().hit_effects)))
                {
                    effect2MC = attachHurtEffect(((this.isInvincible()) ? "effect_cancel" : attackObj.EffectID), collisionHitBox, {
                        "scaleX":((0.25 + (0.75 * Math.min((attackObj.Damage / 16), 1))) * sizeMultiplier),
                        "scaleY":((0.25 + (0.75 * Math.min((attackObj.Damage / 16), 1))) * sizeMultiplier)
                    });
                    if (effect2MC)
                    {
                        effect2MC.rotation = ((attackObj.IsForward) ? (180 - angle) : -(angle));
                    };
                };
                if (flipSuperArmor)
                {
                    attackObj.HasEffect = tmpHasEffect;
                    attackObj.Power = tmpPower;
                    attackObj.KBConstant = tmpKB;
                };
                if (((((inState(CState.CAUGHT)) && (HasStance)) && (attackObj.PlayerID > 0)) && (this.m_grabberID == STAGEDATA.getPlayerByID(attackObj.PlayerID).UID)))
                {
                    if ((!((HasStance) && (Stance.currentLabel === "downed"))))
                    {
                        this.playHurtFrame();
                    };
                };
                stacked = false;
                if ((((!((oldXVector == 0) && (oldYVector == 0))) && (attackObj.StackKnockback)) && (appliedWind)))
                {
                    stacked = true;
                    stackKnockback(tempVelocity, angle, oldXVector, oldYVector);
                };
                resetKnockbackDecay();
                if (((MenuController.debugConsole) && (MenuController.debugConsole.KnockbackCapture)))
                {
                    MenuController.debugConsole.writeTextData((((((((((attackObj.AttackBoxName + ": { xKnockbackVelocity: ") + m_xKnockback) + ", yKnockbackVelocity: ") + m_yKnockback) + ", angle: ") + Utils.getAngleBetween(new Point(), new Point(m_xKnockback, m_yKnockback))) + ", stacked: ") + stacked) + " }"));
                };
                if (((((inState(CState.CAUGHT)) && (attackObj.Owner is Character)) && (attackObj.Owner.inState(CState.GRABBING))) && (Character(attackObj.Owner).Grabbed.indexOf(this) >= 0)))
                {
                    this.m_injureFlashTimer.reset();
                    setTint(0.8, 0.8, 0.8, 1, 51, 51, 51, 0);
                    throbDamageCounter();
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_WIND, {
                    "caller":this.APIInstance.instance,
                    "opponent":((attackObj.Owner) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }));
                if ((((attackObj.Burn) && (attackObj.Freeze <= 0)) && (inState(CState.FROZEN))))
                {
                    this.freeze(false);
                    attachEffect("freeze_break");
                };
                this.applyStrengthDizzy(strengthDizzyBonus);
                return (true);
            };
            if (flipSuperArmor)
            {
                attackObj.HasEffect = tmpHasEffect;
                attackObj.Power = tmpPower;
                attackObj.KBConstant = tmpKB;
            };
            return (false);
        }

        public function takeShieldDamage(attackObj:AttackDamage, collisionHitBox:HitBoxSprite=null):Boolean
        {
            var weight1Multiplier:Number;
            var preDamage:Number;
            var tempDamage:Number;
            var angle:Number;
            var pushBack:Number;
            var backwards:Boolean;
            var stunAmount:Number;
            if (((((((((((((!(attackObj)) || (this.isInvincible())) || (!(inState(CState.SHIELDING)))) || (this.m_standby)) || (this.m_usingSpecialAttack)) || (!(this.m_characterStats.CanReceiveHits))) || ((((this.m_usingSpecialAttack) && (this.m_characterStats.SpecialType == 3)) && (m_attack.ExecTime > 1)) && (!((attackObj.Owner as Character) && (Character(attackObj.Owner).Caught()))))) || (!(this.validateBypass(attackObj)))) || (!(validateOnlyAffects(attackObj)))) || (attackIDArrayContains(attackObj.AttackID))) || ((!(attackObj.HurtSelfShield)) && (attackObj.PlayerID == m_player_id))) || ((((!(attackObj.HurtSelfShield)) && (m_team_id == attackObj.TeamID)) && (m_team_id > 0)) && (!(STAGEDATA.TeamDamage)))))
            {
                return (false);
            };
            weight1Multiplier = ((this.m_isMetal) ? 2.8 : 1);
            preDamage = ((attackObj.Damage <= 0) ? 0 : Utils.calculateChargeDamage(attackObj));
            var preKBVelocity:Number = ((this.m_characterStats.Stamina > 0) ? Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), false, this.m_characterStats.DamageRatio, attackObj.AttackRatio)) : Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, preDamage, m_damage, (this.m_characterStats.Weight1 * weight1Multiplier), false, this.m_characterStats.DamageRatio, attackObj.AttackRatio)));
            tempDamage = 0;
            angle = 0;
            if (((this.m_shieldTimer >= this.m_shieldStartFrame) && (!(isIntangible()))))
            {
                if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                    "target":(((attackObj.Owner) && (attackObj.Owner.APIInstance)) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }))))
                {
                    return (false);
                };
                this.m_hitsReceivedCounter++;
                if ((!(m_attack.DisableLastHitUpdate)))
                {
                    m_lastHitID = attackObj.PlayerID;
                    m_lastHitObject = attackObj;
                };
                if (attackObj.AttackID != -1)
                {
                    stackAttackID(attackObj.AttackID);
                };
                tempDamage = Utils.calculateChargeDamage(attackObj, attackObj.ShieldDamage);
                tempDamage = (tempDamage * attackObj.StaleMultiplier);
                if (((tempDamage <= 0) && (attackObj.Damage > 0)))
                {
                    tempDamage = 1;
                };
		if(!HudMenu.PermanantShieldCPU || MultiplayerManager.Connected)
            {
               this.m_shieldPower -= tempDamage * 0.7 * 2;
            }
                if (((attackObj.HasEffect) || ((!(attackObj.HasEffect)) && (attackObj.Owner as Projectile))))
                {
                    if (this.m_shieldStartTimer < 1)
                    {
                        this.playGlobalSound("shieldhit_strong");
                        STAGEDATA.lightFlash(false);
                    }
                    else
                    {
                        this.playGlobalSound(attackObj.ShieldSound);
                    };
                };
                if ((!(this.PerfectShield)))
                {
                   // this.m_shieldPower = (this.m_shieldPower - ((tempDamage * 0.7) * 2));
                    angle = Utils.calculateAttackDirection(attackObj, this);
                    pushBack = Math.min(20, ((this.m_characterStats.Stamina > 0) ? (Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, 0, 0, (this.m_characterStats.Weight1 * weight1Multiplier), false, this.m_characterStats.DamageRatio, attackObj.AttackRatio))) : (Utils.calculateVelocity(Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, preDamage, m_damage, (this.m_characterStats.Weight1 * weight1Multiplier), false, this.m_characterStats.DamageRatio, attackObj.AttackRatio)))));
                    m_xKnockback = Utils.calculateXSpeed((pushBack * 0.35), angle);
                    m_yKnockback = 0;
                    if (((attackObj.ReversableAngle) && (attackObj.Direction >= 0)))
                    {
                        backwards = ((attackObj.Direction > 90) && (attackObj.Direction < 270));
                        if (((m_sprite.x < attackObj.XLoc) || (m_sprite.x > attackObj.XLoc)))
                        {
                            m_xKnockback = ((m_sprite.x > attackObj.XLoc) ? Utils.fastAbs(m_xKnockback) : -(Utils.fastAbs(m_xKnockback)));
                            if (backwards)
                            {
                                m_xKnockback = (m_xKnockback * -1);
                            };
                        };
                        angle = Utils.getAngleBetween(new Point(), new Point(m_xKnockback, m_yKnockback));
                    };
                    resetKnockbackDecay();
                };
                if (attackObj.HasEffect)
                {
                    attachEffect(((this.m_characterStats.CustomShield) ? "effect_cancel" : (this.m_shieldType + "_hit")), {
                        "x":m_sprite.x,
                        "y":(m_sprite.y - (((m_height / 3) * m_sizeRatio) * this.m_characterStats.ShieldScale)),
                        "absolute":true,
                        "scaleX":((this.PerfectShield) ? 1 : (0.5 * this.m_characterStats.ShieldScale)),
                        "scaleY":((this.PerfectShield) ? 1 : (0.5 * this.m_characterStats.ShieldScale))
                    });
                };
                if ((attackObj.Owner as Item))
                {
                    if (((!(Item(attackObj.Owner) == null)) && (!(Item(attackObj.Owner).Dead))))
                    {
                        if (((this.PerfectShield) && (Item(attackObj.Owner).CanBeReversed)))
                        {
                            Item(attackObj.Owner).reverse(m_player_id, m_team_id, (!(Item(attackObj.Owner).FacingForward)));
                        };
                    };
                };
                if ((attackObj.Owner as Projectile))
                {
                    if ((!(Projectile(attackObj.Owner).Dead)))
                    {
                        if (this.PerfectShield)
                        {
                            Projectile(attackObj.Owner).reverse(m_player_id, m_team_id, (!(Projectile(attackObj.Owner).FacingForward)));
                        };
                    };
                };
                this.m_smashDISelf = false;
                if (attackObj.HasEffect)
                {
                    stunAmount = Utils.calculateHitStun(attackObj.HitStun, tempDamage, attackObj.Shock, false);
                    if ((!(this.PerfectShield)))
                    {
					      if(GameMenu.HitStun && attackObj.HasEffect && !MultiplayerManager.Connected)
								  {
									 setBrightness(200);
								  }
								  Character.AIShieldGrabCPU = 1;	
                        this.m_shieldDelayTimer.reset();
                        this.m_shieldDelayTimer.MaxTime = Math.floor(((Math.round(((Utils.calculateChargeDamage(attackObj) + 4.45) / 2.235)) * attackObj.ShieldStunMultiplier) / 2));
                        this.m_lastHitStun = this.m_shieldDelayTimer.MaxTime;
                        startActionShot(stunAmount);
                    };
                };
                m_eventManager.dispatchEvent(new SSF2Event(((this.PerfectShield) ? SSF2Event.CHAR_POWER_SHIELD_HIT : SSF2Event.CHAR_SHIELD_HIT), {
                    "caller":this.APIInstance.instance,
                    "opponent":attackObj.Owner.APIInstance.instance,
                    "attackBoxData":attackObj.exportAttackDamageData()
                }));
                return (true);
            };
            return (false);
        }

        private function performGroundTech():void
        {
            this.killAllSpeeds(true, false);
            m_xKnockback = (m_xKnockback * 0.5);
            m_yKnockback = 0;
            resetKnockbackDecay();
            this.m_canTech = false;
            this.m_techReady = false;
            this.m_techTimer.reset();
            this.m_techDelay.reset();
            this.m_hitLag = -1;
            this.resetRotation();
            if (this.getMetalStatus())
            {
                STAGEDATA.playSpecificSound("metal_land_m");
            }
            else
            {
                STAGEDATA.playSpecificSound("tech_sfx");
            };
            if (this.m_heldControls.RIGHT != this.m_heldControls.LEFT)
            {
                this.initTechRoll(this.m_heldControls.RIGHT);
                this.setState(CState.TECH_ROLL);
            }
            else
            {
                this.setState(CState.TECH_GROUND);
            };
            this.m_smashDISelf = true;
        }

        private function performWallTech(ceiling:Boolean):void
        {
            this.setState(CState.IDLE);
            if (ceiling)
            {
                this.m_flyingUp = (!(this.m_flyingUp));
            }
            else
            {
                this.m_flyingRight = (!(this.m_flyingRight));
            };
            this.killAllSpeeds();
            this.m_canTech = false;
            this.m_techReady = false;
            this.m_techTimer.reset();
            this.m_techDelay.reset();
            if (this.getMetalStatus())
            {
                STAGEDATA.playSpecificSound("metal_land_m");
            }
            else
            {
                STAGEDATA.playSpecificSound("tech_sfx");
            };
            this.resetRotation();
            if (ceiling)
            {
                this.techEffect(0, -(m_height));
            }
            else
            {
                this.techEffect(((m_facingForward) ? (-(m_width) / 2) : (m_width / 2)), (m_height / 2));
            };
            this.m_justTechedTimer.reset();
        }

        private function techEffect(xoffset:Number=0, yoffset:Number=0):void
        {
            var tmpEff:MovieClip;
            tmpEff = STAGEDATA.attachEffectOverlay("tech_effect");
            tmpEff.scaleX = 0.5;
            tmpEff.scaleY = 0.5;
            tmpEff.x = (OverlayX + (xoffset * m_sizeRatio));
            tmpEff.y = (OverlayY + (yoffset * m_sizeRatio));
        }

        override protected function m_groundCollisionTest():void
        {
            var triggerGroundTouch:Boolean;
            var wasAttacking:Boolean;
            var wasOnGround:Boolean;
            var onGround:Boolean;
            triggerGroundTouch = false;
            wasAttacking = inState(CState.ATTACKING);
            wasOnGround = m_collision.ground;
            if (((((((((!(isHitStunOrParalysis())) && (!(inState(CState.LEDGE_HANG)))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.SCREEN_KO)))) && (!((this.m_usingSpecialAttack) && ((this.m_characterStats.SpecialType == 4) || (this.m_characterStats.SpecialType == 5))))))
            {
                if (inState(CState.CRASH_LAND))
                {
                    this.groundBounceCheck();
                }
                else
                {
                    if (((((inState(CState.FLYING)) && (m_collision.ground)) && (this.netYSpeed() >= 0)) && (!(isHitStunOrParalysis()))))
                    {
                        this.groundBounceCheck();
                    }
                    else
                    {
                        if ((((((inState(CState.INJURED)) && (m_collision.ground)) && (this.netYSpeed() >= 0)) && (this.m_hitLagStunTimer.IsComplete)) && (!(isHitStunOrParalysis()))))
                        {
                            this.setState(CState.IDLE);
                            m_yKnockback = 0;
                            this.resetRotation();
                        };
                    };
                };
                if (((m_collision.ground) && (!(this.netYSpeed() < 0))))
                {
                    attachToGround();
                }
                else
                {
                    if ((!(m_collision.ground)))
                    {
                        pushOutOfGround();
                    };
                };
                onGround = (!((m_currentPlatform = this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1))) == null));
                if (onGround)
                {
                    attachToGround();
                };
                if (((((!(m_collision.ground)) && (onGround)) && (this.netYSpeed() < 0)) || (inState(CState.LEDGE_HANG))))
                {
                    onGround = false;
                    m_currentPlatform = null;
                    m_collision.ground = false;
                };
                if ((((!(m_collision.ground)) && (onGround)) && (!(inState(CState.KIRBY_STAR)))))
                {
                    if (inState(CState.ATTACKING))
                    {
                        m_attack.HasLanded = true;
                    };
                    triggerGroundTouch = true;
                    attachToGround();
                    if ((((!(inState(CState.LEDGE_ROLL))) && (!(inState(CState.LEDGE_CLIMB)))) && (!((inState(CState.ATTACKING)) && (m_attack.Frame == "ledge_attack")))))
                    {
                        this.attachLandEffect();
                    };
                    this.updateItemHolding();
                    if (((((((((((((((((!(this.m_heldControls.LEFT)) && (!(this.m_heldControls.RIGHT))) && (!(inState(CState.ATTACKING)))) && (!(inState(CState.INJURED)))) && (!(inState(CState.FLYING)))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.FROZEN)))) && (!(inState(CState.STUNNED)))) && (!(inState(CState.DIZZY)))) && (!(inState(CState.CRASH_GETUP)))) && (!(inState(CState.CRASH_LAND)))) && (!(inState(CState.TUMBLE_FALL)))) && (!(inState(CState.EGG)))) && (!(inState(CState.KIRBY_STAR)))) && (!(inState(CState.LEDGE_ROLL)))))
                    {
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_LAND, {"caller":this.APIInstance.instance}));
                    };
                    this.groundBounceCheck();
                    if ((!(inState(CState.FLYING))))
                    {
                        m_ySpeed = 0;
                    };
                    m_yKnockback = 0;
                };
                if (((m_collision.ground) && (!(onGround))))
                {
                    if ((!(inState(CState.ATTACKING))))
                    {
                        if (m_xSpeed > this.m_characterStats.MaxJumpSpeed)
                        {
                            m_xSpeed = this.m_characterStats.MaxJumpSpeed;
                        }
                        else
                        {
                            if (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))
                            {
                                m_xSpeed = -(this.m_characterStats.MaxJumpSpeed);
                            };
                        };
                    };
                    if (inState(CState.PITFALL))
                    {
                        this.pitFallRelease();
                    };
                };
                m_collision.ground = onGround;
                if (m_collision.ground)
                {
                    this.m_glideReady = true;
                };
                this.testJumpCount();
                if (m_collision.ground)
                {
                    if ((!(this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1)))))
                    {
                        attachToGround();
                    };
                };
                if ((!(this.m_human)))
                {
                    updateWarningCollision();
                };
                if (m_collision.ground)
                {
                    if (inState(CState.DISABLED))
                    {
                        setBrightness(0);
                        this.setState(CState.HEAVY_LAND);
                    };
                };
                if (((m_collision.ground) && (inState(CState.AIR_DODGE))))
                {
                    this.turnOffInvincibility();
                };
                if (((((wasOnGround) && (!(m_collision.ground))) && (((inState(CState.IDLE)) || (inState(CState.CRASH_GETUP))) || (inState(CState.CRASH_LAND)))) && (inKnockback())))
                {
                    if (inState(CState.CRASH_GETUP))
                    {
                        this.setIntangibility(false);
                    };
                    if (inState(CState.IDLE))
                    {
                        this.setState(CState.JUMP_FALLING);
                    }
                    else
                    {
                        this.setState(CState.TUMBLE_FALL);
                    };
                };
                if ((((wasOnGround) && (!(m_collision.ground))) && (this.isLanding())))
                {
                    this.setState(CState.JUMP_FALLING);
                };
                if (((!(m_collision.ground)) && (inState(CState.SHIELDING))))
                {
                    this.m_deactivateShield();
                    this.setState(CState.TUMBLE_FALL);
                };
                if (((((((((((((inState(CState.IDLE)) || (this.isLanding())) || (inState(CState.WALK))) || (inState(CState.JUMP_RISING))) || (inState(CState.JUMP_MIDAIR_RISING))) || (inState(CState.JUMP_FALLING))) || (inState(CState.RUN))) || (inState(CState.DASH))) || (inState(CState.TURN))) || (inState(CState.SKID))) || (inState(CState.HOVER))) || (inState(CState.CROUCH))))
                {
                    this.checkGroundStateChange();
                };
            };
            if (((((!(m_collision.ground)) && (inState(CState.GRABBING))) && (!(inState(CState.ATTACKING)))) && (!(currentStanceFrameIs("tether")))))
            {
                this.grabReleaseOpponent();
                this.setState(CState.JUMP_FALLING);
            };
            if (((m_collision.ground) && (!(wasOnGround))))
            {
                if (inState(CState.STAMINA_KO))
                {
                    this.m_controlFrames();
                };
                this.clearControlsBuffer();
            };
            if (((wasOnGround) && (!(m_collision.ground))))
            {
                if (inState(CState.STAMINA_KO))
                {
                    this.m_controlFrames();
                };
                if (inState(CState.DIZZY))
                {
                    this.m_dizzyShield = false;
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_LEAVE, {"caller":this.APIInstance.instance}));
            };
            if (triggerGroundTouch)
            {
                if (((wasAttacking) && (!(m_attack.LinkFrames))))
                {
                    initDelayPlayback(true);
                    this.attackCollisionTest();
                    m_attackCollisionTestsPreProcessed = true;
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_TOUCH, {"caller":this.APIInstance.instance}));
            };
            if ((!(inState(CState.LAND))))
            {
                this.m_waveLand = false;
            }
            else
            {
                if (((this.m_waveLand) && (STAGEDATA.AirDodge.match(/vsolo|vdouble/))))
                {
                    if (((((m_xKnockback > 0) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && (this.m_heldControls.LEFT)) || (((m_xKnockback < 0) && (!(this.m_heldControls.LEFT == this.m_heldControls.RIGHT))) && (this.m_heldControls.RIGHT))))
                    {
                        this.decel_knockback();
                    };
                };
            };
        }

        public function touchingLowerWarningBounds(x:int, y:int):Boolean
        {
            var i:int;
            i = 0;
            i = 0;
            while (i < m_warningBounds_lower[0].length)
            {
                if (m_warningBounds_lower[0][i].hitTestPoint(x, y, true))
                {
                    return (true);
                };
                i++;
            };
            i = 0;
            while (i < m_warningBounds_lower[1].length)
            {
                if (m_warningBounds_lower[1][i].hitTestPoint(x, y, true))
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        public function touchingUpperWarningBounds(x:int, y:int):Boolean
        {
            var i:int;
            i = 0;
            i = 0;
            while (i < m_warningBounds_upper[0].length)
            {
                if (m_warningBounds_upper[0][i].hitTestPoint(x, y, true))
                {
                    return (true);
                };
                i++;
            };
            i = 0;
            while (i < m_warningBounds_upper[1].length)
            {
                if (m_warningBounds_upper[1][i].hitTestPoint(x, y, true))
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        public function calculateAICollision(xSpeed:Number, ySpeed:Number):void
        {
            m_collision.leftSide = ((((((xSpeed < 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord((((m_sprite.x + xSpeed) - 9) - (m_width / 2)), ((m_sprite.y + ySpeed) - 35))));
            m_collision.rightSide = ((((((xSpeed > 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord((((m_sprite.x + xSpeed) + 9) + (m_height / 2)), ((m_sprite.y + ySpeed) - 35))));
        }

        override public function m_attemptToMove(xSpeed:Number, ySpeed:Number):void
        {
            var i:int;
            var origLocation:Point;
            var hitGround:Platform;
            var hasHit:Boolean;
            var angle:Number;
            var bouncedOffGround:Boolean;
            var onGround:Boolean;
            var diagonal:Boolean;
            var diagonal2:Boolean;
            var divisions:int;
            var triggeredWallHit:Boolean;
            var desiredXPosition:Number;
            var stoppedX:Boolean;
            if (((inState(CState.STAR_KO)) || (inState(CState.SCREEN_KO))))
            {
                return;
            };
            if (inState(CState.PITFALL))
            {
                xSpeed = 0;
            };
            if ((!((xSpeed == 0) && (ySpeed == 0))))
            {
                i = 0;
                m_collision.leftSide = ((((((xSpeed < 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord(((m_sprite.x + xSpeed) - 11), ((m_sprite.y + ySpeed) - 35))));
                m_collision.rightSide = ((((((xSpeed > 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord(((m_sprite.x + xSpeed) + 11), ((m_sprite.y + ySpeed) - 35))));
                if (((((!(isHitStunOrParalysis())) && (!(inState(CState.LEDGE_ROLL)))) && (!(inState(CState.LEDGE_HANG)))) && (!(((m_collision.ground) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))))))
                {
                    origLocation = Location.clone();
                    hitGround = moveSprite(xSpeed, ySpeed);
                    hasHit = (!(hitGround == null));
                    angle = Utils.getAngleBetween(new Point(origLocation.x, origLocation.y), new Point(m_sprite.x, m_sprite.y));
                    if ((((hasHit) && (!((angle >= 225) && (angle <= 315)))) && (!((m_sprite.x == origLocation.x) && (m_sprite.y == origLocation.y)))))
                    {
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                            "caller":this.APIInstance.instance,
                            "left":((angle < 225) && (angle > 135)),
                            "right":(((angle < 45) && (angle >= 0)) || ((angle <= 360) && (angle > 315))),
                            "top":((angle >= 45) && (angle >= 135))
                        }));
                    };
                    if ((((m_collision.rightSide) && (xSpeed > 0)) || ((m_collision.leftSide) && (xSpeed < 0))))
                    {
                        m_sprite.x = origLocation.x;
                    };
                    bouncedOffGround = (this.netYSpeed() < 0);
                    if (((hasHit) && (ySpeed >= 0)))
                    {
                        this.m_groundCollisionTest();
                    };
                    bouncedOffGround = (!(bouncedOffGround == (this.netYSpeed() < 0)));
                    if ((((((hasHit) && (!(m_collision.ground))) && (ySpeed > 0)) && (inState(CState.FLYING))) && (this.netYSpeed() >= 0)))
                    {
                        onGround = (!((m_currentPlatform = this.testGroundWithCoord(m_sprite.x, (m_sprite.y + 1))) == null));
                        this.groundBounceCheck();
                    };
                    this.repositionGrabbedCharacter();
                    if ((((((((hasHit) && ((inState(CState.FLYING)) || (this.isRocketing()))) && (Utils.fastAbs(xSpeed) > 3)) && (STAGEDATA.Terrains.indexOf(hitGround) >= 0)) && (this.m_ricochetX.IsComplete)) && (this.m_ricochetY.IsComplete)) && (!(this.m_ricochetCount.IsComplete))))
                    {
                        if (((((this.m_techReady) && (!(isHitStunOrParalysis()))) && (this.m_canWallTech)) && (!(this.isRocketing()))))
                        {
                            this.performWallTech(false);
                        }
                        else
                        {
                            if (this.m_ricochetTimer.IsComplete)
                            {
                                this.m_ricochetX.reset();
                                this.m_ricochetCount.tick();
                                diagonal = false;
                                if (((testTerrainWithCoord(m_sprite.x, (m_sprite.y - m_height))) && (((m_xKnockback < 0) && (testTerrainWithCoord((m_sprite.x - (m_width / 2)), (m_sprite.y - m_height)))) || ((m_xKnockback > 0) && (testTerrainWithCoord((m_sprite.x + (m_width / 2)), (m_sprite.y - m_height)))))))
                                {
                                    this.m_ricochetY.reset();
                                    diagonal = true;
                                };
                                this.attachWallBounceEffect((m_xKnockback > 0), diagonal);
                                startActionShot(2);
                                this.m_hitLag = this.calculateHitLag(Utils.calculateKnockbackFromVelocity(Utils.getDistance(new Point(), new Point(m_xKnockback, m_yKnockback))), -0.9);
                            };
                        };
                    };
                    if ((((((((((((hasHit) && ((inState(CState.FLYING)) || (this.isRocketing()))) && (Utils.fastAbs(ySpeed) > 2)) && (STAGEDATA.Terrains.indexOf(hitGround) >= 0)) && (!(m_collision.ground))) && (ySpeed < 0)) && (this.netYSpeed() < 0)) && (!(bouncedOffGround))) && (this.m_ricochetX.IsComplete)) && (this.m_ricochetY.IsComplete)) && (!(this.m_ricochetCount.IsComplete))))
                    {
                        if (((((this.m_techReady) && (!(isHitStunOrParalysis()))) && (this.m_canWallTech)) && (!(this.isRocketing()))))
                        {
                            this.performWallTech(true);
                        }
                        else
                        {
                            if (this.m_ricochetTimer.IsComplete)
                            {
                                this.m_hasArced = false;
                                this.m_ricochetY.reset();
                                this.m_ricochetCount.tick();
                                diagonal2 = false;
                                if (((testTerrainWithCoord(m_sprite.x, (m_sprite.y - m_height))) && (((m_xKnockback > 0) && (testTerrainWithCoord((m_sprite.x + (m_width / 2)), (m_sprite.y - m_height)))) || ((m_xKnockback < 0) && (testTerrainWithCoord((m_sprite.x - (m_width / 2)), (m_sprite.y - m_height)))))))
                                {
                                    this.m_ricochetX.reset();
                                    diagonal2 = true;
                                };
                                this.attachCeilingBounceEffect((m_xKnockback > 0), diagonal2);
                                startActionShot(2);
                                this.m_hitLag = this.calculateHitLag(Utils.calculateKnockbackFromVelocity(Utils.getDistance(new Point(), new Point(m_xKnockback, m_yKnockback))), -0.9);
                            };
                        };
                    };
                }
                else
                {
                    if ((!(isHitStunOrParalysis())))
                    {
                        divisions = (((Utils.fastAbs(xSpeed) >= 10) || (Utils.fastAbs(ySpeed) >= 10)) ? 10 : 5);
                        triggeredWallHit = false;
                        desiredXPosition = (m_sprite.x + xSpeed);
                        stoppedX = false;
                        xSpeed = (xSpeed / divisions);
                        ySpeed = (ySpeed / divisions);
                        i = 0;
                        while (i < divisions)
                        {
                            m_collision.leftSide = ((((((xSpeed < 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord(((m_sprite.x + xSpeed) - this.m_characterStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_characterStats.KneeYOffset))));
                            m_collision.rightSide = ((((((xSpeed > 0) && (!(inState(CState.LEDGE_HANG)))) && (m_collision.ground)) && (!(inState(CState.FLYING)))) && (!(inState(CState.INJURED)))) && (testTerrainWithCoord(((m_sprite.x + xSpeed) + this.m_characterStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_characterStats.KneeYOffset))));
                            if ((((!(triggeredWallHit)) && (!(xSpeed == 0))) && ((m_collision.rightSide) || (m_collision.leftSide))))
                            {
                                triggeredWallHit = true;
                                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                                    "caller":this.APIInstance.instance,
                                    "left":m_collision.leftSide,
                                    "right":m_collision.rightSide,
                                    "top":false
                                }));
                            };
                            if (((ySpeed < 0) && (!(testTerrainWithCoord(m_sprite.x, (m_sprite.y + ySpeed))))))
                            {
                                m_sprite.y = (m_sprite.y + ySpeed);
                            };
                            if (((!(xSpeed == 0)) && (!((this.inPreventFallOffState()) && (this.willFallOffRange((m_sprite.x + xSpeed), m_sprite.y, 10))))))
                            {
                                m_sprite.x = (m_sprite.x + ((!(((m_collision.rightSide) && (xSpeed > 0)) || ((m_collision.leftSide) && (xSpeed < 0)))) ? xSpeed : 0));
                            }
                            else
                            {
                                stoppedX = true;
                            };
                            if (((ySpeed > 0) && (!(testTerrainWithCoord(m_sprite.x, (m_sprite.y + ySpeed))))))
                            {
                                m_sprite.y = (m_sprite.y + ySpeed);
                            };
                            if (((!(m_collision.leftSide)) && (!(m_collision.rightSide))))
                            {
                                attachToGround();
                            };
                            this.repositionGrabbedCharacter();
                            if ((((Utils.fastAbs(xSpeed) > 10) || (Utils.fastAbs(ySpeed) > 10)) && (runExtraHitTests(m_sprite.x, m_sprite.y))))
                            {
                                stoppedX = true;
                                break;
                            };
                            i++;
                        };
                        if (((((!(stoppedX)) && (!(xSpeed === 0))) && (!(testTerrainWithCoord(desiredXPosition, m_sprite.y)))) && (!(this.willFallOffRange(desiredXPosition, m_sprite.y, 10)))))
                        {
                            m_sprite.x = desiredXPosition;
                            attachToGround();
                        };
                    };
                };
                this.repositionEffects();
            };
        }

        private function repositionEffects():void
        {
            if (((!(this.m_chargeGlowHolderMC == null)) && (!(inState(CState.LEDGE_HANG)))))
            {
                this.m_chargeGlowHolderMC.x = m_sprite.x;
                this.m_chargeGlowHolderMC.y = m_sprite.y;
                if ((((m_sprite.parent) && (this.m_chargeGlowHolderMC.parent)) && (this.m_chargeGlowHolderMC.parent.getChildIndex(this.m_chargeGlowHolderMC) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_chargeGlowHolderMC);
                };
            };
            if (((this.HasFinalSmash) && (!(inState(CState.LEDGE_HANG)))))
            {
                this.m_fsGlowHolderMC.x = m_sprite.x;
                this.m_fsGlowHolderMC.y = m_sprite.y;
                if ((((m_sprite.parent) && (this.m_fsGlowHolderMC.parent)) && (this.m_fsGlowHolderMC.parent.getChildIndex(this.m_fsGlowHolderMC) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_fsGlowHolderMC);
                };
            };
        }

        override public function testGroundWithCoord(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            var tmpGround:Platform;
            i = 0;
            i = 0;
            while (((i < m_terrains.length) && ((((!(m_terrains[i].hitTestPoint(xpos, ypos, true))) || (m_terrains[i].fallthrough == true)) || (m_terrains[i].shouldIgnore(this))) || (m_selfPlatform == m_terrains[i]))))
            {
                i++;
            };
            if (((i < m_terrains.length) && (m_terrains[i].hitTestPoint(xpos, ypos, true))))
            {
                tmpGround = this.testPlatformWithCoord(xpos, ypos);
                if (tmpGround)
                {
                    return (tmpGround);
                };
                return (m_terrains[i]);
            };
            {
                i = 0;
                while (((i < m_platforms.length) && ((((!(m_platforms[i].hitTestPoint(xpos, ypos, true))) || (m_platforms[i].fallthrough == true)) || (m_platforms[i].shouldIgnore(this))) || (m_selfPlatform == m_platforms[i]))))
                {
                    i++;
                };
                if ((((((((i < m_platforms.length) && (m_platforms[i].hitTestPoint(xpos, ypos, true))) && ((this.m_fallthroughPlatform == null) || (!(m_platforms[i] === this.m_fallthroughPlatform)))) && (this.netYSpeed() >= 0)) && (!((inState(CState.ATTACKING)) && (m_attack.ForceFallThrough)))) && ((!(this.m_heldControls.DOWN)) || (!(((((this.m_heldControls.DOWN) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (!(m_collision.ground))) && (!(inState(CState.ATTACKING)))) && (!(m_platforms[i].noDropThrough == true)))))) && (!((((inState(CState.ATTACKING)) && (m_attack.Rocket)) && (this.m_rocketAngle > 0)) && (this.m_rocketAngle < 180)))))
                {
                    return (m_platforms[i]);
                };
                return (null);
            };
            return (null);
        }

        override public function testPlatformWithCoord(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            i = 0;
            {
                i = 0;
                while (((i < m_platforms.length) && ((((!(m_platforms[i].hitTestPoint(xpos, ypos, true))) || (m_platforms[i].fallthrough == true)) || (m_platforms[i].shouldIgnore(this))) || (m_selfPlatform == m_platforms[i]))))
                {
                    i++;
                };
                if (((((((((i < m_platforms.length) && (m_platforms[i].hitTestPoint(xpos, ypos, true))) && ((this.m_fallthroughPlatform == null) || (!(m_platforms[i] === this.m_fallthroughPlatform)))) && (this.netYSpeed() >= 0)) && (!((inState(CState.ATTACKING)) && (m_attack.ForceFallThrough)))) && ((!(this.m_heldControls.DOWN)) || (!(((((this.m_heldControls.DOWN) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (!(m_collision.ground))) && (!(inState(CState.ATTACKING)))) && (!(m_platforms[i].noDropThrough == true)))))) && (!((((inState(CState.ATTACKING)) && (m_attack.Rocket)) && (this.m_rocketAngle > 0)) && (this.m_rocketAngle < 180)))) && (!(((m_currentPlatform) && (!(m_currentPlatform === m_platforms[i]))) && (m_platforms.indexOf(m_currentPlatform) >= 0)))))
                {
                    return (m_platforms[i]);
                };
                return (null);
            };
            return (null);
        }

        override protected function testCoordCollision(x_pos:Number, y_pos:Number):Boolean
        {
            if ((((((!(m_currentPlatform == null)) && (m_currentPlatform.hitTestPoint(x_pos, y_pos, true))) && (!(m_currentPlatform.fallthrough == true))) && (!(m_currentPlatform.shouldIgnore(this)))) && (!((OnPlatform) && (this.netYSpeed() < 0)))))
            {
                return (true);
            };
            return (false);
        }

        private function testJumpCount():void
        {
            if (((m_collision.ground) && (!(inState(CState.TUMBLE_FALL)))))
            {
                if (((((this.m_crowdAwe) && (!(inState(CState.CRASH_LAND)))) && (!(inState(CState.CRASH_GETUP)))) && (this.m_jumpCount >= this.m_characterStats.MaxJump)))
                {
                    if (STAGEDATA.CrowdChantID < 0)
                    {
                        STAGEDATA.playSpecificVoice("brawl_almostdied");
                    };
                };
                this.resetJumps();
                this.m_midAirJumpConstantTime.finish();
                this.m_canHover = true;
                this.m_lastLedge = null;
                this.m_wallJumpCount = 0;
                this.m_wallStickTime.MaxTime = this.m_characterStats.WallStick;
                this.m_crowdAwe = false;
                this.m_tetherCount = 0;
                this.m_airDodgeCount = 0;
            };
        }

        private function triggerTaunts():void
        {
            if (((((!(m_lastHitID == m_player_id)) && (m_lastHitID > 0)) && (STAGEDATA.getPlayerByID(m_lastHitID))) && (!((m_team_id > 0) && (STAGEDATA.getPlayerByID(m_lastHitID).Team == m_team_id)))))
            {
                if (STAGEDATA.getPlayerByID(m_lastHitID).isCPU())
                {
                    STAGEDATA.getPlayerByID(m_lastHitID).CPU.triggerTaunt();
                };
            };
        }

        private function m_checkDeath():void
        {
            var i:int;
            var charsToKO:Vector.<Character>;
            var suffix:String;
            var tempMC:MovieClip;
            var padding:Number;
            i = 0;
            charsToKO = null;
            if (((((((((((!(inState(CState.DEAD))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.SCREEN_KO)))) && (!(inState(CState.BARREL)))) && (this.m_starKOTimer.IsComplete)) && (!(inState(CState.REVIVAL)))) && (STAGEDATA.DeathBounds)) && ((((m_sprite.x < STAGEDATA.DeathBounds.x) || (m_sprite.x > (STAGEDATA.DeathBounds.x + STAGEDATA.DeathBounds.width))) || ((((m_sprite.y < STAGEDATA.DeathBounds.y) && (!(STAGEDATA.DisableCeilingDeath))) && (!(inState(CState.GRABBING)))) && (((((((((inState(CState.FLYING)) || (inState(CState.INJURED))) || (m_collision.ground)) || (this.m_windBoxHit)) || (inState(CState.TUMBLE_FALL))) || (inState(CState.DIZZY))) || (inState(CState.STUNNED))) || (inState(CState.EGG))) || (inState(CState.FROZEN))))) || ((m_sprite.y > (STAGEDATA.DeathBounds.y + STAGEDATA.DeathBounds.height)) && (!(STAGEDATA.DisableFallDeath))))))
            {
                if (((((m_sprite.y < STAGEDATA.DeathBounds.y) && (!(this.m_usingSpecialAttack))) && (!(SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1)))) && (this.m_characterStats.CanStarKO)))
                {
                    charsToKO = new Vector.<Character>();
                    i = 0;
                    while (i < this.m_grabbed.length)
                    {
                        charsToKO.push(this.m_grabbed[i]);
                        i++;
                    };
                    this.releaseOpponent();
                    i = 0;
                    while (i < charsToKO.length)
                    {
                        if ((((!(charsToKO[0].inState(CState.STAR_KO))) && (!(charsToKO[0].inState(CState.SCREEN_KO)))) && (!(charsToKO[0].inState(CState.DEAD)))))
                        {
                            charsToKO[i].killCharacterStarKO();
                        };
                        i++;
                    };
                    this.triggerTaunts();
                    this.killCharacterStarKO();
                }
                else
                {
                    suffix = "";
                    if (((m_team_id > 0) && (!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode)))))
                    {
                        if (m_team_id == 1)
                        {
                            suffix = (suffix + "_p1");
                        };
                        if (m_team_id == 2)
                        {
                            suffix = (suffix + "_p4");
                        };
                        if (m_team_id == 3)
                        {
                            suffix = (suffix + "_p2");
                        };
                    }
                    else
                    {
                        if (this.m_human)
                        {
                            suffix = (suffix + ("_p" + m_player_id));
                        };
                    };
                    if (STAGEDATA.CamBounds)
                    {
                        tempMC = STAGEDATA.attachEffectOverlay(("deathMC" + suffix));
                        padding = 80;
                        if (m_sprite.x < STAGEDATA.CamBounds.x)
                        {
                            tempMC.rotation = 90;
                            tempMC.x = ((STAGEDATA.CamBounds.x + STAGE.x) - padding);
                            tempMC.y = (m_sprite.y + STAGE.y);
                        }
                        else
                        {
                            if (m_sprite.x > (STAGEDATA.CamBounds.x + STAGEDATA.CamBounds.width))
                            {
                                tempMC.rotation = 270;
                                tempMC.x = (((STAGEDATA.CamBounds.x + STAGEDATA.CamBounds.width) + STAGE.x) + padding);
                                tempMC.y = (m_sprite.y + STAGE.y);
                            }
                            else
                            {
                                if (m_sprite.y < STAGEDATA.CamBounds.y)
                                {
                                    tempMC.rotation = 180;
                                    tempMC.x = (m_sprite.x + STAGE.x);
                                    tempMC.y = (STAGEDATA.CamBounds.y + STAGE.y);
                                }
                                else
                                {
                                    tempMC.x = (m_sprite.x + STAGE.x);
                                    tempMC.y = ((STAGEDATA.CamBounds.y + STAGEDATA.CamBounds.height) + STAGE.y);
                                    if (ModeFeatures.hasFeature(ModeFeatures.SAVE_RECORDS, STAGEDATA.GameRef.GameMode))
                                    {
                                        if (["gangplankgalleon", "lakeofrage", "planetnamek", "fairyglade"].indexOf(STAGEDATA.GameRef.LevelData.stage) >= 0)
                                        {
                                            SaveData.Unlocks.waterKOs++;
                                        };
                                    };
                                };
                            };
                        };
                        tempMC.scaleX = 1.2;
                        tempMC.scaleY = 1.2;
                    };
                    STAGEDATA.CamRef.addTimedTargetPoint(new Point(m_sprite.x, m_sprite.y), this.m_respawnDelay.MaxTime);
                    if ((((STAGEDATA.CamBounds) && ((m_sprite.y < (STAGEDATA.CamBounds.y + 100)) || (m_sprite.y > ((STAGEDATA.CamBounds.y + STAGEDATA.CamBounds.height) - 160)))) && ((m_sprite.x < (STAGEDATA.CamBounds.x + 100)) || (m_sprite.x > ((STAGEDATA.CamBounds.x + STAGEDATA.CamBounds.width) - 100)))))
                    {
                        tempMC.rotation = Utils.forceBase360((90 - Utils.getAngleBetween(new Point(m_sprite.x, m_sprite.y), new Point((STAGEDATA.CamBounds.x + (STAGEDATA.CamBounds.width / 2)), (STAGEDATA.CamBounds.y + (STAGEDATA.CamBounds.height / 2))))));
                    };
                    this.playGlobalSound("deathExplosion");
                    this.triggerTaunts();
                    charsToKO = new Vector.<Character>();
                    i = 0;
                    while (i < this.m_grabbed.length)
                    {
                        charsToKO.push(this.m_grabbed[i]);
                        i++;
                    };
                    this.releaseOpponent();
                    i = 0;
                    while (i < charsToKO.length)
                    {
                        charsToKO[i].killCharacter(true, true);
                        i++;
                    };
                    this.killCharacter(true, true);
                };
            };
            if ((((((m_baseStats.Stamina > 0) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAMINA_KO)))) && (!(this.StandBy))) && (m_damage <= 0)))
            {
                if ((((STAGEDATA.GameRef.UsingTime) && (!(STAGEDATA.GameRef.UsingLives))) || ((STAGEDATA.GameRef.UsingLives) && (this.m_lives > 1))))
                {
                    if (this.m_grabbed.length > 0)
                    {
                        this.releaseOpponent();
                    };
                    if ((((inState(CState.CAUGHT)) && (this.m_grabberID > 0)) && (STAGEDATA.getCharacterByUID(this.m_grabberID))))
                    {
                        STAGEDATA.getCharacterByUID(this.m_grabberID).grabRelease();
                    };
                    this.playGlobalSound("deathExplosion");
                    attachEffect("stamina_ko_explosion", {"y":(-(this.m_characterStats.Height) / 2)});
                    this.killCharacter(true);
                }
                else
                {
                    if (this.m_grabbed.length > 0)
                    {
                        this.releaseOpponent();
                    };
                    if ((((inState(CState.CAUGHT)) && (this.m_grabberID > 0)) && (STAGEDATA.getCharacterByUID(this.m_grabberID))))
                    {
                        STAGEDATA.getCharacterByUID(this.m_grabberID).grabRelease();
                    };
                    if (inState(CState.EGG))
                    {
                        this.egg(false);
                    };
                    if (inState(CState.FROZEN))
                    {
                        this.freeze(false);
                    };
                    if (inState(CState.SHIELDING))
                    {
                        this.m_deactivateShield();
                    };
                    this.setVisibility(true);
                    this.hideAllEffects();
                    this.updateMatchStatistics();
                    this.loseLife();
                    if (inState(CState.STAMINA_KO))
                    {
                        this.playCharacterSound("starko");
                    };
                };
            };
            this.m_windBoxHit = false;
        }

        public function scorePoint(gain:Boolean):void
        {
            var tmpMC:MovieClip;
            if (m_healthBoxMC)
            {
                tmpMC = MovieClip(m_healthBoxMC.addChild(ResourceManager.getLibraryMC("scoreAnim_mc")));
                Utils.tryToGotoAndStop(tmpMC.score, (((gain) ? "p" : "m") + Utils.convertTeamToColor(m_player_id, m_team_id)));
                tmpMC.x = 19;
                tmpMC.y = -34;
            };
        }

        private function updateMatchStatistics():void
        {
            var currentCostumeObj:Object;
            var killerPlayer:Character;
            if ((!(STAGEDATA.GameEnded)))
            {
                if (m_lastHitID <= 0)
                {
                    this.m_matchResults.SelfDestructs++;
                    if (ModeFeatures.hasFeature(ModeFeatures.SAVE_RECORDS, STAGEDATA.GameRef.GameMode))
                    {
                        currentCostumeObj = ResourceManager.getCostume(this.m_characterStats.StatsName, Utils.getColorString(m_team_id), this.m_costume);
                        if ((((this.m_characterStats.StatsName === "ness") && (((currentCostumeObj) && (currentCostumeObj.metadata)) && (currentCostumeObj.metadata.ghost))) && (this.m_human)))
                        {
                            SaveData.Unlocks.ghostNessSDs++;
                        };
                    };
                    this.m_matchResults.KillerList.push(0);
                    this.m_matchResults.Score--;
                    if ((((STAGEDATA.GameRef.ScoreDisplay) && (m_healthBoxMC)) && (m_healthBoxMC.score)))
                    {
                        m_healthBoxMC.score.text = ("" + this.m_matchResults.Score);
                    };
                    if (STAGEDATA.GameRef.UsingTime)
                    {
                        this.scorePoint(false);
                    };
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_SELF_DESTRUCT, {"caller":this.APIInstance.instance}));
                }
                else
                {
                    if (m_lastHitID > 0)
                    {
                        killerPlayer = STAGEDATA.getPlayerByID(m_lastHitID);
                        this.m_matchResults.Falls++;
                        this.m_matchResults.KillerList.push(m_lastHitID);
                        this.m_matchResults.Score--;
                        if ((((STAGEDATA.GameRef.ScoreDisplay) && (m_healthBoxMC)) && (m_healthBoxMC.score)))
                        {
                            m_healthBoxMC.score.text = ("" + this.m_matchResults.Score);
                        };
                        if (STAGEDATA.GameRef.UsingTime)
                        {
                            this.scorePoint(false);
                        };
                        if (((!((m_team_id > 0) && (killerPlayer.Team == m_team_id))) && (!(m_lastHitID == m_player_id))))
                        {
                            killerPlayer.getMatchResults().KOs++;
                            killerPlayer.getMatchResults().KOList.push(m_player_id);
                            killerPlayer.getMatchResults().Score++;
                            if ((((STAGEDATA.GameRef.ScoreDisplay) && (killerPlayer.HealthBox)) && (killerPlayer.HealthBox.score)))
                            {
                                killerPlayer.HealthBox.score.text = ("" + killerPlayer.getMatchResults().Score);
                            };
                            killerPlayer.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.CHAR_KO_POINT, {
                                "caller":killerPlayer.APIInstance.instance,
                                "victim":this.APIInstance.instance
                            }));
                            if (((killerPlayer.getDamage() >= 100) && (Utils.random() > 0.25)))
                            {
                                STAGEDATA.startCrowdChant(killerPlayer.ID);
                            };
                            if (STAGEDATA.GameRef.UsingTime)
                            {
                                killerPlayer.scorePoint(true);
                            };
                        };
                    };
                };
            };
        }

        private function loseLife(deathBounds:Boolean=false):void
        {
            var teams:Array;
            var othersOnTeam:Boolean;
            var i:int;
            var totalTeams:Number;
            var w:*;
            var opponent:Character;
            var ffa:Boolean;
            var totalPlayers:Number;
            var k:*;
            if (this.m_usingLives)
            {
                this.m_lives--;
                if ((!(STAGEDATA.GameEnded)))
                {
                    this.m_matchResults.StockRemaining = this.m_lives;
                };
                this.updateLivesDisplay();
                if (this.m_lives <= 0)
                {
                    if (((m_baseStats.Stamina > 0) && (!(deathBounds))))
                    {
                        this.setState(CState.STAMINA_KO);
                    }
                    else
                    {
                        this.reset();
                        this.setState(CState.DEAD);
                        this.setVisibility(false);
                    };
                    if (m_healthBoxMC)
                    {
                        showHealthBoxes(false);
                    };
                    teams = new Array();
                    othersOnTeam = false;
                    i = 0;
                    while (i < STAGEDATA.Players.length)
                    {
                        opponent = STAGEDATA.Players[i];
                        if ((((((opponent) && (!(opponent == this))) && (!(opponent.Dead))) && (!(opponent.inState(CState.STAMINA_KO)))) && (!((opponent.Team == m_team_id) && (m_team_id > 0)))))
                        {
                            if ((((opponent.Team > 0) && (teams[("t" + opponent.Team)] == null)) || ((opponent.Team == -1) && (teams["t0"] == null))))
                            {
                                if (opponent.Team == -1)
                                {
                                    teams["t0"] = 1;
                                }
                                else
                                {
                                    teams[("t" + opponent.Team)] = 1;
                                };
                            }
                            else
                            {
                                if (opponent.Team == -1)
                                {
                                    teams["t0"]++;
                                }
                                else
                                {
                                    teams[("t" + opponent.Team)]++;
                                };
                            };
                        }
                        else
                        {
                            if ((((((opponent) && (!(opponent.Dead))) && (!(opponent.inState(CState.STAMINA_KO)))) && (opponent.Team == m_team_id)) && (m_team_id > 0)))
                            {
                                othersOnTeam = true;
                            };
                        };
                        i++;
                    };
                    totalTeams = 0;
                    for (w in teams)
                    {
                        totalTeams++;
                    };
                    if ((!(ModeFeatures.hasFeature(ModeFeatures.IS_CUSTOM, STAGEDATA.GameRef.GameMode))))
                    {
                        if (totalTeams == 1)
                        {
                            ffa = false;
                            totalPlayers = 0;
                            for (k in teams)
                            {
                                if (k == "t0")
                                {
                                    ffa = true;
                                    totalPlayers = teams[k];
                                };
                            };
                            if ((((ffa) && (totalPlayers <= 1)) && (!(STAGEDATA.GameEnded))))
                            {
                                if (ModeFeatures.hasFeature(ModeFeatures.ALLOW_NARRATOR_GAME, STAGEDATA.GameRef.GameMode))
                                {
                                    STAGEDATA.playSpecificVoice("narrator_game");
                                };
                                STAGEDATA.prepareEndGameCharacter(((STAGEDATA.GameRef.UsingStamina) && (!(deathBounds))));
                            }
                            else
                            {
                                if ((((!(ffa)) && (!(othersOnTeam))) && (!(STAGEDATA.GameEnded))))
                                {
                                    if (ModeFeatures.hasFeature(ModeFeatures.ALLOW_NARRATOR_GAME, STAGEDATA.GameRef.GameMode))
                                    {
                                        STAGEDATA.playSpecificVoice("narrator_game");
                                    };
                                    STAGEDATA.prepareEndGameCharacter(((STAGEDATA.GameRef.UsingStamina) && (!(deathBounds))));
                                };
                            };
                        }
                        else
                        {
                            if (((totalTeams == 0) && (!(STAGEDATA.GameEnded))))
                            {
                                if (ModeFeatures.hasFeature(ModeFeatures.ALLOW_NARRATOR_GAME, STAGEDATA.GameRef.GameMode))
                                {
                                    STAGEDATA.playSpecificVoice("narrator_game");
                                };
                                STAGEDATA.prepareEndGameCharacter(((STAGEDATA.GameRef.UsingStamina) && (!(deathBounds))));
                            };
                        };
                    };
                    if (((((!(ModeFeatures.hasFeature(ModeFeatures.IS_CUSTOM, STAGEDATA.GameRef.GameMode))) && (!(STAGEDATA.GameEnded))) && (!(STAGEDATA.EndTrigger))) && (ModeFeatures.hasFeature(ModeFeatures.ALLOW_NARRATOR_CPU_DEFEATED, STAGEDATA.GameRef.GameMode))))
                    {
                        STAGEDATA.playNarratorSpeech([((this.m_human) ? ("narrator_player" + m_player_id) : "narrator_cpu"), "narrator_defeated"]);
                    };
                };
            };
        }

        public function killCharacter(effects:Boolean=true, deathBounds:Boolean=false):void
        {
            var self:Vector.<MovieClip>;
            if ((!(inState(CState.DEAD))))
            {
                if (inState(CState.EGG))
                {
                    this.egg(false);
                };
                if (inState(CState.FROZEN))
                {
                    this.freeze(false);
                };
                if (inState(CState.SHIELDING))
                {
                    this.m_deactivateShield();
                };
                self = new Vector.<MovieClip>();
                self.push(m_sprite);
                if (STAGEDATA.GameRef.GameMode != Mode.TARGET_TEST)
                {
                    CAM.deleteTargets(self);
                };
                this.grabReleaseOpponent();
                this.setVisibility(false);
                this.hideAllEffects();
                if (effects)
                {
                    CAM.shake(10);
                    this.playFrame("fall");
                    this.playCharacterSound("dead");
                    if (this.m_pidHolderMC.parent)
                    {
                        this.m_pidHolderMC.parent.removeChild(this.m_pidHolderMC);
                    };
                };
                this.updateMatchStatistics();
                this.loseLife(deathBounds);
                if (STAGEDATA.CrowdChantID == m_player_id)
                {
                    STAGEDATA.stopCrowdChant();
                    STAGEDATA.playSpecificVoice("crowdcheer_end");
                };
                if (((!(inState(CState.DEAD))) && (!(STAGEDATA.GameRef.GameMode == Mode.TARGET_TEST))))
                {
                    this.reset();
                    m_sprite.x = this.m_playerSettings.x_respawn;
                    m_sprite.y = this.m_playerSettings.y_respawn;
                    this.setInvincibility(true);
                    this.setState(CState.REVIVAL);
                    if (((((this.m_characterStats.StatsName === "sandbag") && (!(this.m_human))) && (STAGEDATA.GameRef.GameMode === Mode.ONLINE_WAITING_ROOM)) && (STAGEDATA.CamBounds)))
                    {
                        this.StandBy = true;
                        this.StandBy = false;
                    };
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.CHAR_KO_DEATH, {"caller":this.APIInstance.instance}));
            };
        }

        public function killCharacterStarKO():void
        {
            var point:Point;
            var alreadyScreenKO:Boolean;
            var i:*;
            var tmpX:Number;
            var targets1:Vector.<MovieClip>;
            if ((!(inState(CState.DEAD))))
            {
                if (inState(CState.EGG))
                {
                    this.egg(false);
                };
                if (inState(CState.FROZEN))
                {
                    this.freeze(false);
                };
                this.resetMovement();
                this.m_recoveryAmount = 0;
                toggleEffect(this.m_healEffect, false);
                if (this.m_item2 != null)
                {
                    this.m_item2.destroy();
                    this.m_item2 = null;
                };
                if (this.m_item != null)
                {
                    this.m_item.destroy();
                    this.m_item = null;
                };
                toggleEffect(this.m_fsGlowHolderMC, false);
                this.playFrame("falling");
                if (this.m_pidHolderMC.parent)
                {
                    this.m_pidHolderMC.parent.removeChild(this.m_pidHolderMC);
                };
                this.releaseOpponent();
                this.setVisibility(false);
                point = new Point();
                this.m_starKOTimer.reset();
                alreadyScreenKO = false;
                i = 0;
                while (i < STAGEDATA.Players.length)
                {
                    if ((((STAGEDATA.Players[i]) && (!(STAGEDATA.Players[i] == this))) && (STAGEDATA.Players[i].ScreenKO)))
                    {
                        alreadyScreenKO = true;
                    };
                    i++;
                };
                if (((Utils.random() < 0.25) && (!(alreadyScreenKO))))
                {
                    this.m_starKOTimer.MaxTime = 60;
                    point = new Point((CAM.MainTerrain.x + (CAM.MainTerrain.width / 2)), CAM.MainTerrain.y);
                    point = STAGE.localToGlobal(point);
                    point = STAGEPARENT.globalToLocal(point);
                    this.m_screenKOHolder.x = point.x;
                    this.m_screenKOHolder.y = point.y;
                    this.m_screenKOHolder.gotoAndStop(1);
                    this.m_screenKOHolder.visible = true;
                    this.m_screenKO = true;
                    this.setState(CState.SCREEN_KO);
                    if (((this.m_starKOMC) && (this.m_starKOMC.parent)))
                    {
                        this.m_starKOMC.parent.removeChild(this.m_starKOMC);
                    };
                    this.m_starKOMC = null;
                    this.m_starKOMC = ResourceManager.getLibraryMC(this.m_characterStats.LinkageID);
                    this.m_starKOMC.uid = m_uid;
                    MovieClip(this.m_screenKOHolder.getChildByName("char")).addChild(this.m_starKOMC);
                    Utils.tryToGotoAndStop(this.m_starKOMC, "falling");
                    Utils.tryToGotoAndStop(this.m_starKOMC, "screenko");
                    if (((STAGEDATA.getQualitySettings().fullscreen_quality === 1) && (Main.isFullscreen)))
                    {
                        this.m_starKOMC.filters = [];
                    }
                    else
                    {
                        if (this.m_starKOMC)
                        {
                            applyPalette(this.m_starKOMC);
                        };
                    };
                    Utils.recursiveMovieClipPlay(this.m_starKOMC, false);
                    STAGEPARENT.addChild(this.m_screenKOHolder);
                }
                else
                {
                    this.m_starKOTimer.MaxTime = 90;
                    tmpX = m_sprite.x;
                    if (m_sprite.x < CAM.MainTerrain.x)
                    {
                        m_sprite.x = (CAM.MainTerrain.x + 150);
                    }
                    else
                    {
                        if (m_sprite.x > (CAM.MainTerrain.x + CAM.MainTerrain.width))
                        {
                            m_sprite.x = ((CAM.MainTerrain.x + CAM.MainTerrain.width) - 150);
                        }
                        else
                        {
                            m_sprite.x = (m_sprite.x + Utils.randomInteger(-50, 50));
                        };
                    };
                    point = new Point(m_sprite.x, (CAM.MainTerrain.y - (m_height * 0.5)));
                    m_sprite.y = CAM.MainTerrain.y;
                    point = STAGE.localToGlobal(point);
                    point = STAGEPARENT.globalToLocal(point);
                    this.m_starKOHolder.x = point.x;
                    this.m_starKOHolder.y = point.y;
                    this.m_starKOHolder.y = (this.m_starKOHolder.y + (m_height * 0.5));
                    this.m_starKOHolder.gotoAndStop(1);
                    this.m_starKOHolder.visible = true;
                    this.m_screenKO = false;
                    this.setState(CState.STAR_KO);
                    if (((this.m_starKOMC) && (this.m_starKOMC.parent)))
                    {
                        this.m_starKOMC.parent.removeChild(this.m_starKOMC);
                    };
                    this.m_starKOMC = null;
                    this.m_starKOMC = ResourceManager.getLibraryMC(this.m_characterStats.LinkageID);
                    this.m_starKOMC.uid = m_uid;
                    MovieClip(this.m_starKOHolder.getChildByName("char")).addChild(this.m_starKOMC);
                    Utils.tryToGotoAndStop(this.m_starKOMC, "falling");
                    Utils.tryToGotoAndStop(this.m_starKOMC, "starko");
                    applyPalette(this.m_starKOMC);
                    Utils.recursiveMovieClipPlay(this.m_starKOMC, false);
                    if (STAGEDATA.GameRef.LevelData.stage === "butterbuilding")
                    {
                        STAGEPARENT.addChildAt(this.m_starKOHolder, 0);
                    }
                    else
                    {
                        STAGEPARENT.addChildAt(this.m_starKOHolder, STAGE.parent.getChildIndex(STAGE));
                    };
                };
                if (((this.m_starKOTimer.MaxTime == 90) && (CAM.Mode == Vcam.NORMAL_MODE)))
                {
                    targets1 = new Vector.<MovieClip>();
                    targets1.push(m_sprite);
                    STAGEDATA.CamRef.addTargets(targets1);
                };
                this.m_respawnDelay.reset();
                this.setInvincibility(true);
            };
        }

        private function m_flipDirection():void
        {
            if ((((((((this.inFreeState((CFreeState.SWALLOWING | CFreeState.NON_IASA))) && (!(inState(CState.CROUCH)))) && (!(inState(CState.DASH)))) && (!(inState(CState.DASH_INIT)))) && (!(inState(CState.TURN)))) && (m_collision.ground)) && (!(this.isLandingOrSkiddingOrChambering()))))
            {
                if ((((this.m_heldControls.RIGHT) && (!(m_facingForward))) && (!(this.m_heldControls.LEFT))))
                {
                    m_faceRight();
                    m_facingForward = true;
                }
                else
                {
                    if ((((this.m_heldControls.LEFT) && (m_facingForward)) && (!(this.m_heldControls.RIGHT))))
                    {
                        m_faceLeft();
                        m_facingForward = false;
                    };
                };
            };
        }

        private function adjustTags(localPoint:Point):void
        {
            var rootLocation:Point;
            rootLocation = STAGE.localToGlobal(new Point(localPoint.x, localPoint.y));
            this.m_pidHolderMC.x = rootLocation.x;
            this.m_pidHolderMC.y = rootLocation.y;
        }

        private function m_checkBounds():void
        {
            var point1:Point;
            var point2:Point;
            var wasOutsideMainTerrain:Boolean;
            var width_right:Number;
            var width_left:Number;
            var height_top:Number;
            var height_bottom:Number;
            point1 = null;
            point2 = null;
            wasOutsideMainTerrain = this.m_outsideMainTerrain;
            width_right = (m_width / 2);
            width_left = (-(m_width) / 2);
            height_top = -(m_height);
            height_bottom = 0;
            width_right = (width_right * m_sizeRatio);
            height_top = (height_top * m_sizeRatio);
            width_right = (width_right * m_sizeRatio);
            height_bottom = (height_bottom * m_sizeRatio);
            this.m_outsideMainTerrain = ((STAGEDATA.CamBounds) && (((((m_sprite.x + width_right) < STAGEDATA.CamBounds.x) || ((m_sprite.x + width_left) > (STAGEDATA.CamBounds.x + STAGEDATA.CamBounds.width))) || ((m_sprite.y + height_top) < STAGEDATA.CamBounds.y)) || ((m_sprite.y + height_bottom) > (STAGEDATA.CamBounds.y + STAGEDATA.CamBounds.height))));
            this.m_outsideCameraBounds = ((STAGEDATA.CamBounds) && (((((OverlayX + width_right) < STAGEDATA.CamRef.CornerX) || ((OverlayX + width_left) > (STAGEDATA.CamRef.CornerX + STAGEDATA.CamRef.Width))) || ((OverlayY + height_bottom) < STAGEDATA.CamRef.CornerY)) || ((OverlayY + height_top) > (STAGEDATA.CamRef.CornerY + STAGEDATA.CamRef.Height))));
            if ((((((((!(this.m_pidHolderMC.parent)) && (!(inState(CState.REVIVAL)))) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.SCREEN_KO)))) && (!(STAGEDATA.StageEvent))) && (!(STAGEDATA.FreezeKeys))))
            {
                if ((((this.m_offScreenIndicatorEnabled) && (m_player_id > 0)) && ((this.m_outsideCameraBounds) || ((((this.m_showPlayerID) || (this.m_playerSettings.name)) && (!(inState(CState.DEAD)))) && (!(inState(CState.REVIVAL)))))))
                {
                    this.m_pidHolderMC.pid.text = (((this.m_showPlayerID) && (!(this.m_playerSettings.name))) ? ("P" + m_player_id) : "");
                    this.m_pidHolderMC.offScreenBubble.visible = false;
                    this.m_pidHolderMC.x = m_sprite.x;
                    this.m_pidHolderMC.y = ((m_sprite.y - m_height) - 20);
                    this.m_pidHolderMC.scaleX = 1;
                    this.m_pidHolderMC.scaleY = 1;
                    this.m_pidHolderMC.width = (this.m_pidHolderMC.width * m_sizeRatio);
                    this.m_pidHolderMC.height = (this.m_pidHolderMC.height * m_sizeRatio);
                    point1 = STAGE.localToGlobal(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                    point2 = STAGE.localToGlobal(new Point(m_sprite.x, (m_sprite.y - m_height)));
                    this.m_pidHolderMC.arrow.rotation = (270 - Utils.getAngleBetween(point1, point2));
                    STAGEDATA.TagsRef.addChild(this.m_pidHolderMC);
                    this.adjustTags(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                };
            };
            if (this.m_pidHolderMC.parent)
            {
                if (((!(this.m_outsideCameraBounds)) && ((STAGEDATA.StageEvent) || ((!(this.m_showPlayerID)) && (!(this.m_playerSettings.name))))))
                {
                    this.m_pidHolderMC.parent.removeChild(this.m_pidHolderMC);
                }
                else
                {
                    if ((((((OverlayX > STAGEDATA.CamRef.CornerX) && (OverlayX < (STAGEDATA.CamRef.CornerX + STAGEDATA.CamRef.Width))) && (OverlayY > STAGEDATA.CamRef.CornerY)) && (OverlayY < (STAGEDATA.CamRef.CornerY + STAGEDATA.CamRef.Height))) && (this.m_showPlayerID)))
                    {
                        this.m_pidHolderMC.x = m_sprite.x;
                        this.m_pidHolderMC.y = ((m_sprite.y - m_height) - 20);
                        point1 = STAGE.localToGlobal(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                        point2 = STAGE.localToGlobal(new Point(m_sprite.x, (m_sprite.y - m_height)));
                        this.m_pidHolderMC.arrow.rotation = (270 - Utils.getAngleBetween(point1, point2));
                        this.adjustTags(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                    }
                    else
                    {
                        this.m_pidHolderMC.x = m_sprite.x;
                        this.m_pidHolderMC.y = (m_sprite.y - (m_sizeRatio * 70));
                        if (OverlayX < ((STAGEDATA.CamRef.X - (STAGEDATA.CamRef.Width / 2)) + 25))
                        {
                            this.m_pidHolderMC.x = (((STAGEDATA.CamRef.X - (STAGEDATA.CamRef.Width / 2)) + 50) - STAGE.x);
                        }
                        else
                        {
                            if (OverlayX > ((STAGEDATA.CamRef.X + (STAGEDATA.CamRef.Width / 2)) - 25))
                            {
                                this.m_pidHolderMC.x = (((STAGEDATA.CamRef.X + (STAGEDATA.CamRef.Width / 2)) - 50) - STAGE.x);
                            };
                        };
                        if ((OverlayY - ((m_sizeRatio * m_height) / 2)) < ((STAGEDATA.CamRef.Y - (STAGEDATA.CamRef.Height / 2)) + 25))
                        {
                            this.m_pidHolderMC.y = (((STAGEDATA.CamRef.Y - (STAGEDATA.CamRef.Height / 2)) + 100) - STAGE.y);
                        }
                        else
                        {
                            if ((OverlayY - (m_sizeRatio * m_height)) > ((STAGEDATA.CamRef.Y + (STAGEDATA.CamRef.Height / 2)) - 25))
                            {
                                this.m_pidHolderMC.y = (((STAGEDATA.CamRef.Y + (STAGEDATA.CamRef.Height / 2)) - 25) - STAGE.y);
                            };
                        };
                        point1 = STAGE.localToGlobal(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                        point2 = STAGE.localToGlobal(new Point(m_sprite.x, (m_sprite.y - m_height)));
                        this.m_pidHolderMC.arrow.rotation = (270 - Utils.getAngleBetween(point1, point2));
                        this.adjustTags(new Point(this.m_pidHolderMC.x, this.m_pidHolderMC.y));
                    };
                };
            };
            if (((this.m_outsideMainTerrain) && (ModeFeatures.hasFeature(ModeFeatures.OFFSCREEN_DAMAGE, STAGEDATA.GameRef.GameMode))))
            {
                if ((((((!(wasOutsideMainTerrain)) || (this.m_standby)) || (inState(CState.STAR_KO))) || (inState(CState.SCREEN_KO))) || (inState(CState.DEAD))))
                {
                    this.m_offscreenDamageTimer.reset();
                };
                this.m_offscreenDamageTimer.tick();
                if (this.m_offscreenDamageTimer.IsComplete)
                {
                    this.damageSelf(1);
                    throbDamageCounter();
                    this.m_offscreenDamageTimer.reset();
                };
            };
        }

        private function setVar(varName:String, varValue:*):void
        {
            m_sprite[varName] = varValue;
        }

        public function setStanceVar(varName:String, varValue:*):void
        {
            if (HasStance)
            {
                m_sprite.stance[varName] = varValue;
            }
            else
            {
                trace(((("Stance var missing? " + varName) + "-") + varValue));
            };
        }

        override public function playFrame(n:String):void
        {
            var shouldUpdate:Boolean;
            var shouldPlay:Boolean;
            if (m_delayPlayback)
            {
                m_delayPlayBackAnimation = n;
                m_delayPlayBackFrame = null;
                return;
            };
            m_delayPlayBackAnimation = null;
            m_delayPlayBackFrame = null;
            if (HasStance)
            {
                m_sprite.stance.stop();
            };
            shouldUpdate = (!(currentFrameIs(n)));
            shouldPlay = ((!(m_sprite.xframe == null)) && (n == m_sprite.xframe));
            if ((!(currentFrameIs(n))))
            {
                m_currentAnimationID = n;
                m_previousAnimation = CurrentFrame;
                m_sprite.gotoAndStop(n);
            };
            if (shouldPlay)
            {
            };
            if (shouldUpdate)
            {
                this.updateItemHolding();
                this.updatePaletteSwap();
                refreshAttackID();
                this.checkReflection();
            };
        }

        override public function stancePlayFrame(n:*):void
        {
            if (m_delayPlayback)
            {
                m_delayPlayBackFrame = n;
                return;
            };
            if (((HasStance) && ((n is Number) || (n is String))))
            {
                m_sprite.stance.gotoAndStop(n);
                this.updatePaletteSwap();
                this.checkReflection();
            };
        }

        private function restartStance():void
        {
            if (HasStance)
            {
                m_sprite.stance.gotoAndStop(1);
            };
        }

        private function m_checkFinalForm():void
        {
            if (this.m_transformedSpecial)
            {
                if (this.m_transformTime >= this.m_transformLimit)
                {
                    this.endFinalForm();
                }
                else
                {
                    if (((!(currentFrameIs("special"))) && (!(this.m_characterStats.UnlimitedFinal))))
                    {
                        this.m_transformTime++;
                    };
                    if (m_healthBoxMC)
                    {
                        m_healthBoxMC.fsmeter.bar.scaleX = ((this.m_transformLimit - this.m_transformTime) / this.m_transformLimit);
                    };
                };
            };
        }

        private function resetChargedAttacks():void
        {
            var i:*;
            for (i in m_attack.ChargedAttacks)
            {
                m_attack.ChargedAttacks[i] = null;
            };
        }

        private function attackIsCharged(attackName:String):Boolean
        {
            var attack:AttackObject;
            attack = m_attackData.getAttack(attackName);
            if (m_attack.ChargedAttacks[attackName])
            {
                return (true);
            };
            if ((((attack) && (attack.LinkCharge)) && (m_attack.ChargedAttacks[attack.LinkCharge])))
            {
                return (true);
            };
            return (false);
        }

        private function setCharge(name:String, linkedAttack:String=null):void
        {
            m_attack.ChargedAttacks[name] = true;
            if (linkedAttack)
            {
                m_attack.ChargedAttacks[linkedAttack] = true;
            };
        }

        private function incrementHitsDealtCounter():void
        {
            this.m_hitsDealtCounter++;
        }

        private function incrementCharge(attackName:String, linkedAttack:String=null):void
        {
            m_attackData.getAttack(attackName).ChargeTime++;
            m_attack.ChargeTime = m_attackData.getAttack(attackName).ChargeTime;
            if (linkedAttack)
            {
                m_attackData.getAttack(linkedAttack).ChargeTime++;
            };
        }

        private function unsetCharge(name:String):void
        {
            var attack1:AttackObject;
            var attack2:AttackObject;
            attack1 = m_attackData.getAttack(name);
            attack2 = ((attack1) ? m_attackData.getAttack(attack1.LinkCharge) : null);
            if (attack1)
            {
                m_attack.ChargedAttacks[name] = false;
                attack1.ChargeTime = 0;
            };
            if (attack2)
            {
                m_attack.ChargedAttacks[attack2.Name] = false;
                attack2.ChargeTime = 0;
            };
        }

        private function releaseKirbyPower(effects:Boolean=false):void
        {
            var tempMC:MovieClip;
            if (this.m_currentPower != null)
            {
                m_attack.ChargedAttacks = new Object();
                m_attackData.resetCharges();
                this.removeChargeGlow();
                this.m_currentPower = null;
                if (HasHatBox)
                {
                    m_sprite.stance.hatBox.visible = false;
                };
                if (effects)
                {
                    tempMC = STAGEDATA.attachEffectOverlay("kirby_powerstar");
                    tempMC.width = (tempMC.width * m_sizeRatio);
                    tempMC.height = (tempMC.height * m_sizeRatio);
                    if ((!(m_facingForward)))
                    {
                        tempMC.scaleX = (tempMC.scaleX * -1);
                    };
                    tempMC.x = OverlayX;
                    tempMC.y = (OverlayY - (10 * m_sizeRatio));
                    this.playGlobalSound("kirby_losepower");
                };
            };
        }

        private function initTaunt():void
        {
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            this.setState(CState.TAUNT);
            if (((((!(this.m_heldControls.UP)) && (!(this.m_heldControls.DOWN))) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.RIGHT))))
            {
                if (Utils.hasLabel(Stance, "taunt_neutral"))
                {
                    this.stancePlayFrame("taunt_neutral");
                };
            }
            else
            {
                if (((this.m_heldControls.UP) || (this.m_heldControls.DOWN)))
                {
                    if (Utils.hasLabel(Stance, "taunt_updown"))
                    {
                        this.stancePlayFrame("taunt_updown");
                    };
                }
                else
                {
                    if (((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)))
                    {
                        if (Utils.hasLabel(Stance, "taunt_side"))
                        {
                            this.stancePlayFrame("taunt_side");
                        };
                    };
                };
            };
            this.m_crouchFrame = -1;
            if (this.m_characterStats.LinkageID == "kirby")
            {
                this.releaseKirbyPower(true);
            };
        }

        public function forceTaunt():void
        {
            if ((((((((!(inState(CState.DEAD))) && (!(inState(CState.STAMINA_KO)))) && (!(STAGEDATA.Paused))) && (!(STAGEDATA.FSCutscene))) && (STAGEDATA.FSCutins <= 0)) && (!(STAGEDATA.StageEvent))) && (!(this.m_standby))))
            {
                if (((((((this.inFreeState((CFreeState.ATTACKING | CFreeState.USING_FS))) && (!((this.m_usingSpecialAttack) && ((!(this.m_characterStats.SpecialType === 0)) || (currentFrameIs("special")))))) && (!(this.isNonInterruptableAttack(CFreeState.USING_FS)))) && (m_collision.ground)) && (!(this.isLandingOrSkiddingOrChambering()))) && (this.m_characterStats.CanTaunt)))
                {
                    this.initTaunt();
                };
            };
        }

        private function m_checkTaunt():void
        {
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return;
            };
            if (((!(m_collision.ground)) && (inState(CState.TAUNT))))
            {
                this.setState(CState.IDLE);
            };
            if (((((((this.m_pressedControls.TAUNT) && (this.inFreeState(CFreeState.ATTACKING))) && (!(this.isNonInterruptableAttack()))) && (m_collision.ground)) && (!(this.isLandingOrSkiddingOrChambering()))) && (this.m_characterStats.CanTaunt)))
            {
                this.initTaunt();
            };
        }

        private function isNonInterruptableAttack(additionalFlags:uint=0):Boolean
        {
            return (((inState((CState.ATTACKING | additionalFlags))) && (!(m_attack.AllowFullInterrupt))) && (!(m_attack.IASA)));
        }

        private function isInterruptableAttack(additionalFlags:uint=0):Boolean
        {
            return ((inState((CState.ATTACKING | additionalFlags))) && ((m_attack.AllowFullInterrupt) || (m_attack.IASA)));
        }

        private function getLastYPosition():void
        {
            this.m_lastYPosition = (m_sprite.y - this.netYSpeed());
        }

        public function updateMatchResults():void
        {
            if ((((!(inState(CState.DEAD))) && (!(inState(CState.STAMINA_KO)))) && (!(STAGEDATA.GameEnded))))
            {
                this.m_matchResults.SurvivalTime++;
                this.m_droughtTimer++;
                this.m_matchResults.DamageRemaining = m_damage;
            };
        }

        private function checkHitLag():void
        {
            if (((!(isHitStunOrParalysis())) && (this.m_hitLag > 0)))
            {
				if(!MultiplayerManager.Connected && GameMenu.HitStun)
                {
                    setTint(1.6,1,1,1,255,40,0,0);
                }
                this.m_hitLag--;
                this.m_hitLagStunTimer.tick();
                if (((((m_collision.ground) && (inState(CState.INJURED))) && (this.netYSpeed() >= 0)) && (!(this.m_hitLagLandDelay.IsComplete))))
                {
                    this.m_hitLag = 0;
                };
            }
            else
            {
				if(!inState(CState.SHIELDING) && !MultiplayerManager.Connected)
				{
				   setTint(1,1,1,1,0,0,0,0);
				}
                if (((!(isHitStunOrParalysis())) && (this.m_hitLag <= 0)))
                {
                    this.m_hitLagLandDelay.finish();
                };
            };
            if ((!(isHitStunOrParalysis())))
            {
                if ((((this.m_hitLag > 0) && (!(this.m_hitLagCancelTimer.IsComplete))) && (!(m_collision.ground))))
                {
                    if (((this.m_hitLagCanCancelWithJump) && (this.jumpIsPressed())))
                    {
                        this.m_hitLagCanCancelWithJump = false;
                    };
                    if ((((this.m_hitLagCanCancelWithUpB) && (this.m_heldControls.UP)) && (this.m_heldControls.BUTTON1)))
                    {
                        this.m_hitLagCanCancelWithUpB = false;
                    };
                    this.m_hitLagCancelTimer.tick();
                };
                if (((((this.m_hitLag > 0) && (this.m_hitLagCancelTimer.IsComplete)) && ((inState(CState.INJURED)) || (inState(CState.FLYING)))) && (!(m_collision.ground))))
                {
                    if (((((this.m_hitLagCanCancelWithUpB) && (this.m_heldControls.UP)) && (this.m_heldControls.BUTTON1)) && (!((this.HoldingItem) && (!(this.m_item.CanAttackWith))))))
                    {
                        m_yKnockback = 0;
                        resetKnockbackDecay();
                        this.setState(CState.IDLE);
                        this.Attack("b_up_air", 2);
                        this.m_hitLagCanCancelWithUpB = false;
                        this.clearControlsBuffer();
                    }
                    else
                    {
                        if ((((((((this.m_hitLagCanCancelWithJump) && (this.jumpIsPressed())) && (!(m_collision.ground))) && (!((this.HoldingItem) && (!(this.m_item.CanJumpWith))))) && (this.m_jumpCount < this.m_characterStats.MaxJump)) && ((this.m_jumpSpeedMidairDelay.IsComplete) || (this.m_characterStats.HoldJump))) && (!((this.m_jumpCount > 2) && (!(this.m_multiJumpDelay.IsComplete))))))
                        {
                            this.initMidairJump();
                            this.m_hitLagCanCancelWithJump = false;
                        };
                    };
                };
            };
        }

        private function positionEffects():void
        {
            var x_loc:Number;
            var y_loc:Number;
            x_loc = ((inState(CState.LEDGE_HANG)) ? m_sprite.x : m_sprite.x);
            y_loc = ((inState(CState.LEDGE_HANG)) ? (m_sprite.y + m_height) : m_sprite.y);
            if (this.m_poisonIncrease > 0)
            {
                this.m_poisonEffect.x = (x_loc - ((m_width / 3) * m_sizeRatio));
                this.m_poisonEffect.y = (y_loc - (m_height * m_sizeRatio));
                if ((((m_sprite.parent) && (this.m_poisonEffect.parent)) && (this.m_poisonEffect.parent.getChildIndex(this.m_poisonEffect) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_poisonEffect);
                };
            };
            if ((!(this.m_burnSmokeTimer.IsComplete)))
            {
                this.m_burnSmoke.x = x_loc;
                this.m_burnSmoke.y = (y_loc - ((m_height * m_sizeRatio) / 2));
                if ((((m_sprite.parent) && (this.m_burnSmoke.parent)) && (this.m_burnSmoke.parent.getChildIndex(this.m_burnSmoke) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_burnSmoke);
                };
            };
            if ((!(this.m_darknessSmokeTimer.IsComplete)))
            {
                this.m_darknessSmoke.x = x_loc;
                this.m_darknessSmoke.y = (y_loc - ((m_height * m_sizeRatio) / 2));
                if ((((m_sprite.parent) && (this.m_darknessSmoke.parent)) && (this.m_darknessSmoke.parent.getChildIndex(this.m_darknessSmoke) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_darknessSmoke);
                };
            };
            if ((!(this.m_auraSmokeTimer.IsComplete)))
            {
                this.m_auraSmoke.x = x_loc;
                this.m_auraSmoke.y = (y_loc - ((m_height * m_sizeRatio) / 2));
                if ((((m_sprite.parent) && (this.m_auraSmoke.parent)) && (this.m_auraSmoke.parent.getChildIndex(this.m_auraSmoke) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_auraSmoke);
                };
            };
            if (((this.m_warioWareIcon) && (!(this.m_warioWareIconTimer.IsComplete))))
            {
                this.m_warioWareIcon.x = x_loc;
                this.m_warioWareIcon.y = (y_loc - (m_height / 2));
                if ((((m_sprite.parent) && (this.m_warioWareIcon.parent)) && (this.m_warioWareIcon.parent.getChildIndex(this.m_warioWareIcon) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_warioWareIcon);
                };
            };
            if ((!(this.m_starmanInvincibilityTimer.IsComplete)))
            {
                this.m_starmanInvincibility.x = x_loc;
                this.m_starmanInvincibility.y = (y_loc - ((m_height * m_sizeRatio) / 2));
                if ((((m_sprite.parent) && (this.m_starmanInvincibility.parent)) && (this.m_starmanInvincibility.parent.getChildIndex(this.m_starmanInvincibility) < m_sprite.parent.getChildIndex(m_sprite))))
                {
                    Utils.swapDepths(m_sprite, this.m_starmanInvincibility);
                };
            };
            if (inState(CState.KIRBY_STAR))
            {
                this.m_kirbyStarMC.x = m_sprite.x;
                this.m_kirbyStarMC.y = m_sprite.y;
            };
            if (inState(CState.EGG))
            {
                this.m_yoshiEggMC.x = m_sprite.x;
                this.m_yoshiEggMC.y = m_sprite.y;
            };
            if (inState(CState.FROZEN))
            {
                this.m_freezeMC.x = m_sprite.x;
                this.m_freezeMC.y = m_sprite.y;
                this.m_freezeMC.rotation = m_sprite.rotation;
            };
            this.repositionEffects();
        }

        private function checkFrameControl():void
        {
            if (((inState(CState.JUMP_RISING)) || (inState(CState.JUMP_MIDAIR_RISING))))
            {
                if ((((m_ySpeed >= -5) && (getStanceVar("done", true))) && (!((this.m_midAirJumpConstantTime.MaxTime > 0) && (!(this.m_midAirJumpConstantTime.IsComplete))))))
                {
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.setState(CState.JUMP_FALLING);
                };
            };
            if (inState(CState.DIZZY))
            {
                if ((!(m_collision.ground)))
                {
                    this.playFrame("falling");
                }
                else
                {
                    if (this.m_strengthDizzyTimer > 0)
                    {
                        this.playFrame("dizzy");
                    }
                    else if (currentFrameIs("falling"))
                    {
                        this.initiateCrash();
                        this.m_forcedCrash = true;
                        this.m_crashTimer.reset();
                        this.m_getUpTimer.reset();
                    }
                    else
                    {
                        if ((!(currentFrameIs("crash"))))
                        {
                            this.playFrame("dizzy");
                        };
                    };
                };
            };
            if (((((((inState(CState.CRASH_LAND)) || (inState(CState.CRASH_GETUP))) || (inState(CState.ROLL))) || (inState(CState.TECH_ROLL))) || (inState(CState.TECH_GROUND))) && (!(m_collision.ground))))
            {
                if (((inState(CState.ROLL)) || (inState(CState.TECH_ROLL))))
                {
                    m_xSpeed = 0;
                };
                this.setState(CState.IDLE);
            };
            if (inState(CState.AIR_DODGE))
            {
                if (m_collision.ground)
                {
                    if ((!((!(m_currentPlatform == null)) && (!(m_currentPlatform.accel_friction == 1)))))
                    {
                        this.killAllSpeeds(false, true);
                    };
                    this.playFrame("land");
                    this.setState(CState.LAND);
                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                    this.m_waveLand = true;
                };
            };
            if (inState(CState.TUMBLE_FALL))
            {
                if (m_collision.ground)
                {
                    this.initiateCrash();
                };
            };
            if (((inState(CState.SHIELDING)) && (this.m_shieldTimer >= this.m_shieldStartFrame)))
            {
                this.m_resizeShield();
            };
        }

        override protected function checkTimers():void
        {
            var revivalWasFinished:Boolean;
            var i:int;
            var j:int;
            var originalJumpSpeed:Number;
            var bouncingX:Boolean;
            var bouncingY:Boolean;
            var max_amount:Number;
            var bits:int;
            var loss:int;
            var limit:int;
            super.checkTimers();
            this.m_jumpJustChambered = false;
            this.m_justFellThroughPlatform = false;
            if (inState(CState.CAUGHT))
            {
                m_knockbackStackingTimer.reset();
            };
            if ((!(this.m_invisibleTimer.IsComplete)))
            {
                this.m_invisibleTimer.tick();
                if (this.m_invisibleTimer.IsComplete)
                {
                    this.setVisibility(true);
                };
            };
            if (((!(inState(CState.CRASH_GETUP))) && (!(inState(CState.CRASH_LAND)))))
            {
                if ((!(this.m_jabResetTimer.IsComplete)))
                {
                    this.m_jabResetTimer.tick();
                    if (this.m_jabResetTimer.IsComplete)
                    {
                        this.m_jabResets = 0;
                    };
                };
            };
            if (((((this.m_characterStats.FinalSmashMeter) && (!(this.m_finalSmashMeterReady))) && (!(this.m_transformedSpecial))) && (!(this.m_usingSpecialAttack))))
            {
                this.FinalSmashMeterCharge = (this.FinalSmashMeterCharge + (1 / (((9 * 60) + 16) * 30)));
            };
            this.m_starKOTimer.tick();
            if ((!(this.m_injureFlashTimer.IsComplete)))
            {
                this.m_injureFlashTimer.tick();
                if (this.m_injureFlashTimer.IsComplete)
                {
                    setTint(1, 1, 1, 1, 0, 0, 0, 0);
                };
            };
            if (inState(CState.FLYING))
            {
                if (((this.m_ricochetX.IsComplete) && (this.m_ricochetY.IsComplete)))
                {
                    this.m_ricochetTimer.tick();
                };
                bouncingX = (!(this.m_ricochetX.IsComplete));
                bouncingY = (!(this.m_ricochetY.IsComplete));
                this.m_ricochetX.tick();
                this.m_ricochetY.tick();
                if (((bouncingX) && (this.m_ricochetX.IsComplete)))
                {
                    m_xKnockback = (m_xKnockback * -0.85);
                    if ((!((bouncingY) && (this.m_ricochetY.IsComplete))))
                    {
                        m_yKnockback = (m_yKnockback * 0.85);
                    };
                    if (m_xKnockback > 0)
                    {
                        faceRight();
                    }
                    else
                    {
                        if (m_xKnockback < 0)
                        {
                            faceLeft();
                        };
                    };
                    if (m_ySpeed > 0)
                    {
                        m_ySpeed = 0;
                    };
                    resetKnockbackDecay();
                };
                if (((bouncingY) && (this.m_ricochetY.IsComplete)))
                {
                    if ((!((bouncingX) && (this.m_ricochetX.IsComplete))))
                    {
                        m_xKnockback = (m_xKnockback * 0.85);
                    };
                    m_yKnockback = (m_yKnockback * -0.85);
                    m_ySpeed = 0;
                    resetKnockbackDecay();
                    if (this.isRocketing())
                    {
                        this.m_rocketAngle = Utils.forceBase360(-(this.m_rocketAngle));
                        this.fixRocketRotation();
                    };
                };
            };
            if (((inState(CState.TUMBLE_FALL)) || (inState(CState.JUMP_FALLING))))
            {
                if (this.m_heldControls.RIGHT != this.m_heldControls.LEFT)
                {
                    if (((this.m_heldControls.RIGHT) && (!(this.m_fallTiltRight))))
                    {
                        m_sprite.rotation = (m_sprite.rotation * 0.5);
                        if (Utils.fastAbs(m_sprite.rotation) <= 1)
                        {
                            this.resetRotation();
                            this.m_fallTiltTimer.reset();
                            this.m_fallTiltRight = true;
                        };
                    }
                    else
                    {
                        if (((this.m_heldControls.LEFT) && (this.m_fallTiltRight)))
                        {
                            m_sprite.rotation = (m_sprite.rotation * 0.5);
                            if (Utils.fastAbs(m_sprite.rotation) <= 1)
                            {
                                this.resetRotation();
                                this.m_fallTiltTimer.reset();
                                this.m_fallTiltRight = false;
                            };
                        }
                        else
                        {
                            this.m_fallTiltTimer.tick();
                            max_amount = ((inState(CState.TUMBLE_FALL)) ? 30 : 6);
                            if (inState(CState.JUMP_FALLING))
                            {
                                this.m_fallTiltTimer.tick();
                                this.m_fallTiltTimer.tick();
                            };
                            m_sprite.rotation = (max_amount * (this.m_fallTiltTimer.CurrentTime / this.m_fallTiltTimer.MaxTime));
                            if ((!(this.m_fallTiltRight)))
                            {
                                m_sprite.rotation = (m_sprite.rotation * -1);
                            };
                        };
                    };
                }
                else
                {
                    if (Utils.fastAbs(m_sprite.rotation) > 1)
                    {
                        m_sprite.rotation = (m_sprite.rotation * 0.5);
                        if (Utils.fastAbs(m_sprite.rotation) <= 1)
                        {
                            m_sprite.rotation = 0;
                        };
                    };
                };
            };
            if (((((m_player_id == 1) && (Main.DEBUG)) && (MenuController.debugConsole)) && (MenuController.debugConsole.ControlsCapture)))
            {
                bits = this.m_key.getControlsObject().controls;
                if (((this.m_attackControlsArr.length == 0) || ((this.m_attackControlsArr.length > 1) && (!(bits == this.m_attackControlsArr[(this.m_attackControlsArr.length - 2)])))))
                {
                    this.m_attackControlsArr.push(bits);
                    this.m_attackControlsArr.push(0);
                };
                this.m_attackControlsArr[(this.m_attackControlsArr.length - 1)]++;
            };
            this.m_fallthroughTimer.tick();
            if (((this.m_fallthroughTimer.IsComplete) || (m_ySpeed < 0)))
            {
                this.m_fallthroughTimer.finish();
                this.m_fallthroughPlatform = null;
            };
            if ((!(this.m_starmanInvincibilityTimer.IsComplete)))
            {
                this.m_starmanInvincibilityTimer.tick();
                Utils.advanceFrame(this.m_starmanInvincibility);
                if (this.m_starmanInvincibilityTimer.IsComplete)
                {
                    toggleEffect(this.m_starmanInvincibility, false);
                    setBrightness(0);
                };
            };
            revivalWasFinished = this.m_revivalInvincibility.IsComplete;
            this.m_revivalInvincibility.tick();
            if ((((this.m_revivalInvincibility.IsComplete) && (!(revivalWasFinished))) && (this.m_starmanInvincibilityTimer.IsComplete)))
            {
                setBrightness(0);
            };
            i = 0;
            j = 0;
            if (this.m_shieldTimer >= this.m_shieldStartFrame)
            {
                this.m_shieldStartTimer++;
            };
            this.m_getUpTimer.tick();
            this.m_crashTimer.tick();
            if (inState(CState.CRASH_LAND))
            {
                if (((this.m_getUpTimer.IsComplete) || (((this.m_pressedControls.UP) || (this.m_forcedCrash)) && (this.m_crashTimer.IsComplete))))
                {
                    this.setState(CState.CRASH_GETUP);
                    this.stancePlayFrame("getup");
                }
                else
                {
                    if (((m_collision.ground) && (!(testTerrainWithCoord(m_sprite.x, (m_sprite.y - 1))))))
                    {
                        if (((this.m_crashTimer.IsComplete) && ((((((this.m_pressedControls.BUTTON2) || (this.m_pressedControls.BUTTON1)) || (this.m_pressedControls.C_UP)) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT))))
                        {
                            this.Attack("getup_attack", 1);
                        };
                    };
                };
            };
            if ((!(isHitStunOrParalysis())))
            {
                this.m_shieldTimer++;
                if ((!(this.m_shieldDelayTimer.IsComplete)))
                {
                    this.m_shieldDelayTimer.tick();
                    if (((inState(CState.SHIELDING)) && (this.m_shieldDelayTimer.IsComplete)))
                    {
                        if ((((!(this.m_heldControls.SHIELD)) && (!(this.m_heldControls.SHIELD2))) || (((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.DOWN))))
                        {
                            this.clearControlsBuffer();
                        };
                    };
                };
            };
            this.m_turnTimer.tick();
            this.m_specialTurnTimer.tick();
            m_attackData.incrementAttackTimers(this);
            if (this.m_characterStats.DamageIncrease > 0)
            {
                this.m_damageIncreaseInterval.tick();
                if (this.m_damageIncreaseInterval.IsComplete)
                {
                    this.dealDamage(this.m_characterStats.DamageIncrease);
                    this.m_damageIncreaseInterval.reset();
                };
            };
            if ((!(this.m_poisonTintTimer.IsComplete)))
            {
                setTint(0.31, 1, 0.65, 1, 0, 25, 0, 0);
                this.m_poisonTintTimer.tick();
                if (this.m_poisonTintTimer.IsComplete)
                {
                    setTint(1, 1, 1, 1, 0, 0, 0, 0);
                };
            };
            if (this.m_poisonIncrease > 0)
            {
                this.m_poisonIncreaseInterval.tick();
                if (this.m_poisonIncreaseInterval.IsComplete)
                {
                    if ((!(this.isInvincible())))
                    {
                        this.dealDamage(this.m_poisonIncrease);
                        throbDamageCounter();
                    };
                    this.m_poisonIncreaseInterval.reset();
                };
                this.m_poisonIncreaseTime.tick();
                if (this.m_poisonIncreaseTime.IsComplete)
                {
                    this.m_poisonIncreaseTime.reset();
                    this.m_poisonIncrease = 0;
                    toggleEffect(this.m_poisonEffect, false);
                };
            };
            if (((this.m_warioWareIcon) && (!(this.m_warioWareIconTimer.IsComplete))))
            {
                this.m_warioWareIconTimer.tick();
                Utils.advanceFrame(this.m_warioWareIcon);
                if (this.m_warioWareIconTimer.IsComplete)
                {
                    toggleEffect(this.m_warioWareIcon, false);
                };
            };
            if ((!(this.m_shockEffectTimer.IsComplete)))
            {
                setTint(0.82, 0.82, 0.82, 1, 9, 0, 46, 0);
                this.m_shockEffectTimer.tick();
                if (this.m_shockEffectTimer.IsComplete)
                {
                    setTint(1, 1, 1, 1, 0, 0, 0, 0);
                };
            };
            if ((!(this.m_burnSmokeTimer.IsComplete)))
            {
                Utils.advanceFrame(this.m_burnSmoke);
                this.m_burnSmokeTimer.tick();
                if (this.m_burnSmokeTimer.CurrentTime < 60)
                {
                    setTint(0.79, 0.63, 0.63, 1, 57, 0, 0, 0);
                }
                else
                {
                    if (this.m_burnSmokeTimer.CurrentTime == 60)
                    {
                        setTint(1, 1, 1, 1, 0, 0, 0, 0);
                    };
                };
                if (this.m_burnSmokeTimer.IsComplete)
                {
                    if (this.m_burnSmoke.parent != null)
                    {
                        this.m_burnSmoke.parent.removeChild(this.m_burnSmoke);
                    };
                };
            };
            if ((!(this.m_darknessSmokeTimer.IsComplete)))
            {
                Utils.advanceFrame(this.m_darknessSmoke);
                this.m_darknessSmokeTimer.tick();
                if (this.m_darknessSmokeTimer.CurrentTime < 60)
                {
                    setTint(0.75, 0.75, 0.75, 1, 15, 2, 21, 0);
                }
                else
                {
                    if (this.m_darknessSmokeTimer.CurrentTime == 60)
                    {
                        setTint(1, 1, 1, 1, 0, 0, 0, 0);
                    };
                };
                if (this.m_darknessSmokeTimer.IsComplete)
                {
                    if (this.m_darknessSmoke.parent != null)
                    {
                        this.m_darknessSmoke.parent.removeChild(this.m_darknessSmoke);
                    };
                };
            };
            if ((!(this.m_auraSmokeTimer.IsComplete)))
            {
                Utils.advanceFrame(this.m_auraSmoke);
                this.m_auraSmokeTimer.tick();
                if (this.m_auraSmokeTimer.CurrentTime < 60)
                {
                    setTint(0.75, 0.75, 0.75, 1, 0, 36, 89, 0);
                }
                else
                {
                    if (this.m_auraSmokeTimer.CurrentTime == 60)
                    {
                        setTint(1, 1, 1, 1, 0, 0, 0, 0);
                    };
                };
                if (this.m_auraSmokeTimer.IsComplete)
                {
                    if (this.m_auraSmoke.parent != null)
                    {
                        this.m_auraSmoke.parent.removeChild(this.m_auraSmoke);
                    };
                };
            };
            if (inState(CState.KIRBY_STAR))
            {
                this.m_starTimer--;
                if (this.m_starTimer < 0)
                {
                    this.setIntangibility(false);
                    this.endAttack();
                    this.unnattachFromGround();
                    this.killAllSpeeds(false, false);
                    m_ySpeed = -12;
                    toggleEffect(this.m_kirbyStarMC, false);
                    this.setVisibility(true);
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                    this.setState(CState.JUMP_FALLING);
                }
                else
                {
                    m_xSpeed = ((m_facingForward) ? -15 : 15);
                };
            };
            this.m_holdTimer--;
            if (((this.m_charIsFull) && (this.m_grabbed.length > 0)))
            {
                i = 0;
                while (i < this.m_grabbed.length)
                {
                    loss = this.m_grabbed[i].Struggle();
                    this.m_holdTimer = (this.m_holdTimer - ((loss > 0) ? loss : 0));
                    i++;
                };
                if (this.m_holdTimer < 0)
                {
                    this.m_holdTimer = 0;
                };
            };
            if (((this.m_holdTimer <= 0) && (this.m_charIsFull)))
            {
                if (this.m_grabbed.length > 0)
                {
                    j = 0;
                    while (j < this.m_grabbed.length)
                    {
                        this.m_grabbed[j].setVisibility(true);
                        this.m_grabbed[j].Uncapture();
                        this.m_grabbed[j].unnattachFromGround();
                        this.m_grabbed[j].setYSpeed(-8);
                        j++;
                    };
                    this.m_grabbed = new Vector.<Character>();
                    m_xSpeed = ((m_facingForward) ? -9 : 9);
                    this.restartStance();
                };
                this.m_charIsFull = false;
            };
            if (this.m_attackDelay > 0)
            {
                this.m_attackDelay--;
            };
            if (((!(this.m_sizeStatus == 0)) && (!(this.m_sizeStatusPermanent))))
            {
                this.m_sizeStatusTimer.tick();
                if (this.m_sizeStatusTimer.IsComplete)
                {
                    this.setSizeStatus(0);
                };
            };
            if ((((((((this.m_forceTransformTime.MaxTime > 0) && (!(inState(CState.SCREEN_KO)))) && (!(inState(CState.STAR_KO)))) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAMINA_KO)))) && (!(inState(CState.REVIVAL)))) && (!(this.m_standby))))
            {
                this.m_forceTransformTime.tick();
                if (this.m_forceTransformTime.IsComplete)
                {
                    if (inState(CState.ATTACKING))
                    {
                        this.forceEndAttack();
                    };
                    this.replaceCharacter(this.m_characterStats.ForceTransformID);
                };
            };
            if (inState(CState.LEDGE_HANG))
            {
                this.m_ledgeHangTimer.tick();
                if (this.m_ledgeHangTimer.CurrentTime >= 14)
                {
                    this.turnOffInvincibility();
                };
                if (this.m_ledgeHangTimer.IsComplete)
                {
                    m_ySpeed = 0;
                    this.unnattachFromLedge();
                    this.setState(CState.IDLE);
                };
                if ((((inState(CState.LEDGE_HANG)) && (((this.m_pressedControls.BUTTON2) || (this.m_pressedControls.BUTTON1)) || ((((this.m_pressedControls.C_UP) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT)))) && (this.m_ledgeHangTimer.CurrentTime > 4)))
                {
                    this.m_ledgeHangTimer.reset();
                    m_sprite.x = (m_sprite.x + ((m_facingForward) ? 1 : -1));
                    limit = 0;
                    while (((!(this.testGroundWithCoord(m_sprite.x, m_sprite.y))) && (limit > 15)))
                    {
                        m_sprite.x = (m_sprite.x + ((m_facingForward) ? 1 : -1));
                        limit = (limit + 1);
                    };
                    if (limit >= 15)
                    {
                        m_sprite.x = (m_sprite.x - ((m_facingForward) ? limit : -(limit)));
                    };
                    this.m_groundCollisionTest();
                    this.Attack("ledge_attack", 1);
                };
            };
            if (((inState(CState.SHIELDING)) && (this.m_shieldTimer >= this.m_shieldStartFrame)))
            {
                if ((((this.m_shieldDelay > 5) && (!(isHitStunOrParalysis()))) && (this.m_shieldDelayTimer.IsComplete)))
                {
               if(GameMenu.HitStun && !MultiplayerManager.Connected)
               {
                  setBrightness(0);
               }
               if(Character.AIShieldGrabCPU == 1)
               {
                  Character.AIShieldGrabCPU = 2;
               }
               if(!HudMenu.PermanantShieldCPU || MultiplayerManager.Connected)
               {
                  this.m_shieldPower -= 0.56 * 2;
               }
                };
                this.m_resizeShield();
                if (this.m_shieldPower <= 0)
                {
                    this.m_breakShield();
                };
            };
            if (((((((((!(this.m_heldControls.UP)) && (!(this.m_heldControls.DOWN))) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.RIGHT))) && (!(this.m_heldControls.BUTTON2))) && (!(this.m_heldControls.BUTTON1))) && (!(this.isLanding()))) && (!(this.isSkidding()))))
            {
                this.m_smashTimer = 0;
            }
            else
            {
                this.m_smashTimer++;
            };
            if ((((((!(this.m_heldControls.UP)) && (!(this.m_heldControls.BUTTON2))) && (!(this.m_heldControls.BUTTON1))) && (!(this.isLanding()))) && (!(this.isSkidding()))))
            {
                this.m_smashTimerUp = 0;
            }
            else
            {
                this.m_smashTimerUp++;
            };
            if ((((((!(this.m_heldControls.DOWN)) && (!(this.m_heldControls.BUTTON2))) && (!(this.m_heldControls.BUTTON1))) && (!(this.isLanding()))) && (!(this.isSkidding()))))
            {
                this.m_smashTimerDown = 0;
            }
            else
            {
                this.m_smashTimerDown++;
            };
            if (((((((!(this.m_heldControls.RIGHT)) && (!(this.m_heldControls.LEFT))) && (!(this.m_heldControls.BUTTON2))) && (!(this.m_heldControls.BUTTON1))) && (!(this.isLanding()))) && (!(this.isSkidding()))))
            {
                this.m_smashTimerSide = 0;
            }
            else
            {
                this.m_smashTimerSide++;
            };
            if (((((!(this.m_heldControls.UP)) && (!(this.m_heldControls.BUTTON1))) && (!(this.isLanding()))) && (!(this.isSkidding()))))
            {
                this.m_upSpecialTimer = 0;
            }
            else
            {
                this.m_smashTimerSide++;
            };
            if (this.isLanding())
            {
                this.killSmashTimers();
            };
            if (((inState(CState.HOVER)) || (this.m_attackHovering)))
            {
                this.m_midAirHoverTime.tick();
                if (((this.m_midAirHoverTime.IsComplete) || ((!(this.m_heldControls.UP)) && (!(this.jumpIsHeld())))))
                {
                    if ((!(this.m_attackHovering)))
                    {
                        this.setState(CState.IDLE);
                    };
                    this.m_attackHovering = false;
                };
            };
            this.m_midAirJumpConstantDelay.tick();
            if (((this.m_midAirJumpConstantDelay.IsComplete) && (!(m_actionShot))))
            {
                this.m_midAirJumpConstantTime.tick();
            };
            originalJumpSpeed = -(this.m_characterStats.JumpSpeedMidAir);
            if (this.m_jumpSpeedList)
            {
                if (this.m_jumpCount < this.m_jumpSpeedList.length)
                {
                    originalJumpSpeed = -(this.m_jumpSpeedList[this.m_jumpCount]);
                }
                else
                {
                    originalJumpSpeed = -(this.m_jumpSpeedList[(this.m_jumpSpeedList.length - 1)]);
                };
            };
            if ((((!(this.m_midAirJumpConstantTime.IsComplete)) && (this.m_midAirJumpConstantDelay.IsComplete)) && (!(isHitStunOrParalysis()))))
            {
                if (this.m_characterStats.MidAirJumpConstantAccel != 0)
                {
                    m_ySpeed = (m_ySpeed - this.m_characterStats.MidAirJumpConstantAccel);
                    if (m_ySpeed < originalJumpSpeed)
                    {
                        m_ySpeed = originalJumpSpeed;
                    };
                }
                else
                {
                    m_ySpeed = originalJumpSpeed;
                };
            };
            if ((!(this.m_jumpEffectTimer.IsComplete)))
            {
                this.m_jumpEffectTimer.tick();
                if ((this.m_jumpEffectTimer.CurrentTime % 2) == 0)
                {
                    this.attachJumpEffect();
                };
            };
            if (inState(CState.ATTACKING))
            {
                if ((!(isHitStunOrParalysis())))
                {
                    m_attack.ExecTime++;
                    m_attack.RefreshRateTimer++;
                };
                if (((((!(this.m_attackIDIncremented)) && (m_attack.RefreshRate > 0)) && (m_attack.RefreshRateReady)) && ((m_attack.RefreshRateTimer % m_attack.RefreshRate) == 0)))
                {
                    m_attack.AttackID = Utils.getUID();
                    this.checkLinkedProjectiles();
                    this.m_attackIDIncremented = true;
                }
                else
                {
                    if ((!(isHitStunOrParalysis())))
                    {
                        this.m_attackIDIncremented = false;
                    };
                };
            };
            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.INVISIBLE))
            {
                if ((!(this.m_invisiblePulseToggle)))
                {
                    this.setAlpha(0);
                };
                this.m_invisiblePulseTimer.tick();
                if (this.m_invisiblePulseTimer.IsComplete)
                {
                    if ((!(this.m_invisiblePulseToggle)))
                    {
                        this.m_invisiblePulseToggle = true;
                        this.m_invisiblePulseTimer.reset();
                        this.m_invisiblePulseTimer.MaxTime = Utils.randomInteger(1, 8);
                        this.setAlpha((Utils.random() * 0.65));
                        this.m_invisiblePulseCount = Utils.randomInteger(1, 8);
                    }
                    else
                    {
                        this.m_invisiblePulseCount--;
                        if (this.m_invisiblePulseCount <= 0)
                        {
                            this.m_invisiblePulseCount = 0;
                            this.m_invisiblePulseToggle = false;
                            this.m_invisiblePulseTimer.reset();
                            this.m_invisiblePulseTimer.MaxTime = Utils.randomInteger(20, 90);
                        }
                        else
                        {
                            this.m_invisiblePulseTimer.reset();
                            this.m_invisiblePulseTimer.MaxTime = Utils.randomInteger(1, 8);
                            this.setAlpha((Utils.random() * 0.65));
                        };
                    };
                };
            };
            if ((((this.m_waveDashPenalty > 0) && (!(inState(CState.AIR_DODGE)))) && (!(inState(CState.LAND)))))
            {
                this.m_waveDashPenalty--;
                if (this.m_waveDashPenalty <= 0)
                {
                    this.m_waveDashPenalty = 0;
                };
            };
            this.m_justTechedTimer.tick();
        }

        public function groundBounceCheck():void
        {
            if (((((((inState(CState.CRASH_LAND)) && (this.m_tumbledCrash)) && (Stance)) && (Stance.currentFrame <= 2)) && (this.shieldIsPressed())) && (!(isHitStunOrParalysis()))))
            {
                this.performGroundTech();
                this.techEffect();
            }
            else
            {
                if (((((((inState(CState.FLYING)) || (inState(CState.TUMBLE_FALL))) && (this.m_canTech)) && (!(this.m_hasBounced))) && (this.m_techReady)) && (!(isHitStunOrParalysis()))))
                {
                    this.performGroundTech();
                    this.techEffect();
                }
                else
                {
                    if ((((inState(CState.FLYING)) && (this.m_canBounce)) && (this.netYSpeed() >= (m_max_ySpeed - 1))))
                    {
                        this.toBounce();
                    }
                    else
                    {
                        if (((inState(CState.FLYING)) || (inState(CState.TUMBLE_FALL))))
                        {
                            this.initiateCrash();
                        };
                    };
                };
            };
        }

        public function initiateCrash():void
        {
            this.m_forcedCrash = false;
            if (((inState(CState.FLYING)) || (inState(CState.TUMBLE_FALL))))
            {
                this.m_tumbledCrash = true;
            }
            else
            {
                this.m_tumbledCrash = false;
            };
            if (((!(inState(CState.CRASH_LAND))) && (!(inState(CState.CRASH_GETUP)))))
            {
                this.m_crashTimer.reset();
                this.m_getUpTimer.reset();
            };
            if ((!(m_collision.ground)))
            {
                m_currentPlatform = getPlatformBetweenPoints(Location, new Point(Location.x, (Location.y + 20)));
                if (m_currentPlatform != null)
                {
                    attachToGround();
                };
            };
            this.m_hitLagCanCancelWithJump = false;
            this.m_hitLagCanCancelWithUpB = false;
            if (inState(CState.FLYING))
            {
                this.setState(CState.CRASH_LAND);
                this.stancePlayFrame("bounce");
            }
            else
            {
                this.setState(CState.CRASH_LAND);
            };
            this.m_crowdAwe = false;
            this.updateItemHolding();
            this.resetRotation();
        }

        private function checkEdgeLean():void
        {
            var cliffSide:Boolean;
            if (inState(CState.IDLE))
            {
                cliffSide = ((((m_collision.ground) && (OnTerrain)) && (m_xSpeed == 0)) && (checkLinearPathBetweenPoints(new Point(((m_facingForward) ? (m_sprite.x + 5) : (m_sprite.x - 5)), (m_sprite.y + 2)), new Point(((m_facingForward) ? (m_sprite.x + 5) : (m_sprite.x - 5)), (m_sprite.y + 20)), true, m_currentPlatform)));
                if (((cliffSide) && (Utils.hasLabel(m_sprite, "edgelean", true))))
                {
                    this.playFrame("edgelean");
                }
                else
                {
                    this.playFrame("stand");
                };
            };
        }

        private function checkFatKirby():void
        {
            if (this.m_charIsFull)
            {
                if (inState(CState.IDLE))
                {
                    this.playFrame("stand");
                    if (getStanceVar("fatstand", false))
                    {
                        this.stancePlayFrame("fatstand");
                    };
                }
                else
                {
                    if (inState(CState.WALK))
                    {
                        this.playFrame("walk");
                        if (((this.m_charIsFull) && (getStanceVar("normalwalk", true))))
                        {
                            this.stancePlayFrame("startwalk2");
                        };
                    }
                    else
                    {
                        if (inState(CState.JUMP_RISING))
                        {
                            this.playFrame("jump");
                            if (getStanceVar("fatjump", false))
                            {
                                this.stancePlayFrame("fatjump");
                            };
                        }
                        else
                        {
                            if (inState(CState.JUMP_FALLING))
                            {
                                this.playFrame("fall");
                                if (getStanceVar("fatfall", false))
                                {
                                    this.stancePlayFrame("fatfall");
                                };
                            }
                            else
                            {
                                if (((inState(CState.LAND)) || (inState(CState.HEAVY_LAND))))
                                {
                                    if (currentFrameIs("land"))
                                    {
                                        this.playFrame("land");
                                    }
                                    else
                                    {
                                        if (currentFrameIs("heavyland"))
                                        {
                                            this.playFrame("heavyland");
                                        }
                                        else
                                        {
                                            if (inState(CState.HEAVY_LAND))
                                            {
                                                this.playFrame("heavyland");
                                            }
                                            else
                                            {
                                                this.playFrame("land");
                                            };
                                        };
                                    };
                                    if (getStanceVar("fatland", false))
                                    {
                                        this.stancePlayFrame("fatland");
                                        this.attachLandEffect();
                                        if ((!((!(m_currentPlatform == null)) && (!(m_currentPlatform.accel_friction == 1)))))
                                        {
                                            m_xSpeed = 0;
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

        private function checkGroundStateChange():void
        {
            if ((!(m_collision.ground)))
            {
                if (((((((((((inState(CState.IDLE)) || (inState(CState.RUN))) || (inState(CState.WALK))) || (inState(CState.SKID))) || (inState(CState.JUMP_CHAMBER))) || (this.isLanding())) || (inState(CState.SKID))) || (inState(CState.CROUCH))) || (inState(CState.TURN))) || (inState(CState.DASH))))
                {
                    if ((!(inState(CState.ATTACKING))))
                    {
                        if (m_xSpeed > this.m_characterStats.MaxJumpSpeed)
                        {
                            m_xSpeed = this.m_characterStats.MaxJumpSpeed;
                        }
                        else
                        {
                            if (m_xSpeed < -(this.m_characterStats.MaxJumpSpeed))
                            {
                                m_xSpeed = -(this.m_characterStats.MaxJumpSpeed);
                            };
                        };
                    };
                    if (inState(CState.TURN))
                    {
                        flip();
                    };
                    this.setState(CState.JUMP_FALLING);
                    this.resetRotation();
                    this.m_fallTiltTimer.reset();
                };
            }
            else
            {
                if ((((((inState(CState.JUMP_RISING)) || (inState(CState.JUMP_MIDAIR_RISING))) || (inState(CState.JUMP_FALLING))) || (inState(CState.HOVER))) || (this.m_attackHovering)))
                {
                    this.resetRotation();
                    this.setState(CState.LAND);
                };
            };
        }

        override protected function m_controlFrames():void
        {
            var wasRun:Boolean;
            var angle:Number;
            var tmpAng:Number;
            var wasCrouching:Boolean;
            if (this.m_charIsFull)
            {
                this.checkFatKirby();
            }
            else
            {
                if (inState(CState.ENTRANCE))
                {
                    this.playFrame("entrance");
                }
                else
                {
                    if (inState(CState.DISABLED))
                    {
                        this.playFrame("fall");
                    }
                    else
                    {
                        if (inState(CState.IDLE))
                        {
                            if (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                            {
                                if (m_xSpeed !== 0)
                                {
                                    this.playFrame("run");
                                }
                                else
                                {
                                    this.playFrame("stand");
                                };
                            }
                            else
                            {
                                this.playFrame("stand");
                            };
                            this.resetRotation();
                            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                        }
                        else
                        {
                            if (inState(CState.DASH_INIT))
                            {
                                this.playFrame("stand");
                            }
                            else
                            {
                                if ((((inState(CState.RUN)) || (inState(CState.DASH))) || (inState(CState.TURN))))
                                {
                                    wasRun = currentFrameIs("run");
                                    this.playFrame("run");
                                    if (((((inState(CState.RUN)) && (!(wasRun))) && (HasStance)) && (Utils.hasLabel(m_sprite.stance, "run"))))
                                    {
                                        this.stancePlayFrame("run");
                                    };
                                }
                                else
                                {
                                    if (inState(CState.WALK))
                                    {
                                        this.playFrame("walk");
                                    }
                                    else
                                    {
                                        if (inState(CState.SKID))
                                        {
                                            this.playFrame("skid");
                                        }
                                        else
                                        {
                                            if (((inState(CState.LAND)) || (inState(CState.HEAVY_LAND))))
                                            {
                                                if (currentFrameIs("land"))
                                                {
                                                    this.playFrame("land");
                                                }
                                                else
                                                {
                                                    if (currentFrameIs("heavyland"))
                                                    {
                                                        this.playFrame("heavyland");
                                                    }
                                                    else
                                                    {
                                                        if (inState(CState.HEAVY_LAND))
                                                        {
                                                            this.playFrame("heavyland");
                                                        }
                                                        else
                                                        {
                                                            this.playFrame("land");
                                                        };
                                                    };
                                                };
                                            }
                                            else
                                            {
                                                if (inState(CState.HOVER))
                                                {
                                                    this.playFrame("jump_midair");
                                                    if (((((HasStance) && (!(m_sprite.stance.currentLabel == "hover"))) && (m_currentAnimationID == "jump_midair")) && (Utils.hasLabel(m_sprite.stance, "hover"))))
                                                    {
                                                        this.stancePlayFrame("hover");
                                                    };
                                                }
                                                else
                                                {
                                                    if ((((inState(CState.JUMP_RISING)) || (inState(CState.JUMP_MIDAIR_RISING))) || (inState(CState.JUMP_CHAMBER))))
                                                    {
                                                        if (((inState(CState.JUMP_RISING)) || (inState(CState.JUMP_CHAMBER))))
                                                        {
                                                            this.playFrame("jump");
                                                        }
                                                        else
                                                        {
                                                            if (inState(CState.JUMP_MIDAIR_RISING))
                                                            {
                                                                this.playFrame("jump_midair");
                                                            };
                                                        };
                                                    }
                                                    else
                                                    {
                                                        if (inState(CState.JUMP_FALLING))
                                                        {
                                                            this.playFrame("fall");
                                                        }
                                                        else
                                                        {
                                                            if (inState(CState.KIRBY_STAR))
                                                            {
                                                                this.playFrame("hurt");
                                                            }
                                                            else
                                                            {
                                                                if (inState(CState.ATTACKING))
                                                                {
                                                                    if (((!(currentFrameIs(m_attack.Frame))) && (!(m_attack.Frame == null))))
                                                                    {
                                                                        this.playFrame(m_attack.Frame);
                                                                    };
                                                                }
                                                                else
                                                                {
                                                                    if (inState(CState.REVIVAL))
                                                                    {
                                                                        this.playFrame("revival");
                                                                    }
                                                                    else
                                                                    {
                                                                        if (inState(CState.CRASH_LAND))
                                                                        {
                                                                            this.playFrame("crash");
                                                                        }
                                                                        else
                                                                        {
                                                                            if (inState(CState.CRASH_GETUP))
                                                                            {
                                                                                this.playFrame("crash");
                                                                            }
                                                                            else
                                                                            {
                                                                                if (inState(CState.STAMINA_KO))
                                                                                {
                                                                                    if (m_collision.ground)
                                                                                    {
                                                                                        this.playFrame("crash");
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        this.playFrame("falling");
                                                                                    };
                                                                                }
                                                                                else
                                                                                {
                                                                                    if (inState(CState.ROLL))
                                                                                    {
                                                                                        this.playFrame("roll");
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        if (inState(CState.TECH_ROLL))
                                                                                        {
                                                                                            this.playFrame("tech_roll");
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            if (inState(CState.TECH_GROUND))
                                                                                            {
                                                                                                this.playFrame("tech_ground");
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                if ((((inState(CState.INJURED)) || (inState(CState.CAUGHT))) || (inState(CState.FLYING))))
                                                                                                {
                                                                                                    if (inState(CState.FLYING))
                                                                                                    {
                                                                                                        if (isHitStunOrParalysis())
                                                                                                        {
                                                                                                            this.resetRotation();
                                                                                                            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                                                                                            this.playFrame("hurt");
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            this.playFrame("flying");
                                                                                                            angle = Utils.getAngleBetween(new Point(0, 0), new Point(this.netXSpeed(), this.netYSpeed()));
                                                                                                            tmpAng = Utils.forceBase360(((!(m_facingForward)) ? -(angle) : (-(angle) + 180)));
                                                                                                            m_sprite.rotation = tmpAng;
                                                                                                        };
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        if (((!(currentFrameIs("hurt"))) || (m_delayPlayback)))
                                                                                                        {
                                                                                                            this.resetRotation();
                                                                                                            Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                                                                                            this.playFrame("hurt");
                                                                                                        };
                                                                                                    };
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    if (inState(CState.STUNNED))
                                                                                                    {
                                                                                                        if ((!(m_collision.ground)))
                                                                                                        {
                                                                                                            this.playFrame("falling");
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            this.playFrame("stunned");
                                                                                                        };
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        if (inState(CState.DIZZY))
                                                                                                        {
                                                                                                            if ((!(m_collision.ground)))
                                                                                                            {
                                                                                                                this.playFrame("falling");
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                this.playFrame("dizzy");
                                                                                                            };
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            if (inState(CState.LEDGE_ROLL))
                                                                                                            {
                                                                                                                this.playFrame("rollup");
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                if (inState(CState.LEDGE_CLIMB))
                                                                                                                {
                                                                                                                    this.playFrame("climbup");
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    if (inState(CState.LEDGE_HANG))
                                                                                                                    {
                                                                                                                        this.playFrame("hang");
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        if (inState(CState.DODGE_ROLL))
                                                                                                                        {
                                                                                                                            this.playFrame("dodgeroll");
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            if (inState(CState.SIDESTEP_DODGE))
                                                                                                                            {
                                                                                                                                this.playFrame("sidestep");
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                if (inState(CState.AIR_DODGE))
                                                                                                                                {
                                                                                                                                    this.playFrame("airdodge");
                                                                                                                                }
                                                                                                                                else
                                                                                                                                {
                                                                                                                                    if (inState(CState.ITEM_TOSS))
                                                                                                                                    {
                                                                                                                                        if (((!(currentFrameIs("toss"))) && (!(currentFrameIs("toss_air")))))
                                                                                                                                        {
                                                                                                                                            if (((!(m_collision.ground)) && (Utils.hasLabel(m_sprite, "toss_air", true))))
                                                                                                                                            {
                                                                                                                                                this.playFrame("toss_air");
                                                                                                                                            }
                                                                                                                                            else
                                                                                                                                            {
                                                                                                                                                this.playFrame("toss");
                                                                                                                                            };
                                                                                                                                        };
                                                                                                                                    }
                                                                                                                                    else
                                                                                                                                    {
                                                                                                                                        if (inState(CState.ITEM_PICKUP))
                                                                                                                                        {
                                                                                                                                            this.playFrame("item_pickup");
                                                                                                                                        }
                                                                                                                                        else
                                                                                                                                        {
                                                                                                                                            if (inState(CState.GRABBING))
                                                                                                                                            {
                                                                                                                                                this.playFrame("grab");
                                                                                                                                            }
                                                                                                                                            else
                                                                                                                                            {
                                                                                                                                                if (inState(CState.CROUCH))
                                                                                                                                                {
                                                                                                                                                    wasCrouching = currentFrameIs("crouch");
                                                                                                                                                    this.playFrame("crouch");
                                                                                                                                                    if (((!(wasCrouching)) && (this.m_crouchFrame > 0)))
                                                                                                                                                    {
                                                                                                                                                        Utils.tryToGotoAndStop(m_sprite.stance, this.m_crouchFrame);
                                                                                                                                                    };
                                                                                                                                                }
                                                                                                                                                else
                                                                                                                                                {
                                                                                                                                                    if (inState(CState.SHIELDING))
                                                                                                                                                    {
                                                                                                                                                        this.playFrame("defend");
                                                                                                                                                        this.m_resizeShield();
                                                                                                                                                    }
                                                                                                                                                    else
                                                                                                                                                    {
                                                                                                                                                        if (inState(CState.SHIELD_DROP))
                                                                                                                                                        {
                                                                                                                                                            this.playFrame("defend");
                                                                                                                                                        }
                                                                                                                                                        else
                                                                                                                                                        {
                                                                                                                                                            if (inState(CState.TAUNT))
                                                                                                                                                            {
                                                                                                                                                                this.playFrame("taunt");
                                                                                                                                                            }
                                                                                                                                                            else
                                                                                                                                                            {
                                                                                                                                                                if (((inState(CState.TUMBLE_FALL)) && (!(isHitStunOrParalysis()))))
                                                                                                                                                                {
                                                                                                                                                                    Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                                                                                                                                                    if (m_collision.ground)
                                                                                                                                                                    {
                                                                                                                                                                        this.initiateCrash();
                                                                                                                                                                    }
                                                                                                                                                                    else
                                                                                                                                                                    {
                                                                                                                                                                        Utils.rotateAroundCenter(m_sprite.stance, m_facingForward, 0);
                                                                                                                                                                        this.playFrame("falling");
                                                                                                                                                                    };
                                                                                                                                                                }
                                                                                                                                                                else
                                                                                                                                                                {
                                                                                                                                                                    if (inState(CState.FROZEN))
                                                                                                                                                                    {
                                                                                                                                                                        this.playFrame("hurt");
                                                                                                                                                                    }
                                                                                                                                                                    else
                                                                                                                                                                    {
                                                                                                                                                                        if (inState(CState.SLEEP))
                                                                                                                                                                        {
                                                                                                                                                                            if ((!(m_collision.ground)))
                                                                                                                                                                            {
                                                                                                                                                                                this.playFrame("falling");
                                                                                                                                                                            }
                                                                                                                                                                            else
                                                                                                                                                                            {
                                                                                                                                                                                this.playFrame("sleep");
                                                                                                                                                                            };
                                                                                                                                                                        }
                                                                                                                                                                        else
                                                                                                                                                                        {
                                                                                                                                                                            if (inState(CState.PITFALL))
                                                                                                                                                                            {
                                                                                                                                                                                this.playFrame("pitfall");
                                                                                                                                                                            }
                                                                                                                                                                            else
                                                                                                                                                                            {
                                                                                                                                                                                if (inState(CState.EGG))
                                                                                                                                                                                {
                                                                                                                                                                                    this.playFrame("hurt");
                                                                                                                                                                                }
                                                                                                                                                                                else
                                                                                                                                                                                {
                                                                                                                                                                                    if (inState(CState.WALL_CLING))
                                                                                                                                                                                    {
                                                                                                                                                                                        this.playFrame("wallstick");
                                                                                                                                                                                    };
                                                                                                                                                                                };
                                                                                                                                                                            };
                                                                                                                                                                        };
                                                                                                                                                                    };
                                                                                                                                                                };
                                                                                                                                                            };
                                                                                                                                                        };
                                                                                                                                                    };
                                                                                                                                                };
                                                                                                                                            };
                                                                                                                                        };
                                                                                                                                    };
                                                                                                                                };
                                                                                                                            };
                                                                                                                        };
                                                                                                                    };
                                                                                                                };
                                                                                                            };
                                                                                                        };
                                                                                                    };
                                                                                                };
                                                                                            };
                                                                                        };
                                                                                    };
                                                                                };
                                                                            };
                                                                        };
                                                                    };
                                                                };
                                                            };
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

        private function stopSoundID(id:int):void
        {
            var tmpObj:SoundObject;
            if (id >= 0)
            {
                tmpObj = STAGEDATA.SoundQueueRef.getSoundObject(id);
                if (((tmpObj.IsPlaying) && (tmpObj.IsPlaying)))
                {
                    tmpObj.stop();
                };
            };
        }

        public function playAttackSound(soundID:Number=-1):int
        {
            var sounds:Array;
            if (m_attack.Frame != null)
            {
                sounds = m_attackData.getAttack(m_attack.Frame).AttackSounds;
                if (soundID === -1)
                {
                    if (sounds[(soundID - 1)].length)
                    {
                        return (this.m_lastSFX = STAGEDATA.playSpecificSound(sounds[Utils.randomInteger(0, (sounds.length - 1))], this.m_characterStats.VolumeSFX));
                    };
                }
                else
                {
                    if (sounds[(soundID - 1)] != null)
                    {
                        return (this.m_lastSFX = STAGEDATA.playSpecificSound(sounds[(soundID - 1)], this.m_characterStats.VolumeSFX));
                    };
                };
            };
            return (-1);
        }

        public function playVoiceSound(soundID:Number=-1):int
        {
            var sounds:Array;
            if (((!(this.m_isMetal)) && (!(m_attack.Frame == null))))
            {
                sounds = m_attackData.getAttack(m_attack.Frame).AttackVoices;
                if (soundID === -1)
                {
                    if (sounds[(soundID - 1)].length)
                    {
                        return (this.m_lastVFX = STAGEDATA.playSpecificVoice(sounds[Utils.randomInteger(0, (sounds.length - 1))], this.m_characterStats.VolumeVFX));
                    };
                }
                else
                {
                    if (sounds[(soundID - 1)] != null)
                    {
                        return (this.m_lastVFX = STAGEDATA.playSpecificVoice(sounds[(soundID - 1)], this.m_characterStats.VolumeVFX));
                    };
                };
            };
            return (-1);
        }

        public function playCharacterSound(soundID:String):int
        {
            if ((((!(this.m_isMetal)) && (!(this.m_characterStats.Sounds[soundID] == null))) && (!(this.m_characterStats.Sounds[soundID] == undefined))))
            {
                return (STAGEDATA.playSpecificVoice(((this.m_characterStats.Sounds[(soundID + "2")] != null) ? ((Utils.random() > 0.5) ? this.m_characterStats.Sounds[(soundID + "2")] : this.m_characterStats.Sounds[soundID]) : this.m_characterStats.Sounds[soundID]), this.m_characterStats.VolumeVFX));
            };
            return (-1);
        }

        public function toHelpless(e:*=null):void
        {
            this.forceEndAttack();
            if ((!(m_collision.ground)))
            {
                this.setState(CState.DISABLED);
            };
        }

        public function toLand(e:*=null):void
        {
            this.forceEndAttack();
            this.setState(CState.LAND);
            m_ySpeed = 0;
        }

        public function toHeavyLand(e:*=null):void
        {
            this.forceEndAttack();
            this.setState(CState.HEAVY_LAND);
            m_ySpeed = 0;
        }

        public function toIdle(e:*=null):void
        {
            this.forceEndAttack();
            this.setState(CState.IDLE);
        }

        public function toGrabbing(e:*=null):void
        {
            if (this.m_grabbed.length === 1)
            {
                if (!StrengthSystem.canGrab(this.getStrengthGrabRatio(this.m_grabbed[0])))
                {
                    this.grabReleaseOpponent();
                    this.grabRelease();
                    return;
                };
                this.m_internalGrabLock = true;
                this.forceEndAttack();
                this.m_internalGrabLock = false;
                if (this.m_grabbed.length)
                {
                    m_attack.Frame = "grab";
                    this.setState(CState.GRABBING);
                    this.initializeStrengthGrab(this.m_grabbed[0], Utils.calculateGrabLength(((this.m_grabbed[0].CharacterStats.Stamina > 0) ? (this.m_grabbed[0].CharacterStats.Stamina - this.m_grabbed[0].getDamage()) : this.m_grabbed[0].getDamage())));
                    this.stancePlayFrame("grabbed");
                    m_attack.AttackID = Utils.getUID();
                    m_attack.ID = Utils.getUID();
                    this.checkLinkedProjectiles();
                };
            };
        }

        public function toBounce(e:*=null):void
        {
            var tmpYSpeed:Number;
            this.forceEndAttack();
            this.setState(CState.FLYING);
            resetKnockbackDecay();
            m_ySpeed = -12;
            this.unnattachFromGround();
            this.attachGroundBounceEffect();
            this.m_canBounce = false;
            this.m_hasBounced = true;
            this.m_hitLagCanCancelWithJump = false;
            this.m_hitLagCanCancelWithUpB = false;
            this.m_hitLagCancelTimer.reset();
            this.m_hitLag = 0;
            tmpYSpeed = -12;
            while (((tmpYSpeed < 12) && (m_gravity > 0)))
            {
                this.m_hitLag++;
                tmpYSpeed = (tmpYSpeed + m_gravity);
            };
        }

        public function toCrashLand(e:*=null):void
        {
            this.forceEndAttack();
            this.initiateCrash();
        }

        public function toToss(e:*=null):void
        {
            var backToss:Boolean;
            var up:Boolean;
            var down:Boolean;
            var left:Boolean;
            var right:Boolean;
            var wasRolling:Boolean;
            var oldXSpeed:Number;
            var frame:String;
            var angle:Number;
            if (((!(this.m_item)) || (!(this.m_item.ItemStats.CanToss))))
            {
                return;
            };
            up = false;
            down = false;
            left = false;
            right = false;
            wasRolling = inState(CState.DODGE_ROLL);
            oldXSpeed = m_xSpeed;
            if (((((inState(CState.SHIELDING)) || (inState(CState.SHIELD_DROP))) || (inState(CState.DODGE_ROLL))) || (inState(CState.SIDESTEP_DODGE))))
            {
                this.m_deactivateShield();
                this.setIntangibility(false);
            };
            if (((((this.m_pressedControls.C_UP) || (this.m_pressedControls.C_DOWN)) || (this.m_pressedControls.C_LEFT)) || (this.m_pressedControls.C_RIGHT)))
            {
                up = this.m_pressedControls.C_UP;
                down = this.m_pressedControls.C_DOWN;
                left = this.m_pressedControls.C_LEFT;
                right = this.m_pressedControls.C_RIGHT;
            }
            else
            {
                if (((((this.m_heldControls.UP) || (this.m_heldControls.DOWN)) || (this.m_heldControls.LEFT)) || (this.m_heldControls.RIGHT)))
                {
                    up = this.m_heldControls.UP;
                    down = this.m_heldControls.DOWN;
                    left = this.m_heldControls.LEFT;
                    right = this.m_heldControls.RIGHT;
                };
            };
            if (inState(CState.ATTACKING))
            {
                this.forceEndAttack();
            };
            m_xSpeed = oldXSpeed;
            if (wasRolling)
            {
                if (m_facingForward)
                {
                    if ((!(right)))
                    {
                        faceLeft();
                        left = true;
                    };
                }
                else
                {
                    if ((!(left)))
                    {
                        faceRight();
                        right = true;
                    };
                };
            };
            if (Utils.hasLabel(m_sprite, "toss", true))
            {
                frame = "";
                if ((((this.m_pressedControls.GRAB) && (!((!(this.m_item.CanBackToss)) && (m_collision.ground)))) && (!((!(up == down)) || (!(left == right))))))
                {
                    this.tossItemOld(8, 105, true);
                    this.setState(CState.IDLE);
                    return;
                };
                if (right != left)
                {
                    if ((!(m_collision.ground)))
                    {
                        if (up)
                        {
                            frame = ((up) ? "toss_forward" : "toss_down");
                        }
                        else
                        {
                            frame = ((((right) && (!(m_facingForward))) || ((left) && (m_facingForward))) ? "toss_back" : "toss_forward");
                        };
                    }
                    else
                    {
                        if (up != down)
                        {
                            frame = ((up) ? "toss_up" : "toss_down");
                        }
                        else
                        {
                            frame = ((((right) && (!(m_facingForward))) || ((left) && (m_facingForward))) ? "toss_back" : "toss_forward");
                        };
                    };
                }
                else
                {
                    if (up != down)
                    {
                        frame = ((up) ? "toss_up" : "toss_down");
                    }
                    else
                    {
                        frame = "toss_forward";
                    };
                };
                this.setState(CState.ITEM_TOSS);
                this.stancePlayFrame(frame);
                this.setStanceVar("backToss", backToss);
                if (frame === "toss_back")
                {
                    addEventListener(SSF2Event.CHAR_ATTACK_COMPLETE, flip);
                };
            }
            else
            {
                if ((((this.m_pressedControls.GRAB) && (!((!(this.m_item.CanBackToss)) && (m_collision.ground)))) && (!((!(up == down)) || (!(left == right))))))
                {
                    this.tossItemOld(8, 105, true);
                    this.setState(CState.IDLE);
                }
                else
                {
                    angle = ((this.m_heldControls.UP) ? 90 : ((down) ? 270 : ((right !== left) ? ((right) ? 20 : 160) : ((m_facingForward) ? 20 : 160))));
                    this.tossItemOld(20, angle);
                    this.setState(CState.IDLE);
                };
            };
            if (((((!(m_collision.ground)) && (!(this.jumpIsPressed()))) && (!((this.jumpIsHeld()) || ((this.m_tap_jump) && (this.m_heldControls.UP))))) && ((m_ySpeed < 0) || ((this.m_midAirJumpConstantTime.MaxTime > 0) && (!(this.m_midAirJumpConstantTime.IsComplete))))))
            {
                if (m_ySpeed < 0)
                {
                    this.m_midAirJumpConstantDelay.finish();
                    this.m_midAirJumpConstantTime.finish();
                }
                else
                {
                    m_ySpeed = 0;
                    this.m_midAirJumpConstantTime.finish();
                };
            };
        }

        public function toFlying(e:*=null):void
        {
            this.forceEndAttack();
            this.setState(CState.FLYING);
        }

        public function toBarrel(e:*=null):void
        {
            if (inState(CState.BARREL))
            {
                return;
            };
            this.forceEndAttack();
            this.setState(CState.BARREL);
        }

        public function playGlobalSound(soundID:String):int
        {
            return (STAGEDATA.playSpecificSound(soundID, this.m_characterStats.VolumeSFX));
        }

        private function m_checkRevival():void
        {
            var targetsX:Vector.<MovieClip>;
            var done:Boolean;
            var mc:MovieClip;
            var targets1:Vector.<MovieClip>;
            if (((inState(CState.STAR_KO)) || (inState(CState.SCREEN_KO))))
            {
                if (this.m_starKOTimer.IsComplete)
                {
                    if (inState(CState.SCREEN_KO))
                    {
                        this.m_screenKO = false;
                    }
                    else
                    {
                        if (inState(CState.STAR_KO))
                        {
                            targetsX = new Vector.<MovieClip>();
                            targetsX.push(m_sprite);
                            STAGEDATA.CamRef.deleteTargets(targetsX);
                        };
                    };
                    this.killCharacter(false, true);
                }
                else
                {
                    this.m_starKOHolder.visible = true;
                    this.m_screenKOHolder.visible = true;
                };
            }
            else
            {
                if (inState(CState.REVIVAL))
                {
                    done = this.m_respawnDelay.IsComplete;
                    this.m_respawnDelay.tick();
                    if (((this.m_respawnDelay.IsComplete) && (!(done))))
                    {
                        this.restartStance();
                    };
                    if (this.m_respawnDelay.IsComplete)
                    {
                        if ((!(m_sprite.visible)))
                        {
                            targets1 = new Vector.<MovieClip>();
                            targets1.push(m_sprite);
                            if ((!((CAM.Mode == Vcam.ZOOM_MODE) && (m_player_id > 1))))
                            {
                                STAGEDATA.CamRef.addTargets(targets1);
                            };
                            this.restartStance();
                        };
                        this.setVisibility(true);
                        showHealthBoxes(true);
                        mc = null;
                        if (this.m_revivalTimer < 0)
                        {
                            if (this.m_characterStats.RevivalEffect != null)
                            {
                                mc = STAGEDATA.attachEffectOverlay(this.m_characterStats.RevivalEffect);
                                if ((!(m_facingForward)))
                                {
                                    mc.scaleX = (mc.scaleX * -1);
                                };
                                mc.width = (mc.width * m_sizeRatio);
                                mc.height = (mc.height * m_sizeRatio);
                                mc.x = OverlayX;
                                mc.y = OverlayY;
                            };
                            this.setState(CState.IDLE);
                        }
                        else
                        {
                            this.m_revivalInvincibility.reset();
                            if (((!(currentFrameIs("revival"))) || (SpecialMode.modeEnabled(STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))))
                            {
                                this.setState(CState.IDLE);
                            }
                            else
                            {
                                if (this.m_revivalTimer >= 120)
                                {
                                    if (this.m_revivalTimer == 150)
                                    {
                                        m_sprite.y = (m_sprite.y - (30 * m_sizeRatio));
                                        this.setAlpha(0);
                                    };
                                    this.m_attemptToMove(0, m_sizeRatio);
                                    this.setAlpha((m_sprite.alpha + 4));
                                }
                                else
                                {
                                    if ((((((((this.m_heldControls.LEFT) || (this.m_heldControls.RIGHT)) || (this.m_heldControls.BUTTON2)) || (this.m_heldControls.BUTTON1)) || (this.m_heldControls.UP)) || (this.m_heldControls.DOWN)) || (this.m_heldControls.GRAB)))
                                    {
                                        if (this.m_characterStats.RevivalEffect != null)
                                        {
                                            mc = STAGEDATA.attachEffectOverlay(this.m_characterStats.RevivalEffect);
                                            if ((!(m_facingForward)))
                                            {
                                                mc.scaleX = (mc.scaleX * -1);
                                            };
                                            mc.width = (mc.width * m_sizeRatio);
                                            mc.height = (mc.height * m_sizeRatio);
                                            mc.x = OverlayX;
                                            mc.y = OverlayY;
                                        };
                                        this.setState(CState.IDLE);
                                    };
                                };
                            };
                            this.m_revivalTimer--;
                        };
                    }
                    else
                    {
                        this.setVisibility(false);
                    };
                };
            };
        }

        public function suddenDeathRespawn():void
        {
            var targets1:Vector.<MovieClip>;
            this.setVisibility(false);
            targets1 = new Vector.<MovieClip>();
            targets1.push(m_sprite);
            STAGEDATA.CamRef.addTargets(targets1);
            this.playFrame("stand");
            m_sprite.x = this.m_playerSettings.x_start;
            m_sprite.y = this.m_playerSettings.y_start;
            this.forceOnGround();
            this.setVisibility(true);
            showHealthBoxes(true);
            this.m_lives = 1;
            this.updateLivesDisplay();
            this.m_usingLives = true;
        }

        private function checkDI():void
        {
            var kbAngle:Number;
            var doTech:Boolean;
            var controlStickAngle:Number;
            var cStickAngle:Number;
            kbAngle = 0;
            doTech = false;
            if (((((((((((!((inState(CState.TECH_GROUND)) || (inState(CState.TECH_ROLL)))) && (!(m_paralysis))) && (!(this.m_smashDISelf))) && ((isHitStunOrParalysis()) || ((inState(CState.SHIELDING)) && (!(this.m_shieldDelayTimer.IsComplete))))) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))) && (!(inState(CState.CRASH_GETUP)))) && (!(inState(CState.CRASH_LAND)))) && (!(inState(CState.DEAD)))) && (!(inState(CState.STAMINA_KO)))))
            {
                controlStickAngle = Utils.getControlsAngle(this.getControls());
                if (((!(this.m_smashDIDirection === controlStickAngle)) && (!(controlStickAngle === -1))))
                {
                    kbAngle = Utils.getAngleBetween(new Point(), new Point(m_xKnockback, m_yKnockback));
                    if (((((this.m_pressedControls.UP) && (!(this.m_pressedControls.DOWN))) && (!(inState(CState.SHIELDING)))) && (!((kbAngle <= 20) || (kbAngle >= 160)))))
                    {
                        this.m_smashDIDirection = controlStickAngle;
                        doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord(m_sprite.x, ((m_sprite.y - (m_height / 2)) - this.m_smashDIAmount))));
                        if (m_collision.ground)
                        {
                            this.unnattachFromGround();
                        };
                        super.m_attemptToMove(0, -(this.m_smashDIAmount));
                        if (doTech)
                        {
                            this.performWallTech(true);
                            return;
                        };
                    }
                    else
                    {
                        if ((((this.m_pressedControls.DOWN) && (!(this.m_pressedControls.UP))) && (!(inState(CState.SHIELDING)))))
                        {
                            this.m_smashDIDirection = controlStickAngle;
                            super.m_attemptToMove(0, this.m_smashDIAmount);
                        };
                    };
                    if (((this.m_pressedControls.LEFT) && (!(this.m_pressedControls.RIGHT))))
                    {
                        this.m_smashDIDirection = controlStickAngle;
                        doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord((m_sprite.x - this.m_smashDIAmount), (m_sprite.y - (m_height / 2)))));
                        super.m_attemptToMove(-(this.m_smashDIAmount), 0);
                        this.m_groundCollisionTest();
                        if ((!(m_collision.ground)))
                        {
                            if (doTech)
                            {
                                this.performWallTech(false);
                                return;
                            };
                        };
                    }
                    else
                    {
                        if (((this.m_pressedControls.RIGHT) && (!(this.m_pressedControls.LEFT))))
                        {
                            this.m_smashDIDirection = controlStickAngle;
                            doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord((m_sprite.x + this.m_smashDIAmount), (m_sprite.y - (m_height / 2)))));
                            super.m_attemptToMove(this.m_smashDIAmount, 0);
                            this.m_groundCollisionTest();
                            if ((!(m_collision.ground)))
                            {
                                if (doTech)
                                {
                                    this.performWallTech(false);
                                    return;
                                };
                            };
                        };
                    };
                }
                else
                {
                    if (controlStickAngle === -1)
                    {
                        this.m_smashDIDirection = -1;
                    };
                };
                cStickAngle = Utils.getControlsAngle({
                    "UP":this.m_pressedControls.C_UP,
                    "DOWN":this.m_pressedControls.C_DOWN,
                    "LEFT":this.m_pressedControls.C_LEFT,
                    "RIGHT":this.m_pressedControls.C_RIGHT
                });
                if (((!(this.m_smashDIDirectionCStick === cStickAngle)) && (!(cStickAngle === -1))))
                {
                    kbAngle = Utils.getAngleBetween(new Point(), new Point(m_xKnockback, m_yKnockback));
                    if (((((this.m_pressedControls.C_UP) && (!(this.m_pressedControls.C_DOWN))) && (!(inState(CState.SHIELDING)))) && (!((kbAngle <= 20) || (kbAngle >= 160)))))
                    {
                        this.m_smashDIDirectionCStick = cStickAngle;
                        doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord(m_sprite.x, (m_sprite.y - this.m_smashDIAmount))));
                        if (m_collision.ground)
                        {
                            this.unnattachFromGround();
                        };
                        super.m_attemptToMove(0, -(this.m_smashDIAmount));
                        if (doTech)
                        {
                            this.performWallTech(true);
                            return;
                        };
                    }
                    else
                    {
                        if ((((this.m_pressedControls.C_DOWN) && (!(this.m_pressedControls.C_UP))) && (!(inState(CState.SHIELDING)))))
                        {
                            this.m_smashDIDirectionCStick = cStickAngle;
                            super.m_attemptToMove(0, this.m_smashDIAmount);
                        };
                    };
                    if (((this.m_pressedControls.C_LEFT) && (!(this.m_pressedControls.C_RIGHT))))
                    {
                        this.m_smashDIDirectionCStick = cStickAngle;
                        doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord((m_sprite.x - this.m_smashDIAmount), m_sprite.y)));
                        super.m_attemptToMove(-(this.m_smashDIAmount), 0);
                        if (m_collision.ground)
                        {
                            attachToGround();
                        };
                        if (doTech)
                        {
                            this.performWallTech(false);
                            return;
                        };
                    }
                    else
                    {
                        if (((this.m_pressedControls.C_RIGHT) && (!(this.m_pressedControls.C_LEFT))))
                        {
                            this.m_smashDIDirectionCStick = cStickAngle;
                            doTech = (((this.m_techReady) && (this.m_canWallTech)) && (testTerrainWithCoord((m_sprite.x + this.m_smashDIAmount), m_sprite.y)));
                            super.m_attemptToMove(this.m_smashDIAmount, 0);
                            if (m_collision.ground)
                            {
                                attachToGround();
                            };
                            if (doTech)
                            {
                                this.performWallTech(false);
                            };
                        };
                    };
                }
                else
                {
                    if (cStickAngle === -1)
                    {
                        this.m_smashDIDirectionCStick = -1;
                    };
                };
            };
        }

        override protected function checkHitStun():void
        {
            if (isHitStunOrParalysis())
            {
                if (m_actionShot)
                {
                    m_actionTimer--;
                    m_hitStunTimer--;
                    if (m_actionTimer < 0)
                    {
                        if (m_paralysis)
                        {
                            m_actionShot = false;
                        }
                        else
                        {
                            if ((((!(this.m_smashDISelf)) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))))
                            {
                                this.checkDI();
                            };
                            this.stopActionShot();
                        };
                    }
                    else
                    {
                        if (m_hitStunTimer <= 0)
                        {
                            m_hitStunTimer = 2;
                            m_hitStunToggle = (!(m_hitStunToggle));
                            if (HasStance)
                            {
                                m_sprite.stance.x = (m_sprite.stance.x + ((m_hitStunToggle) ? 2 : -2));
                            };
                        };
                    };
                }
                else
                {
                    if (m_paralysis)
                    {
                        m_paralysisTimer--;
                        m_hitStunTimer--;
                        if (m_paralysisTimer < 0)
                        {
                            if ((((!(this.m_smashDISelf)) && (!(inState(CState.CAUGHT)))) && (!(inState(CState.BARREL)))))
                            {
                                this.checkDI();
                            };
                            this.stopActionShot();
                        }
                        else
                        {
                            if (m_hitStunTimer <= 0)
                            {
                                m_hitStunTimer = 2;
                                m_hitStunToggle = (!(m_hitStunToggle));
                                if (HasStance)
                                {
                                    m_sprite.stance.x = (m_sprite.stance.x + ((m_hitStunToggle) ? 2 : -2));
                                };
                            };
                        };
                    };
                };
            };
            if (((((isHitStunOrParalysis()) && (m_hitStunTimer <= 0)) && (this.m_hitLag > 0)) && (currentFrameIs("hurt"))))
            {
                if (m_hitStunTimer <= 0)
                {
                    m_hitStunTimer = 2;
                    m_hitStunToggle = (!(m_hitStunToggle));
                    if (HasStance)
                    {
                        m_sprite.stance.x = (m_sprite.stance.x + ((m_hitStunToggle) ? 2 : -2));
                    };
                };
            };
        }

        public function FaceForward(value:Boolean):void
        {
            if (value)
            {
                m_faceRight();
                m_facingForward = true;
            }
            else
            {
                m_faceLeft();
                m_facingForward = false;
            };
            m_facingForward = value;
        }

        private function setAlpha(level:Number):void
        {
            if (level > 1)
            {
                level = 1;
            }
            else
            {
                if (level < 0)
                {
                    level = 0;
                };
            };
            m_sprite.alpha = level;
            if (this.m_hatMC)
            {
                this.m_hatMC.alpha = m_sprite.alpha;
            };
        }

        private function updateTint():void
        {
            if ((((m_team_id > 0) && (!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, STAGEDATA.GameRef.GameMode)))) && (m_sprite.filters == null)))
            {
                switch (m_team_id)
                {
                    case 1:
                        setTint(1, 1, 1, 1, 90, 0, 0, 0);
                        break;
                    case 2:
                        setTint(1, 1, 1, 1, 0, 90, 0, 0);
                        break;
                    case 3:
                        setTint(1, 1, 1, 1, 0, 0, 90, 0);
                        break;
                    case 4:
                        setTint(1, 1, 1, 1, 90, 72, 0, 0);
                        break;
                };
            };
        }

        public function advanceAllEffects():void
        {
            this.m_yoshiEggMC.stance.nextFrame();
            if (this.m_poisonEffect.parent)
            {
                Utils.advanceFrame(this.m_poisonEffect);
            };
        }

        public function pauseAllEffects():void
        {
            if ((((((!(this.m_starKOMC == null)) && (!(this.m_starKOMC.parent == null))) && (!(this.m_starKOMC.parent.parent == null))) && (!(this.m_starKOMC.root == null))) && (this.m_starKOMC.stance)))
            {
                MovieClip(this.m_starKOMC.parent.parent).stop();
                this.m_starKOMC.stance.stop();
            };
            this.m_pidHolderMC.visible = false;
            if (this.m_chargeGlowHolderMC != null)
            {
                Utils.recursiveMovieClipPlay(this.m_chargeGlowHolderMC, false, true);
                this.m_chargeGlowHolderMC.stop();
            };
            Utils.recursiveMovieClipPlay(this.m_shieldHolderMC, false, true);
            this.m_shieldHolderMC.stop();
            if (this.HasFinalSmash)
            {
                this.m_fsGlowHolderMC.stop();
                Utils.recursiveMovieClipPlay(this.m_fsGlowHolderMC, false, true);
            };
            if (this.m_warioWareIcon)
            {
                this.m_warioWareIcon.stop();
            };
            this.m_poisonEffect.stop();
            this.m_pitfallEffect.stop();
            this.m_burnSmoke.stop();
            this.m_darknessSmoke.stop();
            this.m_auraSmoke.stop();
            this.m_starmanInvincibility.stop();
            this.m_healEffect.stop();
            if (this.m_offScreenBubble)
            {
                this.m_offScreenBubble.visible = false;
            };
        }

        public function playAllEffects():void
        {
            var i:int;
            i = 0;
            if (this.m_chargeGlowHolderMC != null)
            {
                Utils.recursiveMovieClipPlay(this.m_chargeGlowHolderMC, true, true);
                this.m_chargeGlowHolderMC.play();
            };
            if (this.HasFinalSmash)
            {
                this.m_fsGlowHolderMC.play();
                Utils.recursiveMovieClipPlay(this.m_fsGlowHolderMC, true, true);
            };
            if ((((((!(this.m_starKOMC == null)) && (!(this.m_starKOMC.parent == null))) && (!(this.m_starKOMC.parent.parent == null))) && (!(this.m_starKOMC.root == null))) && (this.m_starKOMC.stance)))
            {
                if (((this.m_screenKO) && (!(this.m_starKOMC == null))))
                {
                    this.m_starKOMC.visible = true;
                    this.m_screenKOHolder.visible = true;
                };
                i = 0;
                while (i < STAGEDATA.Players.length)
                {
                    if (((((STAGEDATA.Players[i]) && (!(STAGEDATA.Players[i] == this))) && (STAGEDATA.Players[i].ScreenKO)) && (!(STAGEDATA.Players[i].StarKOMC == null))))
                    {
                        STAGEDATA.Players[i].StarKOMC.visible = true;
                        STAGEDATA.Players[i].ScreenKOHolder.visible = true;
                    };
                    i++;
                };
                MovieClip(this.m_starKOMC.parent.parent).nextFrame();
                Utils.recursiveMovieClipPlay(this.m_starKOMC.stance, true);
            };
            Utils.recursiveMovieClipPlay(this.m_shieldHolderMC, true, true);
            this.m_shieldHolderMC.play();
            this.m_pidHolderMC.visible = true;
            if (this.m_warioWareIcon)
            {
                this.m_warioWareIcon.play();
            };
            this.m_poisonEffect.play();
            this.m_pitfallEffect.play();
            this.m_burnSmoke.play();
            this.m_darknessSmoke.play();
            this.m_auraSmoke.play();
            this.m_starmanInvincibility.play();
            this.m_healEffect.play();
            if (this.m_offScreenBubble)
            {
                this.m_offScreenBubble.visible = true;
            };
        }

        private function checkPause():void
        {
            var i:int;
            var stockToSteal:Character;
            var candidate:Character;
            i = 0;
            stockToSteal = null;
            if ((((((((this.m_human) && (ModeFeatures.hasFeature(ModeFeatures.ALLOW_STOCK_STEAL, STAGEDATA.GameRef.GameMode))) && (!(STAGEDATA.Paused))) && (m_team_id > 0)) && (STAGEDATA.GameRef.UsingLives)) && (this.m_lives <= 0)) && (this.m_pressedControls.START)))
            {
                i = 0;
                while (i <= STAGEDATA.Players.length)
                {
                    candidate = STAGEDATA.getPlayerByID(i);
                    if (((((((((candidate) && (candidate)) && (!(candidate.ID == m_player_id))) && (candidate.Team == m_team_id)) && (!(candidate.Dead))) && (candidate.getLives() > 1)) && (!((stockToSteal) && (stockToSteal.getLives() > candidate.getLives())))) && (!(((candidate.inState(CState.SCREEN_KO)) || (candidate.inState(CState.STAR_KO))) && (candidate.getLives() <= 1)))))
                    {
                        stockToSteal = candidate;
                    };
                    i++;
                };
                if (stockToSteal)
                {
                    stockToSteal.stealStock();
                    this.m_lives++;
                    m_sprite.x = this.m_playerSettings.x_respawn;
                    m_sprite.y = this.m_playerSettings.y_respawn;
                    this.reset();
                    this.setInvincibility(true);
                    this.setState(CState.REVIVAL);
                    this.m_pauseLetGo = false;
                    showHealthBoxes(true);
                    this.updateLivesDisplay();
                };
            };
            if (((this.m_key) && (!(this.m_key.IsDown(this.m_key._START)))))
            {
                this.m_pauseLetGo = true;
            };
            if (((this.m_key) && (!(this.m_key.IsDown(this.m_key._GRAB)))))
            {
                this.m_zLetGo = true;
            };
        }

        private function updateComboValues():void
        {
            var tmp:Character;
            tmp = ((this.m_comboID > 0) ? STAGEDATA.getCharacterByUID(this.m_comboID) : null);
            if (tmp != null)
            {
                if ((!(((((((((((tmp.ActionShot) || (tmp.HitLag > 0)) || (tmp.inState(CState.CRASH_GETUP))) || (tmp.inState(CState.CRASH_LAND))) || (tmp.inState(CState.TECH_GROUND))) || (tmp.inState(CState.TECH_ROLL))) || (tmp.inState(CState.ROLL))) || (tmp.inState(CState.CRASH_GETUP))) || (tmp.inState(CState.CAUGHT))) || (tmp.inState(CState.INJURED))) || (tmp.inState(CState.FLYING)))))
                {
                    if (this.m_comboTimer.IsComplete)
                    {
                        this.m_comboCount = 0;
                        this.m_comboID = 0;
                        this.m_comboDamage = 0;
                        this.m_comboDamageTotal = 0;
                    }
                    else
                    {
                        this.m_comboTimer.tick();
                    };
                };
            };
        }

        private function checkStarKOClips():void
        {
            if ((((this.m_starKOHolder) && (this.m_starKOHolder.visible)) && (this.m_starKOHolder.currentFrame >= this.m_starKOHolder.totalFrames)))
            {
                if (((this.m_starKOMC) && (this.m_starKOMC.parent)))
                {
                    this.m_starKOMC.parent.removeChild(this.m_starKOMC);
                    this.m_starKOMC = null;
                };
                this.m_starKOHolder.visible = false;
                this.m_starKOHolder.gotoAndStop(1);
            };
            if ((((this.m_screenKOHolder) && (this.m_screenKOHolder.visible)) && (this.m_screenKOHolder.currentFrame >= this.m_screenKOHolder.totalFrames)))
            {
                if (((this.m_starKOMC) && (this.m_starKOMC.parent)))
                {
                    this.m_starKOMC.parent.removeChild(this.m_starKOMC);
                    this.m_starKOMC = null;
                };
                this.m_screenKOHolder.visible = false;
                this.m_screenKOHolder.gotoAndStop(1);
            };
        }

        public function pauseControlChecks():void
        {
            var i:int;
            var left:Boolean;
            var right:Boolean;
            var up:Boolean;
            var down:Boolean;
            var b:Boolean;
            var a:Boolean;
            var shield:Boolean;
            var grab:Boolean;
            var pause:Boolean;
            if ((!(this.m_pauseFreeze)))
            {
                this.m_pauseFreeze = true;
                if (HasStance)
                {
                    MC.stance.stop();
                };
                this.pauseAllEffects();
                this.m_pauseLetGo = false;
                this.m_zLetGo = false;
                Utils.recursiveMovieClipPlay(m_sprite.stance, false);
            };
            this.m_getKey();
            i = 0;
            if (((this.m_human) && (m_player_id == STAGEDATA.PausedID)))
            {
                if (((this.m_key.getControlStatus().BUTTON2) && (!(this.m_key.getControlStatus().BUTTON1))))
                {
                    CAM.zoomIn();
                    if (CAM.Height < STAGEDATA.PauseCamHeight)
                    {
                        if (((this.m_screenKO) && (!(this.m_starKOMC == null))))
                        {
                            this.m_starKOMC.visible = false;
                            this.m_screenKOHolder.visible = false;
                        };
                        i = 0;
                        while (i < STAGEDATA.Players.length)
                        {
                            if (((((STAGEDATA.Players[i]) && (!(STAGEDATA.Players[i] == this))) && (STAGEDATA.Players[i].ScreenKO)) && (!(STAGEDATA.Players[i].StarKOMC == null))))
                            {
                                STAGEDATA.Players[i].StarKOMC.visible = false;
                                STAGEDATA.Players[i].ScreenKOHolder.visible = false;
                            };
                            i++;
                        };
                    };
                }
                else
                {
                    if (((this.m_key.getControlStatus().BUTTON1) && (!(this.m_key.getControlStatus().BUTTON2))))
                    {
                        CAM.zoomOut();
                        if (CAM.Height >= STAGEDATA.PauseCamHeight)
                        {
                            if (((this.m_screenKO) && (!(this.m_starKOMC == null))))
                            {
                                this.m_starKOMC.visible = true;
                                this.m_screenKOHolder.visible = true;
                            };
                            i = 0;
                            while (i < STAGEDATA.Characters.length)
                            {
                                if (((((STAGEDATA.Characters[i]) && (!(STAGEDATA.Characters[i] == this))) && (STAGEDATA.Characters[i].ScreenKO)) && (!(STAGEDATA.Characters[i].StarKOMC == null))))
                                {
                                    STAGEDATA.Characters[i].StarKOMC.visible = true;
                                    STAGEDATA.Characters[i].ScreenKOHolder.visible = true;
                                };
                                i++;
                            };
                        };
                    };
                };
                if (this.m_key.getControlStatus().LEFT !== this.m_key.getControlStatus().RIGHT)
                {
                    if (this.m_key.getControlStatus().LEFT)
                    {
                        if (this.m_pauseCamXSpeed > 0)
                        {
                            this.m_pauseCamXSpeed = 0;
                        };
                        CAM.panLeft((CAM.CamMC.scaleX * -(this.m_pauseCamXSpeed)));
                        this.m_pauseCamXSpeed = (this.m_pauseCamXSpeed - this.PAUSE_CAM_ACCEL);
                        if (this.m_pauseCamXSpeed < -(this.PAUSE_CAM_MAX_SPEED))
                        {
                            this.m_pauseCamXSpeed = -(this.PAUSE_CAM_MAX_SPEED);
                        };
                    }
                    else
                    {
                        if (this.m_key.getControlStatus().RIGHT)
                        {
                            if (this.m_pauseCamXSpeed < 0)
                            {
                                this.m_pauseCamXSpeed = 0;
                            };
                            CAM.panRight((CAM.CamMC.scaleX * this.m_pauseCamXSpeed));
                            this.m_pauseCamXSpeed = (this.m_pauseCamXSpeed + this.PAUSE_CAM_ACCEL);
                            if (this.m_pauseCamXSpeed > this.PAUSE_CAM_MAX_SPEED)
                            {
                                this.m_pauseCamXSpeed = this.PAUSE_CAM_MAX_SPEED;
                            };
                        };
                    };
                }
                else
                {
                    this.m_pauseCamXSpeed = 0;
                };
                if (this.m_key.getControlStatus().DOWN !== this.m_key.getControlStatus().UP)
                {
                    if (this.m_key.getControlStatus().DOWN)
                    {
                        if (this.m_pauseCamYSpeed < 0)
                        {
                            this.m_pauseCamYSpeed = 0;
                        };
                        CAM.panDown((CAM.CamMC.scaleX * this.m_pauseCamYSpeed));
                        this.m_pauseCamYSpeed = (this.m_pauseCamYSpeed + this.PAUSE_CAM_ACCEL);
                        if (this.m_pauseCamYSpeed > this.PAUSE_CAM_MAX_SPEED)
                        {
                            this.m_pauseCamYSpeed = this.PAUSE_CAM_MAX_SPEED;
                        };
                    }
                    else
                    {
                        if (this.m_key.getControlStatus().UP)
                        {
                            if (this.m_pauseCamYSpeed > 0)
                            {
                                this.m_pauseCamYSpeed = 0;
                            };
                            CAM.panUp((CAM.CamMC.scaleX * -(this.m_pauseCamYSpeed)));
                            this.m_pauseCamYSpeed = (this.m_pauseCamYSpeed - this.PAUSE_CAM_ACCEL);
                            if (this.m_pauseCamYSpeed < -(this.PAUSE_CAM_MAX_SPEED))
                            {
                                this.m_pauseCamYSpeed = -(this.PAUSE_CAM_MAX_SPEED);
                            };
                        };
                    };
                }
                else
                {
                    this.m_pauseCamYSpeed = 0;
                };
            }
            else
            {
                if (((!(STAGEDATA.GameEnded)) && (m_player_id == STAGEDATA.PausedID)))
                {
                    left = (((this.m_key.IsDown(this.m_key._LEFT)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._LEFT)))) ? true : false);
                    right = (((this.m_key.IsDown(this.m_key._RIGHT)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._RIGHT)))) ? true : false);
                    up = (((this.m_key.IsDown(this.m_key._UP)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._UP)))) ? true : false);
                    down = (((this.m_key.IsDown(this.m_key._DOWN)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._DOWN)))) ? true : false);
                    b = ((this.m_key.IsDown(this.m_key._BUTTON1)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._BUTTON1))));
                    a = ((this.m_key.IsDown(this.m_key._BUTTON2)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._BUTTON2))));
                    shield = ((this.m_key.IsDown(this.m_key._SHIELD)) ? true : false);
                    grab = ((this.m_key.IsDown(this.m_key._GRAB)) ? true : false);
                    pause = ((STAGEDATA.PausedID == m_player_id) ? ((this.m_key.IsDown(this.m_key._START)) || ((STAGEDATA.getPlayerByID(1) == null) && (STAGEDATA.getControllerNum(1).IsDown(STAGEDATA.getControllerNum(1)._START)))) : this.m_key.getControlStatus().START);
                    if (((a) && (!(b))))
                    {
                        CAM.zoomIn();
                        if (CAM.Height < STAGEDATA.PauseCamHeight)
                        {
                            if (((this.m_screenKO) && (!(this.m_starKOMC == null))))
                            {
                                this.m_starKOMC.visible = false;
                                this.m_screenKOHolder.visible = false;
                            };
                            i = 0;
                            while (i < STAGEDATA.Characters.length)
                            {
                                if (((((STAGEDATA.Characters[i]) && (!(STAGEDATA.Characters[i] == this))) && (STAGEDATA.Characters[i].ScreenKO)) && (!(STAGEDATA.Characters[i].StarKOMC == null))))
                                {
                                    STAGEDATA.Characters[i].StarKOMC.visible = false;
                                    STAGEDATA.Characters[i].ScreenKOHolder.visible = false;
                                };
                                i++;
                            };
                        };
                    }
                    else
                    {
                        if (((b) && (!(a))))
                        {
                            CAM.zoomOut();
                            if (CAM.Height >= STAGEDATA.PauseCamHeight)
                            {
                                if (((this.m_screenKO) && (!(this.m_starKOMC == null))))
                                {
                                    this.m_starKOMC.visible = true;
                                    this.m_screenKOHolder.visible = true;
                                };
                                i = 0;
                                while (i < STAGEDATA.Characters.length)
                                {
                                    if (((((STAGEDATA.Characters[i]) && (!(STAGEDATA.Characters[i] == this))) && (STAGEDATA.Characters[i].ScreenKO)) && (!(STAGEDATA.Characters[i].StarKOMC == null))))
                                    {
                                        STAGEDATA.Characters[i].StarKOMC.visible = false;
                                        STAGEDATA.Characters[i].ScreenKOHolder.visible = false;
                                    };
                                    i++;
                                };
                            };
                        };
                    };
                    if (left !== right)
                    {
                        if (left)
                        {
                            if (this.m_pauseCamXSpeed > 0)
                            {
                                this.m_pauseCamXSpeed = 0;
                            };
                            CAM.panLeft((CAM.CamMC.scaleX * -(this.m_pauseCamXSpeed)));
                            this.m_pauseCamXSpeed = (this.m_pauseCamXSpeed - this.PAUSE_CAM_ACCEL);
                            if (this.m_pauseCamXSpeed < -(this.PAUSE_CAM_MAX_SPEED))
                            {
                                this.m_pauseCamXSpeed = -(this.PAUSE_CAM_MAX_SPEED);
                            };
                        }
                        else
                        {
                            if (right)
                            {
                                if (this.m_pauseCamXSpeed < 0)
                                {
                                    this.m_pauseCamXSpeed = 0;
                                };
                                CAM.panRight((CAM.CamMC.scaleX * this.m_pauseCamXSpeed));
                                this.m_pauseCamXSpeed = (this.m_pauseCamXSpeed + this.PAUSE_CAM_ACCEL);
                                if (this.m_pauseCamXSpeed > this.PAUSE_CAM_MAX_SPEED)
                                {
                                    this.m_pauseCamXSpeed = this.PAUSE_CAM_MAX_SPEED;
                                };
                            };
                        };
                    }
                    else
                    {
                        this.m_pauseCamXSpeed = 0;
                    };
                    if (down !== up)
                    {
                        if (down)
                        {
                            if (this.m_pauseCamYSpeed < 0)
                            {
                                this.m_pauseCamYSpeed = 0;
                            };
                            CAM.panDown((CAM.CamMC.scaleX * this.m_pauseCamYSpeed));
                            this.m_pauseCamYSpeed = (this.m_pauseCamYSpeed + this.PAUSE_CAM_ACCEL);
                            if (this.m_pauseCamYSpeed > this.PAUSE_CAM_MAX_SPEED)
                            {
                                this.m_pauseCamYSpeed = this.PAUSE_CAM_MAX_SPEED;
                            };
                        }
                        else
                        {
                            if (up)
                            {
                                if (this.m_pauseCamYSpeed > 0)
                                {
                                    this.m_pauseCamYSpeed = 0;
                                };
                                CAM.panUp((CAM.CamMC.scaleX * -(this.m_pauseCamYSpeed)));
                                this.m_pauseCamYSpeed = (this.m_pauseCamYSpeed - this.PAUSE_CAM_ACCEL);
                                if (this.m_pauseCamYSpeed < -(this.PAUSE_CAM_MAX_SPEED))
                                {
                                    this.m_pauseCamYSpeed = -(this.PAUSE_CAM_MAX_SPEED);
                                };
                            };
                        };
                    }
                    else
                    {
                        this.m_pauseCamYSpeed = 0;
                    };
                };
            };
            this.checkPause();
        }

        override public function PERFORMALL():void
        {
            this.PREPERFORM();
            if (((((!(inState(CState.DEAD))) && (!(STAGEDATA.Paused))) && (!((((STAGEDATA.FSCutscene) || (STAGEDATA.FSCutins > 0)) && (!(this.m_usingSpecialAttack))) && (!(this.m_finalSmashCutinMC))))) && (!(this.m_standby))))
            {
                this.m_getKey();
                this.checkRecovery();
                this.checkFrameControl();
                this.advanceAllEffects();
                this.checkTimers();
                this.checkHitLag();
                this.m_checkRevival();
                this.m_checkBounds();
                this.m_checkDeath();
                this.m_checkInvincible();
                this.m_checkStun();
                this.m_checkDizzy();
                this.m_checkPitfall();
                this.m_checkFrozen();
                this.m_checkSleeping();
                this.m_checkEgg();
                this.m_checkTeching();
                this.m_forces();
                this.m_groundCollisionTest();
                this.m_checkItem();
                this.m_charShield();
                this.m_charGrab();
                this.m_charJump();
                this.m_charAttack();
                this.m_charRoll();
                this.m_charHang();
                this.m_charCrouch();
                this.m_charRun();
                this.m_charWallCling();
                this.m_charFall();
                this.m_charGlide();
                this.m_checkTaunt();
                this.m_pushAwayItems();
                this.m_pushAwayOpponents();
                this.pushAwayFromWalls();
                this.m_checkFinalForm();
                this.m_flipDirection();
                this.checkRocket();
                this.checkDI();
                updateSelfPlatform();
                this.getLastYPosition();
                this.checkFrameControl();
                this.updateTint();
                this.checkHitStun();
                this.updateComboValues();
                this.checkPause();
                this.m_pauseFreeze = false;
                checkShowHitBoxes();
                this.positionEffects();
                this.checkStarKOClips();
                this.checkSyncedProjectiles();
                this.checkDeadProjectiles();
                this.updateItemHolding();
                updateCamerBox();
            }
            else
            {
                if (((inState(CState.DEAD)) || ((!(inState(CState.DEAD))) && (this.m_standby))))
                {
                    if ((!(this.m_standby)))
                    {
                        this.m_getKey();
                        this.checkPause();
                        this.m_pauseFreeze = false;
                    };
                    this.checkStarKOClips();
                };
            };
            this.POSTPERFORM();
        }

        override protected function PREPERFORM():void
        {
            if (((Main.DEBUG) && (MenuController.debugConsole.OnlineCapture)))
            {
                this.m_preFrameInfo = this.getFrameData();
            };
            if ((((((((((m_started) && (HasStance)) && (!(inState(CState.DEAD)))) && (!(this.m_standby))) && (!(this.m_freezePlayback))) && (!(STAGEDATA.Paused))) && (!(((STAGEDATA.FSCutscene) || (STAGEDATA.FSCutins > 0)) && (!(this.m_usingSpecialAttack))))) && (!(isHitStunOrParalysis()))) && (!(m_delayPlayback))))
            {
                Utils.advanceFrame(m_sprite.stance);
                Utils.recursiveMovieClipPlay(m_sprite.stance, true);
            }
            else
            {
                handleDelayPlayback();
            };
            if (((((((((((!(STAGEDATA.Paused)) && (!(((STAGEDATA.FSCutscene) || (STAGEDATA.FSCutins > 0)) && (!(this.m_usingSpecialAttack))))) && (m_started)) && (!(this.m_starKOMC == null))) && (!(this.m_starKOMC.parent == null))) && (!(this.m_starKOMC.parent.parent == null))) && (!(this.m_starKOMC.root == null))) && (this.m_starKOMC.stance)) && (!(this.m_freezePlayback))) && (this.m_starKOMC.visible)))
            {
                MovieClip(this.m_starKOMC.parent.parent).nextFrame();
                Utils.recursiveMovieClipPlay(this.m_starKOMC.stance, true);
                Utils.advanceFrame(this.m_starKOMC.stance);
            };
        }

        override protected function POSTPERFORM():void
        {
            if (((!(STAGEDATA.Paused)) && (!(((STAGEDATA.FSCutscene) || (STAGEDATA.FSCutins > 0)) && (!(this.m_usingSpecialAttack))))))
            {
                if (HasStance)
                {
                    m_sprite.stance.stop();
                    Utils.recursiveMovieClipPlay(m_sprite.stance, false);
                    this.updatePaletteSwap();
                    this.checkOffScreenBubble();
                    this.checkReflection();
                    this.checkShadow();
                };
                if ((((((!(this.m_starKOMC == null)) && (!(this.m_starKOMC.parent == null))) && (!(this.m_starKOMC.parent.parent == null))) && (!(this.m_starKOMC.root == null))) && (this.m_starKOMC.stance)))
                {
                    MovieClip(this.m_starKOMC.parent.parent).stop();
                    Utils.recursiveMovieClipPlay(this.m_starKOMC.stance, false);
                    this.m_starKOMC.stance.stop();
                };
                m_started = true;
                m_apiInstance.update();
            };
            if ((((((!(STAGEDATA.Paused)) && (m_player_id > 0)) && (!(STAGEDATA.ReplayMode))) && (ModeFeatures.hasFeature(ModeFeatures.ALLOW_REPLAY_RECORD, STAGEDATA.GameRef.GameMode))) && (this.m_human)))
            {
                STAGEDATA.ReplayDataObj.pushControls(m_player_id, this.m_key.getControlsObject().controls);
            };
        }

        public function fliplocation(facing:Boolean):void
        {
            if ((!(facing)))
            {
                m_faceLeft();
            }
            else
            {
                m_faceRight();
            };
        }


    }
}//package com.mcleodgaming.ssf2.engine
