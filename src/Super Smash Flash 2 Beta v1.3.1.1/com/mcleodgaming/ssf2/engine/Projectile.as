// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.Projectile

package com.mcleodgaming.ssf2.engine
{
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import flash.geom.Point;
    import com.mcleodgaming.ssf2.api.SSF2Projectile;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.Main;
    import com.mcleodgaming.ssf2.platforms.Platform;
    import com.mcleodgaming.ssf2.api.SSF2Event;
    import com.mcleodgaming.ssf2.enums.PState;
    import com.mcleodgaming.ssf2.audio.SoundObject;
    import com.mcleodgaming.ssf2.enemies.Enemy;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.items.Item;
    import com.mcleodgaming.ssf2.enums.TState;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.enums.CState;
    import flash.geom.Rectangle;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.enemies.*;
    import com.mcleodgaming.ssf2.util.*;

    public class Projectile extends InteractiveSprite 
    {

        public static const ATTACK_IDLE:String = "attack_idle";

        protected var m_owner:InteractiveSprite;
        private var m_strengthNormalAttack:Boolean = false;
        private var m_bounce_total:int;
        private var m_xSpeedInit:Number;
        private var m_ySpeedInit:Number;
        private var m_x_start:Number;
        private var m_y_start:Number;
        private var m_time:int;
        private var m_attachedEffect:Boolean;
        private var m_trailEffectTimer:int;
        private var m_homingAngle:Number;
        private var m_reverseTimer:int;
        private var m_wasReversed:Boolean;
        private var m_damageWasDone:Boolean;
        private var m_x_influence:Number;
        private var m_y_influence:Number;
        private var m_angle:Number;
        private var m_latch_id:InteractiveSprite;
        private var m_latch_xLoc:Number;
        private var m_latch_yLoc:Number;
        private var m_hasSwitched:Boolean;
        private var m_rocketReadyTimer:FrameTimer;
        private var m_lastSFX:int;
        private var m_lastVFX:int;
        private var m_volume_sfx:Number;
        private var m_volume_vfx:Number;
        private var m_projectileStats:ProjectileAttack;
        private var m_projectileStatsOriginal:ProjectileAttack;
        private var __attemptToMovePointCache:Point = new Point();

        public function Projectile(parameters:Object, projectileAttack:ProjectileAttack, stageData:StageData)
        {
            stageData.addProjectile(this);
            m_baseStats = (this.m_projectileStats = new ProjectileAttack());
            this.m_projectileStats.importData(projectileAttack.exportData());
            this.m_projectileStatsOriginal = new ProjectileAttack();
            m_apiInstance = new SSF2Projectile(this.m_projectileStats.ClassAPI, this);
            this.m_projectileStats.importData(m_apiInstance.getOwnStats());
            this.m_owner = parameters["owner"];
            this.m_strengthNormalAttack = this.isStrengthNormalAttackSource(this.m_owner);
            var tmpMC:MovieClip = ResourceManager.getLibraryMC(this.m_projectileStats.LinkageID);
            tmpMC.ACTIVE = true;
            super(tmpMC, stageData);
            m_player_id = parameters["player_id"];
            m_attackData = this.m_projectileStats.AttackDataObj;
            m_attackData.Owner = this;
            m_shadowEffect = new MovieClip();
            var effectID:String;
            m_xSpeed = ((parameters["facingForward"]) ? this.m_projectileStats.XSpeed : -(this.m_projectileStats.XSpeed));
            this.m_xSpeedInit = m_xSpeed;
            m_ySpeed = this.m_projectileStats.YSpeed;
            this.m_ySpeedInit = this.m_projectileStats.YSpeed;
            this.m_bounce_total = 0;
            this.m_x_start = parameters["x_start"];
            this.m_y_start = parameters["y_start"];
            m_sizeRatio = parameters["sizeRatio"];
            if ((this.m_owner is Character))
            {
                this.m_volume_sfx = parameters["volume_sfx"];
                this.m_volume_vfx = parameters["volume_vfx"];
            }
            else
            {
                this.m_volume_sfx = 1;
                this.m_volume_vfx = 1;
            };
            m_sprite.width = (m_sprite.width * m_sizeRatio);
            m_sprite.height = (m_sprite.height * m_sizeRatio);
            m_width = this.m_projectileStats.Width;
            m_height = this.m_projectileStats.Height;
            m_facingForward = parameters["facingForward"];
            m_sprite.x = this.m_x_start;
            m_sprite.y = this.m_y_start;
            this.m_hasSwitched = false;
            if (((this.m_projectileStats.InheritPalette) && (this.m_owner is Character)))
            {
                this.m_owner.applyPalette(m_sprite);
                setPaletteSwap(this.m_owner.PaletteSwapData, this.m_owner.PaletteSwapPAData);
            };
            m_lastAttackID = new Array(15);
            m_lastAttackIndex = 0;
            this.m_x_influence = 0;
            this.m_y_influence = 0;
            this.m_lastSFX = -1;
            this.m_lastVFX = -1;
            this.m_rocketReadyTimer = new FrameTimer(5);
            this.m_latch_id = null;
            this.m_latch_xLoc = 0;
            this.m_latch_yLoc = 0;
            this.m_reverseTimer = 0;
            this.m_wasReversed = false;
            m_terrains = parameters["terrains"];
            m_platforms = parameters["platforms"];
            this.m_homingAngle = Utils.forceBase360(Utils.getAngleBetween(new Point(), new Point(m_xSpeed, m_ySpeed)));
            this.m_trailEffectTimer = 0;
            this.m_attachedEffect = false;
            this.m_damageWasDone = false;
            m_sprite.player_id = m_player_id;
            m_sprite.uid = m_uid;
            m_sprite.cam_width = m_width;
            m_sprite.cam_height = m_height;
            m_currentPlatform = null;
            m_collision = new Collision();
            if ((!(m_facingForward)))
            {
                this.m_faceLeft();
            };
            this.m_time = 0;
            if (((this.m_owner) && (this.m_owner.AttackStateData)))
            {
                m_attack.AttackRatio = this.m_owner.AttackStateData.AttackRatio;
            };
            m_attack.importAttackStateData(this.m_projectileStats.exportAttackStateData());
            m_attack.ID = Utils.getUID();
            m_attack.XLoc = m_sprite.x;
            m_attack.YLoc = m_sprite.y;
            m_attack.IsForward = m_facingForward;
            m_attack.ChargeTime = parameters["chargetime"];
            m_attack.ChargeTimeMax = parameters["chargetime_max"];
            m_attack.Frame = Projectile.ATTACK_IDLE;
            m_attack.SizeStatus = parameters["sizeStatus"];
            m_attack.ExecTime = 0;
            m_attack.RefreshRate = m_attackData.getAttack(m_attack.Frame).RefreshRate;
            m_attack.ForceComboContinue = m_attackData.getAttack(m_attack.Frame).ForceComboContinue;
            m_attack.RefreshRateReady = false;
            m_attackData.getAttack(m_attack.Frame).OverrideMap.clear();
            m_attack.StaleMultiplier = parameters["staleMultiplier"];
            m_attack.IsAttacking = true;
            m_team_id = parameters["team_id"];
            if ((((this.m_owner is Character) && (this.m_owner.AttackStateData.IsAttacking)) && (this.m_owner.AttackStateData.IsThrow)))
            {
                m_attack.IsThrow = true;
            };
            m_started = false;
            buildHitBoxData(this.m_projectileStats.LinkageID);
            if (Main.DEBUG)
            {
                verifiyHitBoxData();
            };
            m_apiInstance = new SSF2Projectile(this.m_projectileStats.ClassAPI, this);
            m_attackData.importAttacks(m_apiInstance.getAttackStats());
            m_attackData.importItems(m_apiInstance.getItemStats());
            m_attackData.importProjectiles(m_apiInstance.getProjectileStats());
            m_attack.AttackID = ((this.m_projectileStats.LinkAttackID) ? this.m_owner.AttackStateData.AttackID : Utils.getUID());
            if (this.m_projectileStats.ControlDirection >= 0)
            {
                this.m_projectileStats.importData({"controlDirection":Utils.forceBase360(this.m_projectileStats.ControlDirection)});
                this.m_angle = this.m_projectileStats.ControlDirection;
                m_xSpeed = Utils.fastAbs(m_xSpeed);
                this.m_xSpeedInit = m_xSpeed;
                this.angleControl(this.m_xSpeedInit, this.m_projectileStats.ControlDirection);
            }
            else
            {
                this.m_angle = 0;
            };
            if (((this.m_projectileStats.LockSize) && (this.m_owner is Character)))
            {
                m_sizeRatio = Character(this.m_owner).OriginalSizeRatio;
            };
            this.m_projectileStatsOriginal.importDataCopy(this.m_projectileStats);
            this.syncStats();
            m_apiInstance.initialize();
            playFrame(m_attack.Frame);
        }

        override public function get CurrentAnimation():HitBoxAnimation
        {
            return ((m_hitBoxManager == null) ? null : (((m_hitBoxManager.HitBoxAnimationList.length <= 0) || (!(m_currentAnimationID))) ? null : m_hitBoxManager.getHitBoxAnimation(((this.m_projectileStats.LinkageID + "_") + m_currentAnimationID))));
        }

        override public function m_attemptToMove(xSpeed:Number, ySpeed:Number):void
        {
            var i:int;
            var origLocation:Point;
            var hitGround:Platform;
            var hasHit:Boolean;
            var angle:Number;
            var divisions:int;
            var wallHit:Boolean;
            if ((!((xSpeed == 0) && (ySpeed == 0))))
            {
                i = 0;
                m_collision.leftSide = (((xSpeed < 0) && (m_collision.ground)) && (testTerrainWithCoord(((m_sprite.x + xSpeed) - this.m_projectileStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_projectileStats.KneeYOffset))));
                m_collision.rightSide = (((xSpeed > 0) && (m_collision.ground)) && (testTerrainWithCoord(((m_sprite.x + xSpeed) + this.m_projectileStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_projectileStats.KneeYOffset))));
                if ((((!(m_collision.ground)) && (!(this.m_projectileStats.Ghost))) && (!(this.m_projectileStats.Latch))))
                {
                    origLocation = this.__attemptToMovePointCache;
                    origLocation.copyFrom(Location);
                    hitGround = moveSprite(xSpeed, ySpeed);
                    hasHit = (!(hitGround == null));
                    if ((((m_collision.rightSide) && (xSpeed > 0)) || ((m_collision.leftSide) && (xSpeed < 0))))
                    {
                        m_sprite.x = origLocation.x;
                    };
                    angle = Utils.getAngleBetween(new Point(origLocation.x, origLocation.y), new Point(m_sprite.x, m_sprite.y));
                    if (((hasHit) && (!((angle >= 225) && (angle <= 315)))))
                    {
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                            "caller":this.APIInstance.instance,
                            "left":((angle < 225) && (angle > 135)),
                            "right":(((angle < 45) && (angle >= 0)) || ((angle <= 360) && (angle > 315))),
                            "top":((angle >= 45) && (angle >= 135))
                        }));
                    };
                    if (((hasHit) && (ySpeed >= 0)))
                    {
                        this.m_groundCollisionTest();
                    };
                    if (((hasHit) && (this.m_projectileStats.Sticky)))
                    {
                        this.stick();
                    };
                    if (this.m_projectileStats.Boomerang)
                    {
                        if ((((hasHit) || ((m_collision.leftSide) && (m_xSpeed < 0))) || ((m_collision.rightSide) && (m_xSpeed > 0))))
                        {
                            this.m_hasSwitched = true;
                            m_xSpeed = (m_xSpeed * -1);
                            m_ySpeed = (m_ySpeed * -1);
                        };
                    };
                }
                else
                {
                    if (((!(this.m_projectileStats.Ghost)) && (!(this.m_projectileStats.Latch))))
                    {
                        divisions = 10;
                        xSpeed = (xSpeed / divisions);
                        ySpeed = (ySpeed / divisions);
                        wallHit = false;
                        i = 0;
                        while (((i < divisions) && (!(inState(PState.DEAD)))))
                        {
                            m_collision.leftSide = (((xSpeed < 0) && (m_collision.ground)) && (testTerrainWithCoord(((m_sprite.x + xSpeed) - this.m_projectileStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_projectileStats.KneeYOffset))));
                            m_collision.rightSide = (((xSpeed > 0) && (m_collision.ground)) && (testTerrainWithCoord(((m_sprite.x + xSpeed) + this.m_projectileStats.KneeXOffset), ((m_sprite.y + ySpeed) + this.m_projectileStats.KneeYOffset))));
                            if (((m_collision.leftSide) || (m_collision.rightSide)))
                            {
                                wallHit = true;
                            };
                            if (((ySpeed < 0) && (!(testTerrainWithCoord(m_sprite.x, (m_sprite.y + ySpeed))))))
                            {
                                m_sprite.y = (m_sprite.y + ySpeed);
                            };
                            m_sprite.x = (m_sprite.x + ((!((((!(this.m_projectileStats.Ghost)) && (m_collision.rightSide)) && (xSpeed > 0)) || (((!(this.m_projectileStats.Ghost)) && (m_collision.leftSide)) && (xSpeed < 0)))) ? xSpeed : 0));
                            if (((ySpeed > 0) && (!(testTerrainWithCoord(m_sprite.x, (m_sprite.y + ySpeed))))))
                            {
                                m_sprite.y = (m_sprite.y + ySpeed);
                            };
                            if ((!(inState(PState.DEAD))))
                            {
                                this.attachToGround();
                            };
                            i++;
                        };
                        if (wallHit)
                        {
                            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                                "caller":this.APIInstance.instance,
                                "left":m_collision.leftSide,
                                "right":m_collision.rightSide,
                                "top":false
                            }));
                            if (this.m_projectileStats.Boomerang)
                            {
                                if ((((m_collision.leftSide) && (m_xSpeed < 0)) || ((m_collision.rightSide) && (m_xSpeed > 0))))
                                {
                                    this.m_hasSwitched = true;
                                    m_xSpeed = (m_xSpeed * -1);
                                    m_ySpeed = (m_ySpeed * -1);
                                };
                            };
                        };
                    }
                    else
                    {
                        m_sprite.x = (m_sprite.x + xSpeed);
                        m_sprite.y = (m_sprite.y + ySpeed);
                    };
                };
            };
        }

        override protected function m_groundCollisionTest():void
        {
            var wasHittingGround:Boolean;
            var onGround:Boolean;
            if (this.m_projectileStats.Suspend)
            {
                return;
            };
            if ((((((!(this.m_projectileStats.Ghost)) && (!(inState(PState.DEAD)))) && (m_ySpeed >= 0)) && (!(this.m_projectileStats.Latch))) && (this.m_projectileStats.RideGround)))
            {
                wasHittingGround = m_collision.ground;
                if (((m_collision.ground) && (!(m_ySpeed < 0))))
                {
                    this.attachToGround();
                };
                onGround = (!((m_currentPlatform = testGroundWithCoord(m_sprite.x, (m_sprite.y + 1))) == null));
                m_currentPlatform = testGroundWithCoord(m_sprite.x, (m_sprite.y + 1));
                m_collision.ground = onGround;
                if (m_collision.ground)
                {
                    this.attachToGround();
                };
                if ((((!(inState(PState.DEAD))) && (m_collision.ground)) && (!(wasHittingGround))))
                {
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_TOUCH, {"caller":this.APIInstance.instance}));
                }
                else
                {
                    if ((((!(inState(PState.DEAD))) && (!(m_collision.ground))) && (wasHittingGround)))
                    {
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_LEAVE, {"caller":this.APIInstance.instance}));
                    };
                };
            };
        }

        private function getGround(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            i = 0;
            while (((i < m_terrains.length) && (!(m_terrains[i].hitTestPoint(xpos, (ypos + 1), true)))))
            {
                i++;
            };
            if (((((i < m_terrains.length) && (m_terrains[i].hitTestPoint(xpos, (ypos + 1), true))) && (!(m_terrains[i].fallthrough == true))) && (!(m_terrains[i].shouldIgnore(this)))))
            {
                return (m_terrains[i]);
            };
            i = 0;
            while (((i < m_platforms.length) && (!(m_platforms[i].hitTestPoint(xpos, (ypos + 1), true)))))
            {
                i++;
            };
            if ((((((i < m_platforms.length) && (m_platforms[i].hitTestPoint(xpos, (ypos + 1), true))) && (m_ySpeed >= 0)) && (!(m_platforms[i].fallthrough == true))) && (!(m_platforms[i].shouldIgnore(this)))))
            {
                return (m_platforms[i]);
            };
            return (null);
        }

        override protected function m_faceRight():void
        {
            if (m_delayPlayback)
            {
                m_delayPlayBackFacingRight = true;
            };
            if (((!(this.m_projectileStats.NoFlip)) && (!(m_delayPlayback))))
            {
                m_sprite.scaleX = Math.abs(m_sprite.scaleX);
            };
            m_facingForward = true;
        }

        override protected function m_faceLeft():void
        {
            if (m_delayPlayback)
            {
                m_delayPlayBackFacingRight = false;
            };
            if (((!(this.m_projectileStats.NoFlip)) && (!(m_delayPlayback))))
            {
                m_sprite.scaleX = -(Math.abs(m_sprite.scaleX));
            };
            m_facingForward = false;
        }

        override public function attachToGround():Boolean
        {
            var i:int;
            var j:int;
            var result:Boolean = true;
            if (((!(m_ySpeed < 0)) && (this.m_projectileStats.RideGround)))
            {
                j = 0;
                i = (m_sprite.y + 20);
                while (((m_sprite.y < i) && (!(testCoordCollision(m_sprite.x, m_sprite.y)))))
                {
                    m_sprite.y++;
                };
                this.checkIfDead();
                if (((!(testCoordCollision(m_sprite.x, m_sprite.y))) || (inState(PState.DEAD))))
                {
                    m_sprite.y = (i - 20);
                };
                if (((!(m_currentPlatform == null)) && (m_ySpeed >= 0)))
                {
                    j = 0;
                    if (((!(m_currentPlatform.fallthrough == true)) && (!(m_currentPlatform.shouldIgnore(this)))))
                    {
                        while (m_currentPlatform.hitTestPoint(GlobalX, GlobalY, true))
                        {
                            m_sprite.y = (m_sprite.y - (1 / 4));
                            j = int((j + (1 / 4)));
                        };
                    };
                    this.checkIfDead();
                    if ((((j >= (STAGEDATA.Terrains.indexOf(m_currentPlatform) >= 0)) ? 40 : 10) || (inState(PState.DEAD))))
                    {
                        m_sprite.y = (m_sprite.y + j);
                        if (((this.m_projectileStats.Sticky) && (OnTerrain)))
                        {
                            this.stick();
                        };
                        result = false;
                    };
                }
                else
                {
                    result = false;
                };
            }
            else
            {
                result = false;
            };
            return (result);
        }

        public function get ProjectileAttackObj():ProjectileAttack
        {
            return (this.m_projectileStats);
        }

        public function get Dead():Boolean
        {
            return (inState(PState.DEAD));
        }

        public function get Attack():AttackState
        {
            return (m_attack);
        }

        public function get Visible():Boolean
        {
            return (m_sprite.visible);
        }

        public function get LinkageID():String
        {
            return (this.m_projectileStats.LinkageID);
        }

        public function get TeamID():int
        {
            return (m_team_id);
        }

        public function get Time():int
        {
            return (this.m_time);
        }

        public function get Instance():MovieClip
        {
            return (m_sprite);
        }

        public function get Latched():Boolean
        {
            return (!(this.m_latch_id == null));
        }

        public function get LatchID():InteractiveSprite
        {
            return (this.m_latch_id);
        }

        public function get WasReversed():Boolean
        {
            return (this.m_wasReversed);
        }

        public function get JustReversed():Boolean
        {
            return (Boolean((this.m_reverseTimer > 0)));
        }

        public function isReversed():Boolean
        {
            return (this.m_wasReversed);
        }

        public function getCurrentCharge():int
        {
            return (m_attack.ChargeTime);
        }

        public function getCurrentMaxCharge():int
        {
            return (m_attack.ChargeTimeMax);
        }

        override public function getLinkageID():String
        {
            return (this.m_projectileStats.LinkageID);
        }

        public function getProjectileStat(statName:String):*
        {
            return (this.m_projectileStats.getVar(statName));
        }

        public function exportStats():Object
        {
            return (this.m_projectileStatsOriginal.exportData());
        }

        public function updateProjectileStats(statValues:Object):void
        {
            this.m_projectileStats.importData(statValues);
            this.syncStats();
        }

        override public function updateAttackStats(statValues:Object):void
        {
            super.updateAttackStats(statValues);
            this.syncStats();
        }

        override public function updateAttackBoxStats(id:int, statValues:Object):void
        {
            super.updateAttackBoxStats(id, statValues);
        }

        public function getOwner():InteractiveSprite
        {
            return (this.m_owner);
        }

        private function isStrengthNormalAttackSource(owner:InteractiveSprite):Boolean
        {
            if (owner is Character)
            {
                return owner.AttackStateData.IsAttacking && !owner.AttackStateData.IsThrow &&
                    !Character(owner).UsingFinalSmash &&
                    StrengthSystem.isNormalAttackFrame(owner.AttackStateData.Frame);
            };
            return owner is Projectile && Projectile(owner).StrengthNormalAttack;
        }

        public function get StrengthNormalAttack():Boolean
        {
            // Preserve launch provenance even if the fighter starts another move before impact.
            // Reflections do not turn a special projectile into a normal attack.
            return this.m_strengthNormalAttack && !this.m_wasReversed;
        }

        public function getOwnerAPI():*
        {
            if (this.m_owner)
            {
                return (this.m_owner.APIInstance.instance);
            };
            return (null);
        }

        public function setOwnerAPI(owner:InteractiveSprite):void
        {
            this.m_owner = STAGEDATA.getGameObjectByUID(owner.UID);
            if ((!(this.m_owner)))
            {
                m_player_id = -1;
                m_team_id = -1;
            }
            else
            {
                m_player_id = owner.ID;
                m_team_id = m_team_id;
            };
        }

        override protected function syncStats():void
        {
            m_gravity = this.m_projectileStats.Gravity;
            m_max_ySpeed = this.m_projectileStats.MaxGravity;
            m_width = this.m_projectileStats.Width;
            m_height = this.m_projectileStats.Height;
            m_bypassCollisionTesting = this.m_projectileStats.BypassCollisionTesting;
            this.m_x_influence = ((this.m_projectileStats.InfluenceXMovement === -1) ? 0 : this.m_x_influence);
            this.m_y_influence = ((this.m_projectileStats.InfluenceYMovement === -1) ? 0 : this.m_y_influence);
        }

        public function angleControl(speed:Number, direction:Number):void
        {
            direction = Utils.forceBase360(direction);
            m_xSpeed = (((direction === 90) || (direction === 270)) ? 0 : (speed * Math.cos(((direction * Math.PI) / 180))));
            m_ySpeed = (((direction === 0) || (direction === 180)) ? 0 : (-(speed) * Math.sin(((direction * Math.PI) / 180))));
        }

        private function checkIfDead():void
        {
            if (this.m_projectileStats.Suspend)
            {
                return;
            };
            if (((((!(inState(PState.DEAD))) && (!(this.m_projectileStats.SurviveDeathBounds))) && (STAGEDATA.DeathBounds)) && ((this.m_projectileStats.ControlDirection == -1) && ((((m_sprite.x < STAGEDATA.DeathBounds.x) || (m_sprite.x > (STAGEDATA.DeathBounds.x + STAGEDATA.DeathBounds.width))) || (m_sprite.y < STAGEDATA.DeathBounds.y)) || (m_sprite.y > (STAGEDATA.DeathBounds.y + STAGEDATA.DeathBounds.height))))))
            {
                this.destroy();
            }
            else
            {
                if ((((this.m_projectileStats.TimeMax > 0) && (this.m_time >= this.m_projectileStats.TimeMax)) && (!(inState(PState.DEAD)))))
                {
                    this.destroy();
                }
                else
                {
                    if (((((m_xSpeed <= 0) && (this.m_xSpeedInit > 0)) || ((m_xSpeed >= 0) && (this.m_xSpeedInit < 0))) && (!(this.m_projectileStats.XDecay == 0))))
                    {
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.PROJ_X_DECAY_COMPLETE, {"caller":this.APIInstance.instance}));
                    };
                };
            };
        }

        private function stopSoundsAfterDeath():void
        {
            if (m_attack.CancelSoundOnEnd)
            {
                this.stopSoundID(this.m_lastSFX);
                this.m_lastSFX = -1;
            };
            if (m_attack.CancelVoiceOnEnd)
            {
                this.stopSoundID(this.m_lastSFX);
                this.m_lastVFX = -1;
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

        public function playSpecificSound(sound:String):int
        {
            return (this.m_lastSFX = STAGEDATA.SoundQueueRef.playSoundEffect(sound, this.m_volume_sfx));
        }

        public function playSpecificVoice(sound:String):int
        {
            return (this.m_lastVFX = STAGEDATA.SoundQueueRef.playVoiceEffect(sound, this.m_volume_vfx));
        }

        public function playGlobalSound(soundID:String):int
        {
            return (this.m_lastSFX = STAGEDATA.SoundQueueRef.playSoundEffect(soundID, this.m_volume_sfx));
        }

        public function destroy(e:SSF2Event=null):void
        {
            if ((!(inState(PState.DEAD))))
            {
                m_skipAttackCollisionTests = true;
                m_skipAttackProcessing = true;
                removeFromCamera();
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.PROJ_DESTROYED, {"caller":this.APIInstance.instance}));
                this.stopSoundsAfterDeath();
                setState(PState.DEAD);
                if (m_sprite.parent)
                {
                    m_sprite.parent.removeChild(m_sprite);
                };
                removeAllTempEvents();
                flushTimers();
                if (((m_shadowEffect) && (m_shadowEffect.parent)))
                {
                    m_shadowEffect.parent.removeChild(m_shadowEffect);
                };
                m_shadowEffect = null;
                if (((m_reflectionEffect) && (m_reflectionEffect.parent)))
                {
                    m_reflectionEffect.parent.removeChild(m_reflectionEffect);
                };
                m_reflectionEffect = null;
                STAGEDATA.removeProjectile(this);
            };
        }

        public function endControl():void
        {
            this.m_projectileStats.importData({
                "controlDirection":-1,
                "influenceXMovement":-1,
                "influenceYMovement":-2
            });
            this.m_x_influence = 0;
            this.m_y_influence = 0;
        }

        public function stick():void
        {
            m_xSpeed = 0;
            m_ySpeed = 0;
            this.m_projectileStats.importData({
                "xdecay":0,
                "sticky":false
            });
            m_max_ySpeed = 0;
            m_gravity = 0;
        }

        private function checkInfluence():void
        {
            var controls:Object = ((this.m_owner is Character) ? Character(this.m_owner).getControls() : null);
            if ((((this.m_owner is Character) && ((this.m_projectileStats.InfluenceXMovement > 0) || (this.m_projectileStats.InfluenceYMovement > 0))) && (!((Character(this.m_owner).IsCaught) || (Character(this.m_owner).StandBy)))))
            {
                if (((((controls.UP) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                {
                    this.m_x_influence = (this.m_x_influence - (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                    this.m_y_influence = (this.m_y_influence - (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                }
                else
                {
                    if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                    {
                        this.m_x_influence = (this.m_x_influence + (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                        this.m_y_influence = (this.m_y_influence - (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                    }
                    else
                    {
                        if (((((!(controls.UP)) && (controls.DOWN)) && (controls.LEFT)) && (!(controls.RIGHT))))
                        {
                            this.m_x_influence = (this.m_x_influence - (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                            this.m_y_influence = (this.m_y_influence + (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                        }
                        else
                        {
                            if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (controls.RIGHT)))
                            {
                                this.m_x_influence = (this.m_x_influence + (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                                this.m_y_influence = (this.m_y_influence + (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                            }
                            else
                            {
                                if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                {
                                    this.m_y_influence = (this.m_y_influence - (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                                }
                                else
                                {
                                    if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                    {
                                        this.m_y_influence = (this.m_y_influence + (((this.m_projectileStats.InfluenceYFactor > 0) && (this.m_projectileStats.InfluenceYMovement > 0)) ? this.m_projectileStats.InfluenceYFactor : 0));
                                    }
                                    else
                                    {
                                        if (((((!(controls.UP)) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                                        {
                                            this.m_x_influence = (this.m_x_influence - (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                                        }
                                        else
                                        {
                                            if (((((!(controls.UP)) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                                            {
                                                this.m_x_influence = (this.m_x_influence + (((this.m_projectileStats.InfluenceXFactor > 0) && (this.m_projectileStats.InfluenceXMovement > 0)) ? this.m_projectileStats.InfluenceXFactor : 0));
                                            }
                                            else
                                            {
                                                if (this.m_projectileStats.InfluenceXFactor > 0)
                                                {
                                                    if (((this.m_x_influence > 0) && ((this.m_x_influence - this.m_projectileStats.InfluenceXFactor) < 0)))
                                                    {
                                                        this.m_x_influence = 0;
                                                    }
                                                    else
                                                    {
                                                        if (((this.m_x_influence < 0) && ((this.m_x_influence + this.m_projectileStats.InfluenceXFactor) > 0)))
                                                        {
                                                            this.m_x_influence = 0;
                                                        }
                                                        else
                                                        {
                                                            if (this.m_x_influence != 0)
                                                            {
                                                                this.m_x_influence = (this.m_x_influence - this.m_projectileStats.InfluenceXFactor);
                                                            };
                                                        };
                                                    };
                                                };
                                                if (this.m_projectileStats.InfluenceYFactor > 0)
                                                {
                                                    if (((this.m_y_influence > 0) && ((this.m_y_influence - this.m_projectileStats.InfluenceYFactor) < 0)))
                                                    {
                                                        this.m_y_influence = 0;
                                                    }
                                                    else
                                                    {
                                                        if (((this.m_y_influence < 0) && ((this.m_y_influence + this.m_projectileStats.InfluenceYFactor) > 0)))
                                                        {
                                                            this.m_y_influence = 0;
                                                        }
                                                        else
                                                        {
                                                            if (this.m_y_influence != 0)
                                                            {
                                                                this.m_y_influence = (this.m_y_influence - this.m_projectileStats.InfluenceYFactor);
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
                if (this.m_projectileStats.InfluenceXMovement > 0)
                {
                    if (this.m_x_influence > this.m_projectileStats.InfluenceXMovement)
                    {
                        this.m_x_influence = this.m_projectileStats.InfluenceXMovement;
                    };
                    if (this.m_x_influence < -(this.m_projectileStats.InfluenceXMovement))
                    {
                        this.m_x_influence = -(this.m_projectileStats.InfluenceXMovement);
                    };
                };
                if (this.m_projectileStats.InfluenceYMovement > 0)
                {
                    if (this.m_y_influence > this.m_projectileStats.InfluenceYMovement)
                    {
                        this.m_y_influence = this.m_projectileStats.InfluenceYMovement;
                    };
                    if (this.m_y_influence < -(this.m_projectileStats.InfluenceYMovement))
                    {
                        this.m_y_influence = -(this.m_projectileStats.InfluenceYMovement);
                    };
                };
            };
        }

        private function checkControls():Boolean
        {
            var targetAngle:Number;
            var currentAngle:Number;
            var addSpeed:Number;
            var controls:Object = ((this.m_owner is Character) ? Character(this.m_owner).getControls() : null);
            if ((((this.m_owner is Character) && (this.m_projectileStats.ControlDirection >= 0)) && (!((Character(this.m_owner).IsCaught) || (Character(this.m_owner).StandBy)))))
            {
                if (this.m_projectileStats.CalcAngle)
                {
                    targetAngle = this.m_angle;
                    currentAngle = this.m_angle;
                    if (((((controls.UP) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                    {
                        targetAngle = 135;
                    }
                    else
                    {
                        if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                        {
                            targetAngle = 45;
                        }
                        else
                        {
                            if (((((!(controls.UP)) && (controls.DOWN)) && (controls.LEFT)) && (!(controls.RIGHT))))
                            {
                                targetAngle = 225;
                            }
                            else
                            {
                                if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (controls.RIGHT)))
                                {
                                    targetAngle = 315;
                                }
                                else
                                {
                                    if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                    {
                                        targetAngle = 90;
                                    }
                                    else
                                    {
                                        if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                        {
                                            targetAngle = 270;
                                        }
                                        else
                                        {
                                            if (((((!(controls.UP)) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                                            {
                                                targetAngle = 180;
                                            }
                                            else
                                            {
                                                if (((((!(controls.UP)) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                                                {
                                                    targetAngle = 0;
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                    addSpeed = (Utils.calculateDifferenceBetweenAngles(targetAngle, currentAngle) / 6);
                    this.m_angle = (this.m_angle - addSpeed);
                    this.m_angle = Utils.forceBase360(this.m_angle);
                    this.angleControl(this.m_xSpeedInit, this.m_angle);
                }
                else
                {
                    if (((((controls.UP) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                    {
                        this.m_angle = 135;
                    }
                    else
                    {
                        if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                        {
                            this.m_angle = 45;
                        }
                        else
                        {
                            if (((((!(controls.UP)) && (controls.DOWN)) && (controls.LEFT)) && (!(controls.RIGHT))))
                            {
                                this.m_angle = 225;
                            }
                            else
                            {
                                if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (controls.RIGHT)))
                                {
                                    this.m_angle = 315;
                                }
                                else
                                {
                                    if (((((controls.UP) && (!(controls.DOWN))) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                    {
                                        this.m_angle = 90;
                                    }
                                    else
                                    {
                                        if (((((!(controls.UP)) && (controls.DOWN)) && (!(controls.LEFT))) && (!(controls.RIGHT))))
                                        {
                                            this.m_angle = 270;
                                        }
                                        else
                                        {
                                            if (((((!(controls.UP)) && (!(controls.DOWN))) && (controls.LEFT)) && (!(controls.RIGHT))))
                                            {
                                                this.m_angle = 180;
                                            }
                                            else
                                            {
                                                if (((((!(controls.UP)) && (!(controls.DOWN))) && (!(controls.LEFT))) && (controls.RIGHT)))
                                                {
                                                    this.m_angle = 0;
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                    this.angleControl(this.m_xSpeedInit, this.m_angle);
                };
                return (true);
            };
            return (false);
        }

        public function syncPosition():void
        {
            var loc:Point;
            if ((((this.m_projectileStats.LockTrajectory) && (this.m_owner is Character)) && (this.m_owner.HasPLockBox)))
            {
                loc = new Point((HitBoxSprite(this.m_owner.CurrentAnimation.getHitBoxes(this.m_owner.CurrentFrameNum, HitBoxSprite.PLOCK)[0]).centerx * this.m_owner.MC.scaleX), (HitBoxSprite(this.m_owner.CurrentAnimation.getHitBoxes(this.m_owner.CurrentFrameNum, HitBoxSprite.PLOCK)[0]).centery * this.m_owner.MC.scaleY));
                m_sprite.x = (this.m_owner.getX() + loc.x);
                m_sprite.y = (this.m_owner.getY() + loc.y);
                m_attack.XLoc = m_sprite.x;
                m_attack.YLoc = m_sprite.y;
            }
            else
            {
                if (((this.m_projectileStats.LockTrajectory) && (this.m_owner is Enemy)))
                {
                    m_sprite.x = this.m_owner.X;
                    m_sprite.y = this.m_owner.Y;
                    m_attack.XLoc = m_sprite.x;
                    m_attack.YLoc = m_sprite.y;
                };
            };
        }

        private function getDistanceFrom(xpos:Number, ypos:Number):Number
        {
            return (Math.sqrt((Math.pow((xpos - m_sprite.x), 2) + Math.pow((ypos - m_sprite.y), 2))));
        }

        private function findHomingTarget():void
        {
            var i:int;
            var lastDistance:Number = 99999999;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var opponent:Character;
            var item:Item;
            var target:TargetTestTarget;
            m_attack.HomingTarget = null;
            i = 0;
            while (((i < STAGEDATA.ItemsRef.MAXITEMS) && (m_attack.HomingTarget == null)))
            {
                if (HasHoming)
                {
                    item = STAGEDATA.ItemsRef.ItemsInUse[i];
                    if (((((!(item == null)) && (!(item.MC.hitBox == null))) && (item.IsSmashBall)) && ((collisionRect = InteractiveSprite.hitTest(this, item, HitBoxSprite.HOMING, HitBoxSprite.HIT)).length > 0)))
                    {
                        m_attack.HomingTarget = item;
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                            "caller":this.APIInstance.instance,
                            "target":opponent.APIInstance.instance,
                            "type":"Item"
                        }));
                    };
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Characters.length)
            {
                if (HasHoming)
                {
                    opponent = STAGEDATA.Characters[i];
                    if (((((((((((!(opponent.StandBy)) && (!(opponent.Revival))) && (!(opponent.AirDodge))) && (opponent.HasHitBox)) && (!(opponent.Dead))) && (!(opponent.Invincible))) && ((m_attack.HomingTarget == null) || (this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y) < lastDistance))) && ((collisionRect = InteractiveSprite.hitTest(this, opponent, HitBoxSprite.HOMING, HitBoxSprite.HIT)).length > 0)) && ((!(this.m_wasReversed)) || ((this.m_wasReversed) && (!((m_attack.ReverseID == opponent.ID) || (((m_team_id > 0) && (opponent.Team == m_attack.ReverseTeam)) && (!(STAGEDATA.TeamDamage)))))))) && (!(((m_team_id > 0) && (opponent.Team == m_team_id)) || (m_player_id === opponent.ID)))))
                    {
                        m_attack.HomingTarget = opponent;
                        lastDistance = this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y);
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                            "caller":this.APIInstance.instance,
                            "target":opponent.APIInstance.instance,
                            "type":"Character"
                        }));
                    };
                };
                i++;
            };
            i = 0;
            while (i < STAGEDATA.Targets.length)
            {
                if (HasHoming)
                {
                    target = STAGEDATA.Targets[i];
                    if ((((target.inState(TState.IDLE)) && ((m_attack.HomingTarget == null) || (this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y) < lastDistance))) && ((collisionRect = InteractiveSprite.hitTest(this, target, HitBoxSprite.HOMING, HitBoxSprite.HIT)).length > 0)))
                    {
                        m_attack.HomingTarget = target;
                        lastDistance = this.getDistanceFrom(m_attack.HomingTarget.X, m_attack.HomingTarget.Y);
                        m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HOMING_TARGET, {
                            "caller":this.APIInstance.instance,
                            "target":target.APIInstance.instance,
                            "type":"Target"
                        }));
                    };
                };
                i++;
            };
        }

        private function projectileMove():void
        {
            var targetAngle:Number;
            var angleDiff:Number;
            var wasPositiveHoming:Boolean;
            var tmpYSpeed:Number;
            var tmpMC:MovieClip;
            var angle:Number;
            var angle2:Number;
            if (this.m_projectileStats.Suspend)
            {
                return;
            };
            if (((!(inState(PState.DEAD))) && (!(isHitStunOrParalysis()))))
            {
                if (((this.m_projectileStats.HomingSpeed >= 0) && (!(m_attack.HomingTarget))))
                {
                    this.findHomingTarget();
                };
                if (m_attack.HomingTarget)
                {
                    targetAngle = Utils.getAngleBetween(new Point(m_sprite.x, m_sprite.y), new Point(m_attack.HomingTarget.X, m_attack.HomingTarget.Y));
                    angleDiff = Utils.calculateDifferenceBetweenAngles(this.m_homingAngle, targetAngle);
                    this.m_homingAngle = (this.m_homingAngle + Utils.forceBase360((angleDiff / this.m_projectileStats.HomingEase)));
                    m_xSpeed = Utils.calculateXSpeed(this.m_projectileStats.HomingSpeed, this.m_homingAngle);
                    m_ySpeed = -(Utils.calculateYSpeed(this.m_projectileStats.HomingSpeed, this.m_homingAngle));
                    if (((!(this.m_projectileStats.HomingSpeed == 0)) && (!(this.m_projectileStats.XDecay == 0))))
                    {
                        wasPositiveHoming = (this.m_projectileStats.HomingSpeed > 0);
                        this.m_projectileStats.HomingSpeed = (this.m_projectileStats.HomingSpeed - this.m_projectileStats.XDecay);
                        if ((((wasPositiveHoming) && (this.m_projectileStats.HomingSpeed < 0)) || ((!(wasPositiveHoming)) && (this.m_projectileStats.HomingSpeed > 0))))
                        {
                            this.m_projectileStats.HomingSpeed = 0;
                            this.checkIfDead();
                        };
                    };
                };
                applyGroundInfluence();
                this.m_rocketReadyTimer.tick();
                this.checkInfluence();
                if (this.checkControls())
                {
                    this.m_attemptToMove((m_xSpeed + this.m_x_influence), 0);
                    this.m_attemptToMove(0, (m_ySpeed + this.m_y_influence));
                }
                else
                {
                    if (this.m_projectileStats.LockTrajectory)
                    {
                        this.syncPosition();
                    }
                    else
                    {
                        if ((((!(m_collision.ground)) && (!(this.m_projectileStats.Boomerang))) && (m_gravity > 0)))
                        {
                            if (((!(this.m_projectileStats.Boomerang)) && (m_ySpeed < m_max_ySpeed)))
                            {
                                m_ySpeed = (m_ySpeed + m_gravity);
                            };
                        }
                        else
                        {
                            if (((((this.m_projectileStats.Bounce <= 0) && (m_ySpeed > 0)) && (m_collision.ground)) && (!(this.m_projectileStats.Boomerang))))
                            {
                                m_ySpeed = 0;
                            }
                            else
                            {
                                if (this.m_projectileStats.Boomerang)
                                {
                                    if (((this.m_hasSwitched) && (((this.m_xSpeedInit < 0) && (m_sprite.x <= this.m_owner.MC.x)) || ((this.m_xSpeedInit > 0) && (m_sprite.x >= this.m_owner.MC.x)))))
                                    {
                                        if (((m_sprite.y <= this.m_owner.MC.y) && (m_ySpeed < m_max_ySpeed)))
                                        {
                                            m_ySpeed = (m_ySpeed + m_gravity);
                                        }
                                        else
                                        {
                                            if (((m_sprite.y > this.m_owner.MC.y) && (m_ySpeed > -(m_max_ySpeed))))
                                            {
                                                m_ySpeed = (m_ySpeed - m_gravity);
                                            };
                                        };
                                    }
                                    else
                                    {
                                        if ((!(this.m_hasSwitched)))
                                        {
                                            if ((((this.m_xSpeedInit < 0) && (m_xSpeed >= 0)) || ((this.m_xSpeedInit > 0) && (m_xSpeed <= 0))))
                                            {
                                                this.m_hasSwitched = true;
                                                this.m_projectileStats.importData({"ghost":true});
                                            }
                                            else
                                            {
                                                if (Math.abs(m_ySpeed) > 1)
                                                {
                                                    if (m_ySpeed > 0)
                                                    {
                                                        m_ySpeed = (m_ySpeed - m_gravity);
                                                    }
                                                    else
                                                    {
                                                        if (m_ySpeed < 0)
                                                        {
                                                            m_ySpeed = (m_ySpeed + m_gravity);
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                        tmpYSpeed = 0;
                        if (((m_sprite.rotation > 20) && (m_collision.ground)))
                        {
                            tmpYSpeed = 8;
                        }
                        else
                        {
                            if (((m_sprite.rotation < -20) && (m_collision.ground)))
                            {
                                tmpYSpeed = -8;
                            };
                        };
                        if (tmpYSpeed < 0)
                        {
                        };
                        if ((!(((((m_attack.IsAttacking) && (!(this.m_projectileStats.CanFallOff))) && (!(m_attack.CanFallOff))) && (m_collision.ground)) && (!(testGroundWithCoord(((m_xSpeed > 0) ? ((m_sprite.x + m_xSpeed) + 10) : ((m_sprite.x + m_xSpeed) - 10)), (m_sprite.y + 9)))))))
                        {
                            if (tmpYSpeed < 0)
                            {
                                this.m_attemptToMove(0, tmpYSpeed);
                                this.m_attemptToMove((m_xSpeed + this.m_x_influence), 0);
                            }
                            else
                            {
                                if (tmpYSpeed > 0)
                                {
                                    this.m_attemptToMove((m_xSpeed + this.m_x_influence), 0);
                                    this.m_attemptToMove(0, tmpYSpeed);
                                    this.m_attemptToMove(0, tmpYSpeed);
                                }
                                else
                                {
                                    this.m_attemptToMove((m_xSpeed + this.m_x_influence), tmpYSpeed);
                                };
                            };
                        };
                        if (m_collision.ground)
                        {
                            this.attachToGround();
                        };
                        if (this.m_xSpeedInit > 0)
                        {
                            m_xSpeed = (m_xSpeed - ((m_xSpeed > -(this.m_xSpeedInit)) ? this.m_projectileStats.XDecay : 0));
                            if ((((!(this.m_projectileStats.Boomerang)) && (m_xSpeed < 0)) && (!(this.m_projectileStats.XDecay == 0))))
                            {
                                this.m_projectileStats.importData({"xdecay":0});
                                m_xSpeed = 0;
                            };
                        }
                        else
                        {
                            m_xSpeed = (m_xSpeed + ((m_xSpeed < -(this.m_xSpeedInit)) ? this.m_projectileStats.XDecay : 0));
                            if ((((!(this.m_projectileStats.Boomerang)) && (m_xSpeed > 0)) && (!(this.m_projectileStats.XDecay == 0))))
                            {
                                this.m_projectileStats.importData({"xdecay":0});
                                m_xSpeed = 0;
                            };
                        };
                        this.m_attemptToMove(0, (m_ySpeed + this.m_y_influence));
                        if ((((m_collision.ground) && (this.m_projectileStats.Bounce > 0)) && (m_ySpeed >= 0)))
                        {
                            this.m_bounce_total++;
                            if (!((this.m_projectileStats.BounceLimit > 0) && (this.m_bounce_total > this.m_projectileStats.BounceLimit)))
                            {
                                m_ySpeed = -(this.m_projectileStats.Bounce);
                                this.m_projectileStats.Bounce = (this.m_projectileStats.Bounce * this.m_projectileStats.BounceDecay);
                                while (((this.m_projectileStats.BounceMaxHeight > 0) && (this.getBounceHeight(m_ySpeed) > this.m_projectileStats.BounceMaxHeight)))
                                {
                                    m_ySpeed++;
                                };
                                unnattachFromGround();
                                m_collision.ground = false;
                            };
                        };
                        if (this.m_projectileStats.FollowUser)
                        {
                            m_sprite.x = ((m_facingForward) ? (this.m_owner.MC.x + (this.m_projectileStats.XOffset * m_sizeRatio)) : (this.m_owner.MC.x - (this.m_projectileStats.XOffset * m_sizeRatio)));
                            m_sprite.y = (this.m_owner.MC.y + (this.m_projectileStats.YOffset * m_sizeRatio));
                        };
                    };
                };
                if ((!(inState(PState.DEAD))))
                {
                    m_attack.XLoc = m_sprite.x;
                    m_attack.YLoc = m_sprite.y;
                    m_attack.IsForward = ((this.m_projectileStats.ControlDirection >= 0) ? (m_xSpeed > 0) : m_facingForward);
                };
            };
            if (((!(inState(PState.DEAD))) && (!(this.m_projectileStats.TrailEffect == null))))
            {
                this.m_trailEffectTimer++;
                if (this.m_trailEffectTimer >= this.m_projectileStats.TrailEffectInterval)
                {
                    this.m_trailEffectTimer = 0;
                    tmpMC = STAGEDATA.attachEffectOverlay(this.m_projectileStats.TrailEffect);
                    tmpMC.x = OverlayX;
                    tmpMC.y = OverlayY;
                    if ((!(m_facingForward)))
                    {
                        tmpMC.scaleX = (tmpMC.scaleX * -1);
                    };
                    if (this.m_projectileStats.TrailEffectRotate)
                    {
                        if (((this.m_projectileStats.ControlDirection) && (this.m_projectileStats.CalcAngle)))
                        {
                            angle = this.m_angle;
                            angle = Utils.forceBase360(((m_facingForward) ? -(angle) : (-(angle) + 180)));
                            tmpMC.rotation = angle;
                        }
                        else
                        {
                            angle2 = Utils.getAngleBetween(new Point(0, 0), new Point(m_xSpeed, m_ySpeed));
                            angle2 = Utils.forceBase360(((m_facingForward) ? -(angle2) : (-(angle2) + 180)));
                            tmpMC.rotation = angle2;
                        };
                    };
                };
            };
        }

        private function getBounceHeight(ySpeed:int):Number
        {
            var total:Number = 0;
            while (((ySpeed < 0) && (m_gravity > 0)))
            {
                total = (total - ySpeed);
                ySpeed = (ySpeed + m_gravity);
            };
            return (total);
        }

        override public function reverse(pid:int, team_id:int, isForward:Boolean):Boolean
        {
            if (((((((this.m_reverseTimer <= 0) && (this.m_projectileStats.CanBeReversed)) && (!(m_attack.ReverseID === pid))) && (!(this.m_projectileStats.Suspend))) && (!((!(this.m_wasReversed)) && (pid === m_player_id)))) && (!(((team_id == m_team_id) && (m_team_id > 0)) && (!(STAGEDATA.TeamDamage))))))
            {
                if ((!(m_facingForward)))
                {
                    m_facingForward = true;
                    this.m_faceRight();
                    m_attack.IsForward = true;
                }
                else
                {
                    m_facingForward = false;
                    this.m_faceLeft();
                    m_attack.IsForward = false;
                };
                this.m_reverseTimer = 2;
                m_team_id = team_id;
                if (((this.m_owner) && (this.m_owner.ID === pid)))
                {
                    m_attack.ReverseID = -1;
                    m_attack.ReverseTeam = -1;
                    this.m_wasReversed = false;
                    m_attackData.Owner = this.m_owner;
                    m_player_id = this.m_owner.ID;
                }
                else
                {
                    m_attack.ReverseID = pid;
                    m_attack.ReverseTeam = team_id;
                    this.m_wasReversed = true;
                    m_attack.AttackID = Utils.getUID();
                    m_attackData.Owner = this.m_owner;
                    m_player_id = pid;
                };
                m_xSpeed = (m_xSpeed * -1);
                this.m_xSpeedInit = (this.m_xSpeedInit * -1);
                if ((!(this.m_projectileStats.ControlInitDirection >= 0)))
                {
                    this.m_xSpeedInit = (this.m_xSpeedInit * -1);
                };
                if (((this.m_projectileStats.TimeMax > 0) && (this.m_time < 0)))
                {
                    this.m_time = 0;
                };
                if (this.m_projectileStats.Boomerang)
                {
                    this.m_hasSwitched = true;
                };
                if (m_attack.HomingTarget)
                {
                    this.m_homingAngle = Utils.getAngleBetween(new Point(), new Point(m_xSpeed, m_ySpeed));
                    this.findHomingTarget();
                };
                return (true);
            };
            return (false);
        }

        private function checkReverse():void
        {
            if ((!(inState(PState.DEAD))))
            {
                if (this.m_reverseTimer > 0)
                {
                    this.m_reverseTimer--;
                };
            };
        }

        private function checkIfLinked():void
        {
            if (this.m_projectileStats.LinkAttackID)
            {
                this.m_owner.AttackStateData.AttackID = m_attack.AttackID;
            };
        }

        override public function reactionShield(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if ((((this.m_projectileStats.Suspend) || ((!(this.m_wasReversed)) && (otherSprite === this.m_owner))) || (((STAGEDATA.TeamDamage) && (otherSprite.Team == m_team_id)) && (m_team_id > 0))))
            {
                return (false);
            };
            var opponent:Character = ((otherSprite as Character) ? Character(otherSprite) : null);
            var attackDamage1:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if (opponent)
            {
                if (((attackDamage1.BypassShield) && (otherSprite.takeDamage(attackDamage1, hBoxResult.OverlapHitBox))))
                {
                    this.handleHit(otherSprite, attackDamage1, hBoxResult);
                    return (true);
                };
                if (opponent.takeShieldDamage(m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache), hBoxResult.OverlapHitBox))
                {
                    m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_CONNECT_SHIELD, {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage1.exportAttackDamageData()
                    }));
                    startActionShot(Utils.calculateSelfHitStun(attackDamage1.SelfHitStun, Utils.calculateChargeDamage(attackDamage1)));
                    m_eventManager.dispatchEvent(new SSF2Event(((Character(otherSprite).PerfectShield) ? SSF2Event.ATTACK_HIT_POWER_SHIELD : SSF2Event.ATTACK_HIT_SHIELD), {
                        "caller":this.APIInstance.instance,
                        "receiver":otherSprite.APIInstance.instance,
                        "attackBoxData":attackDamage1.exportAttackDamageData()
                    }));
                    m_attack.RefreshRateReady = true;
                    if ((((opponent.PerfectShield) && (attackDamage1.Priority >= -1)) && (attackDamage1.Priority < 7)))
                    {
                        if (this.m_projectileStats.CanBeReversed)
                        {
                            this.reverse(otherSprite.ID, otherSprite.Team, otherSprite.FacingForward);
                        };
                    };
                    return (true);
                };
                return (false);
            };
            return (false);
        }

        override public function reactionShieldProjectile(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (this.m_projectileStats.Suspend)
            {
                return (false);
            };
            var attackDamage1:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if ((((attackDamage1.Priority < 7) && (attackDamage1.Priority > -1)) && (otherSprite.validateHit(attackDamage1, true))))
            {
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                this.destroy();
                if ((otherSprite as Character))
                {
                    Character(otherSprite).pushBackSlightly((m_sprite.x < otherSprite.X));
                };
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

        override public function reactionAttackReverse(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var attackDamage:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
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

        override public function reactionAbsorb(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (this.m_projectileStats.Suspend)
            {
                return (false);
            };
            var attackDamage:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if (((this.m_projectileStats.CanBeAbsorbed) && (otherSprite.validateHit(attackDamage, true))))
            {
                otherSprite.stackAttackID(attackDamage.AttackID);
                otherSprite.EventManagerObj.dispatchEvent(new SSF2Event(SSF2Event.CHAR_ABSORB, {
                    "caller":otherSprite,
                    "projectile":this,
                    "attackBoxData":attackDamage.exportAttackDamageData()
                }));
                return (true);
            };
            return (false);
        }

        override public function reactionClank(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (((this.m_projectileStats.Suspend) || (otherSprite.isIntangible())))
            {
                return (false);
            };
            if (inState(PState.DEAD))
            {
                return (false);
            };
            var attackDamage1:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            var attackDamage2:AttackDamage = otherSprite.AttackDataObj.getAttackBoxData(otherSprite.AttackStateData.Frame, hBoxResult.SecondHitBox.Name).syncState(otherSprite.AttackCache);
            var totalDamage1:Number = Utils.calculateChargeDamage(attackDamage1);
            var totalDamage2:Number = Utils.calculateChargeDamage(attackDamage2);
            var nonDamagingReverseBox:Boolean = ((((((attackDamage1.Damage === 0) && (attackDamage1.ReverseProjectile)) && (otherSprite is Projectile)) || (((attackDamage1.Damage === 0) && (attackDamage1.ReverseItem)) && (otherSprite is Item))) || (((attackDamage1.Damage === 0) && (attackDamage1.ReverseCharacter)) && (otherSprite is Character))) || ((attackDamage2.Damage === 0) && (attackDamage2.ReverseProjectile)));
            var nonDamagingProjectileHitStun:Boolean = ((((attackDamage1.Damage === 0) && (attackDamage1.HitStunProjectile)) && (otherSprite is Projectile)) || ((attackDamage2.Damage === 0) && (attackDamage2.HitStunProjectile)));
            if ((((((((((!(attackDamage1.HasEffect)) || (!(attackDamage2.HasEffect))) || (isInvincible())) || (otherSprite.isInvincible())) || (attackDamage1.IsThrow)) || (attackDamage2.IsThrow)) || ((!(otherSprite is Projectile)) && (!(otherSprite.validateHit(attackDamage1))))) || (nonDamagingReverseBox)) || (nonDamagingProjectileHitStun)))
            {
                return (false);
            };
            if ((!(this.validateHitClank(attackDamage2))))
            {
                return (false);
            };
            if (((otherSprite is Projectile) && (!(Projectile(otherSprite).validateHitClank(attackDamage1)))))
            {
                return (false);
            };
            if ((((Utils.fastAbs((totalDamage1 - totalDamage2)) < 8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
            {
                if ((((m_attack.HasClanked) || (otherSprite.AttackStateData.HasClanked)) || ((otherSprite is Item) && (!(Item(otherSprite).PickedUp)))))
                {
                    return (false);
                };
                if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                    "target":((otherSprite.APIInstance) ? otherSprite.APIInstance.instance : null),
                    "attackBoxData":null,
                    "collisionRect":hBoxResult.OverlapHitBox.BoundingBox
                }))))
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
                STAGEDATA.playSpecificSound("reflected");
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                CAM.shake(15);
                this.clang(attackDamage2, hBoxResult);
                if ((!(otherSprite is Character)))
                {
                    otherSprite.clang(attackDamage1, hBoxResult);
                }
                else
                {
                    otherSprite.startActionShot(Utils.calculateSelfHitStun(attackDamage2.SelfHitStun, Utils.calculateChargeDamage(attackDamage2)));
                    Character(otherSprite).SmashDISelf = true;
                    otherSprite.AttackStateData.HasClanked = true;
                };
                return (true);
            };
            if (((((totalDamage1 - totalDamage2) >= 8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
            {
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
                if ((!(otherSprite is Character)))
                {
                    otherSprite.clang(attackDamage1, hBoxResult);
                    otherSprite.attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                };
                return (true);
            };
            if (((((totalDamage1 - totalDamage2) <= -8) && (!(attackDamage1.Priority == -1))) && (!(attackDamage2.Priority == -1))))
            {
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
                this.clang(attackDamage2, hBoxResult);
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                return (true);
            };
            return (false);
        }

        override public function clang(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            initDelayPlayback(true);
            m_skipAttackCollisionTests = true;
            this.destroy();
        }

        override public function handleHit(otherSprite:InteractiveSprite, attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            if (otherSprite.isIntangible())
            {
                return;
            };
            m_attack.RefreshRateReady = true;
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.ATTACK_HIT, {
                "caller":this.APIInstance.instance,
                "receiver":otherSprite.APIInstance.instance,
                "attackBoxData":attackBoxData.exportAttackDamageData()
            }));
            if (((otherSprite.Invincible) && (!((otherSprite as Character) && (Character(otherSprite).Revival)))))
            {
                otherSprite.attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
            }
            else
            {
                if (((((this.m_projectileStats.Stale) && (this.m_owner is Character)) && (!(attackBoxData.Frame == null))) && (!(staleIDArrayContains(attackBoxData.ID)))))
                {
                    Character(this.m_owner).queueMove(attackBoxData.Frame);
                    stackStaleID(attackBoxData.ID);
                };
                if ((this.m_owner is Character))
                {
                    Character(this.m_owner).increaseComboCount(attackBoxData, otherSprite.UID);
                };
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
        }

        override public function forceAttack(value:String, toFrame:*=null, isSpecial:Boolean=false):Boolean
        {
            if (value === m_attack.Frame)
            {
                if ((((Main.DEBUG) && (MenuController.debugConsole)) && (MenuController.debugConsole.Alerts)))
                {
                    MenuController.debugConsole.alert((('[Warning] forceAttack("' + value) + '") was called when the SSF2Projectile object was already using that attack. Call has been aborted'));
                };
                return (false);
            };
            if (value != null)
            {
                if (value !== m_attack.Frame)
                {
                    flushTimers();
                    removeAllTempEvents();
                };
                this.InitAttack(value);
                if (toFrame !== null)
                {
                    stancePlayFrame(toFrame);
                };
                return (true);
            };
            return (false);
        }

        public function InitAttack(frame:String):void
        {
            var atkObj:AttackObject = m_attackData.getAttack(frame);
            if ((!(atkObj)))
            {
                m_attack.Frame = null;
                if (frame)
                {
                    playFrame(frame);
                };
                return;
            };
            m_attack.IsAttacking = true;
            m_attack.IsAirAttack = (!(m_collision.ground));
            m_attack.IsForward = m_facingForward;
            m_attack.ExecTime = 0;
            m_attack.HasClanked = false;
            if (m_attack.ResetMovement)
            {
                m_xSpeed = 0;
                m_ySpeed = 0;
            };
            m_attack.RefreshRate = atkObj.RefreshRate;
            m_attack.SuperArmor = atkObj.SuperArmor;
            m_attack.HeavyArmor = atkObj.HeavyArmor;
            m_attack.LaunchResistance = atkObj.LaunchResistance;
            m_attack.Rotate = atkObj.Rotate;
            m_attack.Frame = frame;
            m_attack.AttackID = Utils.getUID();
            m_attack.ID = Utils.getUID();
            playFrame(frame);
        }

        override public function cancelAttack(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
            m_skipAttackCollisionTests = true;
            if (attackBoxData.HitStunProjectile !== 0)
            {
                startActionShot(Utils.calculateHitStun(attackBoxData.HitStunProjectile, Utils.calculateChargeDamage(attackBoxData), attackBoxData.Shock, false));
            }
            else
            {
                attachEffect("effect_cancel", (((hBoxResult) && (hBoxResult.OverlapHitBox)) ? {
    "x":hBoxResult.OverlapHitBox.centerx,
    "y":hBoxResult.OverlapHitBox.centery,
    "absolute":true
} : null));
                this.destroy();
            };
        }

        override public function reactionCounter(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (this.m_projectileStats.Suspend)
            {
                return (false);
            };
            var attackDamage2:AttackDamage = otherSprite.AttackDataObj.getAttackBoxData(otherSprite.AttackStateData.Frame, hBoxResult.SecondHitBox.Name).syncState(otherSprite.AttackCache);
            if (this.validateHit(attackDamage2, true))
            {
                return (true);
            };
            return (false);
        }

        override public function reactionRange(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var xspeed:Number;
            var yspeed:Number;
            if ((((this.m_projectileStats.Suspend) || ((!(this.m_wasReversed)) && (otherSprite === this.m_owner))) || (((STAGEDATA.TeamDamage) && (otherSprite.Team == m_team_id)) && (m_team_id > 0))))
            {
                return (false);
            };
            var opponent:Character = ((otherSprite as Character) ? Character(otherSprite) : null);
            if ((((this.m_projectileStats.Suction) && (opponent)) && (!((opponent) && (((((opponent.isLandingOrSkiddingOrChambering()) || (opponent.Caught())) || (opponent.StandBy)) || (opponent.Revival)) || (opponent.Hanging))))))
            {
                xspeed = ((m_sprite.x - otherSprite.X) / 20);
                yspeed = ((m_sprite.y - otherSprite.Y) / 20);
                otherSprite.unnattachFromGround();
                otherSprite.m_attemptToMove(xspeed, 0);
                otherSprite.setYSpeed(yspeed);
                return (true);
            };
            return (false);
        }

        override public function reactionHit(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            var opponent:Character;
            var attackDamage:AttackDamage = m_attackData.getAttackBoxData(m_attackCache.Frame, hBoxResult.FirstHitBox.Name).syncState(m_attackCache);
            if (((((((otherSprite == this.m_owner) && (!(inState(PState.DEAD)))) && (this.m_rocketReadyTimer.IsComplete)) && (!(this.m_projectileStats.RocketSpeed == 0))) && (!(this.m_wasReversed))) && (otherSprite as Character)))
            {
                m_attack.RefreshRateReady = true;
                opponent = Character(otherSprite);
                opponent.rocketCharacter(this.m_projectileStats.RocketSpeed, ((this.m_projectileStats.RocketAngleAbsolute) ? Utils.getAngleBetween(new Point(m_sprite.x, m_sprite.y), new Point(opponent.X, (opponent.Y - (opponent.Height / 2)))) : this.m_angle), this.m_projectileStats.RocketDecay, this.m_projectileStats.RocketRotation);
                this.m_projectileStats.RocketSpeed = 0;
                return (true);
            };
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
                return (true);
            };
            return (false);
        }

        override public function reactionCollide(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            if (this.m_projectileStats.Suspend)
            {
                return (false);
            };
            m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.PROJ_COLLIDE, {
                "caller":this.APIInstance.instance,
                "opponent":otherSprite.APIInstance.instance
            }));
            if ((((((!((!(this.m_wasReversed)) && (otherSprite === this.m_owner))) && (!(otherSprite.Intangible))) && (this.m_projectileStats.Latch)) && (this.m_latch_id == null)) && (otherSprite as Character)))
            {
                m_xSpeed = 0;
                this.m_projectileStats.XDecay = 0;
                m_ySpeed = 0;
                m_gravity = 0;
                m_max_ySpeed = 0;
                this.m_projectileStats.CanBeReversed = false;
                this.m_latch_id = Character(otherSprite);
                this.m_latch_xLoc = (m_sprite.x - otherSprite.X);
                this.m_latch_yLoc = (m_sprite.y - otherSprite.Y);
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.PROJ_LATCHED, {
                    "caller":this.APIInstance.instance,
                    "opponent":otherSprite.APIInstance.instance
                }));
                return (true);
            };
            return (false);
        }

        override public function attackCollisionTest():void
        {
            if ((((m_bypassCollisionTesting) || (!(m_hitBoxManager.HasHitBoxes))) || (m_attackCollisionTestsPreProcessed)))
            {
                return;
            };
            var i:int;
            var opponent:Character;
            var enemy:Enemy;
            var projectile:Projectile;
            var item:Item;
            var target:TargetTestTarget;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var hBoxArr:Array;
            if ((!(inState(PState.DEAD))))
            {
                if ((!(isHitStunOrParalysis())))
                {
                    m_attack.ExecTime++;
                    m_attack.RefreshRateTimer++;
                    if ((((m_attack.RefreshRate > 0) && (m_attack.RefreshRateReady)) && ((m_attack.RefreshRateTimer % m_attack.RefreshRate) == 0)))
                    {
                        m_attack.AttackID = Utils.getUID();
                    };
                };
                this.checkIfLinked();
                m_attackCache.syncState(m_attack);
                i = 0;
                while (i < STAGEDATA.Characters.length)
                {
                    opponent = STAGEDATA.Characters[i];
                    if (((((((!(opponent == null)) && (!(opponent.StandBy))) && (!(opponent.Dead))) && (!(opponent.inState(CState.STAR_KO)))) && (!(opponent.inState(CState.SCREEN_KO)))) && (!(opponent.inState(CState.REVIVAL)))))
                    {
                        InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.SHIELD, this.reactionShield, STAGEDATA.HitBoxProcessorInstance);
                        if ((!(InteractiveSprite.hitTest(this, opponent, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                        {
                        }
                        else
                        {
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionClank, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.SHIELDPROJECTILE, this.reactionShieldProjectile, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.ABSORB, this.reactionAbsorb, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.EGG, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.FREEZE, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.ATTACK, HitBoxSprite.STAR, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.RANGE, HitBoxSprite.HIT, this.reactionRange, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, opponent, HitBoxSprite.HIT, HitBoxSprite.HIT, this.reactionCollide, STAGEDATA.HitBoxProcessorInstance);
                        };
                    };
                    i++;
                };
                i = 0;
                while (i < STAGEDATA.Projectiles.length)
                {
                    projectile = STAGEDATA.Projectiles[i];
                    if ((((projectile) && (!(projectile == this))) && (!(((projectile.getOwner() == this.getOwner()) && (!(projectile.WasReversed))) && (!(this.WasReversed))))))
                    {
                        if ((!(InteractiveSprite.hitTest(this, projectile, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                        {
                        }
                        else
                        {
                            InteractiveSprite.hitTest(this, projectile, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionAttackReverse, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, projectile, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionClank, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, projectile, HitBoxSprite.HIT, HitBoxSprite.HIT, this.reactionCollide, STAGEDATA.HitBoxProcessorInstance);
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
                            InteractiveSprite.hitTest(this, enemy, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, enemy, HitBoxSprite.COUNTER, HitBoxSprite.ATTACK, this.reactionCounter, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, enemy, HitBoxSprite.HIT, HitBoxSprite.HIT, this.reactionCollide, STAGEDATA.HitBoxProcessorInstance);
                        };
                    };
                    i++;
                };
                i = 0;
                while (i < STAGEDATA.ItemsRef.MAXITEMS)
                {
                    item = STAGEDATA.ItemsRef.getItemData(i);
                    if (item != null)
                    {
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.ATTACK, HitBoxSprite.ATTACK, this.reactionAttackReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.REVERSE, HitBoxSprite.ATTACK, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.REVERSE, HitBoxSprite.HIT, this.reactionReverse, STAGEDATA.HitBoxProcessorInstance);
                        InteractiveSprite.hitTest(this, item, HitBoxSprite.HIT, HitBoxSprite.HIT, this.reactionCollide, STAGEDATA.HitBoxProcessorInstance);
                    };
                    i++;
                };
                i = 0;
                while (i < STAGEDATA.Targets.length)
                {
                    target = STAGEDATA.Targets[i];
                    if (target != null)
                    {
                        if ((!(InteractiveSprite.hitTest(this, target, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length)))
                        {
                        }
                        else
                        {
                            InteractiveSprite.hitTest(this, target, HitBoxSprite.ATTACK, HitBoxSprite.HIT, this.reactionHit, STAGEDATA.HitBoxProcessorInstance);
                            InteractiveSprite.hitTest(this, target, HitBoxSprite.HIT, HitBoxSprite.HIT, this.reactionCollide, STAGEDATA.HitBoxProcessorInstance);
                        };
                    };
                    i++;
                };
                this.checkLatch();
            };
            if (HasMC)
            {
                m_sprite.stop();
                Utils.recursiveMovieClipPlay(m_sprite, false);
            };
        }

        override protected function validateBypass(attackObj:AttackDamage):Boolean
        {
            if (attackObj.BypassProjectiles)
            {
                return (false);
            };
            if (attackObj.BypassNonGrabbed)
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
            if (((!(super.validateHit(attackObj, ignoreInvincible, ignoreIntangible))) || (inState(PState.DEAD))))
            {
                return (false);
            };
            return (true);
        }

        public function validateHitClank(attackObj:AttackDamage, ignoreInvincible:Boolean=false, ignoreIntangible:Boolean=false):Boolean
        {
            if ((((((((((inState(PState.DEAD)) || (!(attackObj))) || (!(this.validateBypass(attackObj)))) || (!(validateOnlyAffects(attackObj)))) || (checkUnhittableSelfHit(attackObj))) || (checkUnhittableTeamHit(attackObj))) || ((!(ignoreInvincible)) && (isInvincible()))) || ((!(ignoreIntangible)) && (isIntangible()))) || (attackIDArrayContains(attackObj.AttackID))))
            {
                return (false);
            };
            return (true);
        }

        override public function takeDamage(attackObj:AttackDamage, collisionHitBox:HitBoxSprite=null):Boolean
        {
            var angle:Number;
            var tempDamage:Number;
            var xVelocity:Number;
            var yVelocity:Number;
            var flyingRight:Boolean;
            var flyingUp:Boolean;
            var effect1MC:MovieClip;
            if ((!(this.validateHit(attackObj, false, true))))
            {
                return (false);
            };
            var oldDamage:Number = m_damage;
            var preDamage:Number = ((attackObj.Damage <= 0) ? 0 : Utils.calculateChargeDamage(attackObj));
            var sizeMultiplier:Number = ((attackObj.SizeStatus == 0) ? 1 : ((attackObj.SizeStatus > 0) ? 2 : 0.5));
            var tempVelocity:Number = 0;
            var tempKnockback:Number = 0;
            if (attackObj.HasEffect)
            {
                if (((!(m_hurtInterrupt == null)) && (m_hurtInterrupt({
                    "target":(((attackObj.Owner) && (attackObj.Owner.APIInstance)) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }))))
                {
                    return (false);
                };
                initDelayPlayback(false);
                angle = 0;
                tempDamage = ((attackObj.Damage <= 0) ? 0 : Utils.calculateChargeDamage(attackObj));
                tempDamage = (tempDamage * attackObj.StaleMultiplier);
                if (((attackObj.Damage > 0) && (tempDamage <= 0)))
                {
                    tempDamage = 1;
                };
                stackAttackID(attackObj.AttackID);
                if (attackObj.Power >= 0)
                {
                    if (((attackObj.Owner as Projectile) && (attackObj.ChargeTimeMax > 0)))
                    {
                        tempVelocity = ((attackObj.ChargeTimeMax > 0) ? (((0.25 + (1 * (attackObj.ChargeTime / attackObj.ChargeTimeMax))) * attackObj.Power) + (((10 * attackObj.KBConstant) * 1) / 1)) : (attackObj.Power + (((10 * attackObj.KBConstant) * 1) / 1)));
                    }
                    else
                    {
                        tempVelocity = ((attackObj.ChargeTimeMax > 0) ? (((0.85 + (0.25 * (attackObj.ChargeTime / attackObj.ChargeTimeMax))) * attackObj.Power) + (((10 * attackObj.KBConstant) * 1) / 1)) : (attackObj.Power + (((10 * attackObj.KBConstant) * 1) / 1)));
                    };
                    if (tempVelocity < 2550)
                    {
                    };
                }
                else
                {
                    tempVelocity = -(attackObj.Power);
                };
                tempVelocity = (tempVelocity / 100);
                if (m_collision.ground)
                {
                    if (((angle > 180) && (angle < 360)))
                    {
                        angle = (360 - angle);
                    };
                };
                if ((!(attackObj.IsForward)))
                {
                    angle = (180 - angle);
                };
                angle = Utils.forceBase360(angle);
                xVelocity = Math.abs((tempVelocity * Math.cos(((angle * Math.PI) / 180))));
                yVelocity = Math.abs((tempVelocity * Math.sin(((angle * Math.PI) / 180))));
                flyingRight = ((((angle >= 0) && (angle < 90)) || ((angle >= 270) && (angle < 360))) ? true : false);
                flyingUp = (((angle >= 0) && (angle < 180)) ? true : false);
                if (((yVelocity > 50) && (!(flyingUp))))
                {
                    yVelocity = 50;
                };
                angle = Utils.calculateReversedAngle(Utils.calculateAttackDirection(attackObj, this), attackObj, this);
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
                if (attackObj.EffectSound != null)
                {
                    this.playGlobalSound(attackObj.EffectSound);
                };
                if (attackObj.HasEffect)
                {
                    if (m_paralysis)
                    {
                        stopActionShot(false, true);
                        m_paralysisHitCount = 3;
                        startActionShot(Utils.calculateHitStun(attackObj.HitStun, tempDamage, attackObj.Shock, false));
                    }
                    else
                    {
                        startActionShot(Utils.calculateHitStun(attackObj.HitStun, tempDamage, attackObj.Shock, false), attackObj.Paralysis);
                    };
                }
                else
                {
                    startActionShot(-1, attackObj.Paralysis);
                };
                tempKnockback = Utils.calculateKnockback(attackObj.KBConstant, attackObj.Power, attackObj.WeightKB, preDamage, oldDamage, this.m_projectileStats.Weight1, false, STAGEDATA.GameRef.LevelData.damageRatio, attackObj.AttackRatio);
                tempVelocity = Utils.calculateVelocity(tempKnockback);
                if (this.m_projectileStats.CanReceiveKnockback)
                {
                    applyKnockbackSpeed(tempVelocity, angle);
                };
                if (this.m_projectileStats.CanReceiveDamage)
                {
                    setDamage(((this.m_projectileStats.Stamina > 0) ? (m_damage - tempDamage) : (m_damage + tempDamage)));
                };
                if (((tempVelocity < Character.HEAVY_KNOCKBACK_THRESHOLD) || (Utils.calculateHitlag(tempKnockback, attackObj.HitLag) < Character.HEAVY_KNOCKBACK_HITLAG_THRESHOLD)))
                {
                    if (attackObj.Power >= 1000)
                    {
                        CAM.shake(6);
                    };
                }
                else
                {
                    if (tempVelocity > 35)
                    {
                        STAGEDATA.lightFlash(false);
                    };
                    CAM.shake(12);
                };
                if (attackObj.CamShake > 0)
                {
                    CAM.shake(attackObj.CamShake);
                };
                if ((!(m_attack.DisableLastHitUpdate)))
                {
                    m_lastHitID = attackObj.PlayerID;
                    m_lastHitObject = attackObj;
                };
                m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.PROJ_HURT, {
                    "caller":this.APIInstance.instance,
                    "opponent":((attackObj.Owner) ? attackObj.Owner.APIInstance.instance : null),
                    "attackBoxData":attackObj.exportAttackDamageData(),
                    "collisionRect":((collisionHitBox) ? collisionHitBox.BoundingBox : null)
                }));
                return (true);
            };
            return (false);
        }

        public function checkLatch():void
        {
            var character:Character;
            if (this.m_latch_id != null)
            {
                character = ((this.m_latch_id as Character) ? Character(this.m_latch_id) : null);
                if (((character) && (((character.Revival) || (character.Dead)) || (character.StandBy))))
                {
                    this.destroy();
                    this.m_latch_id = null;
                }
                else
                {
                    if (((this.m_projectileStats.LatchXOffset == 0) && (this.m_projectileStats.LatchYOffset == 0)))
                    {
                        m_sprite.x = (this.m_latch_id.X + this.m_latch_xLoc);
                        m_sprite.y = (((character) && (character.Hanging)) ? ((this.m_latch_id.Y + this.m_latch_yLoc) + (this.m_latch_id.Height / 2)) : ((this.m_latch_id.Y + this.m_latch_yLoc) - (this.m_latch_id.Height / 2)));
                    }
                    else
                    {
                        m_sprite.x = (this.m_latch_id.X + this.m_projectileStats.LatchXOffset);
                        m_sprite.y = (((character) && (character.Hanging)) ? ((this.m_latch_id.Y + this.m_projectileStats.LatchYOffset) + (this.m_latch_id.Height / 2)) : ((this.m_latch_id.Y + this.m_projectileStats.LatchYOffset) - (this.m_latch_id.Height / 2)));
                    };
                };
            };
        }

        private function visible():Boolean
        {
            return (m_sprite.visible);
        }

        private function setVar(varName:String, varValue:*):void
        {
            m_sprite[varName] = varValue;
        }

        private function m_calcFlyingAngle():void
        {
            var angle:Number;
            if (((this.m_projectileStats.Rotate) && (!(((m_xSpeed == 0) && (m_ySpeed == 0)) || ((this.m_projectileStats.HomingSpeed == 0) && (m_attack.HomingTarget))))))
            {
                angle = Utils.getAngleBetween(new Point(0, 0), new Point(m_xSpeed, m_ySpeed));
                angle = Utils.forceBase360(((m_facingForward) ? -(angle) : (-(angle) + 180)));
                m_sprite.rotation = angle;
            };
        }

        private function checkWall():void
        {
            if (((((((!(m_collision.ground)) && (!(this.m_projectileStats.XOffset == 0))) && (!(this.m_projectileStats.Ghost))) && (!(this.m_projectileStats.Latch))) && (!(inState(PState.DEAD)))) && (testTerrainWithCoord(m_sprite.x, m_sprite.y))))
            {
                if (m_facingForward)
                {
                    m_sprite.x = (m_sprite.x - ((this.m_projectileStats.XOffset > 0) ? 1 : -1));
                }
                else
                {
                    m_sprite.x = (m_sprite.x + ((this.m_projectileStats.XOffset > 0) ? 1 : -1));
                };
            };
        }

        override protected function m_controlFrames():void
        {
            if (m_state == PState.IDLE)
            {
                playFrame(m_attack.Frame);
            }
            else
            {
                if (m_state == PState.DEAD)
                {
                };
            };
        }

        protected function m_pushAwayOpponents():void
        {
            var i:int;
            var opponent:Character;
            var theirRect:Rectangle;
            var myRect:Rectangle;
            if ((((this.m_projectileStats.PushCharacters) && (m_collision.ground)) && (!(inState(PState.DEAD)))))
            {
                i = 0;
                while (i < STAGEDATA.Characters.length)
                {
                    opponent = STAGEDATA.Characters[i];
                    if (((((!(m_collision.ground)) && (!(opponent))) || (!(opponent.CollisionObj.ground))) || (!(InteractiveSprite.hitTest(this, opponent, HitBoxSprite.MASTER, HitBoxSprite.MASTER, reactionMaster).length))))
                    {
                    }
                    else
                    {
                        theirRect = opponent.BoundsRect;
                        myRect = BoundsRect;
                        theirRect.x = (theirRect.x + opponent.X);
                        theirRect.y = (theirRect.y + opponent.Y);
                        myRect.x = (myRect.x + m_sprite.x);
                        myRect.y = (myRect.y + m_sprite.y);
                        if (theirRect.intersects(myRect))
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
                    i++;
                };
            };
        }

        override public function PERFORMALL():void
        {
            this.PREPERFORM();
            if ((((!(inState(PState.DEAD))) && (!(STAGEDATA.FSCutscene))) && ((STAGEDATA.FSCutins <= 0) || ((this.m_owner is Character) && (Character(this.m_owner).UsingFinalSmash)))))
            {
                checkTimers();
                if ((((this.m_projectileStats.TimeMax > 0) && (!(isHitStunOrParalysis()))) && (!(this.m_projectileStats.Suspend))))
                {
                    this.m_time++;
                };
                this.checkWall();
                this.m_groundCollisionTest();
                this.m_calcFlyingAngle();
                this.checkReverse();
                this.projectileMove();
                this.m_pushAwayOpponents();
                m_forces();
                updateSelfPlatform();
                checkReflection();
                checkShadow();
                checkHitStun();
                checkShowHitBoxes();
                updateCamerBox();
                this.checkIfDead();
            };
            this.POSTPERFORM();
        }

        override protected function PREPERFORM():void
        {
            if (((!(STAGEDATA.FSCutscene)) && ((STAGEDATA.FSCutins <= 0) || ((this.m_owner is Character) && (Character(this.m_owner).UsingFinalSmash)))))
            {
                if ((((((m_started) && (HasStance)) && (!(inState(PState.DEAD)))) && (!(isHitStunOrParalysis()))) && (!(m_delayPlayback))))
                {
                    Utils.advanceFrame(m_sprite.stance);
                    Utils.recursiveMovieClipPlay(m_sprite.stance, true);
                }
                else
                {
                    handleDelayPlayback();
                };
            };
        }

        override protected function POSTPERFORM():void
        {
            if (((!(STAGEDATA.FSCutscene)) && ((STAGEDATA.FSCutins <= 0) || ((this.m_owner is Character) && (Character(this.m_owner).UsingFinalSmash)))))
            {
                super.POSTPERFORM();
                m_apiInstance.update();
            };
        }


    }
}//package com.mcleodgaming.ssf2.engine

