from com import *
import sys, time

com_reader = ComReader('/dev/ttyUSB0', 57600)

cycle = int(sys.argv[1])

f = open('data.txt', 'w')
t = time.time()
out = ''
for i in xrange(cycle):

    ch1 = com_reader.read()
    ch2 = com_reader.read()
 
    ch = (ch1 << 8) | ch2
    out += str(i) + ', ' + str(ch) + '\n'
    #print out
    
f.write(out)

print "Rate = ", cycle/(time.time() - t)
f.close()
