function [key,volt] = TextScreen(window,message,varargin)

% varargin is [time], ['key'], [time,sensor], or ['key',sensor]

white = WhiteIndex(window); black = BlackIndex(window);
HideCursor(window);
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,25);

if nargin == 3
    if strcmp(varargin(1),'key')
        keyIsDown = 0;
        while keyIsDown == 0
            WaitSecs(.02)
            [keyIsDown, ~, keyCode] = KbCheck;
        end
        key = KbName(keyCode);
    
    elseif isnumeric(varargin(1))
        time = varargin(1);
        t0=GetSecs;
        while GetSecs-t0 <= time
            DrawFormattedText(window,message,'center','center',white);
            Screen('Flip',window);
        end

elseif nargin == 4
    DrawFormattedText(window,message,'center','center',white);
    Screen('Flip',window);
    
    sensor = varargin(2);
    volt = NaN(1000,1);
    if strcmp(varargin(1),'key')
        keyIsDown = 0;
        while keyIsDown == 0
            WaitSecs(.02)
            [keyIsDown, ~, keyCode] = KbCheck;
        end
        key = KbName(keyCode);
    elseif isnumeric(varargin(1))
        

end
end