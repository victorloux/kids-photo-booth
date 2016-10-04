
// Assign constant names to the pins

#define PIN_GREEN_CIRCLE 13
#define PIN_RED_SQUARE 12
#define PIN_YELLOW_TRIANGLE 11
#define PIN_DRAWER 10
#define PIN_UP 9
#define PIN_DOWN 8
#define PIN_ROLLER 7
#define PIN_GUITAR 6


// Some pins are on analog but they are not really analog data,
// they are just contact switches that return non-5V values
// which won't work if connected to digital inputs, so we
// need to read them from analog inputs and check if their value is over 0
#define PIN_PIANO_BLUE A0
#define PIN_PIANO_RED A1
#define PIN_PIANO_GREEN A2
#define PIN_PIANO_YELLOW A3
#define PIN_BOOK A4

long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 50;    // the debounce time; increase if the output flickers

// Put them all in an array for easier manipulation in loops
int pins[] = { PIN_GREEN_CIRCLE, PIN_RED_SQUARE, PIN_YELLOW_TRIANGLE, PIN_DRAWER, PIN_UP, PIN_DOWN, PIN_ROLLER, PIN_GUITAR, PIN_PIANO_BLUE, PIN_PIANO_RED, PIN_PIANO_GREEN, PIN_PIANO_YELLOW, PIN_BOOK };

// Likewise, for status check and sending names over serial
int state[] = { LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW };
int lastState[] = { LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW };
String pinNames[] =  { "GREEN_CIRCLE", "RED_SQUARE", "YELLOW_TRIANGLE", "DRAWER", "UP", "DOWN", "ROLLER", "GUITAR", "PIANO_BLUE", "PIANO_RED", "PIANO_GREEN", "PIANO_YELLOW", "BOOK" };

void setup() {
  // set digital pins as inputs
  for (int i = 6; i <= 13; ++i) {
    pinMode(i, INPUT);
  }

  Serial.begin(115200);
}

void loop() {
  // Code adapted from the debounce example https://www.arduino.cc/en/Tutorial/Debounce
  for (int i = 0; i < (sizeof(pins) / sizeof(int)); i++) {
    int reading = LOW;
    if (i < 8) { // For the first digital pins
      reading = digitalRead(pins[i]);
    } else { // for the analog pins
      reading = analogRead(pins[i]) > 0;
    }

    if (reading != lastState[i]) {
      // reset the debouncing timer
      lastDebounceTime = millis();
    }

    if ((millis() - lastDebounceTime) > debounceDelay) {
      // whatever the reading is at, it's been there for longer
      // than the debounce delay, so take it as the actual current state:

      // if the button state has changed:
      if (reading != state[i]) {
        state[i] = reading;

        // Print the name of the button...
        Serial.print(pinNames[i]);

        // and its new name
        if (state[i] == HIGH) {
          Serial.println("_ON");
        } else {
          Serial.println("_OFF");
        }
      }
    }

    lastState[i] = reading;
  }

  delay(5);
}
