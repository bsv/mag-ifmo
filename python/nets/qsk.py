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
from bpnn import NN


N = 1000
aa = [rand(0, 4) for x in range(N)]
bb = [rand(0, 4) for x in range(N)]

a1 = [2*x-3 for x in aa]
b1 = [2*x-3 for x in bb]

Fd = 2400 # символьная скорость
Fc = 1800 # несущая
FsFd = 4  # количество отсчетов на один символ
Fs = Fd * FsFd # частота дискретизации

# Дублируем каждый отсчет FsFd раз
a1 = repeat(a1, FsFd)
b1 = repeat(b1, FsFd)

# Формируем аналоговый сигнал
t = [i/Fs for i in range(N*FsFd)] # дискретное время

s_qask16 = []

for i in xrange(N*FsFd):
    s_qask16 += [a1[i]*cos(2*pi*Fc*t[i]) + b1[i]*sin(2*pi*Fc*t[i])]

# add noise - не следует воспринимать за шум, просто изменение данных
noise = []
for i in xrange(len(s_qask16)):
    noise += [float(s_qask16[i] + random.gauss(3,1))]

subplot(211)
plot(t[:200], s_qask16[:200])

subplot(212)
plot(t[:200], noise[:200])

#show()

# Демодуляция

y1 = []
y2 = []

for i in xrange(N*FsFd):
    y1 += [s_qask16[i] * cos(2*pi*Fc*t[i]) * 2] 
    y2 += [s_qask16[i] * sin(2*pi*Fc*t[i]) * 2]

(b, a) = butter(2, Fd*2/Fs, btype = 'low')
fy1 = lfilter(b, a, y1)
fy2 = lfilter(b, a, y2)

fy1 = fy1[FsFd-1:len(fy1):FsFd] 
fy2 = fy2[FsFd-1:len(fy2):FsFd]

aerr = 0
berr = 0

for i in xrange(len(fy1)):

    fy1[i] = round((fy1[i]+3)/2)
    fy2[i] = round((fy2[i]+3)/2)

    if (fy1[i] < 0):
        fy1[i] = 0
    elif (fy1[i] > 3):
        fy1[i] = 3

    if (fy2[i] < 0):
        fy2[i] = 0
    elif (fy2[i] > 3):
        fy2[i] = 3
    
    if(fy1[i] != aa[i]):
        #print i, '.', fy1[i], aa[i]
        aerr += 1
    if(fy2[i] != bb[i]):
        berr += 1

print 'A error = ', aerr/len(aa)
print 'B error = ', berr/len(bb)

subplot(211)
plot(aa[:100])

subplot(212)
plot(y1[:100])

#show()

# Нейронная сеть

# Тренировочные данные

npack = FsFd
sample = s_qask16
target = aa

print "SAMPLE = ", len(sample)

#x = [sample[i-npack+1:i+1] for i in range(npack-1, len(sample))]
#test = [[target[i]] for i in xrange(npack-1, len(target))]
x = [sample[i-npack:i] for i in range(npack, len(sample) + 1, npack)]
test = [[target[i]] for i in xrange(len(target))]

nlearn = 100 # количество обучающих выборок

print "len X = ", len(x)
print 'len test = ', len(test)

pnet = per_net([npack, 5, 1], elman = 1)
epoch = pnet.per_train(x[:nlearn], test[:nlearn], 100, 0.001, 0.1)

#
naerr = 0

out = []
for i in xrange(len(x)):
    val = pnet.sim_net(x[i])[pnet.count_layer - 1][0]
    out += [round(val)]
    test_val = target[i]
    if (round(val) != test_val):
       # print i, '. ', 'val = ', val, ', test_val = ', test_val
        naerr += 1

    #if i < 100:
    #    print i, '. ', val, target[npack - 1 + i]

print 'Net error = ', naerr/len(x)

print len(s_qask16)
print len(out)

scale = 200
t_plot = [i for i in xrange(len(s_qask16))]

subplot(311)
plot(t_plot[:scale], s_qask16[:scale])

out = repeat(out, npack)
subplot(312)
plot(t_plot[:scale], out[:scale])
axis([0, t_plot[scale-1], -0.2, 3.2])

ideal = repeat(aa, FsFd)

subplot(313)
plot(t_plot[:scale], ideal[:scale])
axis([0, t_plot[scale-1], -0.2, 3.2])

show()



