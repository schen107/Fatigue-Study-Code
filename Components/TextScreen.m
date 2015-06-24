function [key,volt,timing] = TextScreen(window,message,color,varargin)
% color is in RGB coords (ex. white: [1 1 1], green: [0 1 0], red: [1 0 0])
% varargin is [time], ['key'], ['DAQ',baseline] or [time,'DAQ',baseline]
% outputs are the key that's pressed (string), voltage, and timing array

global DAR IND

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);

if nargin == 4
    volt = NaN;
    if strcmp(varargin{1},'key')
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
        [~,keyCode] = KbStrokeWait;
        key = KbName(keyCode);
    
    elseif isnumeric(varargin{1}) == 1
        time = varargin{1};
        t0=GetSecs;
        while GetSecs-t0 <= time
            DrawFormattedText(window,message,'center','center',color);
            Screen('Flip',window);
        end
        key = NaN;
    end

% elseif nargin == 5
%     % cd('C:\Users\StevenChen\Documents\MATLAB\Fatigue Code\DAQ functions'); %Personal Laptop
%     cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions'); %Steven's Account
%     key = NaN;
%     baseline = varargin{2};
%     freq = 2000;
%     time = 100; %some large interval of time
%     lever = 1;
%     while lever
%        startCollect(time,freq);
%        if 
%        
%     end
    
    
elseif nargin == 6
    % cd('C:\Users\StevenChen\Documents\MATLAB\Fatigue Code\DAQ functions'); %Personal Laptop
    cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions'); %Steven's Account
    key = NaN;
    time = varargin{1};
    baseline = varargin{3};
    freq = 2000;
    startCollect(time,freq);
    t0=GetSecs;
    while GetSecs-t0 <= time
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
    end
    volt = DAR(2,:)-baseline;
    timing = DAR(1,:);

end

cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\Components'); %Steven's Account

end