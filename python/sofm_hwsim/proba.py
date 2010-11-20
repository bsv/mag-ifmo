# -*- coding: utf-8 -*-

# Параметры командной строки
# 1. - имя файла с даными 
# 2. - количество входов сети


from pylab import *
from sofm_net import *
import csv

def read_file(file_name):
    
    data_file = open(file_name, 'rb')
    data_reader = csv.reader(data_file, delimiter = ',')
    x = []
    for row in data_reader:
        line = []
        for cell in row:
            line += [int(float(cell))]
        x += [line]
    
    data_file.close()

    return x


data = read_file(sys.argv[1])

x = []
y = []
for cur in data:
    x += [cur[0]]
    y += [cur[1]]

num_in = int(sys.argv[2])
num_neuron = 2

# Формируем входные данные сети
net_data_in = []

ctr = 0
slice_data = []
for cur in y:
    if (ctr < num_in):
        slice_data += [cur]
        ctr += 1
    else:
        net_data_in += [slice_data]
        ctr = 0;
        slice_data = []

# Создаем сеть и обучаем её
p = sofm_net([num_in, num_neuron])
p.net_train(net_data_in)

# Формируем выходные данные
net_data_out = []
for cur in net_data_in:
    #x_c = p.norm_vec(x_cur)
    net_data_out += [p.sim_net(cur)]

# Строим графики
subplot(211)
plot(x, y)

subplot(212)
plot(range(size(net_data_out)), net_data_out)
axis([0, size(net_data_out)-1, -0.2, 1.2])

show()
