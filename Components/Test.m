PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);
try
    for i = 1:50
        [choice,~] = GambleScreen(window,50,25,5);
        FixationCross(window,2);
    end
    sca;
catch
    sca;
end
