clear; clc; 

Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);screen=max(Screen('Screens'));
black = BlackIndex(screen);
[window,windowRect]=PsychImaging('OpenWindow',screen,black);
white = WhiteIndex(window);

[key,volt] = TextScreen(window,'Hi',3,1);

% [outcome, volt] = ThermScreen(window,0.45,1,0.9,'horizontal',10);  

% [EffortReport, ReactTime] = NumberLineScreen(window);
KbStrokeWait;
sca;