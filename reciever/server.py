import socket
import os, os.path
import time

if os.path.exists( "/usr/local/etc/unbound/dnstap.sock" ):
  os.remove( "/usr/local/etc/unbound/dnstap.sock" )

print "Opening socket..."
server = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )
server.bind("/usr/local/etc/unbound/dnstap.sock")

print "Listening..."
while True:
  datagram = server.recv( 1024 )
  if not datagram:
    break
  else:
    print "-" * 20
    print datagram
    if "DONE" == datagram:
      break
print "-" * 20
print "Shutting down..."
server.close()
os.remove( "/usr/local/etc/unbound/dnstap.sock" )
print "Done"
