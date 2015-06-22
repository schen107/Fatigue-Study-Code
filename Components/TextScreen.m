function [key,volt,timing] = TextScreen(window,message,color,varargin)
% color is in RGB coords (ex. white: [1 1 1], green: [0 1 0], red: [1 0 0])
% varargin is [time], ['key'], or [time,'DAQ',baseline]
% outputs are the key that's pressed (string), voltage, and timing array

global DAR

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

elseif nargin == 6
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
end