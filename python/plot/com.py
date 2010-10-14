import serial

class ComReader:

    sreader = 0
    
    def __init__(self, dev, baud):
        
        # configure the serial connections (the parameters differs on the device you are connecting to)
        self.sreader = serial.Serial(
	        port     = dev, #'/dev/ttyUSB0',
	        baudrate = baud, #19200,
	        parity   = serial.PARITY_NONE,
	        stopbits = serial.STOPBITS_ONE,
	        bytesize = serial.EIGHTBITS
        )

        self.sreader.open()
        
    def isOpen(self):
        return self.sreader.isOpen()
        
    def read(self):
        return ord(self.sreader.read(1))
        
    def close(self):
        self.sreader.close()

