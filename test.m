global DAQ
clear;
DAQ = 0;

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

[sensor, baseline, chans] = setupDaq(window);
t0 = GetSecs;
ThermScreen(window,sensor,baseline,1,0.5,0.05,'horizontal',4);
% secs=Screen('GetFlipInterval', window)
hz=Screen('NominalFrameRate', window)
sca;