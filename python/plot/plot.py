from  __future__ import division

import sys, time

from com import *

from PyQt4.QtGui import *
from PyQt4.QtCore import *

class PlotGui(QWidget):

    com_reader = 0
    border = 0.1
    scale = 500
    mas = [x for x in xrange(scale)]

    def __init__(self, parent=None):
        
        QWidget.__init__(self, parent)
        
        self.setGeometry(200, 200, 500, 500)
        self.setWindowTitle("Plot Gui")
        
        self.com_reader = ComReader('/dev/ttyUSB0', 19200)
        
    def paintEvent(self, event):
       
        paint = QPainter()
        pen = QPen()
        
        
        
        size = self.size()
        
        x_border = self.border * size.width()
        y_border = self.border * size.height()
        kx = (size.width() - 2 * x_border)/self.scale
        ky = (size.height() - 2 * y_border)/256
        
        x_prev = x_border
        y_prev = size.height() - y_border - self.mas[0]*ky
        
        paint.begin(self)
        
        pen.setWidth(1)
        pen.setColor(Qt.blue)
        paint.setPen(pen)
        
        for val in self.mas[1:]: 
                
                x = x_prev + kx
                y = size.height() - y_border - val*ky
                
                paint.drawLine(x_prev, y_prev, x, y)
                
                x_prev = x
                y_prev = y
             
        paint.end() 
        
    def startRead(self):
    
        print "start_read"
        while(self.com_reader.isOpen()):
        #if self.com_reader.isOpen():
            #t = time.time()    
            self.mas = [self.com_reader.read() for x in xrange(self.scale)]
            #print "Rate ", self.scale/(time.time() - t)
            qApp.processEvents()
            self.repaint()
            
    def keyPressEvent(self, event):
    
        if event.key == Qt.Key_End:
            self.com_reader.close()
            self.quit()
            print "quit"
        else:
            self.startRead()
            print "start read"

        
        
def main (args) :

    app = QApplication (args)
    pg = PlotGui()
    pg.show ()
    app.exec_()
    
if __name__ ==  '__main__':
    main(sys.argv)

    
