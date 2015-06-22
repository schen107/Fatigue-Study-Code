PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);
baseline = 0.1039;
[outcome,volt,timing] = ThermScreen(window,baseline,1,0.5,'horizontal',5);
sca;