function [key,volt] = TextScreen(window,message,varargin)

% varargin is [time], ['key'], or [time,sensor]
% this experiment doesn't need ['key',sensor]
% outputs are the key that's pressed (string) and voltage array

white = WhiteIndex(window); black = BlackIndex(window);
HideCursor(window);
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,25);

if nargin == 3
    volt = NaN;
    if strcmp(varargin{1},'key')
        DrawFormattedText(window,message,'center','center',white);
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
            DrawFormattedText(window,message,'center','center',white);
            Screen('Flip',window);
        end
        key = NaN;
    end

elseif nargin == 4
    DrawFormattedText(window,message,'center','center',white);
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
        volt(i) = i;%getsample(sensor);
        DrawFormattedText(window,message,'center','center',white);
        Screen('Flip',window);
    end
    sca
end
end