// Native cargo escape callback from build/data/character/donkeykong.ssf.
// Resource SHA-256 is recorded in docs/strength-mod.md; exported without edits.
      public function getFree() : void
      {
         --this.endTimer;
         if(this.endTimer <= 0)
         {
            this.self.destroyTimer(this.getFree);
            this.self.stancePlayFrame("end");
            return;
         }
         this.controls2 = this.theOpponent.getControls();
         if(Boolean(this.controls2.UP) && this.formerControl != "up")
         {
            this.formerControl = "up";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.DOWN) && this.formerControl != "down")
         {
            this.formerControl = "down";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.LEFT) && this.formerControl != "left")
         {
            this.formerControl = "left";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.RIGHT) && this.formerControl != "right")
         {
            this.formerControl = "right";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.BUTTON1) && this.formerControl != "button1")
         {
            this.formerControl = "button1";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.BUTTON2) && this.formerControl != "button2")
         {
            this.formerControl = "button2";
            this.endTimer -= this.mashInfluence;
         }
         else if(Boolean(this.controls2.GRAB) && this.formerControl != "grab")
         {
            this.formerControl = "grab";
            this.endTimer -= this.mashInfluence;
         }
      }
      
