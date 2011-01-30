# -*- coding: utf-8 -*-

import random
import math
import copy

class per_net:
    
    w = []
    count_layer = 0
    count_input = 0
    struct_net = []
    elman_layer = []
    elman = 0

    # struct_net = [count_in, count_neuro_in layer1, ...]
    # Если elman != 0, то формируется сеть Элмана с доп слоем, 
    # число elman указывает с какого слоя подается обратная связь
    def __init__(self, struct_net = [], w = [], elman = 0): 
   
        self.count_input = struct_net[0]
        self.elman = elman
        if(elman != 0):
            self.count_input += struct_net[elman] # Добавляем к количеству входов количество выходов первого скрытого слоя 
            self.elman_layer = [0 for i in xrange(struct_net[elman])]
        self.struct_net = struct_net[1:]
        self.count_layer = len(struct_net) - 1 # -1 так как первый член списка-это 
        # количество входов, остальные члены - это количество нейронов в слоях 
        
        if (w == []):
            self.w = self.gen_wmas('rand')  
        else:
            self.w = w
                
    def gen_wmas(self, mode):
        
        struct_net = [self.count_input] + self.struct_net    
        range_seq = range(self.count_layer)
        w = [[] for j in range_seq] 
        for i in range_seq:
            # количество входов*на количество нейронов+1 ещё один вес для смещения 
            for j in xrange((struct_net[i]+1)*struct_net[i+1]):
                if (mode == 'rand'):
                    w_new = random.randrange(0, 5)/50.0
                else:
                    w_new = mode 
                w[i].append(w_new)
        return w


    def get_out(self, input, index_neuro, index_layer):
     
        sum = 0
        input = [1] + input # вход = 1 для веса смещения
        count_n_layer = len(input); # Количество входов
        for i in xrange(count_n_layer):
            sum += (self.w[index_layer])[index_neuro*count_n_layer + i] * input[i] 
        if(index_layer == self.count_layer-1):
            return sum # Выходной нейрон с линейной функцией активации
        else:
            # Скрытые слои с экспоненциальной функцией активации
            out = 1/(1 + math.exp(-sum)) 

        return out

    def sim_net(self, input):
        
        out = [[] for i in xrange(self.count_layer)]
        input_val = input + self.elman_layer

        for num_l in xrange(self.count_layer):
            for num_n in xrange(self.struct_net[num_l]):
                out_i = self.get_out(input_val, num_n, num_l)
                out[num_l].append(out_i)
            # Значения выходов предыдущего слоя являются входами последующего
            input_val = out[num_l]
            if(num_l == self.elman-1) & (self.elman != 0):
                #self.elman_layer = [1/(1 + math.exp(-i)) for i in input_val]
                self.elman_layer = copy.deepcopy(input_val)
        return out

    def sse(self, out, test):
        
        err = 0
        for i in xrange(len(out)):
            for j in xrange(len(out[i])):
                err += (test[i][j] - out[i][j])**2
        return 0.5*err

    def alg_bp(self, x, t, dw_old, lam, alph, bet,  n):

        old_elman_layer = copy.deepcopy(self.elman_layer)
        iter_out = self.sim_net(x)
        rev_count_layer = range(self.count_layer)
        rev_count_layer.reverse()
        if(dw_old == []):
            dw_old = self.gen_wmas(0)
        else:
            dw_old = copy.deepcopy(dw_old)
        d_mas = [[],[]] # d_mas[0] - содержит значения delta для текущего слоя 
                        # d_mas[1] - содержит значения delta для следующего слоя
        cur_w = copy.deepcopy(self.w)
        for num_l in rev_count_layer:
            # Количество входов в нейрон данного слоя
            count_in_layer = len(self.w[num_l])/(self.struct_net[num_l]) 
            for num_n in xrange(self.struct_net[num_l]):    
                o_n = (iter_out[num_l])[num_n] # Выход нейрона
                if(num_l == rev_count_layer[0]): # Если num_l == номеру выходного слоя
                    deg = bet * (t[num_n] - o_n)
                    err = lam * (t[num_n] - o_n) + (1 - lam)*(math.exp(deg) - math.exp(-deg))/(math.exp(deg)+math.exp(-deg)) 
                    delta = err
                else:
                    err = 0
                    for ind in xrange(len(d_mas[1])):
                        # +1 пропускаем смещение  
                        err += (d_mas[1])[ind] * (cur_w[num_l+1])[(self.struct_net[num_l]+1)*ind+num_n+1] 
                        delta = err * o_n * (1-o_n)
                
                d_mas[0].append(delta)
                cur_x = [1] + x + old_elman_layer                 
                
                for num_w in xrange(count_in_layer):
                    if ((num_l - 1) < 0):
                        in_n = cur_x[num_w]
                    else:
                        if (num_w == 0):
                            in_n = 1 # вход для смещения равен 1
                        else:
                            # in_n вход нейрона весовой коэффициент которого подстраивается
                            in_n = (iter_out[num_l-1])[num_w-1] 
                    
                    tmp_i = num_n*count_in_layer + num_w
                    dw = alph * delta * in_n + n*(dw_old[num_l])[tmp_i]
                    (dw_old[num_l])[tmp_i] = dw
                    (self.w[num_l])[tmp_i] += dw 
                        
            d_mas[1] = d_mas[0]
            d_mas[0] = []     
        return dw_old     

    def per_train(self, x, t, count = 1000, eps = 0.01, n = 0.001, alph = 0.05, lam = 1, bet = 4/3):

        # Проверка корректности обучающих данных
        if(len(x) != len(t)):
            print 'Количество обучающих выборок не совпадает'
            return 0 # Признак ошибки
        #Проверка соответствия входов и выходов структуре сети
        for i in xrange(len(x)):
            if self.elman != 0:
                if len(x[i]) != self.count_input - self.struct_net[self.elman - 1]:
                    print 'Количество входов в обучающем множестве не соответствует структуре сети' 
                    return 0
            elif(len(x[i]) != self.count_input):
                print 'Количество входов в обучающем множестве не соответствует структуре сети' 
                return 0
            if(len(t[i]) != self.struct_net[self.count_layer - 1]):
                print 'Количество выходов в обучающем множестве не соответствует структуре сети'     
                return 0
       
        dw_old = []
        for epoch in xrange(count):
            # Подстройка весовых коэффициентов на всем обучающем множестве
            
            for ind_x in xrange(len(x)):
                dw_cur = self.alg_bp(x[ind_x], t[ind_x], dw_old, lam, alph, bet, n)
            out = []
            for i in xrange(len(x)):
                out.append((self.sim_net(x[i]))[self.count_layer-1])
            e = self.sse(out, t)
            print epoch, e
            if(e < eps):
                print epoch,'eps=',e
                return epoch
            lam = math.exp(-1/(e*e))
            #lam = 1
            dw_old = copy.deepcopy(dw_cur)
        print epoch,'eps=',e
        return count

            


            
            




