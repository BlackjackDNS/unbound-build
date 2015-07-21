var FS = require('fs');
var Net = require('net');
var listen = 5354;

var server = Net.createServer(function(c) {
  console.log('New connection');
  c.on('data', function(d) {
    console.log('Recieved ' + d.length + ' bytes');

    // First pass here... Just treat the leading bits of a chunk as the length field
    console.log('Payload Length ' + d.readUInt16LE(0) + ' bytes');
  });
});

server.listen(listen, function() {
  console.log('Listening on ' + listen);
});
