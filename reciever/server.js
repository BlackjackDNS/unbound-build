var FS = require('fs');
var Net = require('net');
var socket = '/usr/local/etc/unbound/dnstap.sock';

var server = Net.createServer(function(c) {
  console.log('New connection');
  c.on('data', function(d) {
    console.log('Recieved ' + d.length + ' bytes');
  });
});

if(FS.existsSync(socket)) FS.unlinkSync(socket);

server.listen(socket, function() {
  console.log('Listening on ' + socket);
  // FS.chmodSync(socket, '777');
});
