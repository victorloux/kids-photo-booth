# The Kids' Photo Booth

CruftFest is a festival run every year in the Interactive Digital Media Techniques module at QMUL. They are students projects, where a piece of old recycled equiment (electronics or not) has to be turned into a controller for an interactive audio and/or video installation.

My starting point for this project was an educational table toy for young children, that has various buttons and tactile components that, when pressed, would say the colour, shape, number… matching the control pressed, to help with memorising it. These controls are very interesting when compared to conventional input devices such as keyboards, touch screens or even gamepads, because their shape is extremely different and varied, and the range of possible movements (pushing away, pulling, flipping a page, opening a small case…) is wider than a simple button push. I transformed the buttons on this table as controls for a photo booth with effects; each button giving a different effect.

![Toy box](_photos/toy.jpg?raw=true "box")
![Wiring inside the box](_photos/spaghetti.jpg?raw=true "spaghetti wiring")
![Watch screen](_photos/watch.jpg?raw=true "watch")

Equipment needed: an educational table with everything rewired to an Arduino; a webcam; an external monitor. Every time a button is pressed the Arduino sends a message by serial and the Processing sketch updates the sketch accordingly. If you have an external monitor you can use it to show all the photos that have been saved.

This repo might mostly be useful for people who want to reuse the various effects used in Processing.
