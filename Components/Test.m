clear; clc; 

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);screen=max(Screen('Screens'));
black = BlackIndex(screen);
[window,windowRect]=PsychImaging('OpenWindow',screen,black);
white = WhiteIndex(window);

key =  TextScreen(window,'Hi',1,1);

% [outcome, volt] = ThermScreen(window,0.45,1,0.9,'horizontal',10);  

% [EffortReport, ReactTime] = NumberLineScreen(window);
KbStrokeWait;
sca;