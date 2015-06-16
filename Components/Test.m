% For running only this phase
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
MVC = 1; 
sensor = 1;

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 5: Please wait for instructions','key');
TextScreen(window,'GET READY',2);

MVCFatiguePercent = 60;
FailureThreshold = 50;
numFatigueTrials = 10;
minFatigueContractions = 10;
numFatiguedChoiceTrials = 170;%size(gambles,1);
FatiguedChoiceTrial = [];
reacttimeFatiguedChoiceTrial = [];

TempFatiguedChoice = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
% NOTE: numFatiguedChoiceTrials/numFatigueTrials only works if it's an
% integer
TempReacttime = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
for j = 1:numFatiguedChoiceTrials/numFatigueTrials
    [choice,ReactTime] = GambleScreen(window,10,20,4); %FIGURE OUT FLIP/SURE VALUES
    FixationCross(window,1+3*rand);
    TempFatiguedChoice(j) = choice; %NOTE: 1 = flip, 0 = sure
    TempReacttime(j) = ReactTime;
end