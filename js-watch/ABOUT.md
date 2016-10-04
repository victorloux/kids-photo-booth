# About
This part of the project was made for demonstration purposes;
It is a node app that watches the folder where Processing's
screenshots are saved, and also runs a local webserver hosting
a simple html file (with some JS in it).

It was made a bit last-minute for the demo day,
and isn't exactly part of my project - what I've done here
was mostly copying and pasting examples of different Node modules
to make it do what I wanted, so there isn't much creative work.

# How it works
Every time a new file is added in that folder,
the server sends a message to the browser
to inform it, giving the path of the new file as an argument.
The browser will then add that file without reloading.

It uses socket.io for websockets communication between server+client.

# Usage
To install dependencies: npm install (you need to have Node.js installed)
To run: node app.js
Once it's running, go to localhost:8080
