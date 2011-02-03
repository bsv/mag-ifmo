# -*- coding: utf-8 -*-

# Параметры командной строки

from __future__ import division
from pylab import *
from sofm_hwsim.sofm_net import *
from func import *
from scipy.signal import butter, lfilter
from random import randrange as rand
from math import *
from per_net.per_net import *

N = 1000
m = 0.65 # коэффициент модуляции
s = [rand(0, 2) for x in range(N)]

Fd = 1 # символьная скорость
Fc = 4 # несущая
FsFd = 40  # количество отсчетов на один символ
Fs = Fd * FsFd # частота дискретизации

time = [i/Fs for i in xrange(len(s)*FsFd)] # дискретное время

s_ask = []

for t in time:
    s_ask += [(1 + m*s[int(Fd*t)])*cos(2*pi*Fc*t)]

#plot(time[:200], s_ask[:200])

#show()
noise = addNoise(s_ask, 1, 0.5)

# Демодуляция
# Нейронная сеть

# Тренировочные данные

npack = 20
ndiff = 1
epoch = 1000
source = noise
target = repeat(s, int(FsFd/npack))
nlearn = 200 # количество обучающих выборок

pnet, x = netdem(source, target, ndiff, npack, nlearn, epoch)

naerr = 0

out = []
for i in xrange(len(x)):
    val = pnet.sim_net(x[i])[pnet.count_layer - 1][0]
    out += [round(val)]
    test_val = target[i]
    if (round(val) != test_val):
       # print i, '. ', 'val = ', val, ', test_val = ', test_val
        naerr += 1

print 'Net error = ', naerr/len(x)

scale = 1000

subplot(411)
plot(s_ask[:scale])

subplot(412)
plot(noise[:scale])

out = repeat(out, npack)
subplot(413)
plot(out[:scale])
axis([0, scale-1, -0.2, max(out) + 0.2])

ideal = repeat(s, FsFd)

subplot(414)
plot(ideal[:scale])
axis([0, scale-1, -0.2, max(out) + 0.2])

show()



