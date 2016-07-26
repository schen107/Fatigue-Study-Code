sensor = analoginput('mcc'); %Default sample rate: 1000
chans=addchannel(sensor,0);
start(sensor);
baseline = getsample(sensor);