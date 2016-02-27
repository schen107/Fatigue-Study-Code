function timing = FixationCross(window,time)

global TRIGGER

white = WhiteIndex(window);
[xpix,ypix] = Screen('WindowSize',window);
xcenter = xpix/2; ycenter = ypix/2;

FixationSize=25;
coords = [-FixationSize FixationSize 0 0; 0 0 -FixationSize FixationSize];
width=3;

t0=GetSecs;
i = 0;
while GetSecs-t0 <= time
    i = i+1;
    Screen('DrawLines',window,coords,width,white,[xcenter,ycenter]);
    Screen('Flip',window);
    if i == 1
        timing = GetSecs-TRIGGER;
    end
end

end