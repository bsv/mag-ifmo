# -*- coding: utf-8 -*-

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

def norm_vec(vec, max_val):
    
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
def mem_form(name, weights, num_in):
    f_out = open(name + '.v', 'w')
    
    module_str  = """module %(name)s (
    input wire [%(addr_size)d:0] addr,
    output wire [%(data_size)d:0] out_weight
);
    wire [%(data_size)d:0] w [%(num_w)d:0]
    
    assign out_weight = w[addr];\n""" % {'name': name, 'addr_size': bit_size(num_in - 1), 'data_size': 8, 'num_w': num_in - 1}

    for i in xrange(len(weights)):
        module_str += "    assign w[%(ind)d] = %(w)d;\n" % {'ind': i, 'w':weights[i]}

    module_str += "endmodule \n"

    f_out.write(module_str)
    f_out.close()
