# -*- coding: utf-8 -*-

# Параметры командной строки
# 1. - имя файла с исходной битовой последовательностью 
# 2. - имя файла с аналоговым сигналом

from __future__ import division

import sys

from pylab import *
from scipy.signal import butter, lfilter

def readFile(file_name):
    data_file = open(file_name, 'rb')

    x = []
    for row  in data_file.readlines():
        x += [float(row)]
                                                
    data_file.close()

    return x

def getBitSeq(data, Fd, Fs):
    
    bit_seq = []
    posedge = 0
    ctr = 0
    for i in xrange(1, len(data)):
        if (data[i-1] < 0.5) & (data[i] >= 0.5):
            posedge = 1
            ctr = 0
        elif (data[i-1] >= 0.5) & (data[i] < 0.5):
            posedge = 0
            ctr = 0

        if (ctr % round(Fs/Fd) == 0):
            bit_seq += [posedge]
        
        ctr = ctr + 1;
    return bit_seq

bit = readFile(sys.argv[1])
data = readFile(sys.argv[2])

#print bit[:10]
#print data[:10]

Fd = 1 # символьная скорость
Fs = 2 # частота дискретизации

# Обработка данных фильтром нижних частот
(b, a) = butter(5, Fd/Fs/4, btype = 'low')
bout = data#lfilter(b, a, data)

scale = 1000

subplot(211)
plot(data[:scale])

subplot(212)
plot(bout[:scale])

#show()

bit_seq = getBitSeq(data, Fd, Fs)
bit_seq = [0] + bit_seq

print "Длина выделенной последовательности: ", len(bit_seq)

err = 0
for i in xrange(len(bit_seq)):
    if(bit_seq[i] != bit[i]):
        err += 1
        print i, " | ", bit_seq[i], " != ", bit[i]

print "Количество ошибок равно = ", err
