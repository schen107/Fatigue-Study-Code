global DAR IND
DAR = [];
IND = 0;

seconds = 5;
freq = 2000;

startCollect(seconds,freq);
pause(0.4)
if IND ~=0
    getData()
end
plot(DAR(1,1:IND),DAR(2,1:IND),'b')