from per_net.per_net import *
import math
import sys

x_tmp = xrange(-10, 10, 2)

x = [[x_tmp[i]/10.0] for i in xrange(len(x_tmp))]

t = [[math.sin(x[i][0])] for i in xrange(len(x_tmp))]

print x
print t
a_in = float(sys.argv[2])
n_in = float(sys.argv[3])
c_in = int(sys.argv[1])

p = per_net([1, 5, 2,  1])
epoch = p.per_train(x, t, c_in, n = n_in, alph = a_in)

x_tmp = xrange(-10, 10, 5)
test_x = [[x_tmp[i]/10.0] for i in xrange(len(x_tmp))]
print test_x

if(epoch < 999):
    for i in xrange(len(test_x)):
        print (p.sim_net(test_x[i]))[p.count_layer -1]
    
