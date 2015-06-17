PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);
baseline=-2.0952;
MVC = 0.2686-(baseline);

[choice,ReactTime] = GambleScreen(window,15,8.7,4);
sca;
 