function td = getData()
% output: a 1x2 array, first value is time, second is voltage
global DAR IND 

td = [DAR(1,IND) DAR(2,IND)];

end

