from per_net.per_net import *
import math
import sys

Fd = 2400 # символьная скорость
Fc = 1800 # несущая
FsFd = 4  # количество отсчетов на один символ
Fs = Fd * FsFd # частота дискретизации

t = [i/Fs for i in range(N*FsFd)] # дискретное время

x = [2*math.pi*Fc*i for i in t]

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
    
