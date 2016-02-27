global DAR IND
DAR = [];
IND = 0;

seconds = 10;
freq = 2000;

addpath('Z:\Fatigue Experiment\Code\DAQ functions');

startCollect(seconds,freq);
WaitSecs(seconds);
% plot(DAR(1,:),DAR(2,:))