// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.engine.InteractiveSprite

package com.mcleodgaming.ssf2.engine
{
    import com.mcleodgaming.ssf2.api.SSF2GameObject;
    import flash.display.MovieClip;
    import com.mcleodgaming.ssf2.util.Vcam;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.platforms.Platform;
    import com.mcleodgaming.ssf2.events.EventManager;
    import com.mcleodgaming.ssf2.util.IntervalTimer;
    import flash.geom.Point;
    import com.mcleodgaming.ssf2.platforms.MovingPlatform;
    import com.mcleodgaming.ssf2.util.FrameTimer;
    import flash.geom.Rectangle;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.api.SSF2API;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.display.DisplayObject;
    import com.mcleodgaming.ssf2.enums.ModeFeatures;
    import com.mcleodgaming.ssf2.enums.Mode;
    import flash.text.TextField;
    import com.mcleodgaming.ssf2.api.SSF2Event;
    import com.mcleodgaming.ssf2.Main;
    import com.mcleodgaming.ssf2.items.Item;
    import com.mcleodgaming.ssf2.enemies.Enemy;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.enums.SpecialMode;
    import flash.geom.ColorTransform;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.display.Bitmap;
    import flash.events.Event;
    import __AS3__.vec.*;
    import com.mcleodgaming.ssf2.platforms.*;
    import com.mcleodgaming.ssf2.util.*;

    public class InteractiveSprite 
    {

        public static var SHOW_HITBOXES:Boolean = false;
        public static var HITBOXES_WAS_ON:Boolean = false;

        protected var m_uid:int;
        protected var m_state:uint;
        protected var m_hitBoxManager:HitBoxManager;
        protected var m_apiInstance:SSF2GameObject;
        protected var m_delayPlayback:Boolean;
        protected var m_delayPlayBackAnimation:String;
        protected var m_delayPlayBackFrame:String;
        protected var m_delayPlayBackFacingRight:Boolean;
        protected var m_delayPlayBackHitStun:Boolean;
        protected var STAGE:MovieClip;
        protected var STAGEPARENT:MovieClip;
        protected var STAGEEFFECTS:MovieClip;
        protected var CAM:Vcam;
        protected var STAGEDATA:StageData;
        protected var m_baseStats:InteractiveSpriteStats;
        protected var m_sprite:MovieClip;
        protected var m_collision:Collision;
        protected var m_width:Number;
        protected var m_height:Number;
        protected var m_terrains:Vector.<Platform>;
        protected var m_platforms:Vector.<Platform>;
        protected var m_eventManager:EventManager;
        protected var m_tempEvents:Vector.<Object>;
        protected var m_timers:Vector.<IntervalTimer>;
        protected var m_sizeRatio:Number;
        protected var m_currentPlatform:Platform;
        protected var m_gravity:Number;
        protected var m_max_ySpeed:Number;
        protected var m_xSpeed:Number;
        protected var m_ySpeed:Number;
        protected var m_facingForward:Boolean;
        protected var m_started:Boolean;
        protected var m_hitPlatform:Platform;
        protected var m_collisionPoint:Point;
        protected var m_selfPlatform:MovingPlatform;
        protected var m_player_id:int;
        protected var m_team_id:int;
        protected var m_healthBoxMC:MovieClip;
        protected var m_damage:Number;
        protected var m_attack:AttackState;
        protected var m_attackCache:AttackState;
        protected var m_attackData:AttackData;
        protected var m_skipAttackCollisionTests:Boolean;
        protected var m_skipAttackProcessing:Boolean;
        protected var m_attackCollisionTestsPreProcessed:Boolean;
        protected var m_lastHitID:int;
        protected var m_lastHitObject:AttackDamage;
        protected var m_lastAttackID:Array;
        protected var m_lastAttackIndex:int;
        protected var m_lastStaleID:Array;
        protected var m_lastStaleIndex:int;
        protected var m_xKnockback:Number;
        protected var m_yKnockback:Number;
        protected var m_xKnockbackDecay:Number;
        protected var m_yKnockbackDecay:Number;
        protected var m_knockbackStackingTimer:FrameTimer;
        protected var m_knockbackStacked:Boolean;
        protected var m_counterAttackData:Object;
        protected var m_invincible:Boolean;
        protected var m_intangible:Boolean;
        protected var m_actionShot:Boolean;
        protected var m_actionTimer:int;
        protected var m_paralysis:Boolean;
        protected var m_paralysisHitCount:int;
        protected var m_paralysisTimer:int;
        protected var m_maxParalysisTime:FrameTimer;
        protected var m_hitStunToggle:Boolean;
        protected var m_hitStunTimer:int;
        protected var m_weight2:Number;
        protected var m_cancelEffectDelay:FrameTimer;
        protected var m_cancelEffectDelay2:FrameTimer;
        protected var m_cancelEffectCount:int;
        protected var m_cancelEffect:String;
        protected var m_bypassCollisionTesting:Boolean;
        private var m_globalVariables:Object;
        protected var m_framesSinceLastState:int;
        protected var m_shadowEffect:MovieClip;
        protected var m_reflectionEffect:MovieClip;
        protected var m_fadeTimer:FrameTimer;
        protected var m_hurtInterrupt:Function;
        protected var m_targetInterrupt:Function;
        protected var m_warningBounds_lower:Array;
        protected var m_warningBounds_upper:Array;
        protected var m_currentAnimationID:String;
        protected var m_paletteSwapData:Object;
        protected var m_paletteSwapPAData:Object;
        protected var m_shortestPath:Vector.<Beacon>;
        protected var m_currentTarget:Target;
        protected var m_targetTemp:Target;
        protected var m_previousAnimation:String;
        private var __locationCached:Point = new Point();
        private var __boundsRectCached:Rectangle = new Rectangle();
        private var __currentScaleCached:Point = new Point();
        private var __attemptToMovePointCache:Point = new Point();

        public function InteractiveSprite(mc:MovieClip, stageData:StageData, addMC:Boolean=true)
        {
            this.m_globalVariables = new Object();
            this.m_attack = new AttackState(this);
            this.m_attackCache = new AttackState(this);
            var i:int;
            this.m_state = 0;
            this.STAGEDATA = stageData;
            this.STAGE = this.STAGEDATA.StageRef;
            this.STAGEPARENT = this.STAGEDATA.StageParentRef;
            this.STAGEEFFECTS = this.STAGEDATA.StageEffectsRef;
            this.CAM = this.STAGEDATA.CamRef;
            this.m_uid = Utils.getUID();
            if (addMC)
            {
                this.m_sprite = MovieClip(this.STAGE.addChild(mc));
            }
            else
            {
                this.m_sprite = mc;
            };
            this.m_delayPlayback = false;
            this.m_delayPlayBackAnimation = null;
            this.m_delayPlayBackFrame = null;
            this.m_delayPlayBackFacingRight = true;
            this.m_delayPlayBackHitStun = false;
            this.m_collision = new Collision();
            this.m_healthBoxMC = null;
            this.m_damage = ((this.m_baseStats.Stamina > 0) ? this.m_baseStats.Stamina : 0);
            this.m_currentPlatform = null;
            this.m_gravity = 0;
            this.m_max_ySpeed = 0;
            this.m_xSpeed = 0;
            this.m_ySpeed = 0;
            this.m_sizeRatio = 1;
            this.m_facingForward = true;
            this.m_terrains = this.STAGEDATA.Terrains;
            this.m_platforms = this.STAGEDATA.Platforms;
            this.m_started = false;
            this.m_collisionPoint = new Point();
            this.m_hitPlatform = null;
            this.m_selfPlatform = null;
            this.m_counterAttackData = null;
            this.m_eventManager = new EventManager();
            this.m_tempEvents = new Vector.<Object>();
            this.m_timers = new Vector.<IntervalTimer>();
            this.m_player_id = -1;
            this.m_team_id = -1;
            this.m_lastHitID = 0;
            this.m_lastHitObject = null;
            this.m_lastAttackIndex = 0;
            this.m_lastAttackID = new Array(60);
            this.m_shadowEffect = new MovieClip();
            this.m_reflectionEffect = new MovieClip();
            i = 0;
            while (i < this.m_lastAttackID.length)
            {
                this.m_lastAttackID[i] = 0;
                i++;
            };
            this.m_lastStaleIndex = 0;
            this.m_lastStaleID = new Array(60);
            i = 0;
            while (i < this.m_lastStaleID.length)
            {
                this.m_lastStaleID[i] = 0;
                i++;
            };
            this.m_xKnockback = 0;
            this.m_yKnockback = 0;
            this.m_xKnockbackDecay = 0;
            this.m_yKnockbackDecay = 0;
            this.m_knockbackStackingTimer = new FrameTimer(5);
            this.m_knockbackStacked = false;
            this.m_invincible = false;
            this.m_intangible = false;
            this.m_actionShot = false;
            this.m_actionTimer = 0;
            this.m_paralysis = false;
            this.m_paralysisHitCount = 0;
            this.m_paralysisTimer = 0;
            this.m_maxParalysisTime = new FrameTimer(15);
            this.m_maxParalysisTime.finish();
            this.m_hitStunTimer = 0;
            this.m_hitStunToggle = false;
            this.m_weight2 = (Utils.VELOCITY_SCALE * Utils.WEIGHT2_BASE);
            this.m_cancelEffectDelay = new FrameTimer(10);
            this.m_cancelEffectDelay2 = new FrameTimer(60);
            this.m_cancelEffectCount = 0;
            this.m_cancelEffect = "effect_cancel";
            this.m_bypassCollisionTesting = false;
            this.m_framesSinceLastState = 0;
            this.m_fadeTimer = new FrameTimer(15);
            this.m_hurtInterrupt = null;
            this.m_targetInterrupt = null;
            this.m_warningBounds_lower = new Array(this.STAGEDATA.getWarningBounds_LL(), this.STAGEDATA.getWarningBounds_LR());
            this.m_warningBounds_upper = new Array(this.STAGEDATA.getWarningBounds_UL(), this.STAGEDATA.getWarningBounds_UR());
            this.m_skipAttackCollisionTests = false;
            this.m_skipAttackProcessing = false;
            this.m_attackCollisionTestsPreProcessed = false;
            this.m_shortestPath = null;
            this.m_currentTarget = new Target();
            this.m_targetTemp = new Target();
            this.m_previousAnimation = null;
            this.m_currentAnimationID = (((this.m_sprite.xframe) || (this.m_sprite.currentLabel)) || (null));
            this.m_paletteSwapData = null;
            this.m_paletteSwapPAData = null;
        }

        public static function hitTest(mySprite:InteractiveSprite, theirSprite:InteractiveSprite, myType:uint, theirType:uint, callback:Function=null, processor:HitBoxProcessor=null, optimized:Boolean=false):Vector.<HitBoxCollisionResult>
        {
            var anim:HitBoxAnimation;
            var i:int;
            var j:int;
            var rect:Rectangle;
            var tmpResult:HitBoxCollisionResult;
            var cindex:int;
            var collisionRect:Vector.<HitBoxCollisionResult>;
            var myHitBoxes:Array;
            var theirHitBoxes:Array;
            if (((!(mySprite.hitboxManager.HasHitBoxes)) || (!(theirSprite.hitboxManager.HasHitBoxes))))
            {
                return (new Vector.<HitBoxCollisionResult>());
            };
            if (((myType == HitBoxSprite.SHIELD) && (mySprite as Character)))
            {
                myHitBoxes = Character(mySprite).ShieldHitBoxes;
            }
            else
            {
                if (((myType == HitBoxSprite.STAR) && (mySprite as Character)))
                {
                    myHitBoxes = Character(mySprite).StarHitBoxes;
                }
                else
                {
                    if (((myType == HitBoxSprite.EGG) && (mySprite as Character)))
                    {
                        myHitBoxes = Character(mySprite).EggHitBoxes;
                    }
                    else
                    {
                        if (((myType == HitBoxSprite.FREEZE) && (mySprite as Character)))
                        {
                            myHitBoxes = Character(mySprite).FreezeHitBoxes;
                        }
                        else
                        {
                            if (((myType == HitBoxSprite.PICKUP) && (mySprite as Character)))
                            {
                                myHitBoxes = Character(mySprite).PickupHitBoxes;
                            }
                            else
                            {
                                myHitBoxes = mySprite.CurrentAnimation.getHitBoxes(mySprite.CurrentFrameNum, myType);
                            };
                        };
                    };
                };
            };
            if (((theirType == HitBoxSprite.SHIELD) && (theirSprite as Character)))
            {
                theirHitBoxes = Character(theirSprite).ShieldHitBoxes;
            }
            else
            {
                if (((theirType == HitBoxSprite.STAR) && (theirType as Character)))
                {
                    theirHitBoxes = Character(theirSprite).StarHitBoxes;
                }
                else
                {
                    if (((theirType == HitBoxSprite.EGG) && (theirSprite as Character)))
                    {
                        theirHitBoxes = Character(theirSprite).EggHitBoxes;
                    }
                    else
                    {
                        if (((theirType == HitBoxSprite.FREEZE) && (theirSprite as Character)))
                        {
                            theirHitBoxes = Character(theirSprite).FreezeHitBoxes;
                        }
                        else
                        {
                            if (((theirType == HitBoxSprite.PICKUP) && (theirSprite as Character)))
                            {
                                theirHitBoxes = Character(theirSprite).PickupHitBoxes;
                            }
                            else
                            {
                                anim = theirSprite.CurrentAnimation;
                                theirHitBoxes = (((theirSprite) && (anim)) ? anim.getHitBoxes(theirSprite.CurrentFrameNum, theirType) : null);
                                if ((!(anim)))
                                {
                                    SSF2API.print(((("Warning!!! Missing hitboxes for animation detected in MC. Current label: " + theirSprite.MC.currentLabel) + " Frame #: ") + theirSprite.MC.currentFrame));
                                };
                            };
                        };
                    };
                };
            };
            var myScale:Point = (mySprite is Character) ? Character(mySprite).getStrengthCollisionScale(myType) : mySprite.CurrentScale;
            var theirScale:Point = (theirSprite is Character) ? Character(theirSprite).getStrengthCollisionScale(theirType) : theirSprite.CurrentScale;
            var priority:int = 6;
            if (((myType == HitBoxSprite.GRAB) || (theirType === HitBoxSprite.GRAB)))
            {
                priority = 0;
            }
            else
            {
                if (((myType == HitBoxSprite.COUNTER) || (theirType === HitBoxSprite.COUNTER)))
                {
                    priority = 1;
                }
                else
                {
                    if (((myType == HitBoxSprite.REVERSE) || (theirType === HitBoxSprite.REVERSE)))
                    {
                        priority = 2;
                    }
                    else
                    {
                        if (((myType == HitBoxSprite.ATTACK) && (theirType === HitBoxSprite.ATTACK)))
                        {
                            priority = 3;
                        }
                        else
                        {
                            if (((myType == HitBoxSprite.GRAB) && (theirType === HitBoxSprite.GRAB)))
                            {
                                priority = 4;
                            }
                            else
                            {
                                if (((myType == HitBoxSprite.SHIELDPROJECTILE) || (theirType === HitBoxSprite.SHIELDPROJECTILE)))
                                {
                                    priority = 5;
                                };
                            };
                        };
                    };
                };
            };
            if (optimized)
            {
                collisionRect = new Vector.<HitBoxCollisionResult>();
                if (((myHitBoxes == null) || (theirHitBoxes == null)))
                {
                    return (collisionRect);
                };
                i = 0;
                while (i < myHitBoxes.length)
                {
                    j = 0;
                    while (j < theirHitBoxes.length)
                    {
                        rect = myHitBoxes[i].hitTest(theirHitBoxes[j], mySprite.Location, theirSprite.Location, (!(mySprite.FacingForward)), (!(theirSprite.FacingForward)), myScale, theirScale, mySprite.CurrentRotation, theirSprite.CurrentRotation);
                        if (rect)
                        {
                            tmpResult = new HitBoxCollisionResult(myHitBoxes[i], theirHitBoxes[j], new HitBoxSprite(myHitBoxes[i].Type, rect, myHitBoxes[i].Circular, myHitBoxes[i].CustomData));
                            collisionRect.push(tmpResult);
                            if (((!(callback == null)) && (callback(theirSprite, tmpResult))))
                            {
                                return (collisionRect);
                            };
                        };
                        j++;
                    };
                    i++;
                };
            }
            else
            {
                if ((((collisionRect = HitBoxSprite.hitTestArray(myHitBoxes, theirHitBoxes, mySprite.Location, theirSprite.Location, (!(mySprite.FacingForward)), (!(theirSprite.FacingForward)), myScale, theirScale, mySprite.CurrentRotation, theirSprite.CurrentRotation)).length > 0) && (!(callback == null))))
                {
                    cindex = 0;
                    while (cindex < collisionRect.length)
                    {
                        if (processor)
                        {
                            processor.queue(new HitBoxProcessorNode(mySprite, theirSprite, collisionRect[cindex], callback), priority);
                        }
                        else
                        {
                            (callback(theirSprite, collisionRect[cindex]));
                        };
                        cindex++;
                    };
                };
            };
            return (collisionRect);
        }


        public function get ID():int
        {
            return (this.m_player_id);
        }

        public function get UID():int
        {
            return (this.m_uid);
        }

        public function get APIInstance():SSF2GameObject
        {
            return (this.m_apiInstance);
        }

        public function get Team():int
        {
            return (this.m_team_id);
        }

        public function set Team(value:int):void
        {
            if (((value === -1) || ((value >= 1) && (value <= 3))))
            {
                this.m_team_id = value;
            };
        }

        public function get EventManagerObj():EventManager
        {
            return (this.m_eventManager);
        }

        public function get TempEventObj():Vector.<Object>
        {
            return (this.m_tempEvents);
        }

        public function get ActionShot():Boolean
        {
            return (this.m_actionShot);
        }

        public function get SelfPlatform():MovingPlatform
        {
            return (this.m_selfPlatform);
        }

        public function get Location():Point
        {
            this.__locationCached.setTo(this.m_sprite.x, this.m_sprite.y);
            return (this.__locationCached);
        }

        public function get BoundsRect():Rectangle
        {
            this.__boundsRectCached.setTo((this.m_sprite.x - ((this.m_width / 2) * this.m_sizeRatio)), (this.m_sprite.y - (this.m_height * this.m_sizeRatio)), (this.m_width * this.m_sizeRatio), (this.m_height * this.m_sizeRatio));
            return (this.__boundsRectCached);
        }

        public function get CurrentAnimation():HitBoxAnimation
        {
            return ((this.m_hitBoxManager == null) ? null : (((this.m_hitBoxManager.HitBoxAnimationList.length <= 0) || (!(this.m_currentAnimationID))) ? null : this.m_hitBoxManager.getHitBoxAnimation(this.m_currentAnimationID)));
        }

        public function get CurrentFrame():String
        {
            return ((this.m_sprite.xframe != null) ? this.m_sprite.xframe : this.m_currentAnimationID);
        }

        public function get CurrentFrameNum():int
        {
            return ((this.HasStance) ? this.m_sprite.stance.currentFrame : this.m_sprite.currentFrame);
        }

        public function get CurrentScale():Point
        {
            this.__currentScaleCached.setTo(Utils.fastAbs(this.m_sprite.scaleX), Utils.fastAbs(this.m_sprite.scaleY));
            return (this.__currentScaleCached);
        }

        public function get CurrentRotation():Number
        {
            return (Utils.forceBase360((360 - this.m_sprite.rotation)));
        }

        public function get CollisionObj():Collision
        {
            return (this.m_collision);
        }

        public function get Width():Number
        {
            return (this.m_width);
        }

        public function get FacingForward():Boolean
        {
            return (this.m_facingForward);
        }

        public function get Height():Number
        {
            return (this.m_height);
        }

        public function get OnPlatform():Boolean
        {
            return ((!(this.m_currentPlatform == null)) && (this.STAGEDATA.Platforms.indexOf(this.m_currentPlatform) >= 0));
        }

        public function get OnTerrain():Boolean
        {
            return ((!(this.m_currentPlatform == null)) && (this.STAGEDATA.Terrains.indexOf(this.m_currentPlatform) >= 0));
        }

        public function get Weight2():Number
        {
            return (this.m_weight2);
        }

        public function set Weight2(value:Number):void
        {
            this.m_weight2 = value;
        }

        public function get LastHitID():int
        {
            return (this.m_lastHitID);
        }

        public function get X():Number
        {
            var xp:Number = this.m_sprite.x;
            return (xp);
        }

        public function get Y():Number
        {
            var yp:Number = this.m_sprite.y;
            return (yp);
        }

        public function set X(value:Number):void
        {
            this.m_sprite.x = value;
        }

        public function set Y(value:Number):void
        {
            this.m_sprite.y = value;
        }

        public function get XSpeed():Number
        {
            return (this.m_xSpeed);
        }

        public function set XSpeed(value:Number):void
        {
            this.m_xSpeed = value;
        }

        public function get YSpeed():Number
        {
            return (this.m_ySpeed);
        }

        public function set YSpeed(value:Number):void
        {
            this.m_ySpeed = value;
        }

        public function get GlobalX():Number
        {
            return (this.m_sprite.x);
        }

        public function get GlobalY():Number
        {
            return (this.m_sprite.y);
        }

        public function get OverlayX():Number
        {
            return (this.m_sprite.x + this.STAGEDATA.StageRef.x);
        }

        public function get OverlayY():Number
        {
            return (this.m_sprite.y + this.STAGEDATA.StageRef.y);
        }

        public function get Ground():Boolean
        {
            return (this.m_collision.ground as Boolean);
        }

        public function get MC():MovieClip
        {
            return (this.m_sprite);
        }

        public function get CurrentPlatform():Platform
        {
            return (this.m_currentPlatform);
        }

        public function get Depth():Number
        {
            return ((!(this.m_sprite.parent)) ? 0 : this.m_sprite.parent.getChildIndex(this.m_sprite));
        }

        public function get HasMC():Boolean
        {
            return (Boolean((!(this.m_sprite == null))));
        }

        public function get HasStance():Boolean
        {
            return (Boolean(((this.HasMC) && (!(this.m_sprite.stance == null)))));
        }

        public function get HasHand():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HAND)))));
        }

        public function get HasHitBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HIT)))));
        }

        public function get HasAttackBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.ATTACK)))));
        }

        public function get HasReverseBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.REVERSE)))));
        }

        public function get HasAbsorbBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.ABSORB)))));
        }

        public function get HasShieldAttackBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.SHIELDATTACK)))));
        }

        public function get HasShieldProjectileBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.SHIELDPROJECTILE)))));
        }

        public function get HasCamBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.CAM)))));
        }

        public function get HasGrabBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.GRAB)))));
        }

        public function get HasGrabber():Boolean
        {
            return (Boolean(((this.HasStance) && (!(this.m_sprite.stance.grabber == null)))));
        }

        public function get HasItemBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.ITEM)))));
        }

        public function get HasHatBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HAT)))));
        }

        public function get HasTouchBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.TOUCH)))));
        }

        public function get HasRange():Boolean
        {
            return (Boolean(((this.HasStance) && (!(this.m_sprite.stance.range == null)))));
        }

        public function get HasHoming():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HOMING)))));
        }

        public function get HasCatchBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.CATCH)))));
        }

        public function get HasCounterBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.COUNTER)))));
        }

        public function get HasPLockBox():Boolean
        {
            return (Boolean((((this.HasStance) && (this.CurrentAnimation)) && (this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.PLOCK)))));
        }

        public function get PickupHitBoxes():Array
        {
            return (null);
        }

        public function get ShieldHitBoxes():Array
        {
            return (null);
        }

        public function get StarHitBoxes():Array
        {
            return (null);
        }

        public function get EggHitBoxes():Array
        {
            return (null);
        }

        public function get FreezeHitBoxes():Array
        {
            return (null);
        }

        public function get hitboxManager():HitBoxManager
        {
            return (this.m_hitBoxManager);
        }

        public function get AttackDataObj():AttackData
        {
            return (this.m_attackData);
        }

        public function get AttackStateData():AttackState
        {
            return (this.m_attack);
        }

        public function get AttackCache():AttackState
        {
            return (this.m_attackCache);
        }

        public function get PreviousAttackID():int
        {
            return ((this.m_lastAttackIndex == 0) ? this.m_lastAttackID[(this.m_lastAttackID.length - 1)] : this.m_lastAttackID[(this.m_lastAttackIndex - 1)]);
        }

        public function get LastAttackID():Array
        {
            return (this.m_lastAttackID);
        }

        public function get LastHitObject():AttackDamage
        {
            return (this.m_lastHitObject);
        }

        public function get LastAttackIndex():int
        {
            return (this.m_lastAttackIndex);
        }

        public function get Stance():MovieClip
        {
            return ((this.HasStance) ? this.m_sprite.stance : null);
        }

        public function get SizeRatio():Number
        {
            return (this.m_sizeRatio);
        }

        public function get Invincible():Boolean
        {
            return (this.isInvincible());
        }

        public function get Intangible():Boolean
        {
            return (this.isIntangible());
        }

        public function set SizeRatio(value:Number):void
        {
            this.m_sizeRatio = value;
            this.m_sprite.scaleX = ((this.m_sprite.scaleX > 0) ? this.m_sizeRatio : -(this.m_sizeRatio));
            this.m_sprite.scaleY = ((this.m_sprite.scaleY > 0) ? this.m_sizeRatio : -(this.m_sizeRatio));
        }

        public function get BypassCollisionTesting():Boolean
        {
            return (this.m_bypassCollisionTesting);
        }

        public function set BypassCollisionTesting(value:Boolean):void
        {
            this.m_bypassCollisionTesting = value;
        }

        public function get HurtInterrupt():Function
        {
            return (this.m_hurtInterrupt);
        }

        public function set HurtInterrupt(fn:Function):void
        {
            this.m_hurtInterrupt = fn;
        }

        public function get TargetInterrupt():Function
        {
            return (this.m_targetInterrupt);
        }

        public function set TargetInterrupt(fn:Function):void
        {
            this.m_targetInterrupt = fn;
        }

        public function get PreviousAnimation():String
        {
            return (this.m_previousAnimation);
        }

        public function get HealthBox():MovieClip
        {
            return (this.m_healthBoxMC);
        }

        public function get SkipAttackCollisionTests():Boolean
        {
            return (this.m_skipAttackCollisionTests);
        }

        public function get SkipAttackProcessing():Boolean
        {
            return (this.m_skipAttackProcessing);
        }

        public function get AttackCollisionTestsPreProcessed():Boolean
        {
            return (this.m_attackCollisionTestsPreProcessed);
        }

        public function get PaletteSwapData():Object
        {
            return (this.m_paletteSwapData);
        }

        public function set PaletteSwapData(value:Object):void
        {
            this.m_paletteSwapData = value;
        }

        public function get PaletteSwapPAData():Object
        {
            return (this.m_paletteSwapPAData);
        }

        public function set PaletteSwapPAData(value:Object):void
        {
            this.m_paletteSwapPAData = value;
        }

        protected function buildHitBoxData(linkage_id:String, processAdditional:Boolean=true):void
        {
            var obj:*;
            var obj2:*;
            this.m_hitBoxManager = HitBoxManager.getOrCreate(linkage_id);
            if (processAdditional)
            {
                for (obj in this.m_attackData.ProjectilesArray)
                {
                    if (ProjectileAttack(this.m_attackData.ProjectilesArray[obj]).LinkageID)
                    {
                        HitBoxManager.getOrCreate(ProjectileAttack(this.m_attackData.ProjectilesArray[obj]).LinkageID);
                    };
                };
                for (obj2 in this.m_attackData.ItemsArray)
                {
                    if (ItemData(this.m_attackData.ItemsArray[obj2]).LinkageID)
                    {
                        HitBoxManager.getOrCreate(ItemData(this.m_attackData.ItemsArray[obj2]).LinkageID);
                    };
                };
            };
        }

        public function setInvincibility(value:Boolean):void
        {
            this.m_invincible = value;
        }

        public function setIntangibility(value:Boolean):void
        {
            this.m_intangible = value;
        }

        public function playSound(linkage:*, vfx:Boolean=false):int
        {
            if ((linkage is Array))
            {
                return (this.STAGEDATA.SoundQueueRef.playChainedAudio(linkage, vfx));
            };
            if (vfx)
            {
                return (this.STAGEDATA.SoundQueueRef.playVoiceEffect(linkage));
            };
            return (this.STAGEDATA.SoundQueueRef.playSoundEffect(linkage));
        }

        public function stopSound(id:int):void
        {
            this.STAGEDATA.SoundQueueRef.stopSound(id);
        }

        public function applyPalette(mc:MovieClip):void
        {
            var filters:Array = [];
            var i:int;
            while (((this.m_sprite.filters) && (i < this.m_sprite.filters.length)))
            {
                filters.push(this.m_sprite.filters[i].clone());
                i++;
            };
            mc.filters = filters;
        }

        public function updatePaletteSwap():void
        {
            if (((this.m_paletteSwapData) && (this.HasStance)))
            {
                Utils.replacePalette(this.m_sprite.stance, this.m_paletteSwapData, 2);
            };
        }

        public function setPaletteSwap(normalData:Object, PADAta:Object):void
        {
            this.m_paletteSwapData = normalData;
            this.m_paletteSwapPAData = PADAta;
            if (this.m_healthBoxMC)
            {
                Utils.replacePalette(this.m_healthBoxMC.charHead, this.m_paletteSwapPAData, 1, true, true);
            };
            this.updatePaletteSwap();
        }

        public function updateColorFilter(mc:DisplayObject, team_id:int, statsName:String, costumeID:int=-1):void
        {
            var count:int;
            var i:int;
            var _local_9:Character;
            var colorStr:String = Utils.getColorString(team_id);
            var colorObj:Object = ResourceManager.getCostume(statsName, colorStr, costumeID);
            if (colorObj == null)
            {
                colorObj = Utils.getCostumeObject();
            };
            if (colorObj != null)
            {
                if (team_id > 0)
                {
                    count = 0;
                    i = 0;
                    while (i < this.STAGEDATA.Players.length)
                    {
                        _local_9 = this.STAGEDATA.Players[i];
                        if (_local_9 != null)
                        {
                            if (_local_9 == this)
                            {
                                break;
                            };
                            if (((((_local_9.Team == team_id) && (!(_local_9 === this))) && (this is Character)) && (_local_9.StatsName == Character(this).StatsName)))
                            {
                                count++;
                            };
                        };
                        i++;
                    };
                    if (count == 1)
                    {
                        colorObj.redOffset = ((colorObj.redOffset) || (0));
                        colorObj.greenOffset = ((colorObj.greenOffset) || (0));
                        colorObj.blueOffset = ((colorObj.blueOffset) || (0));
                        colorObj.redOffset = (colorObj.redOffset + 60);
                        colorObj.greenOffset = (colorObj.greenOffset + 60);
                        colorObj.blueOffset = (colorObj.blueOffset + 60);
                    }
                    else
                    {
                        if (count == 2)
                        {
                            colorObj.redOffset = ((colorObj.redOffset) || (0));
                            colorObj.greenOffset = ((colorObj.greenOffset) || (0));
                            colorObj.blueOffset = ((colorObj.blueOffset) || (0));
                            colorObj.redOffset = (colorObj.redOffset - 60);
                            colorObj.greenOffset = (colorObj.greenOffset - 60);
                            colorObj.blueOffset = (colorObj.blueOffset - 60);
                        };
                    };
                }
                else
                {
                    colorObj.brightness = ((colorObj.brightness) || (0));
                };
                Utils.setColorFilter(mc, colorObj);
            };
            this.setPaletteSwap(((colorObj.paletteSwap) || (null)), ((colorObj.paletteSwapPA) || (null)));
        }

        public function updateColorFilterAPI(settings:Object):void
        {
            if (settings == null)
            {
                settings = Utils.getCostumeObject();
            };
            if (settings != null)
            {
                Utils.setColorFilter(this.m_sprite, settings);
            };
        }

        public function attachHealthBox(name:String, thumbnail:String, seriesIcon:String, teamID:int=-1, costumeName:String=null, costumeIndex:int=-1):void
        {
            var mcLoad:MovieClip;
            if ((!(this.m_healthBoxMC)))
            {
                this.m_healthBoxMC = ResourceManager.getLibraryMC("DamageCounter");
            };
            this.m_healthBoxMC.visible = true;
            this.m_healthBoxMC.cacheAsBitmap = true;
            if (this.m_healthBoxMC.charHead.getChildByName("charhead"))
            {
                this.m_healthBoxMC.charHead.removeChild(this.m_healthBoxMC.charHead.getChildByName("charhead"));
            };
            mcLoad = ResourceManager.getLibraryMC(thumbnail);
            if (mcLoad != null)
            {
                mcLoad.name = "charhead";
                this.m_healthBoxMC.charHead.addChild(mcLoad);
            };
            mcLoad = ResourceManager.getLibraryMC(seriesIcon);
            if (mcLoad != null)
            {
                mcLoad.name = "icon";
                this.m_healthBoxMC.icon.addChild(mcLoad);
                this.applyPalette(this.m_healthBoxMC.charHead);
                Utils.replacePalette(this.m_healthBoxMC.charHead, this.m_paletteSwapPAData, 1, true, true);
                if (((teamID > 0) && (!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, this.STAGEDATA.GameRef.GameMode)))))
                {
                    switch (teamID)
                    {
                        case 1:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 90, 0, 0, 0);
                            break;
                        case 2:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 0, 90, 0, 0);
                            break;
                        case 3:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 0, 0, 90, 0);
                            break;
                        case 4:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 90, 72, 0, 0);
                            break;
                    };
                }
                else
                {
                    switch (this.m_player_id)
                    {
                        case 1:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 90, 0, 0, 0);
                            break;
                        case 2:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 0, 0, 90, 0);
                            break;
                        case 3:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 90, 90, 0, 0);
                            break;
                        case 4:
                            Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 0, 90, 0, 0);
                            break;
                    };
                    if (((this.STAGEDATA.GameRef.GameMode == Mode.TRAINING) && (this.m_player_id > 1)))
                    {
                        Utils.setTint(this.m_healthBoxMC.icon, 1, 1, 1, 1, 0, 0, 0, 0);
                    };
                };
            };
            if ((!(ModeFeatures.hasFeature(ModeFeatures.IGNORE_TEAM_COSTUME, this.STAGEDATA.GameRef.GameMode))))
            {
                if (teamID < 0)
                {
                    switch (this.m_player_id)
                    {
                        case 1:
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team1");
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team1");
                            break;
                        case 2:
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team3");
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team3");
                            break;
                        case 3:
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team4");
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team4");
                            break;
                        case 4:
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team2");
                            Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team2");
                            break;
                    };
                }
                else
                {
                    Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, ("team" + teamID));
                    Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, ("team" + teamID));
                };
            }
            else
            {
                switch (this.m_player_id)
                {
                    case 1:
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team1");
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team1");
                        break;
                    case 2:
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team3");
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team3");
                        break;
                    case 3:
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team4");
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team4");
                        break;
                    case 4:
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team2");
                        Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team2");
                        break;
                };
                if (this.m_player_id > 1)
                {
                    Utils.tryToGotoAndStop(this.m_healthBoxMC.damageBox, "team-1");
                    Utils.tryToGotoAndStop(this.m_healthBoxMC.damageStrike, "team-1");
                };
            };
            this.m_healthBoxMC.charName.text = name;
            this.setDamage(this.m_damage);
            if (this.m_healthBoxMC.score)
            {
                this.m_healthBoxMC.score.visible = false;
                this.m_healthBoxMC.scoreLabel.visible = false;
            };
            this.STAGEDATA.HudRef.addHealthBox(this.m_healthBoxMC);
        }

        public function detachHealthBox():void
        {
            this.STAGEDATA.HudRef.removeHealthBox(this.m_healthBoxMC);
            this.m_healthBoxMC = null;
        }

        public function getDamage():Number
        {
            return (this.m_damage);
        }

        public function dealDamage(damage:Number):void
        {
            this.setDamage(((this.m_baseStats.Stamina > 0) ? (this.m_damage - damage) : (this.m_damage + damage)));
        }

        public function healDamage(damage:Number):void
        {
            this.setDamage(((this.m_baseStats.Stamina > 0) ? Math.min(this.m_baseStats.Stamina, (this.m_damage + damage)) : (this.m_damage - damage)));
        }

        public function setDamage(amount:Number):void
        {
            var percent:Number;
            var red:uint;
            var green:uint;
            var blue:uint;
            if (amount > 999)
            {
                amount = 999;
            }
            else
            {
                if (amount < 0)
                {
                    amount = 0;
                };
            };
            if (((this.m_baseStats.Stamina > 0) && (this.m_damage > this.m_baseStats.Stamina)))
            {
                amount = this.m_baseStats.Stamina;
            };
            var difference:Number = (amount - this.m_damage);
            this.m_damage = amount;
            if (this.m_healthBoxMC != null)
            {
                this.m_healthBoxMC.damageMC_holder.damageMC.damage.text = (((this.m_damage > 0) && (this.m_damage < 1.5)) ? 1 : Math.ceil(this.m_damage));
                this.m_healthBoxMC.percent_mc.damage.text = ((this.m_baseStats.Stamina > 0) ? "HP" : "%");
                percent = 0;
                if (this.m_baseStats.Stamina > 0)
                {
                    percent = ((this.m_damage < 50) ? 1 : (1 - (Math.max(1, (this.m_damage - 50)) / Math.max(1, (this.m_baseStats.Stamina - 50)))));
                }
                else
                {
                    percent = ((this.m_damage > 300) ? 1 : (this.m_damage / 300));
                };
                red = ((percent < 0.6) ? 0xFF : uint((0xFF - (128 * ((percent - 0.6) / 0.6)))));
                green = ((percent >= 0.6) ? 0 : uint((0xFF - (0xFF * (percent / 0.6)))));
                blue = ((percent >= 0.6) ? 0 : uint((0xFF - (0xFF * (percent / 0.6)))));
                TextField(this.m_healthBoxMC.damageMC_holder.damageMC.damage).textColor = (((red << 16) + (green << 8)) + blue);
                TextField(this.m_healthBoxMC.percent_mc.damage).textColor = (((red << 16) + (green << 8)) + blue);
            };
            if (difference !== 0)
            {
                this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.DAMAGE_CHANGED, {
                    "caller":this.APIInstance.instance,
                    "damage":difference
                }));
            };
        }

        public function throbDamageCounter():void
        {
            if (this.m_healthBoxMC != null)
            {
                if (this.m_healthBoxMC.damageMC_holder)
                {
                    this.m_healthBoxMC.damageMC_holder.damage = this.m_damage;
                };
                this.m_healthBoxMC.damageMC_holder.gotoAndPlay("throb");
            };
        }

        public function inLowerLeftWarningBounds():Boolean
        {
            this.updateWarningCollision();
            return (this.m_collision.lbound_lower);
        }

        public function inUpperLeftWarningBounds():Boolean
        {
            this.updateWarningCollision();
            return (this.m_collision.lbound_upper);
        }

        public function inLowerRightWarningBounds():Boolean
        {
            this.updateWarningCollision();
            return (this.m_collision.rbound_lower);
        }

        public function inUpperRightWarningBounds():Boolean
        {
            this.updateWarningCollision();
            return (this.m_collision.rbound_upper);
        }

        public function updateWarningCollision():void
        {
            var foundLeft:Boolean;
            var foundRight:Boolean;
            var i:int;
            i = 0;
            while (((i < this.m_warningBounds_lower[0].length) && (!(foundLeft))))
            {
                if (this.m_warningBounds_lower[0][i].hitTestPoint(this.GlobalX, this.GlobalY, true))
                {
                    foundLeft = true;
                };
                i++;
            };
            i = 0;
            while (((i < this.m_warningBounds_lower[1].length) && (!(foundRight))))
            {
                if (this.m_warningBounds_lower[1][i].hitTestPoint(this.GlobalX, this.GlobalY, true))
                {
                    foundRight = true;
                };
                i++;
            };
            this.m_collision.lbound_lower = foundLeft;
            this.m_collision.rbound_lower = foundRight;
            foundLeft = false;
            foundRight = false;
            i = 0;
            while (((i < this.m_warningBounds_upper[0].length) && (!(foundLeft))))
            {
                if (this.m_warningBounds_upper[0][i].hitTestPoint(this.GlobalX, this.GlobalY, true))
                {
                    foundLeft = true;
                };
                i++;
            };
            i = 0;
            while (((i < this.m_warningBounds_upper[1].length) && (!(foundRight))))
            {
                if (this.m_warningBounds_upper[1][i].hitTestPoint(this.GlobalX, this.GlobalY, true))
                {
                    foundRight = true;
                };
                i++;
            };
            this.m_collision.lbound_upper = foundLeft;
            this.m_collision.rbound_upper = foundRight;
        }

        public function getNearestPath(_arg_1:String, skipSameTeam:Boolean=true, skipOwner:Boolean=true):Array
        {
            var i:int;
            var results:Array = [];
            this.m_shortestPath = null;
            this.getNearestOpponent(_arg_1, skipSameTeam, skipOwner);
            if (this.m_currentTarget.CurrentTarget)
            {
                this.getNearestOpponent(_arg_1, skipSameTeam, skipOwner);
                this.checkPotentialBeaconPath(_arg_1, skipSameTeam, skipOwner);
                if (this.m_shortestPath !== null)
                {
                    i = (this.m_shortestPath.length - 1);
                    while (i >= 0)
                    {
                        results.push(this.m_shortestPath[i]);
                        i--;
                    };
                };
                results.push(this.m_targetTemp.CurrentTarget);
            };
            return (results);
        }

        protected function getNearestTarget(_arg_1:String, skipSameTeam:Boolean=true, skipOwner:Boolean=true):Target
        {
            var target:Target = new Target();
            target.CurrentTarget = this.getNearest(_arg_1, skipSameTeam, skipOwner);
            if (target.CurrentTarget)
            {
                target.Distance = Utils.getDistanceFrom(this, target.CurrentTarget);
            };
            return ((target.CurrentTarget == null) ? null : target);
        }

        protected function getNearestOpponent(_arg_1:String, skipSameTeam:Boolean=true, skipOwner:Boolean=true):void
        {
            var myBeacon:Beacon;
            var theirBeacon:Beacon;
            if (((!(this.m_targetTemp.CurrentTarget == null)) && (this.m_targetTemp.CurrentTarget.MC.parent == null)))
            {
                this.m_targetTemp.CurrentTarget = null;
            };
            this.m_currentTarget.CurrentTarget = null;
            var results:Target = this.getNearestTarget(_arg_1, skipSameTeam, skipOwner);
            if (results != null)
            {
                this.m_currentTarget.CurrentTarget = results.CurrentTarget;
                this.m_targetTemp.CurrentTarget = this.m_currentTarget.CurrentTarget;
                this.m_currentTarget.setDistance(new Point(this.m_sprite.x, this.m_sprite.y));
                this.m_targetTemp.setDistance(new Point(this.m_sprite.x, this.m_sprite.y));
            };
            if ((((((!(this.m_currentTarget == null)) && (!(this.m_currentTarget.CurrentTarget == null))) && (this.STAGEDATA.getBeacons().length > 0)) && (this.m_shortestPath == null)) && ((this.m_currentTarget.Distance > 200) || (!(this.m_currentTarget.CurrentTarget.checkLinearPath(this))))))
            {
                myBeacon = Utils.getClosetBeaconTo(this.STAGEDATA, this.m_sprite);
                theirBeacon = Utils.getClosetBeaconTo(this.STAGEDATA, this.m_currentTarget.CurrentTarget.MC);
                if (myBeacon != theirBeacon)
                {
                    this.m_shortestPath = Utils.getPath(this.STAGEDATA.getBeacons(), Utils.dijkstra(this.STAGEDATA, this.STAGEDATA.getBeacons(), this.STAGEDATA.getAdjMatrix(), myBeacon, theirBeacon), myBeacon.BID, theirBeacon.BID);
                };
            }
            else
            {
                if (this.m_shortestPath != null)
                {
                    this.m_currentTarget.CurrentTarget = this.m_shortestPath[(this.m_shortestPath.length - 1)];
                    this.m_currentTarget.setDistance(new Point(this.m_sprite.x, this.m_sprite.y));
                };
            };
        }

        protected function checkPotentialBeaconPath(_arg_1:String, skipSameTeam:Boolean=true, skipOwner:Boolean=true):void
        {
            if (this.m_targetTemp.CurrentTarget != null)
            {
                this.m_targetTemp.setDistance(new Point(this.m_sprite.x, this.m_sprite.y));
            };
            if ((((!(this.m_shortestPath == null)) && (!(this.m_targetTemp.CurrentTarget == null))) && ((this.m_targetTemp.Distance < 100) && (this.m_targetTemp.CurrentTarget.checkLinearPath(this)))))
            {
                this.m_shortestPath = null;
                this.m_currentTarget.CurrentTarget = this.m_targetTemp.CurrentTarget;
                this.m_targetTemp.CurrentTarget = null;
                this.getNearestOpponent(_arg_1, skipSameTeam, skipOwner);
            }
            else
            {
                if (this.m_shortestPath != null)
                {
                    this.m_currentTarget.CurrentTarget = this.m_shortestPath[(this.m_shortestPath.length - 1)];
                    this.m_currentTarget.setDistance(new Point(this.m_sprite.x, this.m_sprite.y));
                    if (this.m_currentTarget.Distance < 50)
                    {
                        this.m_currentTarget.CurrentTarget = null;
                        this.m_shortestPath.pop();
                        if (((this.m_shortestPath.length > 0) && (!(((!(this.m_targetTemp.CurrentTarget == null)) && (this.m_targetTemp.CurrentTarget.checkLinearPath(this))) && (this.m_targetTemp.Distance < Utils.getDistanceFrom(this, this.m_shortestPath[(this.m_shortestPath.length - 1)]))))))
                        {
                            this.m_currentTarget.CurrentTarget = this.m_shortestPath[(this.m_shortestPath.length - 1)];
                        }
                        else
                        {
                            this.m_shortestPath = null;
                            this.getNearestOpponent(_arg_1, skipSameTeam, skipOwner);
                        };
                    };
                };
            };
        }

        public function getNearestLedge():MovieClip
        {
            var ledges:Array = this.STAGEDATA.getLedgesAPI();
            var closest:MovieClip;
            var oldDistance:Number = 0;
            var i:int;
            while (i < ledges.length)
            {
                if (((!(closest)) || (((closest.x * this.m_sprite.x) + (closest.y * this.m_sprite.y)) < oldDistance)))
                {
                    if (closest)
                    {
                        oldDistance = (Math.pow((closest.x - this.m_sprite.x), 2) + Math.pow((closest.y - this.m_sprite.y), 2));
                    };
                    closest = ledges[i];
                };
                i++;
            };
            return (closest);
        }

        public function forceOnGroundAPI(threshold:Number=200):void
        {
            var startY:Number = this.m_sprite.y;
            var tmpDistance:Number = 0;
            if (this.m_currentPlatform)
            {
                return;
            };
            while (((!(this.m_currentPlatform = this.testGroundWithCoord(this.m_sprite.x, (this.m_sprite.y + 1)))) && (tmpDistance < threshold)))
            {
                this.m_sprite.y++;
                tmpDistance++;
            };
            if ((!(this.m_currentPlatform)))
            {
                this.m_sprite.y = startY;
            }
            else
            {
                this.m_collision.ground = true;
                this.attachToGround();
            };
        }

        public function forceAttack(value:String, toFrame:*=null, isSpecial:Boolean=false):Boolean
        {
            return (false);
        }

        public function getLinkageID():String
        {
            return (null);
        }

        public function getProjectiles():Array
        {
            return ([]);
        }

        public function isInvincible():Boolean
        {
            return (this.m_invincible);
        }

        public function isIntangible():Boolean
        {
            return (this.m_intangible);
        }

        public function isHitStunOrParalysis():Boolean
        {
            return ((this.inParalysis()) || (this.inHitStun()));
        }

        public function inHitStun():Boolean
        {
            return (this.m_actionShot);
        }

        public function inParalysis():Boolean
        {
            return (this.m_paralysis);
        }

        protected function checkShowHitBoxes():void
        {
            var arr:Array;
            var rect:Rectangle;
            var i:int;
            var point1:Point;
            var point2:Point;
            var point3:Point;
            var point4:Point;
            var holder:MovieClip;
            var theHolder:MovieClip;
            if (InteractiveSprite.SHOW_HITBOXES)
            {
                InteractiveSprite.HITBOXES_WAS_ON = true;
                arr = null;
                rect = null;
                i = 0;
                point1 = new Point();
                point2 = new Point();
                point3 = new Point();
                point4 = new Point();
                holder = ((this.m_sprite.getChildByName("hBoxHolder")) ? MovieClip(this.m_sprite.getChildByName("hBoxHolder")) : null);
                if (holder)
                {
                    holder.graphics.clear();
                };
                if (this.HasHitBox)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HIT);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(16743571, 0.5);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                if (this.HasAttackBox)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.ATTACK);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(0xFF0000, 0.5);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                if (this.HasTouchBox)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.TOUCH);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(0xFF, 0.5);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                if (this.HasGrabBox)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.GRAB);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(0xFF00FF, 0.5);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                if (this.HasHand)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.HAND);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(6737151, 0.25);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                if (this.HasCounterBox)
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    arr = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.COUNTER);
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(31265, 0.25);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
                arr = this.PickupHitBoxes;
                if (((arr) && (arr.length > 0)))
                {
                    if ((!(holder)))
                    {
                        holder = new MovieClip();
                        holder.name = "hBoxHolder";
                        this.m_sprite.addChild(holder);
                    };
                    i = 0;
                    while (i < arr.length)
                    {
                        rect = arr[i].BoundingBox;
                        point1.x = rect.x;
                        point1.y = rect.y;
                        point2.x = (rect.x + rect.width);
                        point2.y = rect.y;
                        point3.x = (rect.x + rect.width);
                        point3.y = (rect.y + rect.height);
                        point4.x = rect.x;
                        point4.y = (rect.y + rect.height);
                        holder.graphics.beginFill(6750003, 0.15);
                        holder.graphics.moveTo(point1.x, point1.y);
                        holder.graphics.lineTo(point2.x, point2.y);
                        holder.graphics.lineTo(point3.x, point3.y);
                        holder.graphics.lineTo(point4.x, point4.y);
                        holder.graphics.lineTo(point1.x, point1.y);
                        holder.graphics.endFill();
                        holder.parent.setChildIndex(holder, (holder.parent.numChildren - 1));
                        i++;
                    };
                };
            }
            else
            {
                if (InteractiveSprite.HITBOXES_WAS_ON)
                {
                    theHolder = ((this.m_sprite.getChildByName("hBoxHolder")) ? MovieClip(this.m_sprite.getChildByName("hBoxHolder")) : null);
                    if (theHolder)
                    {
                        theHolder.graphics.clear();
                    };
                    InteractiveSprite.HITBOXES_WAS_ON = false;
                };
            };
        }

        public function verifiyHitBoxData():void
        {
            var animationName:String;
            var j:int;
            var attack:AttackObject;
            var user:String;
            if ((!(Main.DEBUG)))
            {
                return;
            };
            var i:int;
            while (i < this.m_hitBoxManager.HitBoxAnimationList.length)
            {
                animationName = this.m_hitBoxManager.HitBoxAnimationList[i].Name;
                animationName = ((animationName) ? animationName.substr((animationName.indexOf("_") + 1)) : "");
                if (animationName == "item")
                {
                }
                else
                {
                    j = 0;
                    while (j < this.m_hitBoxManager.HitBoxAnimationList[i].AttackBoxes.length)
                    {
                        attack = this.m_attackData.getAttack(animationName);
                        if (((((Main.DEBUG) && (!(animationName == "star"))) && (attack)) && (!(attack.AttackBoxes[this.m_hitBoxManager.HitBoxAnimationList[i].AttackBoxes[j].Name]))))
                        {
                            user = "some object";
                            if ((this is Character))
                            {
                                user = Character(this).LinkageName;
                            }
                            else
                            {
                                if ((this is Projectile))
                                {
                                    user = Projectile(this).LinkageID;
                                }
                                else
                                {
                                    if ((this is Item))
                                    {
                                        user = Item(this).LinkageID;
                                    }
                                    else
                                    {
                                        if ((this is Enemy))
                                        {
                                            user = Enemy(this).LinkageID;
                                        };
                                    };
                                };
                            };
                            if (MenuController.debugConsole)
                            {
                                MenuController.debugConsole.alert((((((("Warning! Unstatted " + this.m_hitBoxManager.HitBoxAnimationList[i].AttackBoxes[j].Name) + " found on ") + user) + "'s ") + animationName) + " attack!"));
                            };
                        };
                        j++;
                    };
                };
                i++;
            };
        }

        public function hasHitBoxType(_arg_1:int):Boolean
        {
            if (_arg_1 == HitBoxSprite.HIT)
            {
                return (this.HasHitBox);
            };
            if (_arg_1 == HitBoxSprite.ATTACK)
            {
                return (this.HasAttackBox);
            };
            if (_arg_1 == HitBoxSprite.REVERSE)
            {
                return (this.HasReverseBox);
            };
            if (_arg_1 == HitBoxSprite.ABSORB)
            {
                return (this.HasAbsorbBox);
            };
            if (_arg_1 == HitBoxSprite.SHIELDATTACK)
            {
                return (this.HasShieldAttackBox);
            };
            if (_arg_1 == HitBoxSprite.SHIELDPROJECTILE)
            {
                return (this.HasShieldProjectileBox);
            };
            if (_arg_1 == HitBoxSprite.CAM)
            {
                return (this.HasCamBox);
            };
            if (_arg_1 == HitBoxSprite.GRAB)
            {
                return (this.HasGrabBox);
            };
            if (_arg_1 == HitBoxSprite.ITEM)
            {
                return (this.HasItemBox);
            };
            if (_arg_1 == HitBoxSprite.HAT)
            {
                return (this.HasHatBox);
            };
            if (_arg_1 == HitBoxSprite.TOUCH)
            {
                return (this.HasTouchBox);
            };
            if (_arg_1 == HitBoxSprite.RANGE)
            {
                return (this.HasRange);
            };
            if (_arg_1 == HitBoxSprite.HOMING)
            {
                return (this.HasHoming);
            };
            if (_arg_1 == HitBoxSprite.CATCH)
            {
                return (this.HasCatchBox);
            };
            if (_arg_1 == HitBoxSprite.COUNTER)
            {
                return (this.HasCounterBox);
            };
            if (_arg_1 == HitBoxSprite.PLOCK)
            {
                return (this.HasPLockBox);
            };
            return (false);
        }

        public function addEventListener(_arg_1:String, func:Function, options:Object=null):void
        {
            var i:*;
            var defaults:Object = {"persistent":false};
            if ((!(options)))
            {
                options = new Object();
            };
            for (i in defaults)
            {
                if (options[i] === undefined)
                {
                    options[i] = defaults[i];
                };
            };
            this.m_eventManager.addEventListener(_arg_1, func);
            if ((!(options.persistent)))
            {
                this.m_tempEvents.push({
                    "type":_arg_1,
                    "listener":func,
                    "useCapture":false
                });
            };
        }

        public function hasEventListener(_arg_1:String, func:Function=null):Boolean
        {
            return (this.m_eventManager.hasEvent(_arg_1, func));
        }

        public function removeEventListener(_arg_1:String, func:Function):void
        {
            this.m_eventManager.removeEventListener(_arg_1, func);
        }

        public function reactionMaster(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (true);
        }

        public function reactionShield(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionShieldAttack(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionShieldProjectile(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionAbsorb(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionGrab(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionReverse(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionAttackReverse(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionClank(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionHit(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionCollide(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionCounter(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionTouch(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionRange(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function reactionCatch(otherSprite:InteractiveSprite, hBoxResult:HitBoxCollisionResult):Boolean
        {
            return (false);
        }

        public function clang(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
        }

        public function handleHit(otherSprite:InteractiveSprite, attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
        }

        public function cancelAttack(attackBoxData:AttackDamage, hBoxResult:HitBoxCollisionResult):void
        {
        }

        public function setXSpeed(amount:Number, absolute:Boolean=true):void
        {
            if (absolute)
            {
                this.m_xSpeed = amount;
            }
            else
            {
                if (this.m_facingForward)
                {
                    this.m_xSpeed = ((amount > 0) ? Utils.fastAbs(amount) : -(Utils.fastAbs(amount)));
                }
                else
                {
                    this.m_xSpeed = ((amount < 0) ? Utils.fastAbs(amount) : -(Utils.fastAbs(amount)));
                };
            };
        }

        public function forceHitStun(num:int, sdiDistance:Number=-1):void
        {
            this.startActionShot(num);
        }

        protected function checkHitStun():void
        {
            if (this.m_actionShot)
            {
                this.m_actionTimer--;
                this.m_hitStunTimer--;
                if (this.m_actionTimer < 0)
                {
                    if (this.m_paralysis)
                    {
                        this.m_actionShot = false;
                    }
                    else
                    {
                        this.stopActionShot();
                    };
                }
                else
                {
                    if (this.m_hitStunTimer <= 0)
                    {
                        this.m_hitStunTimer = 2;
                        this.m_hitStunToggle = (!(this.m_hitStunToggle));
                        this.m_attemptToMove(((this.m_hitStunToggle) ? 2 : -2), 0);
                    };
                };
            }
            else
            {
                if (this.m_paralysis)
                {
                    this.m_paralysisTimer--;
                    if (this.m_paralysisTimer < 0)
                    {
                        this.stopActionShot();
                    }
                    else
                    {
                        if (this.m_hitStunTimer <= 0)
                        {
                            this.m_hitStunTimer = 2;
                            this.m_hitStunToggle = (!(this.m_hitStunToggle));
                            this.m_attemptToMove(((this.m_hitStunToggle) ? 4 : -4), 0);
                        };
                    };
                };
            };
        }

        public function startActionShot(hitStun:int, paralysis:int=-1):void
        {
            if (SpecialMode.modeEnabled(this.STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                return;
            };
            if (hitStun > 0)
            {
                if ((!(this.m_actionShot)))
                {
                    if (this.HasStance)
                    {
                        this.Stance.stop();
                    };
                    this.m_actionShot = true;
                };
                this.m_actionTimer = (hitStun - 1);
            };
            if ((((paralysis > 0) && (this.m_paralysisHitCount < 3)) && (this.m_maxParalysisTime.IsComplete)))
            {
                if ((!(this.m_paralysis)))
                {
                    if (this.HasStance)
                    {
                        this.Stance.stop();
                    };
                    this.m_paralysis = true;
                    this.m_paralysisHitCount = 1;
                    this.m_paralysisTimer = (paralysis - 1);
                }
                else
                {
                    this.m_paralysisHitCount++;
                    if (this.m_paralysisHitCount >= 3)
                    {
                        this.stopActionShot();
                        return;
                    };
                };
            };
        }

        public function stopActionShot(hitstun:Boolean=true, paralysis:Boolean=true):void
        {
            if (((this.m_actionShot) && (hitstun)))
            {
                this.m_actionShot = false;
                this.m_controlFrames();
            };
            if (((this.m_paralysis) && (paralysis)))
            {
                this.m_paralysis = false;
                this.m_maxParalysisTime.reset();
                this.m_controlFrames();
            };
        }

        public function getGameObjectStat(statName:String):*
        {
            return (this.m_baseStats.getVar(statName));
        }

        public function updateAttackStats(statValues:Object):void
        {
            this.m_attack.importAttackStateData(statValues);
        }

        public function getAttackStat(statName:String):*
        {
            return (this.m_attack.getVar(statName));
        }

        public function updateAttackBoxStats(id:int, statValues:Object):void
        {
            var str:String = "attackBox";
            var calculateChargeDamage:Boolean;
            if (id > 1)
            {
                str = (str + id);
            };
            this.m_attackData.setAttackBoxDataOverride(this.m_attack.Frame, str, statValues);
        }

        public function getAttackBoxStat(id:int, statName:String):*
        {
            var str:String = "attackBox";
            if (id > 1)
            {
                str = (str + id);
            };
            var attack:AttackDamage = this.m_attackData.getAttackBoxData(this.m_attack.Frame, str).syncState(this.m_attack);
            return (attack.getVar(statName));
        }

        public function exportAttackBoxStats(id:int, frame:String):Object
        {
            var str:String = "attackBox";
            if (id > 1)
            {
                str = (str + id);
            };
            var attack:AttackDamage = this.m_attackData.getAttackBoxData(frame, str).syncState(this.m_attack);
            return (attack.exportAttackDamageData());
        }

        public function replaceAttackStats(attackName:String, statValues:Object):void
        {
            this.m_attackData.getAttack(attackName).importAttackData(statValues);
        }

        public function replaceAttackBoxStats(attackName:String, attackBoxID:int, statValues:Object):void
        {
            var attackBox:AttackDamage;
            var str:String = "attackBox";
            if (attackBoxID > 1)
            {
                str = (str + attackBoxID);
            };
            var attack:AttackObject = this.m_attackData.getAttack(attackName);
            if (attack.AttackBoxes[str])
            {
                attackBox = attack.AttackBoxes[str];
                attackBox.importAttackDamageData(statValues);
            };
        }

        public function refreshAttackID():void
        {
            this.m_attack.AttackID = Utils.getUID();
        }

        public function refreshStaleID():void
        {
            this.m_attack.ID = Utils.getUID();
        }

        public function getHitBox(name:String):Object
        {
            var text:String;
            var id:int;
            var types:Object;
            var hitBoxes:Array;
            var hBox:HitBoxSprite;
            var matches1:Array = name.match(/[a-zA-Z]+/g);
            var matches2:Array = name.match(/[0-9]+/g);
            if (((!(matches1)) || (!(matches2))))
            {
                return (null);
            };
            text = matches1[0];
            id = (parseInt(matches2[0]) - 1);
            types = {};
            types["attackBox"] = HitBoxSprite.ATTACK;
            types["hitBox"] = HitBoxSprite.HIT;
            types["grabBox"] = HitBoxSprite.GRAB;
            types["touchBox"] = HitBoxSprite.TOUCH;
            types["hand"] = HitBoxSprite.HAND;
            types["range"] = HitBoxSprite.RANGE;
            types["absorbBox"] = HitBoxSprite.ABSORB;
            types["counterBox"] = HitBoxSprite.COUNTER;
            types["shieldBox"] = HitBoxSprite.SHIELD;
            types["shieldAttackBox"] = HitBoxSprite.SHIELDATTACK;
            types["shieldProjectileBox"] = HitBoxSprite.SHIELDPROJECTILE;
            types["reverseBox"] = HitBoxSprite.REVERSE;
            types["catchBox"] = HitBoxSprite.CATCH;
            types["ledgeBox"] = HitBoxSprite.LEDGE;
            types["camBox"] = HitBoxSprite.CAM;
            types["homing"] = HitBoxSprite.HOMING;
            types["pLockBox"] = HitBoxSprite.PLOCK;
            types["hatBox"] = HitBoxSprite.HAT;
            types["itemBox"] = HitBoxSprite.ITEM;
            types["eggBox"] = HitBoxSprite.EGG;
            types["freezeBox"] = HitBoxSprite.FREEZE;
            types["starBox"] = HitBoxSprite.STAR;
            types["customBox"] = HitBoxSprite.CUSTOM;
            if (types[text])
            {
                hitBoxes = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, types[text]);
                if (((hitBoxes) && (id < hitBoxes.length)))
                {
                    hBox = hitBoxes[id];
                    return ({
                        "x":hBox.BoundingBox.x,
                        "y":hBox.BoundingBox.y,
                        "width":hBox.BoundingBox.width,
                        "height":hBox.BoundingBox.height,
                        "rotation":hBox.rotation,
                        "xreg":hBox.xreg,
                        "yreg":hBox.yreg,
                        "scaleX":hBox.scaleX,
                        "scaleY":hBox.scaleY,
                        "transform":hBox.transform,
                        "depth":hBox.depth
                    });
                };
                return (null);
            };
            return (null);
        }

        public function getHomingTarget():InteractiveSprite
        {
            if (((this.m_attack) && (this.m_attack.HomingTarget)))
            {
                return (this.m_attack.HomingTarget);
            };
            return (null);
        }

        public function getHomingTargetAPI():*
        {
            if (((this.m_attack) && (this.m_attack.HomingTarget)))
            {
                return (this.m_attack.HomingTarget.APIInstance.instance);
            };
            return (null);
        }

        public function homeTowardsTargetAPI(speed:Number, target:InteractiveSprite):void
        {
            var angle:Number;
            if (((this.m_attack) && (target)))
            {
                angle = Utils.getAngleBetween(new Point(this.m_sprite.x, this.m_sprite.y), new Point(target.X, target.Y));
                this.m_xSpeed = Utils.calculateXSpeed(speed, angle);
                this.m_ySpeed = -(Utils.calculateYSpeed(speed, angle));
                if (this.m_xSpeed > 0)
                {
                    this.m_faceRight();
                }
                else
                {
                    this.m_faceLeft();
                };
            };
        }

        protected function syncStats():void
        {
        }

        public function setYSpeed(amount:Number):void
        {
            this.m_ySpeed = amount;
            if (((amount < 0) && (this.m_collision.ground)))
            {
                this.unnattachFromGround();
            };
        }

        public function forceSetXSpeed(value:Number):void
        {
            this.m_xSpeed = value;
        }

        public function forceSetYSpeed(value:Number):void
        {
            this.m_ySpeed = value;
        }

        public function swapDepths(c:InteractiveSprite):void
        {
            if ((((!(c == null)) && (c.MC.parent == this.m_sprite.parent)) && (!(this.m_sprite.parent == null))))
            {
                this.m_sprite.parent.swapChildren(c.MC, this.m_sprite);
            };
        }

        public function swapDepthsAPI(c:InteractiveSprite):void
        {
            if ((((!(c == null)) && (c.MC.parent == this.m_sprite.parent)) && (!(this.m_sprite.parent == null))))
            {
                this.m_sprite.parent.swapChildren(c.MC, this.m_sprite);
            };
        }

        public function bringBehindAPI(c:InteractiveSprite):void
        {
            if (((((!(c == null)) && (c.MC.parent == this.m_sprite.parent)) && (!(this.m_sprite.parent == null))) && (this.Depth > c.Depth)))
            {
                this.m_sprite.parent.swapChildren(c.MC, this.m_sprite);
            };
        }

        public function bringInFrontAPI(c:InteractiveSprite):void
        {
            if (((((!(c == null)) && (c.MC.parent == this.m_sprite.parent)) && (!(this.m_sprite.parent == null))) && (this.Depth < c.Depth)))
            {
                this.m_sprite.parent.swapChildren(c.MC, this.m_sprite);
            };
        }

        public function updateSelfPlatform():void
        {
            var diffX:Number;
            var diffY:Number;
            if (this.m_selfPlatform)
            {
                this.m_selfPlatform.storeOldLocation();
                diffX = (this.m_sprite.x - this.m_selfPlatform.PreviousX);
                diffY = (this.m_sprite.y - this.m_selfPlatform.PreviousY);
                this.m_selfPlatform.setXSpeed(diffX);
                this.m_selfPlatform.setYSpeed(diffY);
            };
        }

        public function recover(amount:int):Boolean
        {
            return (false);
        }

        public function reverse(pid:int, team_id:int, isForward:Boolean):Boolean
        {
            return (false);
        }

        public function stackAttackID(num:Number):void
        {
            this.m_lastAttackID[this.m_lastAttackIndex] = num;
            this.m_lastAttackIndex++;
            if (this.m_lastAttackIndex >= this.m_lastAttackID.length)
            {
                this.m_lastAttackIndex = 0;
            };
        }

        public function attackIDArrayContains(num:Number):Boolean
        {
            var i:int;
            while (i < this.m_lastAttackID.length)
            {
                if (this.m_lastAttackID[i] == num)
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        public function stackStaleID(num:Number):void
        {
            this.m_lastStaleID[this.m_lastStaleIndex] = num;
            this.m_lastStaleIndex++;
            if (this.m_lastStaleIndex >= this.m_lastStaleID.length)
            {
                this.m_lastStaleIndex = 0;
            };
        }

        public function staleIDArrayContains(num:Number):Boolean
        {
            var i:int;
            while (i < this.m_lastStaleID.length)
            {
                if (this.m_lastStaleID[i] == num)
                {
                    return (true);
                };
                i++;
            };
            return (false);
        }

        public function createSelfPlatform(x:Number, y:Number, width:Number, height:Number, terrain:Boolean=true, platformClass:Class=null):MovingPlatform
        {
            this.removeSelfPlatform();
            var platform:MovieClip = new MovieClip();
            this.STAGE.addChild(platform);
            platform.graphics.beginFill(0xFF0000, 1);
            platform.graphics.drawRect(x, y, width, height);
            platform.graphics.endFill();
            platform.visible = false;
            this.m_selfPlatform = new MovingPlatform(platform, this.STAGEDATA, "ground", {"classAPI":platformClass});
            this.m_selfPlatform.SpriteOwner = this;
            if (terrain)
            {
                this.STAGEDATA.Terrains.push(this.m_selfPlatform);
            }
            else
            {
                this.STAGEDATA.Platforms.push(this.m_selfPlatform);
            };
            this.STAGEDATA.MovingPlatforms.push(this.m_selfPlatform);
            this.updateSelfPlatform();
            if (this.m_selfPlatform.APIInstance)
            {
                this.m_selfPlatform.APIInstance.initialize();
            };
            this.m_selfPlatform.IgnoreList.push(this);
            return (this.m_selfPlatform);
        }

        public function createSelfPlatformWithMC(mc:MovieClip, terrain:Boolean=true, platformClass:Class=null):MovingPlatform
        {
            this.removeSelfPlatform();
            this.STAGE.addChild(mc);
            this.m_selfPlatform = new MovingPlatform(mc, this.STAGEDATA, "ground", {"classAPI":platformClass});
            this.m_selfPlatform.SpriteOwner = this;
            if (terrain)
            {
                this.STAGEDATA.Terrains.push(this.m_selfPlatform);
            }
            else
            {
                this.STAGEDATA.Platforms.push(this.m_selfPlatform);
            };
            this.STAGEDATA.MovingPlatforms.push(this.m_selfPlatform);
            if (this.m_selfPlatform.APIInstance)
            {
                this.m_selfPlatform.APIInstance.initialize();
            };
            this.m_selfPlatform.IgnoreList.push(this);
            return (this.m_selfPlatform);
        }

        public function pushBackSlightly(toTheRight:Boolean):void
        {
            this.stackKnockback(3, ((toTheRight) ? 0 : 180), this.m_xKnockback, this.m_yKnockback);
        }

        protected function m_convertForceToSpeed():void
        {
            this.m_xSpeed = (this.m_xSpeed + this.m_xKnockback);
            this.m_ySpeed = (this.m_ySpeed + this.m_yKnockback);
            this.m_xKnockback = 0;
            this.m_yKnockback = 0;
        }

        public function resetRotation():void
        {
            this.m_sprite.rotation = 0;
        }

        public function getKnockbackDecay():Object
        {
            return ({
                "x":this.m_xKnockbackDecay,
                "y":this.m_yKnockbackDecay
            });
        }

        public function setKnockbackDecay(xDecay:Number, yDecay:Number):void
        {
            this.m_xKnockbackDecay = xDecay;
            this.m_yKnockbackDecay = yDecay;
        }

        public function resetKnockbackDecay():void
        {
            var angle:Number = Utils.getAngleBetween(new Point(0, 0), new Point(this.m_xKnockback, this.m_yKnockback));
            this.m_xKnockbackDecay = -(Utils.calculateXSpeed(this.m_weight2, angle));
            this.m_yKnockbackDecay = Utils.calculateYSpeed(this.m_weight2, angle);
        }

        protected function stackKnockback(velocity:Number, angle:Number, oldXVector:Number, oldYVector:Number):void
        {
            var newXVector:Number = 0;
            var newYVector:Number = 0;
            var finalXVector:Number = 0;
            var finalYVector:Number = 0;
            newXVector = (velocity * Math.cos(((angle * Math.PI) / 180)));
            newYVector = (-(velocity) * Math.sin(((angle * Math.PI) / 180)));
            if ((((newXVector <= 0) && (oldXVector >= 0)) || ((newXVector >= 0) && (oldXVector <= 0))))
            {
                finalXVector = (newXVector + oldXVector);
            }
            else
            {
                if (Utils.fastAbs(newXVector) > Utils.fastAbs(oldXVector))
                {
                    finalXVector = newXVector;
                }
                else
                {
                    finalXVector = oldXVector;
                };
            };
            if ((((newYVector <= 0) && (oldYVector >= 0)) || ((newYVector >= 0) && (oldYVector <= 0))))
            {
                finalYVector = (newYVector + oldYVector);
            }
            else
            {
                if (Utils.fastAbs(newYVector) > Utils.fastAbs(oldYVector))
                {
                    finalYVector = newYVector;
                }
                else
                {
                    finalYVector = oldYVector;
                };
            };
            var finalAngle:Number = Utils.getAngleBetween(new Point(0, 0), new Point(finalXVector, finalYVector));
            var finalSpeed:Number = Utils.calculateSpeed(finalXVector, finalYVector);
            angle = finalAngle;
            if (((this.m_knockbackStackingTimer.CurrentTime == 0) && (finalSpeed < Utils.calculateSpeed(this.m_xKnockback, this.m_yKnockback))))
            {
                return;
            };
            this.m_xKnockback = (finalSpeed * Math.cos(((finalAngle * Math.PI) / 180)));
            this.m_yKnockback = (-(finalSpeed) * Math.sin(((finalAngle * Math.PI) / 180)));
            this.resetKnockbackDecay();
            this.m_knockbackStackingTimer.reset();
        }

        protected function move():void
        {
            this.applyGroundInfluence();
            this.m_sprite.x = (this.m_sprite.x + this.m_xSpeed);
            this.m_sprite.y = (this.m_sprite.y + this.m_ySpeed);
        }

        protected function gravity():void
        {
            if ((((!(this.m_collision.ground)) && (this.m_ySpeed < this.m_max_ySpeed)) && (!(this.isHitStunOrParalysis()))))
            {
                this.m_ySpeed = (this.m_ySpeed + this.m_gravity);
            };
        }

        public function decel(rate:Number):void
        {
            var wasRight:Boolean;
            var correctRate:Number;
            var wasRight2:Boolean;
            if (this.m_xSpeed == 0)
            {
                return;
            };
            if ((!(this.m_collision.ground)))
            {
                if (rate >= 0)
                {
                    this.m_xSpeed = ((this.m_xSpeed < 0) ? -(Math.abs((-(this.m_xSpeed) * rate))) : (this.m_xSpeed * rate));
                }
                else
                {
                    wasRight = (this.m_xSpeed > 0);
                    this.m_xSpeed = (this.m_xSpeed - ((this.m_xSpeed > 0) ? Utils.fastAbs(rate) : -(Utils.fastAbs(rate))));
                    if ((((wasRight) && (this.m_xSpeed < 0)) || ((!(wasRight)) && (this.m_xSpeed > 0))))
                    {
                        this.m_xSpeed = 0;
                    };
                };
                if (Utils.fastAbs(this.m_xSpeed) < 0.5)
                {
                    this.m_xSpeed = 0;
                };
            }
            else
            {
                if (rate >= 0)
                {
                    correctRate = (((!(this.m_currentPlatform == null)) && (!(this.m_currentPlatform.decel_friction == 1))) ? (this.m_currentPlatform.decel_friction * rate) : rate);
                    this.m_xSpeed = ((this.m_xSpeed < 0) ? -(Math.abs((-(this.m_xSpeed) * correctRate))) : (this.m_xSpeed * correctRate));
                }
                else
                {
                    if (this.m_currentPlatform != null)
                    {
                        rate = (rate * this.m_currentPlatform.decel_friction);
                    }
                    else
                    {
                        if (SpecialMode.modeEnabled(this.STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
                        {
                            rate = (rate * 0.6);
                        };
                    };
                    wasRight2 = (this.m_xSpeed > 0);
                    this.m_xSpeed = (this.m_xSpeed - ((this.m_xSpeed > 0) ? Utils.fastAbs(rate) : -(Utils.fastAbs(rate))));
                    if ((((wasRight2) && (this.m_xSpeed < 0)) || ((!(wasRight2)) && (this.m_xSpeed > 0))))
                    {
                        this.m_xSpeed = 0;
                    };
                };
                if (Utils.fastAbs(this.m_xSpeed) < 0.5)
                {
                    this.m_xSpeed = 0;
                };
            };
            if (Utils.fastAbs(this.m_xSpeed) < 0.5)
            {
                this.m_xSpeed = 0;
            };
        }

        public function decel_air(rate:Number):void
        {
            var wasUp:Boolean;
            var wasUp2:Boolean;
            if (this.m_ySpeed == 0)
            {
                return;
            };
            if ((!(this.m_collision.ground)))
            {
                if (rate >= 0)
                {
                    this.m_ySpeed = (this.m_ySpeed * rate);
                }
                else
                {
                    wasUp = (this.m_ySpeed < 0);
                    this.m_ySpeed = (this.m_ySpeed - ((this.m_ySpeed > 0) ? Utils.fastAbs(rate) : -(Utils.fastAbs(rate))));
                    if ((((wasUp) && (this.m_ySpeed > 0)) || ((!(wasUp)) && (this.m_ySpeed < 0))))
                    {
                        this.m_ySpeed = 0;
                    };
                };
                if (Utils.fastAbs(this.m_ySpeed) < 0.5)
                {
                    this.m_ySpeed = 0;
                };
            }
            else
            {
                if (this.m_ySpeed > 0)
                {
                    this.m_ySpeed = 0;
                }
                else
                {
                    if (rate >= 0)
                    {
                        this.m_ySpeed = (this.m_ySpeed * ((this.m_ySpeed != 0) ? (((!(this.m_currentPlatform == null)) && (!(this.m_currentPlatform.decel_friction == 1))) ? (this.m_currentPlatform.decel_friction * rate) : rate) : 0));
                    }
                    else
                    {
                        if (this.m_currentPlatform != null)
                        {
                            rate = (rate * this.m_currentPlatform.decel_friction);
                        };
                        wasUp2 = (this.m_ySpeed < 0);
                        this.m_ySpeed = (this.m_ySpeed - ((this.m_ySpeed > 0) ? Utils.fastAbs(rate) : -(Utils.fastAbs(rate))));
                        if ((((wasUp2) && (this.m_ySpeed < 0)) || ((!(wasUp2)) && (this.m_ySpeed > 0))))
                        {
                            this.m_ySpeed = 0;
                        };
                    };
                    if (Utils.fastAbs(this.m_ySpeed) < 0.5)
                    {
                        this.m_ySpeed = 0;
                    };
                };
            };
            if (Utils.fastAbs(this.m_ySpeed) < 0.5)
            {
                this.m_ySpeed = 0;
            };
        }

        public function netXSpeed(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):Number
        {
            var xspeed:Number = 0;
            if ((!(ignoreNormal)))
            {
                xspeed = (xspeed + this.m_xSpeed);
            };
            if ((!(ignoreKnockback)))
            {
                xspeed = (xspeed + this.m_xKnockback);
            };
            return (xspeed);
        }

        public function netYSpeed(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):Number
        {
            var yspeed:Number = 0;
            if ((!(ignoreNormal)))
            {
                yspeed = (yspeed + this.m_ySpeed);
            };
            if ((!(ignoreKnockback)))
            {
                yspeed = (yspeed + this.m_yKnockback);
            };
            return (yspeed);
        }

        public function netSpeed(ignoreNormal:Boolean=false, ignoreKnockback:Boolean=false):Number
        {
            var speed:Number = Utils.getDistance(new Point(), new Point(this.netXSpeed(ignoreNormal, ignoreKnockback), this.netYSpeed(ignoreNormal, ignoreKnockback)));
            return (speed);
        }

        protected function applyGroundInfluence():void
        {
            if ((((((this.m_currentPlatform) && (this.m_currentPlatform.x_influence)) && (!(this.m_attack.IgnorePlatformInfluence))) && (!(this.STAGEDATA.FSCutscene))) && (this.STAGEDATA.FSCutins <= 0)))
            {
                this.m_attemptToMove(this.m_currentPlatform.x_influence, 0);
            };
        }

        protected function checkPlatformBounce():void
        {
        }

        protected function validateBypass(attackObj:AttackDamage):Boolean
        {
            return (false);
        }

        public function validateOnlyAffects(attackObj:AttackDamage):Boolean
        {
            if (((attackObj.OnlyAffectsAir) && (this.m_collision.ground)))
            {
                return (false);
            };
            if (((attackObj.OnlyAffectsGround) && (!(this.m_collision.ground))))
            {
                return (false);
            };
            if (((attackObj.OnlyAffectsFall) && (!((!(this.m_collision.ground)) && (this.netYSpeed() >= 0)))))
            {
                return (false);
            };
            return (true);
        }

        public function checkUnhittableTeamHit(attackObj:AttackDamage):Boolean
        {
            return (((((!(attackObj.HurtSelf)) && (!(this.m_baseStats.HurtByTeam))) && (this.m_team_id == attackObj.TeamID)) && (this.m_team_id > 0)) && (!(this.STAGEDATA.TeamDamage)));
        }

        public function checkUnhittableSelfHit(attackObj:AttackDamage):Boolean
        {
            return (((!(attackObj.HurtSelf)) && (!(this.m_baseStats.HurtByOwner))) && (attackObj.PlayerID == this.m_player_id));
        }

        public function validateHit(attackObj:AttackDamage, ignoreInvincible:Boolean=false, ignoreIntangible:Boolean=false):Boolean
        {
            if ((((((((((!(attackObj)) || (!(this.m_baseStats.CanReceiveHits))) || (!(this.validateBypass(attackObj)))) || (!(this.validateOnlyAffects(attackObj)))) || (this.checkUnhittableSelfHit(attackObj))) || (this.checkUnhittableTeamHit(attackObj))) || ((!(ignoreInvincible)) && (this.isInvincible()))) || ((!(ignoreIntangible)) && (this.isIntangible()))) || (this.attackIDArrayContains(attackObj.AttackID))))
            {
                return (false);
            };
            if (((((((this is Character) && (attackObj.Damage === 0)) && (!(attackObj.ReverseCharacter))) && ((attackObj.ReverseItem) || (attackObj.ReverseProjectile))) || ((((this is Item) && (attackObj.Damage === 0)) && (!(attackObj.ReverseItem))) && ((attackObj.ReverseCharacter) || (attackObj.ReverseProjectile)))) || ((((this is Projectile) && (attackObj.Damage === 0)) && (!(attackObj.ReverseProjectile))) && ((attackObj.ReverseCharacter) || (attackObj.ReverseItem)))))
            {
                return (false);
            };
            return (true);
        }

        public function removeSelfPlatform():void
        {
            var index:int;
            if (this.m_selfPlatform)
            {
                this.m_selfPlatform.SpriteOwner = null;
                index = this.STAGEDATA.Terrains.indexOf(this.m_selfPlatform);
                if (index >= 0)
                {
                    this.STAGEDATA.Terrains.splice(index, 1);
                };
                index = this.STAGEDATA.Platforms.indexOf(this.m_selfPlatform);
                if (index >= 0)
                {
                    this.STAGEDATA.Platforms.splice(index, 1);
                };
                index = this.STAGEDATA.MovingPlatforms.indexOf(this.m_selfPlatform);
                if (index >= 0)
                {
                    this.STAGEDATA.MovingPlatforms.splice(index, 1);
                };
                if (((this.m_selfPlatform) && (this.m_selfPlatform.Container.parent)))
                {
                    this.m_selfPlatform.Container.parent.removeChild(this.m_selfPlatform.Container);
                };
            };
        }

        public function attachToGround():Boolean
        {
            var i:int;
            var movedDistance:Number;
            if ((!(this.m_currentPlatform)))
            {
                return (false);
            };
            var result:Boolean = true;
            var j:Number = 0;
            var oldY:Number = this.m_sprite.y;
            i = (this.m_sprite.y + 20);
            while (((this.m_sprite.y < i) && (!(this.testGroundWithCoord(this.m_sprite.x, this.m_sprite.y)))))
            {
                this.m_sprite.y++;
            };
            if ((!(this.testGroundWithCoord(this.m_sprite.x, this.m_sprite.y))))
            {
                this.m_sprite.y = (i - 20);
            };
            if (((!(this.m_currentPlatform == null)) && (this.netYSpeed() >= 0)))
            {
                j = 0;
                if (((!(this.m_currentPlatform.fallthrough == true)) && (!(this.m_currentPlatform.shouldIgnore(this)))))
                {
                    while (((this.testGroundWithCoord(this.m_sprite.x, this.m_sprite.y)) && (j < 150)))
                    {
                        this.m_sprite.y = (this.m_sprite.y - 0.5);
                        j = (j + 0.5);
                    };
                };
                movedDistance = Utils.fastAbs((this.m_currentPlatform.Y - this.m_currentPlatform.PreviousY));
                if (j >= ((this.STAGEDATA.Terrains.indexOf(this.m_currentPlatform) >= 0) ? (40 + movedDistance) : 10))
                {
                    this.m_sprite.y = (this.m_sprite.y + (j - 0.5));
                    result = false;
                };
            }
            else
            {
                result = false;
            };
            if (this.STAGEDATA.testGroundWithCoord(this.m_sprite.x, this.m_sprite.y, {
                "platforms":false,
                "ignoreList":[this.m_currentPlatform]
            }))
            {
                this.m_sprite.y = oldY;
            };
            return (result);
        }

        protected function calcGroundAngle():Number
        {
            var i:int;
            var y_pos:Number;
            var x1:Number;
            var x2:Number;
            var y1:Number;
            var y2:Number;
            var angle:Number = 0;
            var diff:Number = 0;
            if (this.m_currentPlatform != null)
            {
                i = 0;
                y_pos = this.m_sprite.y;
                x1 = 0;
                x2 = 0;
                y1 = 0;
                y2 = 0;
                while (((this.testCoordCollision((this.m_sprite.x - 5), y_pos)) && (diff > -20)))
                {
                    y_pos = (y_pos - (1 / 4));
                    diff = (diff - (1 / 4));
                };
                if (diff <= -20)
                {
                    y_pos = this.m_sprite.y;
                    diff = 0;
                };
                i = (this.m_sprite.y + 20);
                while (((y_pos < i) && (!(this.testCoordCollision((this.m_sprite.x - 5), (y_pos - 2))))))
                {
                    y_pos++;
                };
                if (((y_pos < i) && (this.testCoordCollision((this.m_sprite.x - 5), y_pos))))
                {
                    x1 = (this.m_sprite.x - 5);
                    y1 = y_pos;
                    y_pos = this.m_sprite.y;
                    while (((this.testCoordCollision((this.m_sprite.x + 5), y_pos)) && (diff > -20)))
                    {
                        y_pos = (y_pos - (1 / 4));
                        diff = (diff - (1 / 4));
                    };
                    if (diff <= -20)
                    {
                        y_pos = this.m_sprite.y;
                        diff = 0;
                    };
                    i = (this.m_sprite.y + 20);
                    while (((y_pos < i) && (!(this.testCoordCollision((this.m_sprite.x + 5), (y_pos - 2))))))
                    {
                        y_pos++;
                    };
                    if (((y_pos < i) && (this.testCoordCollision((this.m_sprite.x + 5), y_pos))))
                    {
                        x2 = (this.m_sprite.x + 5);
                        y2 = y_pos;
                        angle = ((y2 > y1) ? (Math.tan((Utils.fastAbs((y1 - y2)) / Utils.fastAbs((x1 - x2)))) / (Math.PI / 180)) : (-(Math.tan((Utils.fastAbs((y1 - y2)) / Utils.fastAbs((x1 - x2))))) / (Math.PI / 180)));
                    };
                };
            };
            if (angle > 45)
            {
                angle = 45;
            }
            else
            {
                if (angle < -45)
                {
                    angle = -45;
                };
            };
            return (angle);
        }

        protected function attachToGroundTest(xpos:Number, ypos:Number):Boolean
        {
            var origX:Number = this.m_sprite.x;
            var origY:Number = this.m_sprite.y;
            this.m_sprite.x = xpos;
            this.m_sprite.y = ypos;
            var result:Boolean = this.attachToGround();
            this.m_sprite.x = origX;
            this.m_sprite.y = origY;
            return (result);
        }

        public function willFallOffRange(x_loc:Number, y_loc:Number, range:int=5, angleTolerance:int=85):Boolean
        {
            var angle:Number;
            angleTolerance = (90 - angleTolerance);
            var i:int = -(range);
            while (i < range)
            {
                if (this.testGroundWithCoord(x_loc, (y_loc + i)))
                {
                    angle = Utils.getAngleBetween(new Point(this.m_sprite.x, this.m_sprite.y), new Point(x_loc, (y_loc + i)));
                    if ((((angle >= (90 - angleTolerance)) && (angle <= (90 + angleTolerance))) || ((angle >= (270 - angleTolerance)) && (angle <= (270 + angleTolerance)))))
                    {
                    }
                    else
                    {
                        return (false);
                    };
                };
                i++;
            };
            return (true);
        }

        protected function testCoordCollision(x_pos:Number, y_pos:Number):Boolean
        {
            if ((((((!(this.m_currentPlatform == null)) && (this.m_currentPlatform.hitTestPoint(x_pos, (y_pos + 1), true))) && (!(this.m_currentPlatform.fallthrough == true))) && (!(this.m_currentPlatform.shouldIgnore(this)))) && (!((this.OnPlatform) && (this.netYSpeed() < 0)))))
            {
                return (true);
            };
            return (false);
        }

        protected function testAbsCoordCollision(x_pos:Number, y_pos:Number):Boolean
        {
            if ((((((!(this.m_currentPlatform == null)) && (this.m_currentPlatform.hitTestPoint(x_pos, (y_pos + 1), true))) && (!(this.m_currentPlatform.fallthrough == true))) && (!(this.m_currentPlatform.shouldIgnore(this)))) && (!((this.OnPlatform) && (this.netYSpeed() < 0)))))
            {
                return (true);
            };
            return (false);
        }

        public function testGroundWithCoord(xpos:Number, ypos:Number):Platform
        {
            var tmpGround:Platform;
            var i:int;
            i = 0;
            while (((i < this.m_terrains.length) && ((((!(this.m_terrains[i].hitTestPoint(xpos, ypos, true))) || (this.m_terrains[i].fallthrough == true)) || (this.m_terrains[i].shouldIgnore(this))) || (this.m_selfPlatform == this.m_terrains[i]))))
            {
                i++;
            };
            if (((i < this.m_terrains.length) && (this.m_terrains[i].hitTestPoint(xpos, ypos, true))))
            {
                tmpGround = this.testPlatformWithCoord(xpos, ypos);
                if (tmpGround)
                {
                    return (tmpGround);
                };
                return (this.m_terrains[i]);
            };
            i = 0;
            while (((i < this.m_platforms.length) && ((((!(this.m_platforms[i].hitTestPoint(xpos, ypos, true))) || (this.m_platforms[i].fallthrough == true)) || (this.m_platforms[i].shouldIgnore(this))) || (this.m_selfPlatform == this.m_platforms[i]))))
            {
                i++;
            };
            if ((((i < this.m_platforms.length) && (this.m_platforms[i].hitTestPoint(xpos, ypos, true))) && (this.netYSpeed() >= 0)))
            {
                return (this.m_platforms[i]);
            };
            return (null);
        }

        public function testTerrainWithCoord(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            i = 0;
            while (((i < this.m_terrains.length) && ((((!(this.m_terrains[i].hitTestPoint(xpos, ypos, true))) || (this.m_terrains[i].fallthrough == true)) || (this.m_terrains[i].shouldIgnore(this))) || (this.m_selfPlatform == this.m_terrains[i]))))
            {
                i++;
            };
            if (((i < this.m_terrains.length) && (this.m_terrains[i].hitTestPoint(xpos, ypos, true))))
            {
                return (this.m_terrains[i]);
            };
            return (null);
        }

        public function testPlatformWithCoord(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            i = 0;
            while (((i < this.m_platforms.length) && ((((!(this.m_platforms[i].hitTestPoint(xpos, ypos, true))) || (this.m_platforms[i].fallthrough == true)) || (this.m_platforms[i].shouldIgnore(this))) || (this.m_selfPlatform == this.m_platforms[i]))))
            {
                i++;
            };
            if ((((i < this.m_platforms.length) && (this.m_platforms[i].hitTestPoint(xpos, ypos, true))) && (this.netYSpeed() >= 0)))
            {
                return (this.m_platforms[i]);
            };
            return (null);
        }

        protected function testAbsCoordinates(xpos:Number, ypos:Number):Boolean
        {
            var i:int;
            i = 0;
            while (((i < this.m_terrains.length) && ((((!(this.m_terrains[i].hitTestPoint(xpos, ypos, true))) || (this.m_terrains[i].fallthrough == true)) || (this.m_terrains[i].shouldIgnore(this))) || (this.m_selfPlatform == this.m_terrains[i]))))
            {
                i++;
            };
            if (((i < this.m_terrains.length) && (this.m_terrains[i].hitTestPoint(xpos, ypos, true))))
            {
                return (true);
            };
            return (false);
        }

        public function testCoordinates(xpos:Number, ypos:Number):Platform
        {
            var i:int;
            i = 0;
            while (((i < this.m_terrains.length) && ((!(this.m_terrains[i].hitTestPoint(xpos, ypos, true))) || (this.m_selfPlatform == this.m_terrains[i]))))
            {
                i++;
            };
            if (((i < this.m_terrains.length) && (this.m_terrains[i].hitTestPoint(xpos, ypos, true))))
            {
                return (this.m_terrains[i]);
            };
            i = 0;
            while (((i < this.m_platforms.length) && ((!(this.m_platforms[i].hitTestPoint(xpos, ypos, true))) || (this.m_selfPlatform == this.m_platforms[i]))))
            {
                i++;
            };
            if (((i < this.m_platforms.length) && (this.m_platforms[i].hitTestPoint(xpos, ypos, true))))
            {
                return (this.m_platforms[i]);
            };
            return (null);
        }

        public function checkLinearPath(b:InteractiveSprite):Boolean
        {
            return (this.checkLinearPathBetweenPoints(new Point(this.X, this.Y), new Point(b.X, b.Y)));
        }

        public function checkLinearPathBetweenPoints(p1:Point, p2:Point, terrainOnly:Boolean=true, currentPlatform:Platform=null):Boolean
        {
            return (this.getPlatformBetweenPoints(p1, p2, terrainOnly, currentPlatform) == null);
        }

        public function getPlatformBetweenPoints(p1:Point, p2:Point, terrainOnly:Boolean=true, currentPlatform:Platform=null):Platform
        {
            var startX:Number = p1.x;
            var startY:Number = p1.y;
            var currentX:Number = p1.x;
            var currentY:Number = p1.y;
            var xDis:Number = (p2.x - p1.x);
            var yDis:Number = (p2.y - p1.y);
            var repeats:Number = ((Math.abs(xDis) + Math.abs(yDis)) / 10);
            var ground:Platform = currentPlatform;
            if (repeats < 1)
            {
                repeats = 1;
            };
            var i:int;
            while (i < Math.floor(repeats))
            {
                if (((((currentPlatform) && (currentPlatform.hitTestPoint((currentX + (xDis / repeats)), (currentY + (yDis / repeats))))) || (((terrainOnly) && (currentPlatform == null)) && (ground = this.testTerrainWithCoord((currentX + (xDis / repeats)), (currentY + (yDis / repeats)))))) || (((!(terrainOnly)) && (currentPlatform == null)) && (ground = this.testGroundWithCoord((currentX + (xDis / repeats)), (currentY + (yDis / repeats)))))))
                {
                    return (ground);
                };
                currentX = (currentX + (xDis / repeats));
                currentY = (currentY + (yDis / repeats));
                i++;
            };
            return (null);
        }

        protected function pushOutOfGround():void
        {
            var max:int = 50;
            var i:int;
            while (((i < max) && (this.testTerrainWithCoord(this.m_sprite.x, this.m_sprite.y))))
            {
                this.m_sprite.y--;
                i++;
            };
            if (i >= max)
            {
                this.m_sprite.y = (this.m_sprite.y + i);
            };
        }

        protected function m_groundCollisionTest():void
        {
            var wasHittingGround:Boolean = this.m_collision.ground;
            if (((this.m_collision.ground) && ((!(this.m_ySpeed)) < 0)))
            {
                this.attachToGround();
            };
            var onGround:Boolean = (!((this.m_currentPlatform = this.testGroundWithCoord(this.m_sprite.x, (this.m_sprite.y + 1))) == null));
            this.m_collision.ground = onGround;
            if (this.m_collision.ground)
            {
                this.attachToGround();
            };
            if (this.m_collision.ground)
            {
                this.attachToGround();
            };
            if (((this.m_collision.ground) && (!(wasHittingGround))))
            {
                this.m_ySpeed = 0;
                this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_TOUCH, {"caller":this.APIInstance.instance}));
            }
            else
            {
                if (((!(this.m_collision.ground)) && (wasHittingGround)))
                {
                    this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.GROUND_LEAVE, {"caller":this.APIInstance.instance}));
                };
            };
        }

        public function m_attemptToMove(xSpeed:Number, ySpeed:Number):void
        {
            var i:int;
            var origLocation:Point;
            var hitGround:Platform;
            var hasHit:Boolean;
            var angle:Number;
            var divisions:int;
            var triggeredWallHit:Boolean;
            if ((!((xSpeed == 0) && (ySpeed == 0))))
            {
                i = 0;
                this.m_collision.leftSide = (((xSpeed < 0) && (this.m_collision.ground)) && (this.testTerrainWithCoord(((this.m_sprite.x + xSpeed) - this.m_baseStats.KneeXOffset), ((this.m_sprite.y + ySpeed) + this.m_baseStats.KneeYOffset))));
                this.m_collision.rightSide = (((xSpeed > 0) && (this.m_collision.ground)) && (this.testTerrainWithCoord(((this.m_sprite.x + xSpeed) + this.m_baseStats.KneeXOffset), ((this.m_sprite.y + ySpeed) + this.m_baseStats.KneeYOffset))));
                if ((!(this.m_collision.ground)))
                {
                    origLocation = this.__attemptToMovePointCache;
                    origLocation.copyFrom(this.Location);
                    hitGround = this.moveSprite(xSpeed, ySpeed, (((xSpeed === 0) && (ySpeed >= 20)) ? 10 : 5));
                    hasHit = (!(hitGround == null));
                    angle = Utils.getAngleBetween(new Point(origLocation.x, origLocation.y), new Point(this.m_sprite.x, this.m_sprite.y));
                    if ((((hasHit) && (!((angle >= 225) && (angle <= 315)))) && (!((this.m_sprite.x == origLocation.x) && (this.m_sprite.y == origLocation.y)))))
                    {
                        this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                            "caller":this.APIInstance.instance,
                            "left":((angle < 225) && (angle > 135)),
                            "right":(((angle < 45) && (angle >= 0)) || ((angle <= 360) && (angle > 315))),
                            "top":((angle >= 45) && (angle >= 135))
                        }));
                    };
                    if ((((this.m_collision.rightSide) && (xSpeed > 0)) || ((this.m_collision.leftSide) && (xSpeed < 0))))
                    {
                        this.m_sprite.x = origLocation.x;
                    };
                    if (((hasHit) && (ySpeed >= 0)))
                    {
                        this.m_groundCollisionTest();
                    };
                }
                else
                {
                    divisions = (((Utils.fastAbs(xSpeed) >= 10) || (Utils.fastAbs(ySpeed) >= 10)) ? 10 : 1);
                    triggeredWallHit = false;
                    xSpeed = (xSpeed / divisions);
                    ySpeed = (ySpeed / divisions);
                    i = 0;
                    while (i < divisions)
                    {
                        this.m_collision.leftSide = (((xSpeed < 0) && (this.m_collision.ground)) && (this.testTerrainWithCoord(((this.m_sprite.x + xSpeed) - (this.m_width / 2)), ((this.m_sprite.y + ySpeed) - 35))));
                        this.m_collision.rightSide = (((xSpeed > 0) && (this.m_collision.ground)) && (this.testTerrainWithCoord(((this.m_sprite.x + xSpeed) + (this.m_width / 2)), ((this.m_sprite.y + ySpeed) - 35))));
                        if ((((!(triggeredWallHit)) && (!(xSpeed == 0))) && ((this.m_collision.rightSide) || (this.m_collision.leftSide))))
                        {
                            triggeredWallHit = true;
                            this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.HIT_WALL, {
                                "caller":this.APIInstance.instance,
                                "left":this.m_collision.leftSide,
                                "right":this.m_collision.rightSide,
                                "top":false
                            }));
                        };
                        if (ySpeed < 0)
                        {
                            this.m_sprite.y = (this.m_sprite.y + ySpeed);
                        };
                        this.m_sprite.x = (this.m_sprite.x + ((!(((this.m_collision.rightSide) && (xSpeed > 0)) || ((this.m_collision.leftSide) && (xSpeed < 0)))) ? xSpeed : 0));
                        if (((ySpeed > 0) && (!(this.testTerrainWithCoord(this.m_sprite.x, (this.m_sprite.y + ySpeed))))))
                        {
                            this.m_sprite.y = (this.m_sprite.y + ySpeed);
                        };
                        if (((!(this.m_collision.leftSide)) && (!(this.m_collision.rightSide))))
                        {
                            this.attachToGround();
                        };
                        if ((((Utils.fastAbs(xSpeed) > 10) || (Utils.fastAbs(ySpeed) > 10)) && (this.runExtraHitTests(0, 0))))
                        {
                            break;
                        };
                        i++;
                    };
                };
            };
        }

        public function safeMove(xSpeed:Number, ySpeed:Number):Boolean
        {
            return (!(this.moveSprite(xSpeed, ySpeed) == null));
        }

        protected function moveSprite(xSpeed:Number, ySpeed:Number, repeats:int=5):Platform
        {
            this.m_hitPlatform = null;
            var i:int;
            var j:int;
            var absX:Number = Utils.fastAbs(xSpeed);
            var absY:Number = Utils.fastAbs(ySpeed);
            var ground:Platform;
            var origRepeats:int = repeats;
            if (((repeats == 0) || ((xSpeed == 0) && (ySpeed == 0))))
            {
                return (ground);
            };
            if (absX > absY)
            {
                repeats = int(Math.max(repeats, (absX / repeats)));
            }
            else
            {
                repeats = int(Math.max(repeats, (absY / repeats)));
            };
            var origX:Number = this.m_sprite.x;
            var origY:Number = this.m_sprite.y;
            var currentX:Number = origX;
            var currentY:Number = origY;
            var Xoffset:Number = 0;
            var Yoffset:Number = 0;
            if (xSpeed > 0)
            {
                Xoffset = ((-(this.m_width) * this.m_sizeRatio) / 2);
                currentX = (currentX + ((this.m_width * this.m_sizeRatio) / 2));
            }
            else
            {
                if (xSpeed < 0)
                {
                    Xoffset = ((this.m_width * this.m_sizeRatio) / 2);
                    currentX = (currentX - ((this.m_width * this.m_sizeRatio) / 2));
                };
            };
            if (ySpeed == 0)
            {
                Yoffset = ((this.m_height * this.m_sizeRatio) / 2);
                currentY = (currentY - ((this.m_height * this.m_sizeRatio) / 2));
            }
            else
            {
                if (ySpeed < 0)
                {
                    Yoffset = (this.m_height * this.m_sizeRatio);
                    currentY = (currentY - (this.m_height * this.m_sizeRatio));
                };
            };
            var divXSpeed:Number = (xSpeed / repeats);
            var divYSpeed:Number = (ySpeed / repeats);
            var collisionFound:Boolean;
            i = 0;
            for (;i < (repeats - 1);i++)
            {
                if ((ground = this.testGroundWithCoord((currentX + divXSpeed), (currentY + divYSpeed))))
                {
                    if ((((ySpeed < 0) || (ySpeed == 0)) && (this.STAGEDATA.Platforms.indexOf(ground) >= 0)))
                    {
                        ground = null;
                        continue;
                    };
                    break;
                };
                if (((absX > 10) || (absY > 10)))
                {
                    if (this.runExtraHitTests(((currentX + Xoffset) - origX), ((currentY + Yoffset) - origY)))
                    {
                        return (null);
                    };
                };
                currentX = (currentX + divXSpeed);
                currentY = (currentY + divYSpeed);
            };
            repeats = origRepeats;
            divXSpeed = (divXSpeed / repeats);
            divYSpeed = (divYSpeed / repeats);
            collisionFound = false;
            i = 0;
            for (;((i < repeats) && (!(collisionFound)));i++)
            {
                if ((ground = this.testGroundWithCoord((currentX + divXSpeed), (currentY + divYSpeed))))
                {
                    if ((((ySpeed < 0) || (ySpeed == 0)) && (this.STAGEDATA.Platforms.indexOf(ground) >= 0)))
                    {
                        ground = null;
                        continue;
                    };
                    break;
                };
                if (((absX > 10) || (absY > 10)))
                {
                    if (this.runExtraHitTests(((currentX + Xoffset) - origX), ((currentY + Yoffset) - origY)))
                    {
                        return (null);
                    };
                };
                currentX = (currentX + divXSpeed);
                currentY = (currentY + divYSpeed);
            };
            if (((ground == null) && (!(this.testTerrainWithCoord((origX + xSpeed), (origY + ySpeed))))))
            {
                this.m_sprite.x = (origX + xSpeed);
                this.m_sprite.y = (origY + ySpeed);
            }
            else
            {
                this.m_sprite.x = (currentX + Xoffset);
                this.m_sprite.y = (currentY + Yoffset);
            };
            this.m_collisionPoint.x = (currentX - Xoffset);
            this.m_collisionPoint.y = (currentY - Yoffset);
            this.m_hitPlatform = ground;
            return (ground);
        }

        protected function getCollisionQuadrants(angle:Number):Object
        {
            var obj:Object = {
                "left":((angle < 225) && (angle > 135)),
                "right":(((angle < 45) && (angle >= 0)) || ((angle <= 360) && (angle > 315))),
                "top":((angle >= 45) && (angle >= 135)),
                "bottom":((angle >= 225) && (angle <= 315))
            };
            return (obj);
        }

        public function extraHitTests(x_offset:Number, y_offset:Number, caller:InteractiveSprite=null):Boolean
        {
            return (this.m_apiInstance.extraHitTests(x_offset, y_offset, caller));
        }

        public function runExtraHitTests(x_offset:Number, y_offset:Number):Boolean
        {
            var tmpPlayer:Character;
            var tmpItem:Item;
            var tmpProjectile:Projectile;
            var tmpEnemy:Enemy;
            var j:int;
            var tmpPlatList:Vector.<MovingPlatform> = this.STAGEDATA.MovingPlatforms;
            var result:Boolean;
            j = 0;
            while (j < tmpPlatList.length)
            {
                result = ((result) || (tmpPlatList[j].extraHitTests(x_offset, y_offset, this)));
                j++;
            };
            j = 0;
            while (j < this.STAGEDATA.Players.length)
            {
                tmpPlayer = this.STAGEDATA.getPlayerByID((j + 1));
                if (tmpPlayer)
                {
                    result = ((result) || (tmpPlayer.extraHitTests(x_offset, y_offset, this)));
                };
                j++;
            };
            j = 0;
            while (j < this.STAGEDATA.ItemsRef.ItemsInUse.length)
            {
                tmpItem = this.STAGEDATA.ItemsRef.ItemsInUse[j];
                if (tmpItem)
                {
                    result = ((result) || (tmpItem.extraHitTests(x_offset, y_offset, this)));
                };
                j++;
            };
            j = 0;
            while (j < this.STAGEDATA.Projectiles.length)
            {
                tmpProjectile = this.STAGEDATA.Projectiles[j];
                if (tmpProjectile)
                {
                    result = ((result) || (tmpProjectile.extraHitTests(x_offset, y_offset, this)));
                };
                j++;
            };
            j = 0;
            while (j < this.STAGEDATA.Enemies.length)
            {
                tmpEnemy = this.STAGEDATA.Enemies[j];
                if (tmpEnemy)
                {
                    result = ((result) || (tmpEnemy.extraHitTests(x_offset, y_offset, this)));
                };
                j++;
            };
            return (result);
        }

        public function checkMovingPlatforms(mc:MovingPlatform):void
        {
            var x_difference:Number;
            var y_difference:Number;
            if ((((this.m_collision.ground) && (!(this.m_currentPlatform == null))) && (this.m_currentPlatform == mc)))
            {
                x_difference = (mc.X - mc.PreviousX);
                y_difference = (mc.Y - mc.PreviousY);
                this.safeMove(0, y_difference);
                this.safeMove(x_difference, 0);
            };
        }

        public function faceLeft():void
        {
            this.m_faceLeft();
        }

        public function faceRight():void
        {
            this.m_faceRight();
        }

        public function isFacingRight():Boolean
        {
            return (this.m_facingForward);
        }

        public function isCloseToGround():Boolean
        {
            return ((this.m_collision.ground) || (this.testGroundWithCoord(this.m_sprite.x, (this.m_sprite.y + 10))));
        }

        public function isOnGround():Boolean
        {
            return (this.m_collision.ground);
        }

        public function getCounterAttackBoxStats():Object
        {
            return (this.m_counterAttackData);
        }

        public function flip(e:*=null):void
        {
            if (this.m_facingForward)
            {
                this.m_faceLeft();
            }
            else
            {
                this.m_faceRight();
            };
        }

        public function addToCamera():void
        {
            this.STAGEDATA.CamRef.addTarget(this.m_sprite);
        }

        public function removeFromCamera():void
        {
            this.STAGEDATA.CamRef.deleteTarget(this.m_sprite);
        }

        public function resetCameraBox():void
        {
            if (this.m_sprite)
            {
                this.m_sprite.camOverride = null;
            };
        }

        public function updateCamerBox():void
        {
            var hBox:HitBoxSprite;
            if (this.HasCamBox)
            {
                hBox = this.CurrentAnimation.getHitBoxes(this.CurrentFrameNum, HitBoxSprite.CAM)[0];
                if (((this.m_sprite.camOverride) && (this.m_sprite.camOverride is Rectangle)))
                {
                    this.m_sprite.camOverride.x = hBox.x;
                    this.m_sprite.camOverride.y = hBox.y;
                    this.m_sprite.camOverride.width = hBox.width;
                    this.m_sprite.camOverride.height = hBox.height;
                }
                else
                {
                    this.m_sprite.camOverride = new Rectangle(hBox.x, hBox.y, hBox.width, hBox.height);
                };
            }
            else
            {
                this.resetCameraBox();
            };
        }

        protected function m_faceRight():void
        {
            if (this.m_delayPlayback)
            {
                this.m_delayPlayBackFacingRight = true;
            }
            else
            {
                this.m_sprite.scaleX = Math.abs(this.m_sprite.scaleX);
            };
            this.m_facingForward = true;
            if (this.m_attack)
            {
                this.m_attack.IsForward = true;
            };
        }

        protected function m_faceLeft():void
        {
            if (this.m_delayPlayback)
            {
                this.m_delayPlayBackFacingRight = false;
            }
            else
            {
                this.m_sprite.scaleX = -(Math.abs(this.m_sprite.scaleX));
            };
            this.m_facingForward = false;
            if (this.m_attack)
            {
                this.m_attack.IsForward = false;
            };
        }

        public function setGravity(value:Number):void
        {
            this.m_gravity = value;
        }

        public function setCamBoxSize(width:Number, height:Number, x_offset:Number=0, y_offset:Number=0):void
        {
            this.m_sprite.cam_width = width;
            this.m_sprite.cam_height = height;
            this.m_sprite.cam_x_offset = x_offset;
            this.m_sprite.cam_y_offset = y_offset;
        }

        public function camFocus(length:int):void
        {
            this.CAM.addZoomFocus(this.m_sprite, length);
        }

        public function camUnfocus():void
        {
            this.CAM.removeZoomFocus(this.m_sprite);
            this.CAM.deleteForcedTarget(this.m_sprite);
        }

        public function setGlobalVariable(vName:String, value:*):void
        {
            this.m_globalVariables[vName] = value;
        }

        public function getGlobalVariable(vName:String):*
        {
            return ((this.m_globalVariables[vName] == undefined) ? null : this.m_globalVariables[vName]);
        }

        public function getRotation():Number
        {
            return (this.m_sprite.rotation);
        }

        public function setRotation(value:Number):void
        {
            this.m_sprite.rotation = value;
        }

        public function getWidth():Number
        {
            return (this.m_width);
        }

        public function getHeight():Number
        {
            return (this.m_height);
        }

        public function setWidth(value:Number):void
        {
            this.m_width = value;
        }

        public function setHeight(value:Number):void
        {
            this.m_height = value;
        }

        public function getXSpeed():Number
        {
            return (this.m_xSpeed);
        }

        public function getYSpeed():Number
        {
            return (this.m_ySpeed);
        }

        public function getX():Number
        {
            return (this.m_sprite.x);
        }

        public function setX(value:Number):void
        {
            this.m_sprite.x = value;
        }

        public function getY():Number
        {
            return (this.m_sprite.y);
        }

        public function setY(value:Number):void
        {
            this.m_sprite.y = value;
        }

        public function getXScale():Number
        {
            return (this.CurrentScale.x);
        }

        public function getYScale():Number
        {
            return (this.CurrentScale.y);
        }

        public function playFrame(n:String):void
        {
            if (this.m_delayPlayback)
            {
                this.m_delayPlayBackAnimation = n;
                this.m_delayPlayBackFrame = null;
                return;
            };
            this.m_delayPlayBackAnimation = null;
            this.m_delayPlayBackFrame = null;
            if ((!(this.currentFrameIs(n))))
            {
                this.m_currentAnimationID = n;
                this.m_sprite.gotoAndStop(n);
                this.refreshAttackID();
                this.updatePaletteSwap();
            };
        }

        public function stancePlayFrame(n:*):void
        {
            if (this.m_delayPlayback)
            {
                this.m_delayPlayBackFrame = n;
                return;
            };
            if (this.HasStance)
            {
                this.m_sprite.stance.gotoAndStop(n);
                this.updatePaletteSwap();
            };
        }

        public function currentStanceFrameIs(s:String):Boolean
        {
            var isEqual:Boolean = ((((this.HasStance) && (!(this.m_sprite.stance.xframe == null))) && (this.m_sprite.stance.xframe == s)) ? true : false);
            return (isEqual);
        }

        protected function getStanceVar(varName:String, varValue:*):Boolean
        {
            if ((((this.HasStance) && (!(this.m_sprite.stance[varName] == null))) && (this.m_sprite.stance[varName] == varValue)))
            {
                return (true);
            };
            return (false);
        }

        public function currentFrameIs(s:String):Boolean
        {
            var isEqual:Boolean = ((((!(this.m_sprite.xframe == null)) && (this.m_sprite.xframe == s)) || ((this.m_sprite.xframe == null) && (this.m_currentAnimationID == s))) ? true : false);
            return (isEqual);
        }

        protected function setBrightness(level:Number):void
        {
            if (Math.abs(level) > 100)
            {
                level = ((level > 0) ? 100 : -100);
            };
            var priorAlpha:Number = this.m_sprite.alpha;
            var color:ColorTransform = new ColorTransform();
            color.redOffset = (level * 2.55);
            color.greenOffset = (level * 2.55);
            color.blueOffset = (level * 2.55);
            this.m_sprite.transform.colorTransform = color;
            this.m_sprite.alpha = priorAlpha;
        }

        public function setPosition(x:Number, y:Number):void
        {
            this.m_sprite.x = x;
            this.m_sprite.y = y;
        }

        protected function setTint(redMultiplier:Number, greenMultiplier:Number, blueMultiplier:Number, alphaMultiplier:Number, redOffset:Number, greenOffset:Number, blueOffset:Number, alphaOffset:Number):void
        {
            Utils.setTint(this.m_sprite, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
        }

        public function getMC():MovieClip
        {
            return (this.m_sprite);
        }

        public function getStanceMC():MovieClip
        {
            return ((this.HasStance) ? this.m_sprite.stance : null);
        }

        public function getScale():Point
        {
            return (this.CurrentScale);
        }

        public function setScale(x:Number, y:Number):void
        {
            this.m_sprite.scaleX = (x * this.m_sizeRatio);
            this.m_sprite.scaleY = (y * this.m_sizeRatio);
        }

        public function getID():int
        {
            return (this.m_player_id);
        }

        public function getNearest(_arg_1:String, skipSameTeam:Boolean=true, skipOwner:Boolean=true):InteractiveSprite
        {
            var currTarget:InteractiveSprite;
            var target:InteractiveSprite;
            var closest:Number = Number.MAX_VALUE;
            var dis:Number = 0;
            var x:int;
            if (_arg_1 === "character")
            {
                x = 0;
                while (x < this.STAGEDATA.Characters.length)
                {
                    currTarget = this.STAGEDATA.Characters[x];
                    if (((((currTarget) && (!(Character(currTarget).isStandby()))) && (!(this.m_targetInterrupt == null))) && (this.m_targetInterrupt({"target":currTarget.APIInstance.instance}))))
                    {
                    }
                    else
                    {
                        if (((((currTarget) && (!(currTarget == this))) && (!(this.STAGEDATA.Characters[x].StandBy))) && (!((this.m_player_id > 0) && (currTarget.ID == this.m_player_id)))))
                        {
                            if ((!((skipSameTeam) && (((this.m_team_id > 0) && (currTarget.Team == this.m_team_id)) || (this.m_player_id === currTarget.ID)))))
                            {
                                dis = Utils.getDistanceFrom(this, currTarget);
                                if (dis < closest)
                                {
                                    target = currTarget;
                                    closest = dis;
                                };
                            };
                        };
                    };
                    x++;
                };
            }
            else
            {
                if (_arg_1 === "player")
                {
                    x = 0;
                    while (x < this.STAGEDATA.Players.length)
                    {
                        currTarget = this.STAGEDATA.Players[x];
                        if (((!(this.m_targetInterrupt == null)) && (this.m_targetInterrupt({"target":currTarget.APIInstance.instance}))))
                        {
                        }
                        else
                        {
                            if ((((currTarget) && (!(currTarget == this))) && (!((this.m_player_id > 0) && (currTarget.ID == this.m_player_id)))))
                            {
                                if ((!(((skipSameTeam) && ((this.m_team_id > 0) && (currTarget.Team == this.m_team_id))) || (this.m_player_id === currTarget.ID))))
                                {
                                    dis = Utils.getDistanceFrom(this, currTarget);
                                    if (dis < closest)
                                    {
                                        target = currTarget;
                                        closest = dis;
                                    };
                                };
                            };
                        };
                        x++;
                    };
                }
                else
                {
                    if (_arg_1 === "item")
                    {
                        x = 0;
                        while (x < this.STAGEDATA.ItemsRef.ItemsInUse.length)
                        {
                            currTarget = this.STAGEDATA.ItemsRef.ItemsInUse[x];
                            if (((!(this.m_targetInterrupt == null)) && (this.m_targetInterrupt({"target":currTarget.APIInstance.instance}))))
                            {
                            }
                            else
                            {
                                if ((((currTarget) && (!(currTarget == this))) && (!((this.m_player_id > 0) && (currTarget.ID == this.m_player_id)))))
                                {
                                    if (((!((skipSameTeam) && (((this.m_team_id > 0) && (currTarget.Team == this.m_team_id)) || (this.m_player_id === currTarget.ID)))) && (!((skipOwner) && (Item(currTarget).getOwner() === this)))))
                                    {
                                        dis = Utils.getDistanceFrom(this, currTarget);
                                        if (dis < closest)
                                        {
                                            target = currTarget;
                                            closest = dis;
                                        };
                                    };
                                };
                            };
                            x++;
                        };
                    }
                    else
                    {
                        if (_arg_1 === "projectile")
                        {
                            x = 0;
                            while (x < this.STAGEDATA.Projectiles.length)
                            {
                                currTarget = this.STAGEDATA.Projectiles[x];
                                if (((!(this.m_targetInterrupt == null)) && (this.m_targetInterrupt({"target":currTarget.APIInstance.instance}))))
                                {
                                }
                                else
                                {
                                    if ((((currTarget) && (!(currTarget == this))) && (!((this.m_player_id > 0) && (currTarget.ID == this.m_player_id)))))
                                    {
                                        if (((!(((skipSameTeam) && ((this.m_team_id > 0) && (currTarget.Team == this.m_team_id))) || (this.m_player_id === currTarget.ID))) && (!((skipOwner) && (Projectile(currTarget).getOwner() === this)))))
                                        {
                                            dis = Utils.getDistanceFrom(this, currTarget);
                                            if (dis < closest)
                                            {
                                                target = currTarget;
                                                closest = dis;
                                            };
                                        };
                                    };
                                };
                                x++;
                            };
                        }
                        else
                        {
                            if (_arg_1 === "enemy")
                            {
                                x = 0;
                                while (x < this.STAGEDATA.Enemies.length)
                                {
                                    currTarget = this.STAGEDATA.Enemies[x];
                                    if (((!(this.m_targetInterrupt == null)) && (this.m_targetInterrupt({"target":currTarget.APIInstance.instance}))))
                                    {
                                    }
                                    else
                                    {
                                        if ((((currTarget) && (!(currTarget == this))) && (!((this.m_player_id > 0) && (currTarget.ID == this.m_player_id)))))
                                        {
                                            if (((!((skipSameTeam) && (((this.m_team_id > 0) && (currTarget.Team == this.m_team_id)) || (this.m_player_id === currTarget.ID)))) && (!((skipOwner) && (Enemy(currTarget).getOwner() === this)))))
                                            {
                                                dis = Utils.getDistanceFrom(this, currTarget);
                                                if (dis < closest)
                                                {
                                                    target = currTarget;
                                                    closest = dis;
                                                };
                                            };
                                        };
                                    };
                                    x++;
                                };
                            };
                        };
                    };
                };
            };
            return (target);
        }

        public function showHealthBoxes(show:Boolean):void
        {
            if ((((show) && (this.STAGEDATA.GameRef.GameMode === Mode.TRAINING)) && (this.STAGEDATA.HudRef.HudMode === 2)))
            {
                return;
            };
            if (this.m_healthBoxMC)
            {
                this.m_healthBoxMC.visible = show;
                this.m_healthBoxMC.damageMC_holder.visible = show;
                this.m_healthBoxMC.percent_mc.damage.visible = show;
            };
        }

        public function setVisibility(value:Boolean):void
        {
            this.m_sprite.visible = value;
            this.m_shadowEffect.visible = value;
            this.m_reflectionEffect.visible = value;
        }

        public function unnattachFromGround():void
        {
            var limit:Number = 0;
            while (((limit < 30) && (this.testGroundWithCoord(this.m_sprite.x, (this.m_sprite.y + 1)))))
            {
                limit++;
                this.m_sprite.y--;
            };
            if (limit >= 30)
            {
                this.m_sprite.y = (this.m_sprite.y + limit);
            };
            this.m_collision.ground = false;
            this.m_currentPlatform = null;
        }

        public function resetFade(duration:int=15):void
        {
            this.m_fadeTimer.reset();
            this.m_fadeTimer.MaxTime = duration;
        }

        public function resetKnockback():void
        {
            this.m_xKnockback = 0;
            this.m_yKnockback = 0;
            this.resetKnockbackDecay();
        }

        public function fadeIn():void
        {
            if ((!(this.m_fadeTimer.IsComplete)))
            {
                this.m_fadeTimer.tick();
                this.setBrightness(((1 - (this.m_fadeTimer.CurrentTime / this.m_fadeTimer.MaxTime)) * 100));
            };
        }

        public function fadeOut():void
        {
            if ((!(this.m_fadeTimer.IsComplete)))
            {
                this.m_fadeTimer.tick();
                this.setBrightness(((this.m_fadeTimer.CurrentTime / this.m_fadeTimer.MaxTime) * 100));
            };
        }

        public function isFading():Boolean
        {
            return (!(this.m_fadeTimer.IsComplete));
        }

        public function initDelayPlayback(useHitstun:Boolean=false):void
        {
            this.m_delayPlayback = true;
            this.m_delayPlayBackFacingRight = this.m_facingForward;
            this.m_delayPlayBackHitStun = useHitstun;
        }

        public function disableDelayPlayback():void
        {
            this.m_delayPlayback = false;
            this.m_delayPlayBackAnimation = null;
            this.m_delayPlayBackFrame = null;
        }

        protected function handleDelayPlayback():void
        {
            if (((this.m_delayPlayback) && (!((this.m_delayPlayBackHitStun) && (this.isHitStunOrParalysis())))))
            {
                this.m_delayPlayback = false;
                if (this.m_delayPlayBackFacingRight)
                {
                    this.m_faceRight();
                }
                else
                {
                    this.m_faceLeft();
                };
                if (this.m_delayPlayBackAnimation)
                {
                    this.playFrame(this.m_delayPlayBackAnimation);
                };
                if (this.m_delayPlayBackFrame)
                {
                    this.stancePlayFrame(this.m_delayPlayBackFrame);
                };
                this.m_delayPlayBackAnimation = null;
                this.m_delayPlayBackFrame = null;
            };
        }

        protected function PREPERFORM():void
        {
            if ((((((this.m_started) && (this.HasMC)) && (!(this.STAGEDATA.Paused))) && (!(this.isHitStunOrParalysis()))) && (!(this.m_delayPlayback))))
            {
                Utils.advanceFrame(this.m_sprite);
                Utils.recursiveMovieClipPlay(this.m_sprite, true);
            }
            else
            {
                this.handleDelayPlayback();
            };
        }

        public function PERFORMALL():void
        {
            this.PREPERFORM();
            this.move();
            this.m_forces();
            this.gravity();
            this.m_groundCollisionTest();
            this.updateSelfPlatform();
            this.updateCamerBox();
            this.POSTPERFORM();
        }

        protected function POSTPERFORM():void
        {
            if (this.HasMC)
            {
                this.m_sprite.stop();
                Utils.recursiveMovieClipPlay(this.m_sprite, false);
                this.updatePaletteSwap();
                this.checkReflection();
                this.checkShadow();
            };
            this.m_started = true;
        }

        protected function checkReflection(multiplier:Number=1):void
        {
            var groundPoint:Point;
            var boundsRect:Rectangle;
            var outsideRect:Rectangle;
            var bmpData:BitmapData;
            var flippedH:Boolean;
            var flippedV:Boolean;
            var mat:Matrix;
            var bmp:Bitmap;
            var skewMat:Matrix;
            var actualAngle:Number;
            if (((((((this.m_baseStats.Reflection) && (this.m_reflectionEffect)) && (this.STAGEDATA.ReflectionsRef)) && (this.STAGEDATA.ReflectionsMaskRef)) && (this.HasStance)) && (this.STAGEDATA.getQualitySettings().shadows)))
            {
                groundPoint = this.STAGEDATA.getPlatformBetweenPointsAsPoint(this.Location, new Point(this.m_sprite.x, (this.m_sprite.y + 200)));
                if ((((this.m_sprite) && (this.m_sprite.parent)) && (groundPoint)))
                {
                    while (this.STAGEDATA.testGroundWithCoord(groundPoint.x, groundPoint.y))
                    {
                        groundPoint.y--;
                    };
                    boundsRect = this.m_sprite.getBounds(this.m_sprite);
                    boundsRect.x = (boundsRect.x * multiplier);
                    boundsRect.y = (boundsRect.y * multiplier);
                    boundsRect.width = (boundsRect.width * multiplier);
                    boundsRect.height = (boundsRect.height * multiplier);
                    outsideRect = this.m_sprite.getBounds(this.m_sprite.parent);
                    if (((boundsRect.width > 2000) || (boundsRect.height > 2000)))
                    {
                        return;
                    };
                    bmpData = new BitmapData(Math.round((boundsRect.width + 0.5)), Math.round((boundsRect.height + 0.5)), true, 1127270);
                    flippedH = false;
                    flippedV = false;
                    mat = new Matrix();
                    mat.tx = -(boundsRect.x);
                    mat.ty = -(boundsRect.y);
                    mat.a = multiplier;
                    mat.d = multiplier;
                    flippedH = (this.m_sprite.transform.matrix.a < 0);
                    flippedV = (this.m_sprite.transform.matrix.d < 0);
                    bmpData.draw(this.m_sprite, mat, null, null, new Rectangle(0, 0, boundsRect.width, Utils.fastAbs(boundsRect.height)), false);
                    while (this.m_reflectionEffect.numChildren > 0)
                    {
                        if ((this.m_reflectionEffect.getChildAt(0) is Bitmap))
                        {
                            (this.m_reflectionEffect.getChildAt(0) as Bitmap).bitmapData.dispose();
                            (this.m_reflectionEffect.getChildAt(0) as Bitmap).bitmapData = null;
                        };
                        this.m_reflectionEffect.removeChild(this.m_reflectionEffect.getChildAt(0));
                    };
                    bmp = new Bitmap(bmpData);
                    bmp.transform.colorTransform = new ColorTransform(1, 1, 1, 0.75);
                    skewMat = new Matrix();
                    actualAngle = 0;
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
                    bmp.transform.matrix = skewMat.clone();
                    this.m_reflectionEffect.addChild(bmp);
                    this.m_reflectionEffect.scaleX = this.CurrentScale.x;
                    this.m_reflectionEffect.scaleY = (-0.9 * this.CurrentScale.y);
                    this.m_reflectionEffect.alpha = this.m_sprite.alpha;
                    this.m_reflectionEffect.x = this.m_sprite.x;
                    this.m_reflectionEffect.y = (groundPoint.y + (groundPoint.y - this.m_sprite.y));
                    if ((!(this.m_reflectionEffect.parent)))
                    {
                        this.STAGEDATA.ReflectionsRef.addChildAt(this.m_reflectionEffect, 0);
                    };
                }
                else
                {
                    this.toggleEffect(this.m_reflectionEffect, false);
                };
            };
        }

        protected function checkShadow(multiplier:Number=1):void
        {
            var boundsRect:Rectangle;
            var outsideRect:Rectangle;
            var bmpData:BitmapData;
            var flippedH:Boolean;
            var flippedV:Boolean;
            var mat:Matrix;
            var bmp:Bitmap;
            var skewMat:Matrix;
            var actualAngle:Number;
            var angle:Number;
            if (((((((this.m_baseStats.Shadow) && (this.m_shadowEffect)) && (this.STAGEDATA.LightSource)) && (this.STAGEDATA.ShadowsRef)) && (this.HasStance)) && (this.STAGEDATA.getQualitySettings().shadows)))
            {
                if (((((this.m_collision.ground) && (this.m_currentPlatform)) && (this.m_sprite)) && (this.m_sprite.parent)))
                {
                    boundsRect = this.m_sprite.getBounds(this.m_sprite);
                    boundsRect.x = (boundsRect.x * multiplier);
                    boundsRect.y = (boundsRect.y * multiplier);
                    boundsRect.width = (boundsRect.width * multiplier);
                    boundsRect.height = (boundsRect.height * multiplier);
                    outsideRect = this.m_sprite.getBounds(this.m_sprite.parent);
                    if ((((boundsRect.width > 2000) || (boundsRect.height > 2000)) || (boundsRect.y >= 0)))
                    {
                        return;
                    };
                    if ((boundsRect.y + boundsRect.height) > 0)
                    {
                        boundsRect.height = (boundsRect.height - (boundsRect.height + boundsRect.y));
                    };
                    bmpData = new BitmapData(Math.round((boundsRect.width + 0.5)), Math.round((boundsRect.height + 0.5)), true, 1127270);
                    flippedH = false;
                    flippedV = false;
                    mat = new Matrix();
                    mat.tx = -(boundsRect.x);
                    mat.ty = -(boundsRect.y);
                    mat.a = multiplier;
                    mat.d = multiplier;
                    flippedH = (this.m_sprite.transform.matrix.a < 0);
                    flippedV = (this.m_sprite.transform.matrix.d < 0);
                    bmpData.draw(this.m_sprite, mat, null, null, new Rectangle(0, 0, boundsRect.width, Utils.fastAbs(boundsRect.height)), false);
                    while (this.m_shadowEffect.numChildren > 0)
                    {
                        if ((this.m_shadowEffect.getChildAt(0) is Bitmap))
                        {
                            (this.m_shadowEffect.getChildAt(0) as Bitmap).bitmapData.dispose();
                            (this.m_shadowEffect.getChildAt(0) as Bitmap).bitmapData = null;
                        };
                        this.m_shadowEffect.removeChild(this.m_shadowEffect.getChildAt(0));
                    };
                    bmp = new Bitmap(bmpData);
                    bmp.transform.colorTransform = new ColorTransform(1, 1, 1, 0.25, -255, -255, -255, 0);
                    skewMat = new Matrix();
                    actualAngle = 0;
                    if (this.STAGEDATA.LightSource)
                    {
                        actualAngle = Utils.forceBase360((90 - Utils.getAngleBetween(new Point(this.STAGEDATA.LightSource.x, ((this.m_sprite.y > this.STAGEDATA.LightSource.y) ? (this.STAGEDATA.LightSource.y - Utils.fastAbs((this.STAGEDATA.LightSource.y - this.m_sprite.y))) : this.m_sprite.y)), new Point(this.m_sprite.x, this.STAGEDATA.LightSource.y))));
                        if (actualAngle > 180)
                        {
                            actualAngle = (actualAngle - 180);
                        };
                    };
                    angle = (((actualAngle >= 45) && (actualAngle < 90)) ? 45 : (((actualAngle >= 90) && (actualAngle < 135)) ? 135 : actualAngle));
                    skewMat.c = Math.tan(Utils.toRadians(angle));
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
                    bmp.transform.matrix = skewMat.clone();
                    this.m_shadowEffect.addChild(bmp);
                    this.m_shadowEffect.x = (this.m_sprite.x - (Math.tan(Utils.toRadians(angle)) * boundsRect.height));
                    this.m_shadowEffect.y = this.m_sprite.y;
                    this.m_shadowEffect.scaleX = 1;
                    this.m_shadowEffect.scaleY = 1;
                    this.m_shadowEffect.scaleY = -0.25;
                    this.m_shadowEffect.alpha = this.m_sprite.alpha;
                    if ((!(this.m_shadowEffect.parent)))
                    {
                        this.STAGEDATA.ShadowsRef.addChildAt(this.m_shadowEffect, 0);
                    };
                }
                else
                {
                    this.toggleEffect(this.m_shadowEffect, false);
                };
            };
        }

        protected function toggleEffect(effect:MovieClip, visible:Boolean=true):void
        {
            if (visible)
            {
                if (((effect) && (!(effect.parent))))
                {
                    this.STAGE.addChild(effect);
                };
            }
            else
            {
                if (((effect) && (!(effect.parent == null))))
                {
                    effect.parent.removeChild(effect);
                };
            };
        }

        protected function hideAllEffects():void
        {
            this.toggleEffect(this.m_shadowEffect, false);
        }

        public function inKnockback():Boolean
        {
            return (!((this.m_xKnockback == 0) && (this.m_yKnockback == 0)));
        }

        public function inState(state:uint):Boolean
        {
            return (this.m_state == state);
        }

        public function getState():uint
        {
            return (this.m_state);
        }

        public function setState(state:uint):void
        {
            var changedStates:Boolean = (!(state == this.m_state));
            var oldState:uint = this.m_state;
            this.m_state = state;
            if (changedStates)
            {
                this.m_framesSinceLastState = 0;
                this.flushTimers();
                this.removeAllTempEvents();
                this.m_controlFrames();
                this.m_eventManager.dispatchEvent(new SSF2Event(SSF2Event.STATE_CHANGE, {
                    "caller":this.APIInstance.instance,
                    "fromState":oldState,
                    "toState":this.m_state
                }));
            };
        }

        protected function removeAllTempEvents():void
        {
            while (this.m_tempEvents.length > 0)
            {
                this.m_eventManager.removeEventListener(this.m_tempEvents[0].type, this.m_tempEvents[0].listener, this.m_tempEvents[0].useCapture);
                this.m_tempEvents.splice(0, 1);
            };
        }

        protected function m_controlFrames():void
        {
        }

        public function attachEffect(id:*, options:Object=null):MovieClip
        {
            options = ((options) || ({}));
            var absolute:Boolean;
            var resize:Boolean = true;
            var flip:Boolean = true;
            var force:Boolean;
            var scaleX:Number = 1;
            var scaleY:Number = 1;
            var behind:Boolean;
            flip = ((options.flip !== undefined) ? options.flip : flip);
            resize = ((options.resize !== undefined) ? options.resize : resize);
            absolute = ((options.absolute !== undefined) ? options.absolute : absolute);
            force = ((options.force !== undefined) ? options.force : force);
            options.x = ((options.x !== undefined) ? options.x : 0);
            options.y = ((options.y !== undefined) ? options.y : 0);
            behind = ((options.behind !== undefined) ? options.behind : false);
            if (((((id is String) && (id.match(/^global_/))) && (!(this.STAGEDATA.getQualitySettings().global_effects))) && (!(force))))
            {
                return (new MovieClip());
            };
            var tmpMC:MovieClip;
            if (((!(id == null)) && (((this.m_cancelEffectDelay.IsComplete) || (!(id == this.m_cancelEffect))) || (this.m_cancelEffectCount < 6))))
            {
                if ((!(absolute)))
                {
                    if (resize)
                    {
                        options.x = (this.m_sprite.x + (options.x * this.m_sizeRatio));
                        options.y = (this.m_sprite.y + (options.y * this.m_sizeRatio));
                    }
                    else
                    {
                        options.x = (this.m_sprite.x + options.x);
                        options.y = (this.m_sprite.y + options.y);
                    };
                };
                tmpMC = this.STAGEDATA.attachEffect(id, options);
                if (tmpMC)
                {
                    if (resize)
                    {
                        tmpMC.width = (tmpMC.width * this.m_sizeRatio);
                        tmpMC.height = (tmpMC.height * this.m_sizeRatio);
                    };
                    if (((!(this.m_facingForward)) && (flip)))
                    {
                        tmpMC.scaleX = (tmpMC.scaleX * -1);
                    };
                    if (id != this.m_cancelEffect)
                    {
                        this.m_cancelEffectCount = 0;
                    }
                    else
                    {
                        this.m_cancelEffectCount++;
                        this.m_cancelEffectDelay2.reset();
                    };
                    this.m_cancelEffectDelay.reset();
                    this.augmentEffect(tmpMC, options);
                    if ((((behind) && (tmpMC.parent)) && (tmpMC.parent === this.m_sprite.parent)))
                    {
                        tmpMC.parent.setChildIndex(tmpMC, this.m_sprite.parent.getChildIndex(this.m_sprite));
                    };
                };
            };
            return (tmpMC);
        }

        public function attachEffectOverlay(id:*, options:Object=null):MovieClip
        {
            options = ((options) || ({}));
            var absolute:Boolean;
            var resize:Boolean = true;
            var flip:Boolean = true;
            var force:Boolean;
            var scaleX:Number = 1;
            var scaleY:Number = 1;
            flip = ((options.flip !== undefined) ? options.flip : flip);
            resize = ((options.resize !== undefined) ? options.resize : resize);
            absolute = ((options.absolute !== undefined) ? options.absolute : absolute);
            force = ((options.force !== undefined) ? options.force : force);
            options.x = ((options.x !== undefined) ? options.x : 0);
            options.y = ((options.y !== undefined) ? options.y : 0);
            if (((((id is String) && (id.match(/^global_/))) && (!(this.STAGEDATA.getQualitySettings().global_effects))) && (!(force))))
            {
                return (new MovieClip());
            };
            var tmpMC:MovieClip;
            if (id != null)
            {
                if (absolute)
                {
                    options.x = (this.STAGEDATA.StageRef.x + options.x);
                    options.y = (this.STAGEDATA.StageRef.y + options.y);
                }
                else
                {
                    if (resize)
                    {
                        options.x = (this.OverlayX + (options.x * this.m_sizeRatio));
                        options.y = (this.OverlayY + (options.y * this.m_sizeRatio));
                    }
                    else
                    {
                        options.x = (this.OverlayX + options.x);
                        options.y = (this.OverlayY + options.y);
                    };
                };
                tmpMC = this.STAGEDATA.attachEffectOverlay(id, options);
                if (tmpMC)
                {
                    if (resize)
                    {
                        tmpMC.width = (tmpMC.width * this.m_sizeRatio);
                        tmpMC.height = (tmpMC.height * this.m_sizeRatio);
                    };
                    if (((!(this.m_facingForward)) && (flip)))
                    {
                        tmpMC.scaleX = (tmpMC.scaleX * -1);
                    };
                    this.augmentEffect(tmpMC, options);
                };
            };
            return (tmpMC);
        }

        private function augmentEffect(effect:MovieClip, options:Object):void
        {
            var loop:int;
            var loopHandler:Function;
            var parentLockHandler:Function;
            var flipXHandler:Function;
            var hitStuncheckHandler:Function;
            loop = 0;
            var parentLock:Boolean;
            var flipOnX:Boolean;
            var syncHitStun:Boolean;
            loop = ((options.loop !== undefined) ? options.loop : loop);
            parentLock = ((options.parentLock !== undefined) ? options.parentLock : parentLock);
            flipOnX = ((options.flipOnX !== undefined) ? options.flipOnX : flipOnX);
            syncHitStun = ((options.syncHitStun !== undefined) ? options.syncHitStun : syncHitStun);
            if (loop > 0)
            {
                loopHandler = function (e:Event):void
                {
                    if (effect.currentFrame === (effect.totalFrames - 1))
                    {
                        effect.gotoAndStop(1);
                        loop--;
                        if (loop <= 0)
                        {
                            STAGEDATA.removeEventListener(SSF2Event.GAME_TICK_END, loopHandler);
                        };
                    };
                };
                this.STAGEDATA.addEventListener(SSF2Event.GAME_TICK_END, loopHandler);
            };
            if (parentLock)
            {
                parentLockHandler = function (e:Event):void
                {
                    effect.x = (m_sprite.x + effect.x_offset);
                    effect.y = (m_sprite.y + effect.y_offset);
                    if (((effect.currentFrame === effect.totalFrames) || (!(effect.parent))))
                    {
                        STAGEDATA.removeEventListener(SSF2Event.GAME_TICK_END, parentLockHandler);
                    };
                };
                effect.x_offset = (effect.x - this.m_sprite.x);
                effect.y_offset = (effect.y - this.m_sprite.y);
                this.STAGEDATA.addEventListener(SSF2Event.GAME_TICK_END, parentLockHandler);
            };
            if (flipOnX)
            {
                effect.originalScaleX = effect.scaleX;
                effect.originalFacingRight = this.m_facingForward;
                flipXHandler = function (e:Event):void
                {
                    if (m_facingForward !== effect.originalFacingRight)
                    {
                        effect.scaleX = (effect.originalScaleX * -1);
                    }
                    else
                    {
                        effect.scaleX = effect.originalScaleX;
                    };
                    if (effect.currentFrame === effect.totalFrames)
                    {
                        STAGEDATA.removeEventListener(SSF2Event.GAME_TICK_END, flipXHandler);
                    };
                };
                this.STAGEDATA.addEventListener(SSF2Event.GAME_TICK_END, flipXHandler);
            };
            if (syncHitStun)
            {
                effect.bypassTicker = this.inHitStun();
                hitStuncheckHandler = function (e:Event):void
                {
                    effect.bypassTicker = inHitStun();
                    if ((!(effect.parent)))
                    {
                        STAGEDATA.removeEventListener(SSF2Event.GAME_TICK_END, hitStuncheckHandler);
                    };
                };
                this.STAGEDATA.addEventListener(SSF2Event.GAME_TICK_END, hitStuncheckHandler);
            };
        }

        public function attachHurtEffect(id:String, collisionHitBox:HitBoxSprite=null, options:Object=null):MovieClip
        {
            var i:*;
            var opts:Object = {
                "x":((collisionHitBox) ? collisionHitBox.centerx : 0),
                "y":((collisionHitBox) ? collisionHitBox.centery : 0),
                "scaleX":((1 + Math.min((0 / 100), 0.5)) * this.CurrentScale.x),
                "scaleY":((1 + Math.min((0 / 100), 0.5)) * this.CurrentScale.y),
                "resize":false,
                "absolute":true
            };
            if (options)
            {
                for (i in options)
                {
                    opts[i] = options[i];
                };
            };
            return (this.attachEffectOverlay(id, opts));
        }

        public function dispose():void
        {
            while (((this.m_shadowEffect) && (this.m_shadowEffect.numChildren > 0)))
            {
                if ((this.m_shadowEffect.getChildAt(0) is Bitmap))
                {
                    (this.m_shadowEffect.getChildAt(0) as Bitmap).bitmapData.dispose();
                    (this.m_shadowEffect.getChildAt(0) as Bitmap).bitmapData = null;
                };
                this.m_shadowEffect.removeChild(this.m_shadowEffect.getChildAt(0));
            };
            while (((this.m_reflectionEffect) && (this.m_reflectionEffect.numChildren > 0)))
            {
                if ((this.m_reflectionEffect.getChildAt(0) is Bitmap))
                {
                    (this.m_reflectionEffect.getChildAt(0) as Bitmap).bitmapData.dispose();
                    (this.m_reflectionEffect.getChildAt(0) as Bitmap).bitmapData = null;
                };
                this.m_reflectionEffect.removeChild(this.m_reflectionEffect.getChildAt(0));
            };
            if (this.m_apiInstance)
            {
                this.m_apiInstance.dispose();
            };
        }

        protected function checkTimers():void
        {
            if (SpecialMode.modeEnabled(this.STAGEDATA.GameRef.LevelData.specialModes, SpecialMode.SSF1))
            {
                this.m_attack.RefreshRate = 1;
            };
            this.m_framesSinceLastState++;
            this.tickTimers();
            this.m_knockbackStackingTimer.tick();
            if ((!(this.m_paralysis)))
            {
                if ((!(this.m_maxParalysisTime.IsComplete)))
                {
                    this.m_maxParalysisTime.tick();
                    if (this.m_maxParalysisTime.IsComplete)
                    {
                        this.m_paralysisHitCount = 0;
                    };
                };
            };
            this.m_cancelEffectDelay.tick();
            this.m_cancelEffectDelay2.tick();
            if (this.m_cancelEffectDelay2.IsComplete)
            {
                this.m_cancelEffectDelay2.reset();
                this.m_cancelEffectCount = 0;
            };
            this.m_knockbackStacked = false;
        }

        public function createTimer(interval:int, repeats:int, func:Function, options:Object=null):void
        {
            var i:*;
            var defaults:Object = {
                "persistent":false,
                "hitStunPause":true
            };
            if ((!(options)))
            {
                options = {};
            };
            for (i in defaults)
            {
                if (options[i] === undefined)
                {
                    options[i] = defaults[i];
                };
            };
            if (options.hitStunPause)
            {
                options.pauseCondition = this.timerHitStunPauseCallback;
            };
            this.m_timers.push(new IntervalTimer(interval, repeats, func, options));
        }

        public function flushTimers(flushPersistent:Boolean=false):void
        {
            var i:int;
            while (i < this.m_timers.length)
            {
                if (((flushPersistent) || (!(this.m_timers[i].Options.persistent))))
                {
                    this.m_timers[i].disableProcess();
                    this.m_timers.splice(i--, 1);
                };
                i++;
            };
        }

        private function timerHitStunPauseCallback():Boolean
        {
            return (this.m_actionShot);
        }

        private function tickTimers():void
        {
            var i:int;
            var batchTimers:Vector.<IntervalTimer>;
            var index:int;
            if (this.m_timers.length)
            {
                batchTimers = new Vector.<IntervalTimer>();
                i = 0;
                while (i < this.m_timers.length)
                {
                    this.m_timers[i].tick();
                    if (this.m_timers[i].ReadyToProcess)
                    {
                        batchTimers.push(this.m_timers[i]);
                    };
                    i++;
                };
                i = 0;
                while (i < batchTimers.length)
                {
                    batchTimers[i].process();
                    if ((!(batchTimers[i].Active)))
                    {
                        index = this.m_timers.indexOf(batchTimers[i]);
                        if (index >= 0)
                        {
                            this.m_timers.splice(index, 1);
                        };
                    };
                    i++;
                };
            };
        }

        public function destroyTimer(func:Function):void
        {
            var i:int;
            while (i < this.m_timers.length)
            {
                if (this.m_timers[i].Callback == func)
                {
                    this.m_timers[i].disableProcess();
                    this.m_timers.splice(i--, 1);
                };
                i++;
            };
        }

        public function takeDamage(attackObj:AttackDamage, collisionHitBox:HitBoxSprite=null):Boolean
        {
            return (false);
        }

        public function attackCollisionTest():void
        {
        }

        public function attackCollisionTestsCompleted():void
        {
            this.m_skipAttackCollisionTests = false;
            this.m_skipAttackProcessing = false;
            this.m_attackCollisionTestsPreProcessed = false;
            this.m_attack.HasClanked = false;
        }

        public function applyKnockback(knockback:Number, angle:Number):void
        {
            var speed:Number = Utils.calculateVelocity(knockback);
            this.applyKnockbackSpeed(speed, angle);
        }

        public function applyKnockbackSpeed(speed:Number, angle:Number):void
        {
            this.m_xKnockback = Utils.calculateXSpeed(speed, angle);
            this.m_yKnockback = -(Utils.calculateYSpeed(speed, angle));
            this.resetKnockbackDecay();
        }

        protected function decel_knockback():void
        {
            if (((this.m_xKnockback == 0) && (this.m_yKnockback == 0)))
            {
                return;
            };
            var wasRight:Boolean = (this.m_xKnockback > 0);
            var wasUp:Boolean = (this.m_yKnockback < 0);
            if (this.m_xKnockback != 0)
            {
                this.m_xKnockback = (this.m_xKnockback + this.m_xKnockbackDecay);
            };
            if (this.m_yKnockback != 0)
            {
                this.m_yKnockback = (this.m_yKnockback + this.m_yKnockbackDecay);
            };
            if (((((wasRight) && (this.m_xKnockback < 0)) || ((!(wasRight)) && (this.m_xKnockback > 0))) || (Utils.fastAbs(this.m_xKnockback) < 0.0001)))
            {
                this.m_xKnockback = 0;
            };
            if (((((wasUp) && (this.m_yKnockback > 0)) || ((!(wasUp)) && (this.m_yKnockback < 0))) || (Utils.fastAbs(this.m_yKnockback) < 0.0001)))
            {
                this.m_yKnockback = 0;
            };
        }

        protected function m_forces():void
        {
            if (((!(this.isHitStunOrParalysis())) && (this.inKnockback())))
            {
                if (((this.m_collision.ground) && (this.m_yKnockback > 0)))
                {
                    this.m_yKnockback = 0;
                };
                this.m_attemptToMove(this.m_xKnockback, 0);
                this.m_attemptToMove(0, this.m_yKnockback);
                this.decel_knockback();
                if (Main.FRAMERATE == 30)
                {
                    this.m_attemptToMove(this.m_xKnockback, 0);
                    this.m_attemptToMove(0, this.m_yKnockback);
                    this.decel_knockback();
                };
            };
        }


    }
}//package com.mcleodgaming.ssf2.engine

