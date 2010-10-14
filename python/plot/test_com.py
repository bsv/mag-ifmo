from com import *

com_reader = ComReader('/dev/ttyUSB0', 19200)

while(1):
    ch = com_reader.read()
    if ch != 0x6C:
        print "%x" % ch
