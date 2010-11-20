# -*- coding: utf-8 -*-
#
import random
import time
import copy

class sofm_net:
    
    w = []
    struct_net = []
    p = []
    count_reinit = 100 # 50-1
    
    def __init__(self, struct_net = [], w = []):
        
        self.struct_net = struct_net
        self.f_max = 2048
        
        self.p = [self.f_max for i in xrange(self.struct_net[1])] 
        if (w == []):
            for i in xrange(self.struct_net[1]): # struct_net[1] - количество нейронов
                w_new = []
                for j in xrange(self.struct_net[0]): # struct_net[1] - количество входов
                    #w_new.append(random.randrange(0, 5)/50.0) 
                    #w_new.append(random.randrange(0, 256)) 
                    w_new.append(255.0/(i+1)) 
                self. w.append(w_new)
        else:
            self.w = w
            
    def sim_net(self, x):
        
        # MANHATTAN DISTANCE
        for i in xrange(self.struct_net[1]):
            di = 0
            w = self.w[i]
            for j in xrange(len(self.w[i])):
                di += abs((x[j] - w[j]))
            if(i == 0):
                d_min = di
                ind = i
            elif(di < d_min):
                    d_min = di
                    ind = i
        return ind
        
    def calc_w(self, n, x, num_win):
        
        w = self.w[num_win]
        for i in xrange(len(x)):
            w[i] += n * (x[i] - w[i])
    
    def quant_err(self, x):
        
        p = len(x)
        qe = 0
        for i in xrange(p):
            num_win = self.sim_net(x[i])
            x_cur = x[i]
            w = self.w[num_win]
            for j in xrange(self.struct_net[0]):
                qe += (x_cur[j] - w[j]) ** 2
        return qe/p
    
    def calc_n(self, p):
        
        f = self.f_max - p
        if (f >= 0) & (f < 8):
            return 0.75
        elif (f > 7) & (f < 64):
            return 0.375
        elif (f > 63) & (f < 1024):
            return 0.09
        elif (f > 1023) & (f < 2048):
            return 0.0156
        elif (f > 2047):
            return 0
    
    def calc_epoch(self, x, cycle_ctr):
    
        num_win = self.sim_net(x)
        n = self.calc_n(self.p[num_win])
        
        #n = 0.75
        
        self.calc_w(n, x, num_win)
        if(self.p[num_win] != 0):
            self.p[num_win] -= 1
        if(cycle_ctr != 0):
            if ((cycle_ctr % self.count_reinit) == 0) : # Решаем задачу с мертвыми нейронами 
                    # путем реинициализации мертвого нейрона значением весов победителя
                for num in xrange(len(self.p)):
                    if (self.p[num] == self.f_max):
                        self.w[num] = copy.deepcopy(self.w[num_win])
    
    def net_train(self, x, count = 1, eps = 0.01):
        
        for epoch in xrange(count):
            for i in xrange(len(x)):
                self.calc_epoch(x[i], i)
            #print epoch
                #print 'num_win=' , num_win
                #print 'n = ', n
                #print p
                #if ((i % 10000) == 0):
                #    print i
                #print self.w
            #qe = self.quant_err(x)
            #print epoch, qe
            #if(qe < eps):
            #    print 'epoch = ', epoch, 'qe =', qe
            #    return epoch

        
        #print 'epoch = ', epoch, 'qe =', qe
        #print p
        #print self.quant_err(x)
        return epoch
            
