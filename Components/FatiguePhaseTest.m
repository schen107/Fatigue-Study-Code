clear; clc

global DAR

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

load('C:\Users\Steven\Documents\MATLAB\FatigueCode\Gambles_12_5.mat');
gambles = Gambles_12_5;
[r,~] = size(gambles);
gambleShuffled = gambles(randperm(r),:);

% New DAQ
% cd('C:\Users\StevenChen\Documents\MATLAB\Fatigue Code\DAQ functions'); %Personal Laptop
cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions'); %Steven's Account
time = 5;
freq = 2000;
startCollect(time,freq);

% pause(5);
% cd('Y:\Fatigue Code\Components') %KKI Computer
% cd 'C:\Users\Steven Chen\Documents\MATLAB\Fatigue Code\Components' %Personal Laptop
cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\Components') %Steven's Computer
TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
baseline = mode(DAR(2,:));

TextScreen(window,'Phase 1: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

time = 4;
freq = 2000;
numMVCTrials = 3;
MVCTrial = NaN(numMVCTrials,time*freq); %rows-trial#, columns-voltages
MVCTiming = NaN(numMVCTrials,time*freq);
for i = 1:numMVCTrials
    [~,volt,timing] = TextScreen(window,'SQUEEZE!',[1 1 1],time,'DAQ',baseline);
    MVCTiming(i,:) = timing;
    MVCTrial(i,:) = volt;
    FixationCross(window,1+3*rand) %random duration btwn 1-4 sec
end

MVC = max(max(MVCTrial));
MVC = 0.8*MVC;
% ^We are adjusting the 'effort range' of 0 to 100 to map from no force, 
% to 80% of the max force

TextScreen(window,'End of Phase 1',[1 1 1],'key');

TextScreen(window,'Phase 5: Please wait for instructions',[1 1 1],'key');

time = 4;
freq = 2000;
gambleShuffled_1 = gambles(randperm(r),:);
MVCFatiguePercent = 80;
FailureThreshold = 75;
numChoicesPerTrial = 10;
numFatigueTrials = r/numChoicesPerTrial; %%%%%%%%%%%%%%HOW MANY DO WE DO? (TEST THIS)
minFatigueContractions = 20;
numFatigueContractions = 5;
numFatiguedChoiceTrials = r; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choiceFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);
reacttimeFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);
initvoltFatiguedChoiceTrial = zeros(500,time*freq);
initFatiguedChoiceTiming = zeros(500,time*freq);
voltFatiguedChoiceTrial = zeros(numFatigueContractions*numFatigueTrials,time*freq);
FatiguedChoiceTiming = zeros(numFatigueContractions*numFatigueTrials,time*freq);

TextScreen(window,'FATIGUE PHASE: PRESS ANY KEY TO CONTINUE',[1 1 1],'key');

% Initial Fatigue - reps until 75% failure, minimum of 20 trials
TextScreen(window,'GET READY',[1 1 1],1.5);
success = 0;
failure = 0;
for n = 1:minFatigueContractions
    [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
    initvoltFatiguedChoiceTrial(n,:) = volt;
    initFatiguedChoiceTiming(n,:) = timing;
    if outcome == 1
        success = success+1;
    elseif outcome == 0
        failure = failure+1;
    end
    FixationCross(window,3);
end
n = minFatigueContractions;
while success/failure > (100-FailureThreshold)/FailureThreshold
    n = n+1;
    [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
    initvoltFatiguedChoiceTrial(n,:) = volt;
    initFatiguedChoiceTiming(n,:) = timing;
    if outcome == 1
        success = success+1;
    elseif outcome == 0
        failure = failure+1;
    end
    FixationCross(window,3);
end 

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% HideCursor(window);

% Post-Fatigue initial trials
TextScreen(window,'GAMBLE PHASE',[1 1 1],2);
TextScreen(window,'GET READY',[1 1 1],1.5);

for i = 1:numChoicesPerTrial
    flip = gambleShuffled_1(i,2);
    sure = gambleShuffled_1(i,1);
    [choice,ReactTime] = GambleScreen(window,flip,sure,time);
    FixationCross(window,1+3*rand);
    choiceFatiguedChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
    reacttimeFatiguedChoiceTrial(i) = ReactTime;
end

% subsequent trials - 5 reps per trial
for i = 2:numFatigueTrials
    TextScreen(window,'FATIGUE PHASE',[1 1 1],2);
    TextScreen(window,'GET READY',[1 1 1],1.5);
    
    FatigueLeftIndex = (i-2)*numFatigueContractions+1;
    FatigueRightIndex = (i-1)*numFatigueContractions;
    for n = FatigueLeftIndex:FatigueRightIndex
        [~,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
        voltFatiguedChoiceTrial(n,:) = volt;
        FatiguedChoiceTiming(n,:) = timing;
        FixationCross(window,3);
    end
    
    % Post-Fatigue Choice Trials
    TextScreen(window,'GAMBLE PHASE',[1 1 1],2);
    TextScreen(window,'GET READY',[1 1 1],1.5);
    ChoiceLeftIndex = (i-1)*numChoicesPerTrial+1;
    ChoiceRightIndex = i*numChoicesPerTrial;
    for j = ChoiceLeftIndex:ChoiceRightIndex
        flip = gambleShuffled_1(j,2);
        sure = gambleShuffled_1(j,1);
        [choice,ReactTime] = GambleScreen(window,flip,sure,4);
        FixationCross(window,1+3*rand);
        choiceFatiguedChoiceTrial(j) = choice; %NOTE: 1 = flip, 0 = sure
        reacttimeFatiguedChoiceTrial(j) = ReactTime;
    end
end

FatiguedChoiceTrial = [gambleShuffled_1(:,[1 2]) choiceFatiguedChoiceTrial ...
    reacttimeFatiguedChoiceTrial];
% ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
% column4-reaction time

TextScreen(window,'End of Phase 5',[1 1 1],'key');
sca;