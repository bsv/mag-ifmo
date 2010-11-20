s = serial("/dev/ttyUSB0");
set(s,'BaudRate',19200);
fopen(s);
plot([0:255], fread(s, 256))
fclose(s);
