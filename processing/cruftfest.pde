/**
 * Cruftfest Project 2015
 * Kids' Photo Booth
 *
 * Victor Loux <v.loux@qmul.ac.uk>
 */

// Import the Serial library for communicating with the Arduino
import processing.serial.*;

// Import the OpenCV and video processing libraries
// OpenCV: https://github.com/atduskgreg/opencv-processing
import gab.opencv.*;

// Video library not installed by default in Processing 3,
// has to be installed from the extensions manager
import processing.video.*;

// The OpenCV library returns Rectangle objects
import java.awt.Rectangle;

// Objects that will hold the above imported classes
Serial device;
Capture video;
OpenCV opencv;

// Default colours
color blue   = #34A5D6;
color red    = #D62414;
color green  = #4AD65F;
color yellow = #D6B400;

// Store all effects in an array of objects (see Effect class)
// this will allow us to manipulate each effect with different
// properties, without having to deal with arrays
Effect[] effects = new Effect[13];

// Each index in that array above will correspond to an effect.
// These constants are for convenience, to know which index
// corresponds to which colour
final int GREEN_CIRCLE = 0, // GREEN_CIRCLE
          RED_SQUARE      = 1, // RED_SQUARE
          YELLOW_TRIANGLE = 2, // YELLOW_TRIANGLE
          SCREENSHOT      = 3, // DRAWER
          UP              = 4, // UP
          DOWN            = 5, // DOWN
          PEARLS          = 6, // ROLLER
          ROLL            = 7, // GUITAR
          BLUE_FILTER     = 8, // PIANO_BLUE
          RED_FILTER      = 9, // PIANO_RED
          GREEN_FILTER    = 10, // PIANO_GREEN
          YELLOW_FILTER   = 11, // PIANO_YELLOW
          FLIP            = 12; // BOOK

// Speed of the fade in / out transitions
// (a transition goes from 0 to 255, this is the incrementation
// amount at every frame)
final float transitionSpeed = 15;

// hold the faces detection
Rectangle[] faces;

// see in setup() for more details about these
float xShift, yShift;

// Array of "pearls", for the roller effect
Pearl[] pearls = new Pearl[300];


void setup() {
  // uncomment size() to display in a window
  // or use fullScreen with the id of a monitor to present full screen
  // on an external monitor

  //size(720, 450);
  fullScreen(2);

  // This will shift all shapes
  // to make them start from the top-left of the window
  // as we translate the screen by that amount for some features
  xShift = -width / 2.0;
  yShift = -height / 2.0;

  // Initialise all effects
  for(int i = 0; i < effects.length; ++i) {
    effects[i] = new Effect(i);
  }

  // Set up pearls, for the roller effect
  for(int i = 0; i < pearls.length; ++i) {
    pearls[i] = new Pearl();
  }

  // Start the capture of the video
  // add the name of the external camera as the last parameter
  video = new Capture(this, 720, 450, "USB Camera #2");

  // Initialise OpenCV and the face recognition cascade
  opencv = new OpenCV(this, 720, 450);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  // Try to initialise the serial connection
  try {
    // println(Serial.list());
    String portName = Serial.list()[2];
    device = new Serial(this, portName, 115200);
    device.bufferUntil(10); // 10 = ASCII code for line feed
  } catch(Exception e) {
    e.printStackTrace();
    // do not exit the program if there's an error - it can still be used
    // with the keyboard if the device isn't found / not working
  }

  video.start();
}

void draw() {
  background(210);
  // Translate everything to start from the middle of the screen
  // We'll then draw everything minus half the width and half the height
  // The reason for this is that some effects (scale, rotate, shear...) normally
  // start from the top-left corner, instead of the middle of the sketch
  translate(width / 2, height / 2);


  // Reset styles
  noTint();
  noStroke();


  // Update every effect. This will change the "timer" for
  // fading in/out any effect that has just been pressed or released
  for(int i = 0; i < 13; ++i) {
    effects[i].updateTimer();
  }

  // If we're doing a flip, we're scaling the image again
  // using -1 instead of 1, to reverse it
  // The timer will ensure it's animated
  if(effects[FLIP].enabled) {
    scale(effects[FLIP].timer(1.0, -1.0), 1);
  }

  // DO A BARREL ROLL
  if(effects[ROLL].enabled) {
    rotate(effects[ROLL].timer(0, PI * 2));
  }

  // We draw an initial image, this will be used for filter effects
  // as a background to the overlay (otherwise it starts on the background grey)
  if(effects[BLUE_FILTER].enabled || effects[RED_FILTER].enabled || effects[GREEN_FILTER].enabled || effects[YELLOW_FILTER].enabled) {
    image(video, xShift, yShift);
  }

  // Colour filter effects (piano keys)
  // we tint the image with the given colour,
  // with an alpha value for fading in/out
  if(effects[BLUE_FILTER].enabled) {
    tint(blue, effects[BLUE_FILTER].timer(0, 255));
  }
  if(effects[RED_FILTER].enabled) {
    tint(red, effects[RED_FILTER].timer(0, 255));
  }
  if(effects[GREEN_FILTER].enabled) {
    tint(green, effects[GREEN_FILTER].timer(0, 255));
  }
  if(effects[YELLOW_FILTER].enabled) {
    tint(yellow, effects[YELLOW_FILTER].timer(0, 255));
  }

  // Output the actual image from the camera
  image(video, xShift, yShift);

  // anything below will be overlaid on top of the camera image

  // Horizontal mirror/kaleidoscope
  if(effects[UP].enabled) {
    // Invert the image
    scale(-1, 1);

    // Copy the original video at half the size
    copy(video,
          0, 0,
          (int)effects[UP].timer(-width / 4, video.width / 2), video.height,
          (int)xShift, (int)yShift,
          (int)effects[UP].timer(-width / 4, video.width / 2), video.height);
  }

  // Vertical mirror/kaleidoscope
  if(effects[DOWN].enabled) {
    // Invert the image
    scale(1, -1);

    // Copy the original video at half the size
    copy(video,
          0, 0,
          video.width, (int)effects[DOWN].timer(-height / 4, video.height / 2),
          (int)xShift, (int)yShift,
          video.width, (int)effects[DOWN].timer(-height / 4, video.height / 2));
  }

  // if any of the geometric buttons is pressed, we will do face detection
  if(effects[GREEN_CIRCLE].enabled || effects[RED_SQUARE].enabled || effects[YELLOW_TRIANGLE].enabled) {
    noFill();
    strokeWeight(6);

    // get OpenCV to load that image and process faces
    // we do that here as it's quite resource-intensive
    // and really slows down the sketch when it's not actually used
    opencv.loadImage(video);
    faces = opencv.detect();

    // For each face detected, draw one (or several) shapes
    // base code from the FaceDetect example of the processing-opencv library
    for (int i = 0; i < faces.length; i++) {
      if(effects[GREEN_CIRCLE].enabled) {
        stroke(green, effects[GREEN_CIRCLE].timer(0, 255)); // change stroke to green + alpha for fading in
        ellipse(faces[i].x + (faces[i].width / 2) + xShift,  // x
                faces[i].y + (faces[i].height / 2) + yShift, // y
                faces[i].width + 20,                // w
                faces[i].height + 20);              // h
      }

      if(effects[RED_SQUARE].enabled) {
        stroke(red, effects[RED_SQUARE].timer(0, 255)); // change stroke to red + alpha for fading in
        rect(faces[i].x + xShift,
             faces[i].y + yShift,
             faces[i].width,
             faces[i].height);
      }
      if(effects[YELLOW_TRIANGLE].enabled) {
        stroke(yellow, effects[YELLOW_TRIANGLE].timer(0, 255)); // change stroke to yellow + alpha for fading in
        triangle(faces[i].x + faces[i].width / 2 + xShift,   // x1
                 faces[i].y - 50 + yShift,                   // y1
                 faces[i].x + faces[i].width + 30 + xShift,  // x2
                 faces[i].y + faces[i].height + 10 + yShift, // y2
                 faces[i].x - 30 + xShift,                   // x3
                 faces[i].y + faces[i].height + 10 + yShift);// y3
      }
    }
  }

  // When the roller has been turned, show the pearls
  if(effects[PEARLS].enabled) {
    for (int i = 0; i < pearls.length; ++i) {
      pearls[i].draw();
    }
  }

  // Lifting the drawer takes a screenshot
  // It only happens when it's raised, so do not do anything
  // while it is fading out
  if(effects[SCREENSHOT].enabled && !effects[SCREENSHOT].fadeOut) {
    // Immediately when the internal effect's timer equals 1 (= just ran)
    // then save a picture to the "shots" folder with a unique name
    if(!effects[SCREENSHOT].pictureTaken) {
      println("!!!!");
      save("shots/image_"+ year() + "-" + month() + "-" + day() + "-" + hour() + minute() + second() + frameCount +".jpg");
      effects[SCREENSHOT].pictureTaken = true;
    }

    // Make an overlay that goes progressively from full white to transparent
    // to give a flash effect
    fill(255, effects[SCREENSHOT].timer(255, 0));
    noStroke();
    rect(xShift, yShift, width, height);
  }

  // Uncomment this to see debug info
  // printDebug();
}

/**
 * This is used for debugging with the keyboard
 * Shows all the effects and whether they're on or not
 */
void printDebug() {
  textSize(8);
  fill(effects[GREEN_CIRCLE].enabled ? green : red);
  text("green_circle", 15, 20);

  fill(effects[RED_SQUARE].enabled ? green : red);
  text("red_square", 15, 30);

  fill(effects[YELLOW_TRIANGLE].enabled ? green : red);
  text("yellow_triangle", 15, 40);

  fill(effects[SCREENSHOT].enabled ? green : red);
  text("screenshot", 15, 50);

  fill(effects[UP].enabled ? green : red);
  text("up", 15, 60);

  fill(effects[DOWN].enabled ? green : red);
  text("down", 15, 70);

  fill(effects[PEARLS].enabled ? green : red);
  text("pearls", 15, 80);

  fill(effects[ROLL].enabled ? green : red);
  text("roll", 15, 90);

  fill(effects[BLUE_FILTER].enabled ? green : red);
  text("blue_filter", 15, 100);

  fill(effects[RED_FILTER].enabled ? green : red);
  text("red_filter", 15, 110);

  fill(effects[GREEN_FILTER].enabled ? green : red);
  text("green_filter", 15, 120);

  fill(effects[YELLOW_FILTER].enabled ? green : red);
  text("yellow_filter", 15, 130);

  fill(effects[FLIP].enabled ? green : red);
  text("flip", 15, 140);

}

/**
 * Updates the camera every time a frame is received
 * @param  {Capture} c  The Capture object
 */
void captureEvent(Capture c) {
  c.read();
}

/**
 * Acts when receiving a serial event
 * @param  {Serial} p  The Serial object
 */
void serialEvent(Serial p) {
  try {
    // Store the message in a variable.
    // I trim() it as it may contain a line feed at the end, which will not work
    String message = trim(p.readString());

    // Sometimes the message is null and this breaks updateEffects(),
    // so we have to cancel it here
    if(message == null) return;

    // If all is fine, process that message
    updateEffects(message);
  } catch (Exception e) {
    e.printStackTrace();
  }
}

/**
 * Update the effects variable, based on the message
 * received from the Serial or keyboard
 *
 * @param  {String} lastMessage  The message that's been sent
 */
void updateEffects(String lastMessage) {
  // check if the last 3 characters of the message are "_ON"
  // we will use this to define the state (true or false)
  boolean newState = lastMessage.substring(lastMessage.length() - 3, lastMessage.length()).equals("_ON");

  // Check which messages was actually sent
  // we remove either the last 3 (_ON) or 4 (_OFF) characters of the message for this
  String requestedEffect = lastMessage.substring(0, lastMessage.length() - (newState ? 3 : 4));

  int effectConstant = 0;

  // There's no switch for strings so we have to use a massive if-elseif chain
  if(requestedEffect.equals("GREEN_CIRCLE")) {
      effectConstant = GREEN_CIRCLE;
  } else if(requestedEffect.equals("RED_SQUARE")) {
      effectConstant = RED_SQUARE;
  } else if(requestedEffect.equals("YELLOW_TRIANGLE")) {
      effectConstant = YELLOW_TRIANGLE;
  } else if(requestedEffect.equals("DRAWER")) {
      effectConstant = SCREENSHOT;
  } else if(requestedEffect.equals("UP")) {
      effectConstant = UP;
  } else if(requestedEffect.equals("DOWN")) {
      effectConstant = DOWN;
  } else if(requestedEffect.equals("ROLLER")) {
      effectConstant = PEARLS;
  } else if(requestedEffect.equals("GUITAR")) {
      effectConstant = ROLL;
  } else if(requestedEffect.equals("PIANO_BLUE")) {
      effectConstant = BLUE_FILTER;
  } else if(requestedEffect.equals("PIANO_RED")) {
      effectConstant = RED_FILTER;
  } else if(requestedEffect.equals("PIANO_GREEN")) {
      effectConstant = GREEN_FILTER;
  } else if(requestedEffect.equals("PIANO_YELLOW")) {
      effectConstant = YELLOW_FILTER;
  } else { // BOOK
      effectConstant = FLIP;
  }

  if(newState) {
    effects[effectConstant].start();
  } else {
    effects[effectConstant].stop();
  }
}


/**
 * ===============================================================
 * ===============================================================
 *
 * All the code below is used for debug - it simulates the device
 * from a keyboard - keys are QWERTYUIOP ASDFG
 * Every time a key is pressed or released, it sends the
 * same code that the device would send by serial
 */

void keyPressed() { actOnKey(key, true); }
void keyReleased() { actOnKey(key, false); }

/**
 * Do an action on key press or release. Split in here to
 * avoid code repetition in keyPressed() and keyReleased().
 *
 * @param  char    keyp          The key code that has been pressed
 * @param  boolean pressed       true if pressed, false if released
 */
void actOnKey(char keyp, boolean pressed) {
  String lastMessage;

  //println(keyp);
  switch (keyp) {
    case 'q':
      lastMessage = "GREEN_CIRCLE";
      break;

    case 'w':
      lastMessage = "RED_SQUARE";
      break;

    case 'e':
      lastMessage = "YELLOW_TRIANGLE";
      break;

    case 'r':
      lastMessage = "DRAWER";
      break;

    case 't':
      lastMessage = "UP";
      break;

    case 'y':
      lastMessage = "DOWN";
      break;

    case 'u':
      lastMessage = "ROLLER";
      break;

    case 'i':
      lastMessage = "GUITAR";
      break;

    case 'a':
      lastMessage = "PIANO_BLUE";
      break;

    case 's':
      lastMessage = "PIANO_RED";
      break;

    case 'd':
      lastMessage = "PIANO_GREEN";
      break;

    case 'f':
      lastMessage = "PIANO_YELLOW";
      break;

    case 'g':
      lastMessage = "BOOK";
      break;

    default:
      return;
  }

  lastMessage += pressed ? "_ON" : "_OFF";
  updateEffects(lastMessage);
}