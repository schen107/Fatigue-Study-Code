function td = getData()
% output: a 1x2 array, first value is time, second is voltage
global DAR IND 

e = IND;
s = max(IND-5,1);
td = [DAR(1,IND) mean(DAR(2,s:e))];

end