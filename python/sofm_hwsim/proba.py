# -*- coding: utf-8 -*-

# Параметры командной строки
# 1. - имя файла с даными 
# 2. - количество входов сети
# 3. - количество циклов обученя

from pylab import *
from sofm_net import *
from func import *
    
data = read_file(sys.argv[1])

x = []
y = []
for cur in data:
    x += [cur[0]]
    y += [cur[1]]

# Переносим значения y в зиапазон 0 - 255
y = norm_vec(y, 255)

num_in = int(sys.argv[2])
num_neuron = 2
num_epoch = int(sys.argv[3])

# Формируем входные данные сети
net_data_in = []

ctr = 0
slice_data = []
i = 0
for cur in y:
    slice_data += [cur]
    if (ctr < num_in-1):
        ctr += 1
    else:
        net_data_in += [slice_data]
        ctr = 0;
        slice_data = []

# Создаем сеть и обучаем её
p = sofm_net([num_in, num_neuron])
p.net_train(net_data_in, num_epoch)
print p.w

for i in xrange(len(p.w)):
    mem_form('w' + str(i), p.w[i], num_in)

# Формируем выходные данные
net_data_out = []
for cur in net_data_in:
    out = p.sim_net(cur)
    net_data_out += [out for i in xrange(num_in)]

# Строим графики
subplot(211)
plot(x, y)

subplot(212)
plot(range(size(net_data_out)), net_data_out)
axis([0, size(net_data_out)-1, min(net_data_out) - 0.2, max(net_data_out) + 0.2])

show()
