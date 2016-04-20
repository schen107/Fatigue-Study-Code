function [sensor,baseline,chans] = setupDaq(window)
%SETUPDAQ initialize DAQ

global DAQ DAR

if DAQ == 0 %Old Sensor
    sensor = analoginput('mcc'); %Default sample rate: 1000
    chans=addchannel(sensor,0);
    start(sensor);
    TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
    %Pausing to be sure that the sensor has time to equilibriate
    baseline = getsample(sensor);

elseif DAQ == 1 %New Sensor
    sensor = 0;
    time = 5;
    freq = 2000;
    startCollect(time,freq);

    TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
    baseline = mode(DAR(2,:));
end


end

