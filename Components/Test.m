PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

t0 = GetSecs;
[~,~,~,a] = TextScreen(window,'Wait for Trigger',[1 1 1],'MRI');
pause(2);
sca;
return

