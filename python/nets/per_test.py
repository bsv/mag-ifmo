from per_net.per_net import *
import sys

x = [[0, 0, 0, 0],
     [0, 0, 0, 1],
     [0, 0, 1, 1],
     [0, 1, 1, 1],
     [1, 1, 1, 1]]
t = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
     [1, 0, 0, 0, 0, 0, 0, 0, 0],
     [0, 1, 0, 0, 0, 0, 0, 0, 0],
     [0, 0, 1, 0, 0, 0, 0, 0, 0],
     [0, 0, 0, 1, 0, 0, 0, 0, 0]]

a_in = float(sys.argv[2])
n_in = float(sys.argv[3])
c_in = int(sys.argv[1])

p = per_net([4, 20, 9])
epoch = p.per_train(x, t, c_in, n = n_in, alph = a_in)

test_x = [[1, 1, 1, 0]]

if(epoch < 999):
    for i in xrange(len(test_x)):
        print (p.sim_net(test_x[i]))[p.count_layer -1]
    
