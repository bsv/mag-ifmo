# -*- coding: utf-8 -*-

# Параметры командной строки

from __future__ import division
from pylab import *
from sofm_net import *
from func import *
from scipy.signal import butter, lfilter
from random import randrange as rand
from math import *

def repeat(x, n):
    y = []
    for cur in x:
        for i in xrange(n):
            y += [cur]
    return y


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

print t[:10]

s_qask16 = []

for i in xrange(N*FsFd):
    s_qask16 += [a1[i]*cos(2*pi*Fc*t[i]) + b1[i]*sin(2*pi*Fc*t[i])]

#plot(t[:200], s_qask16[:200])

# Демодуляция

y1 = []
y2 = []

for i in xrange(N*FsFd):
    y1 += [s_qask16[i] * cos(2*pi*Fc*t[i]) * 2] 
    y2 += [s_qask16[i] * sin(2*pi*Fc*t[i]) * 2]

(b, a) = butter(2, Fd*2/Fs, btype = 'low')
y1 = lfilter(b, a, y1)
y2 = lfilter(b, a, y2)

y1 = y1[3:len(y1):FsFd] 
y2 = y2[3:len(y2):FsFd]

aerr = 0
berr = 0

for i in xrange(len(y1)):

    y1[i] = round((y1[i]+3)/2)
    y2[i] = round((y2[i]+3)/2)

    if (y1[i] < 0):
        y1[i] = 0
    elif (y1[i] > 3):
        y1[i] = 3

    if (y2[i] < 0):
        y2[i] = 0
    elif (y2[i] > 3):
        y2[i] = 3
    
    if(round(y1[i]) != aa[i]):
        print y1[i], aa[i]
        aerr += 1
    if(y2[i] != bb[i]):
        berr += 1

print 'A error = ', aerr/len(aa)
print 'B error = ', berr/len(bb)

subplot(211)
plot(aa[:100])

subplot(212)
plot(y1[:100])


show()
