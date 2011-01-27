# -*- coding: utf-8 -*-

from __future__ import division
from pylab import *
from math import *
from per_net.per_net import *
import random
from func import *
from sofm_hwsim.sofm_net import *

N = 1000

bits = [randint(2) for i in xrange(N)]
Fd = 2000 # Символьная скорость
FsFd = 40 # Количество отсчетов на один символ Fs/Fd
Fs = Fd * FsFd # Частота дискретизации
f = [4000, 8000]
time = [i/Fs for i in xrange(FsFd)] # Дискретное время для одной посылки

s_fsk = []
t = 0
for bit in bits:
    for i in xrange(FsFd): 
        s_fsk += [cos(2*pi*t*f[bit])]
        t += 1/Fs

print 'Len s_fsk = ', len(s_fsk)

#scale = 1000

#subplot(211)
#plot(range(scale), s_fsk[:scale])

#show()

# add noise - просто изменение данных не шум как таковой
noise = addNoise(s_fsk, 1, 0.5)

# Нейронная сеть

npack = 20
nlearn = 100
ndiff = 1
epoch = 2000

source = noise
target = repeat(bits, int(FsFd/npack))

pnet, x = netdem(source, target, ndiff, npack, nlearn, epoch)

#
nerr = 0

#sample = s_fsk
#x = [sample[i-npack:i] for i in xrange(npack, len(sample)+1, npack)]

out = []
for i in xrange(len(x)):
    val = pnet.sim_net(x[i])[pnet.count_layer - 1][0]
    test_val = target[i]
    out += [round(val)]
    if(round(val) != test_val):
        nerr += 1

print 'Net error = ', nerr/len(x)

scale = 1000

subplot(411)
t_plot = range(len(s_fsk))
plot(t_plot[:scale], s_fsk[:scale])

subplot(412)
plot(t_plot[:scale], noise[:scale])

bit_out = repeat(out, npack)

subplot(413)
plot(t_plot[:scale], bit_out[:scale])
axis([0, t_plot[scale-1], -0.2, 1.2])

print 'Target len = ', len(target)
print 'Bit out len = ', len(bit_out)
print 'x len = ', len(x)

bits_ideal = repeat(bits, FsFd)

print "Bit ideal = ", len(bits_ideal)

subplot(414)
plot(t_plot[:scale], bits_ideal[:scale])
axis([0, t_plot[scale-1], -0.2, max(bits_ideal) + 0.2])

show()
