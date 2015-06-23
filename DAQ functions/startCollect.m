function startCollect(seconds,freq)
global DAR IND s
IND = 0;
DAR = zeros(2,seconds*freq);
s = daq.createSession('ni');
s.DurationInSeconds = seconds;
s.Rate = freq;
s.NotifyWhenDataAvailableExceeds = 100;
addAnalogInputChannel(s,'Dev1',0,'Voltage');
% lh = addlistener(s,'DataAvailable', @(src,e) disp(length(e.Data)));
lh = addlistener(s,'DataAvailable', @dropTheD);
startBackground(s);

end

function dropTheD(src,event)
global DAR IND

inds = IND+(1:length(event.Data));

DAR(1,inds) = event.TimeStamps;
DAR(2,inds) = event.Data;
IND = inds(end);
end