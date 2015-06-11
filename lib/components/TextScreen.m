function presses = TextScreen( wkspc,dispText,wait )
%TEXTSCREEN Displays a text for a certain amount of time and return key
%press
%   wkspc: workspace Screen var
%   str: String to display
%   wait: time to wait for response

[screenWidth, screenHeight]=Screen('WindowSize', wkspc);
black = BlackIndex(wkspc);
Screen(wkspc, 'FillRect', black);

Screen(wkspc,'TextSize',24);

DrawFormattedText(wkspc, dispText, ...
    'center', screenHeight/2, [255,255,255,255], 0);
Screen('Flip',wkspc);

presses = {};
startSecs = GetSecs();
WaitSecs(.2)
while wait -(GetSecs()-startSecs)>0
    WaitSecs(.02)
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        presses = KbName(keyCode);
        break
    end
    
end
    


end

