# -*- coding: utf-8 -*-
from  __future__ import division

import sys, time

sys.path += ['../']

from com import *
from scipy.signal import butter, lfilter

from PyQt4.QtGui import *
from PyQt4.QtCore import *

def data_prepare(data, num_in):
    
    data_out = []
    ctr = 0
    slice_data = []
    for cur in data:
        slice_data += [cur]
        if (ctr < num_in-1):
            ctr += 1
        else:
           data_out += [slice_data]
           ctr = 0;
           slice_data = []
    return data_out


class PlotGui(QWidget):

    com_reader = 0
    border = 0.1
    scale = 100
    max_value = 255
    mas = []
    f_data = 0
    run = 0

    def __init__(self,  scale = 100, parent=None):
        
        QWidget.__init__(self, parent)
        
        self.setGeometry(200, 200, 500, 500)
        self.setWindowTitle("Plot Gui")
        
        self.com_reader = ComReader('/dev/ttyUSB0', 57600)
        self.f_data = open("f_data.txt", "w")
        self.run = 0
        self.scale = scale
        self.mas = [0 for i in xrange(self.scale)]

    def draw(self, data_mas, y_start, border, k, size):
        
        paint = QPainter()
        pen = QPen()
        
        x_prev = border[0]
        y_prev = size.height() - border[1] - (data_mas[0] + y_start)*k[1]

        paint.begin(self)
        
        pen.setWidth(1)
        pen.setColor(Qt.blue)
        paint.setPen(pen)
        
        for val in data_mas[1:]: 
                
                x = x_prev + k[0]
                y = size.height() - border[1] - (val + y_start)*k[1]
                
                paint.drawLine(x_prev, y_prev, x, y)
                
                x_prev = x
                y_prev = y
             
        paint.end() 

        
    def paintEvent(self, event):
       
        
        size = self.size()
        
        x_border = 0#self.border * size.width()
        y_border = self.border * size.height()
        kx = (size.width() - 2 * x_border)/self.scale
        ky = (size.height() - 2 * y_border)/512
        
        self.draw(self.mas, 256, [x_border, y_border], [kx, ky], size)

        # Обработка данных фильтром нижних частот
        (b, a) = butter(5, 0.1, btype = 'low')
        bout = lfilter(b, a, self.mas)
        # print bout
        self.draw(bout, 0, [x_border, y_border], [kx, ky], size)
       
            
    def startRead(self):
    
        print "start_read"
        while(self.com_reader.isOpen()):
        #if self.com_reader.isOpen():
            t = time.time()    
            for x in xrange(self.scale):
                ch = self.com_reader.read()
                #print 'CH = ', ch
                v = ch*5/self.max_value
                self.mas[x] = ch
                self.f_data.write("%d\n" % ch)
                #print "%d" % ord(ch)
            #self.mas = [self.com_reader.read() for x in xrange(self.scale)]
            if(self.run == 1):
                print "Rate ", 2*self.scale/(time.time() - t)
                print "Volt = ", v
                print "CH = ", ch
            qApp.processEvents()
            if(self.run == 1):
                self.repaint()
            
    def keyPressEvent(self, event):
    
        if event.key == Qt.Key_Down:
            self.com_reader.close()
            self.quit()
            self.f_data.close()
            print "quit"
        else:
            if(self.run == 1):
                self.run = 0
            else:
                self.run = 1
            print self.run
            #self.startRead()

        
        
def main (args) :

    app = QApplication (args)
    pg = PlotGui(int(args[1]))
    pg.show ()
    pg.startRead()
    app.exec_()
    
if __name__ ==  '__main__':
    main(sys.argv)


