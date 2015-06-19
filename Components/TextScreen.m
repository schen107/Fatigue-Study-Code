function [key,volt,timing] = TextScreen(window,message,color,varargin)
% color is in RGB coords (ex. white: [1 1 1], green: [0 1 0], red: [1 0 0])
% varargin is [time], ['key'], or [time,sensor,baseline]
% this experiment doesn't need ['key',sensor,baseline]
% outputs are the key that's pressed (string) and voltage array

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
    DrawFormattedText(window,message,'center','center',color);
    Screen('Flip',window);
    key = NaN;
    time = varargin{1};
    sensor = varargin{2};
    numSample = 1000;
    volt = NaN(1,numSample);
    timing = NaN(1,numSample);
    t0=GetSecs;
    i = 0;
    while GetSecs-t0 <= time
%         WaitSecs(0.02);
        i = i+1;
        volt(i) = getsample(sensor)-varargin{3};
        timing(i) = GetSecs-t0;
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
    end

end
end