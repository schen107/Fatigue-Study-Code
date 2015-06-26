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
numFatiguedChoiceTrials = r; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
voltFatiguedChoiceTrial = NaN(100,time*freq,numFatigueTrials);
timingFatiguedChoiceTrial = NaN(100,time*freq,numFatigueTrials);
outcomeFatiguedChoiceTrial = NaN(100,numFatigueTrials);

TextScreen(window,'FATIGUE PHASE: PRESS ANY KEY TO CONTINUE',[1 1 1],'key');
for i = 1:numFatigueTrials
    success = 0;
    failure = 0;
    if i == 1
        % Initial Fatigue - minimum of 10 reps
        minFatigueReps = 10;
        TextScreen(window,'GET READY',[1 1 1],1.5);
    else
        % Subsequent Fatigue - minimum of 5 reps
        minFatigueReps = 5;
        TextScreen(window,'FATIGUE PHASE',[1 1 1],2);
        TextScreen(window,'GET READY',[1 1 1],1.5);
    end

    % min reps
    for n = 1:minFatigueReps
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
        voltFatiguedChoiceTrial(n,:,i) = volt;
        timingFatiguedChoiceTrial(n,:,i) = timing;
        outcomeFatiguedChoiceTrial(n,i) = outcome;
        if outcome == 1
            success = success+1;
        elseif outcome == 0
            failure = failure+1;
        end
        FixationCross(window,3);
    end
    % until failure threshold
    n = minFatigueReps;
    while success/failure > (100-FailureThreshold)/FailureThreshold
        n = n+1;
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
        voltFatiguedChoiceTrial(n,:,i) = volt;
        timingFatiguedChoiceTrial(n,:,i) = timing;
        outcomeFatiguedChoiceTrial(n,i) = outcome;
        if outcome == 1
            success = success+1;
        elseif outcome == 0
            failure = failure+1;
        end
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