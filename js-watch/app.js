// This is essentially a mixture of the basic examples
// of the socket.io docs, for real-time Node to browser communication,
// with the examples of Chokidar, for real-time watching of docs.
// Not claiming I've made anything new here, this is mostly
// for the demo day and not really part of the project.

var app = require('http').createServer(handler),
    io = require('socket.io')(app),
    fs = require('fs'),
    path = require("path"),
    chokidar = require('chokidar'),
    static = require('node-static');

// change to the path where shots are located
var pathToWatch = '/Users/DeadPx/Documents/Processing/cruftfest/shots/';
var files = new static.Server(pathToWatch);

app.listen(8080);

function handler (req, res) {
  if(req.url == '/') {
    fs.readFile(__dirname + '/index.html',
    function (err, data) {
      if (err) {
        res.writeHead(500);
        return res.end('Error loading index.html');
      }

      res.writeHead(200);
      res.end(data);
    });
  } else {
    req.addListener('end', function () {
      files.serve(req, res);
    }).resume();
  }
}

io.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });

  // List all already existing files on startup
  fs.readdir(pathToWatch, function (err, files) {
      if (err) {
          throw err;
      }

      files.map(function (file) {
          return path.join(pathToWatch, file);
      }).filter(function (file) {
          return fs.statSync(file).isFile();
      }).forEach(function (file) {
        socket.emit('file', path.basename(file));
          // console.log("%s (%s)", file, path.extname(file));
      });
  });
});

var watcher = chokidar.watch(pathToWatch, {ignored: /^\./, persistent: true});

watcher
  .on('add', function(file) {
    console.log('File', file, 'has been added');
    io.emit('file', path.basename(file));
  });
  // .on('change', function(file) {
  //   console.log('File', file, 'has been changed');
  //   io.emit('file', path.basename(file));
  // })
  // .on('unlink', function(file) {
  //   console.log('File', file, 'has been removed');
  //   io.emit('file', path.basename(file));
  // })
  // .on('error', function(error) {
  //   console.error('Error happened', error);
  // });
