# -*- coding: utf-8 -*-

# Параметры командной строки
# 1. - имя файла с даными 
# 2. - количество входов сети
# 3. - количество циклов обученя

from pylab import *
from sofm_hwsim.sofm_net import *
from func import *
from scipy.signal import butter, lfilter
    
data = readCsvFile(sys.argv[1])

x = []
y = []
for cur in data:
    x += [cur[0]]
    y += [cur[1]]

# Переносим значения y в зиапазон 0 - 255
y = normVec(y, 2**14)

num_in = int(sys.argv[2])
num_neuron = 2
num_epoch = int(sys.argv[3])

net_data_in = vec2mas(y, num_in)

# Создаем сеть и обучаем её
p = sofm_net([num_in, num_neuron])
p.net_train(net_data_in, num_epoch)
print p.w

for i in xrange(len(p.w)):
    memForm('w' + str(i), p.w[i], num_in)

# Формируем выходные данные
net_data_out = p.masOut(net_data_in)

# Строим графики
subplot(311)
plot(x, y)

subplot(312)
plot(range(size(net_data_out)), net_data_out)
axis([0, size(net_data_out)-1, min(net_data_out) - 0.2, max(net_data_out) + 0.2])

subplot(313)
(b, a) = butter(5, 0.2, btype = 'low')
bout = lfilter(b, a, y)
plot(x, bout)

level = (max(bout)- min(bout))/2
step  = 250
bit_data = sig2bit(y, level, step)
print bit_data

show()
