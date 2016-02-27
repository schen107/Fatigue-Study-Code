PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);
global TRIGGER

TRIGGER = GetSecs;
    t0 = GetSecs;
    test = FixationCross(window,1);
    sca;

