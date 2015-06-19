function FixationCross(window,time)

white = WhiteIndex(window); black = BlackIndex(window);
[xpix,ypix] = Screen('WindowSize',window);
xcenter = xpix/2; ycenter = ypix/2;

FixationSize=25;
coords = [-FixationSize FixationSize 0 0; 0 0 -FixationSize FixationSize];
width=3;

t0=GetSecs;
while GetSecs-t0 <= time
    Screen('DrawLines',window,coords,width,white,[xcenter,ycenter]);
    Screen('Flip',window);
end

end