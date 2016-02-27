function [EffortReport,ReactTime,timing] = NumberLineScreen(window)
% outputs: EffortReport - value on number line (%MVC)
% ReactTime - time it took to make choice (s)

global TRIGGER

white = WhiteIndex(window);
[xpix,ypix] = Screen('WindowSize',window);
xcenter = xpix/2; ycenter = ypix/2;

click = 0;
HalfLength = xpix/3;
margin=0.5*(xpix-2*HalfLength);
xrand=round(margin+rand*2*HalfLength);yrand=round(rand*ypix);
SetMouse(xrand,yrand);
i = 0;
tic;
while ~click(1)
    i = i+1;
    [xmouse,~,click]=GetMouse(window);
    y=ypix/2;
    if xmouse<xcenter-HalfLength;
        xmouse=xcenter-HalfLength;
    elseif xmouse>xcenter+HalfLength;
        xmouse=xcenter+HalfLength;
    end 
    
    %Setup 'Number-line' from 0 to 100...
    xLine=[-HalfLength HalfLength 0 0];yLine=[0 0 0 0];
    LineCoords=[xLine;yLine];

    %Setup 0 and 100 dashes...
    xDash=[0 0 0 0];
    yDash=[0 0 -20 20];
    DashCoords=[xDash;yDash];

    %Setup 0 and 100 labels...
    label0='0';label100='100';
    xp0=xcenter-HalfLength;xp100=xcenter+HalfLength;

    %Setup other labels...
    label10='10';label20='20';label30='30';label40='40';
    label50='50';label60='60';label70='70';label80='80';label90='90';

    xp10=margin+0.1*2*HalfLength;
    xp20=margin+0.2*2*HalfLength;
    xp30=margin+0.3*2*HalfLength;
    xp40=margin+0.4*2*HalfLength;
    xp50=margin+0.5*2*HalfLength;
    xp60=margin+0.6*2*HalfLength;
    xp70=margin+0.7*2*HalfLength;
    xp80=margin+0.8*2*HalfLength;
    xp90=margin+0.9*2*HalfLength;

    %Instructional message...
    msg_instr='Select the level you just squeezed:';

    %Draw everything to screen...
    Screen('TextSize',window,25);
    Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,label0,xp0-8,ycenter+25,white);

    xcor=-15;ycor=25;
    DrawFormattedText(window,label10,xp10+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label20,xp20+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label30,xp30+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label40,xp40+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label50,xp50+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label60,xp60+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label70,xp70+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label80,xp80+xcor,ycenter+ycor,white);
    DrawFormattedText(window,label90,xp90+xcor,ycenter+ycor,white);

    DrawFormattedText(window,label100,xp100-23,ycenter+25,white);
    Screen('DrawLines',window,DashCoords,2,white,[xcenter-HalfLength ycenter]);

    Screen('TextSize',window,40);
    DrawFormattedText(window,msg_instr,'center',ycenter-round(0.5*ycenter),white);

    Screen('DrawLines',window,DashCoords,2,white,[xp10 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp20 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp30 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp40 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp50 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp60 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp70 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp80 ycenter]);
    Screen('DrawLines',window,DashCoords,2,white,[xp90 ycenter]);

    Screen('DrawLines',window,DashCoords,2,white,[xcenter+HalfLength ycenter]);
    Screen('DrawLines',window,LineCoords,2,white,[xcenter ycenter]);
    Screen('DrawDots',window,[xmouse y],20, white,[],1);
    Screen('Flip',window);
    if i == 1
        timing = GetSecs-TRIGGER;
    end
    
    PercentPix=xmouse;
end
ReactTime = toc;
%Get reaction times.

NormalPix = PercentPix-margin;
EffortReport = 100*NormalPix/(2*HalfLength);
end
