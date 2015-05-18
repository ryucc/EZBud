#!/usr/bin/python
import bluetooth

target_name = "Jason-bt00"
target_address = None
addr = None

nearby_devices = bluetooth.discover_devices()

for bdaddr in nearby_devices:
    print bluetooth.lookup_name( bdaddr )
    if target_name == bluetooth.lookup_name( bdaddr ):
        target_address = bdaddr
        break

if target_address is not None:
    print "found target bluetooth device with address ", target_address
    sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    sock.settimeout(1)
    sock.setblocking(True)
    sock.connect((target_address,1))
    while 1:
        print " ".join("{:02x}".format(ord(c)) for c in sock.recv(16))
else:
    print "could not find target bluetooth device nearby"

