# -*- coding: utf-8 -*-

from per_net.per_net import *
import random

def addNoise(signal, m, s):
    
    noise = []
    for i in xrange(len(signal)):
        noise += [float(signal[i] + random.gauss(m, s))]
    return noise

def netdem(source, target, ndiff, npack = 10, nlearn = 500, epoch = 100):
    
    diffx = []

    for i in xrange(len(source)):
        val = 0
        for j in xrange(ndiff):
            if(i + j < len(source)):
                val += source[i+j]
        diffx += [(val/ndiff)]

    sample = diffx

    x = [sample[i-npack:i] for i in xrange(npack, len(sample)+1, npack)]
    test = [[target[i]] for i in xrange(len(target))]

    pnet = per_net([npack, 4, 1], elman = 0)    
    epoch = pnet.per_train(x[:nlearn], test[:nlearn], epoch, 0.001, 0.01)

    return pnet, x

def repeat(x, n):
    y = []
    for cur in x:
        for i in xrange(n):
            y += [cur]
    return y

def readCsvFile(file_name):
    
    data_file = open(file_name, 'rb')

    x = []
    for row  in data_file.readlines():
        line = []
        for cell in row.split(','):
            line += [int(float(cell))]
        x += [line]
    
    data_file.close()

    return x

def normVec(vec, max_val):
    
    shift = 0
    if (min(vec) < 0):
        shift = abs(min(vec))

    norm_val = max(vec) + shift

    for i in xrange(len(vec)):
        vec[i] = int((float(vec[i] + shift)/norm_val) * max_val)
    return vec

# Определение размера адреса
bit_size = lambda max_data: 0 if max_data == 0 else bit_size(max_data >> 1) + 1
 
# Создаем модули весов(Verilog)
def memForm(name, weights, num_in):
    f_out = open(name + '.v', 'w')
    
    max_w = max(weights)

    module_str  = """module %(name)s (
    input wire [%(addr_size)d:0] addr,
    output wire [%(data_size)d:0] out_weight
);
    wire [%(data_size)d:0] w [%(num_w)d:0];
    
    assign out_weight = w[addr];\n""" % {'name': name, 'addr_size': bit_size(num_in - 1) - 1, 'data_size': bit_size(max_w) - 1, 'num_w': num_in - 1}

    for i in xrange(len(weights)):
        module_str += "    assign w[%(ind)d] = %(w)d;\n" % {'ind': i, 'w':weights[i]}

    module_str += "endmodule \n"

    f_out.write(module_str)
    f_out.close()

# Разбиваем входной вектор на группы по num элементов
def vec2mas(vec, num):
    out = []

    for i in xrange(0, len(vec), num):
            out += [vec[i:i + num]]

    # Если последняя группа не содержит num 
    # элементов, то удаляем её из последовательности 
    if(len(out[-1]) != num):
        del out[-1]

    return out

# Выделение битовой последовательности из сигнала
def sig2bit(data, level, step):
    
    bit_seq = []
    for i in range(0, len(data), step):
        if(data[i] > level):
            bit_seq += [1]
        else: 
            bit_seq += [0] 
    return bit_seq

