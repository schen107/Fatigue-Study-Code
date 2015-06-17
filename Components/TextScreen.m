function [key,volt] = TextScreen(window,message,color,varargin)
% color is in RGB coords (ex. white: [1 1 1], green: [0 1 0], red: [1 0 0])
% varargin is [time], ['key'], or [time,sensor,baseline]
% this experiment doesn't need ['key',sensor,baseline]
% outputs are the key that's pressed (string) and voltage array

HideCursor(window);
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);

if nargin == 4
    volt = NaN;
    if strcmp(varargin{1},'key')
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
        keyIsDown = 0;
        while keyIsDown == 0
            WaitSecs(.02);
            [keyIsDown, ~, keyCode] = KbCheck;
        end
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
    volt = NaN(numSample,1);
    t0=GetSecs;
    i = 0;
    while GetSecs-t0 <= time
%         WaitSecs(0.02);
        i = i+1;
        volt(i) = getsample(sensor)-varargin{3};
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
    end

end
end