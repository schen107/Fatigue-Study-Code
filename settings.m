function P = settings()
%SETTINGS Returns a struct with settings relevant to the local machine.
%   This function returns a struct with settings relvant the machine and
%   envoirment.
%
%       P.DATA_PATH: location of data root folder on current machine.
%       P.DAQ_ADDR: data address of DAQ device

P.DATA_PATH = ['D:\EXP_DATA\'];
P.DAQ_ADDR = 'D100';

end

