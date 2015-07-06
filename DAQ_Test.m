global DAR IND
DAR = [];
IND = 0;

seconds = 10;
freq = 2000;

cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions');

startCollect(seconds,freq);

% if IND ~=0
%     getData()
% end
% plot(DAR(1,1:IND),DAR(2,1:IND),'b')