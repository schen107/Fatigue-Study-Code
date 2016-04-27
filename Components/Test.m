PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);
cedrus=0;
t0 = GetSecs;
global MRI
[xpix,ypix] = Screen('WindowSize',window);
MRI = 0;
GambleScreen(window,cedrus,9,50,200);
% TextScreen(window,'hi',[1 0 0],4);

sca;


