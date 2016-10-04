
class Effect {
  private int id;
  public boolean enabled;
  public boolean fadeOut;
  public int timer;
  private int startedAtFrame;
  public boolean pictureTaken; // used for ensuring screenshots are taken once only

  /**
   * Constructor - simply create the effect
   * we remember its index in the effects[] array
   * so we can know from within the class what effect it holds
   */
  Effect(int id)
  {
    this.id = id;
  }

  /**
   * Fired when a button is pressed
   * mark as enabled, which will start the fade in
   * in .update()
   */
  public void start()
  {
    this.enabled = true;
    this.timer = 1;
    this.startedAtFrame = frameCount;
  }

  /**
   * Fired when a button is released
   * start the fading out, which will happen in .update()
   * when the fading out is finished then .update() will
   * actually mark the effect as disabled/done
   */
  public void stop()
  {
    // the pager/roller for the pearl effect
    // does not work correctly, it generally gets stuck
    // on "ON" after it has been rolled, or does not always get
    // triggered when off. To work around this, instead of the
    // usual fade in/out, we trigger it for 1.5 seconds after every
    // state change (whether it's on or off)
    if(this.id == PEARLS) {
      this.start();
      return;
    }

    this.fadeOut = true;
    this.pictureTaken = false; // for screenshot
    this.updateTimer();
  }

  public void updateTimer()
  {
    // for pearls, for the reason mention above,
    // we automatically start fading out after 40 frames
    // (the rest of the code will disable it)
    if(this.id == PEARLS && this.enabled) {
      if(frameCount - this.startedAtFrame >= 40) {
        this.fadeOut = true;
      }
    }
    
    // immediately disable screenshot once it's been released
    if(this.id == SCREENSHOT && this.fadeOut) {
        this.fadeOut = false;
        this.enabled = false;
    }

    // If it has been stopped and we started fading it out,
    // then put the timer in the opposite direction
    // once it reaches 0 then actually disable the effect
    // and reset the fadeout variable
    if(this.fadeOut) {
      timer -= transitionSpeed;
      if(timer <= 0) {
        this.fadeOut = false;
        this.enabled = false;
      }
    } else if(this.enabled && timer <= 255) {
      // If we are fading in and not at peak (on) yet,
      // then continue to increase the timer
      timer += transitionSpeed;
    }
  }


  /**
   * This will give a value to be used in the effects.
   * It is related to the timer; when the effect is fully on
   * then it will return high, if it is still fading in or out
   * then it will return a mapped value between low and high.
   *
   * Can be used for alpha values, rotation, scaling values…
   *
   * @param  float low  The lower end, should be the value when effect is disabled
   * @param  float high The higher end, should be when the effect is fully on
   * @return float
   */
  public float timer(float low, float high)
  {
    return map(this.timer, 0, 255, low, high);
  }
}