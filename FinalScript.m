% Final Script for Fatigue Study
% Created by Steven Chen

clear; clc;
rng('shuffle'); %Generate new random seed
cd 'Y:\Fatigue Code\Components' %For KKI computer
% cd 'C:\Users\Steven Chen\Documents\MATLAB\Fatigue Code\Components' %For personal laptop
%% Setup PsychToolBox------------------------------------------------------

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

%% Setup DAQ---------------------------------------------------------------
% Dummy
% sensor = 1;

sensor = analoginput('mcc'); %Default sample rate: 1000
chans=addchannel(sensor,0);
start(sensor);
pause(5); %Pausing to be sure that the sensor has time to equilibriate
baseline = getsample(sensor);

%% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION----------------------------------

% For running only this phase

% Dummy
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);

TextScreen(window,'Phase 1: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

numMVCTrials = 3;
MVCTrial = NaN(numMVCTrials,1000); %rows-trial#, columns-voltages
for i = 1:numMVCTrials
    [~,volt] = TextScreen(window,'SQUEEZE!',[1 1 1],4,sensor,baseline);
    MVCTrial(i,:) = volt;
    FixationCross(window,1+3*rand) %random duration btwn 1-4 sec
end

MVC = max(max(MVCTrial));
MVC = 0.8*MVC; 
% ^We are adjusting the 'effort range' of 0 to 100 to map from no force, 
% to 80% of the max force

TextScreen(window,'End of Phase 1',[1 1 1],'key');

%% PHASE 2: ASSOCIATION----------------------------------------------------

% For running only this phase
% Dummy Vars
% MVC = 1;
% sensor = 1;
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);

TextScreen(window,'Phase 2: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

numAssocTrials = 5;
PercentMVClevels = [10 20 30 40 50 60 70 80];
PercentMVClevelshuffle = PercentMVClevels(randperm(numel(PercentMVClevels)));
AssocTrial = repmat(PercentMVClevelshuffle,[numAssocTrials 1]);
AssocTrial = AssocTrial(:);
% ^40x1 representing each individual trial
voltAssocTrial = NaN(numel(AssocTrial),1000);
% ^rows-trial# for each level, columns-MVC percentages, depth-voltages
AssocTiming = NaN(numel(AssocTrial),1000);
% ^timings associated with voltages

count = 0;
count_1 = 0;
for i = AssocTrial
    count = count+1;
    count_1 = count_1+1;
    TextScreen(window,num2str(i),[1 1 1],2);
    [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,i/100,'vertical',4);
    voltAssocTrial(count,:) = volt;
    AssocTiming(count,:) = timing;
    if outcome == 1
        TextScreen(window,'SUCCESS',[0 1 0],2);
    elseif outcome == 0
        TextScreen(window,'FAILURE',[1 0 0],2);
    FixationCross(window,1+3*rand);
    end
    while count_1 == numAssocTrials
        TextScreen(window,'REST',[1 1 1],60);
        count_1 = 0;
    end
end

TextScreen(window,'End of Phase 2',[1 1 1],'key');

%% PHASE 3: RECALL---------------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);

TextScreen(window,'Phase 3: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

numRecallTrials = 3;
PercentMVClevels = [10 20 30 40 50 60 70 80];
PercentMVClevels_3 = repmat(PercentMVClevels,[numRecallTrials,1]);
PercentMVClevels_3_shuffle = PercentMVClevels_3(randperm(numel(PercentMVClevels_3)));
voltRecallTrial = NaN(numel(PercentMVClevels_3),1000);
reportRecallTrial = zeros(numel(PercentMVClevels_3),1);
reacttimeRecallTrial = zeros(numel(PercentMVClevels_3),1);
RecallTiming = NaN(numel(PercentMVClevels_3),1000);
count = 0;
for i = PercentMVClevels_3_shuffle
    count = count+1;
    [~,volt,timing] = ThermScreen(window,sensor,baseline,MVC,i/100,'horizontal',4);
    voltRecallTrial(count,:) = volt;
    RecallTiming(count,:) = timing;
    [EffortReport,ReactTime] = NumberLineScreen(window);
    reportRecallTrial(count) = EffortReport;
    reacttimeRecallTrial(count) = ReactTime;
end

RecallTrial = [PercentMVClevels_3_shuffle' reportRecallTrial ... 
    reacttimeRecallTrial];
% ^rows-recall trial#, column1-actual MVC percentage, column2-reported MVC
% percentage, column3-reaction time

TextScreen(window,'REST',[1 1 1],60);

TextScreen(window,'End of Phase 3',[1 1 1],'key');

%% PHASE 4: CHOICE---------------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);

TextScreen(window,'Phase 4: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

load('Gambles_12_5.mat');
gambles = Gambles_12_5;
[r,~] = size(gambles);
gambleShuffled = gambles(randperm(r),:);

numChoiceTrials = r;
choiceChoiceTrial = zeros(numChoiceTrials,1);
reacttimeChoiceTrial = zeros(numChoiceTrials,1);
for i = 1:numChoiceTrials
    flip = gambleShuffled(i,2);
    sure = gambleShuffled(i,1);
    [choice,ReactTime] = GambleScreen(window,flip,sure,4);
    FixationCross(window,1+3*rand);
    reacttimeChoiceTrial(i) = ReactTime;
    choiceChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
end

ChoiceTrial = [gambleShuffled(:,[1 2]) choiceChoiceTrial ... 
    reacttimeChoiceTrial];
% ^rows-gamble trial#, column1-sure, column2-flip, column3-choice,
% column4-reaction time

TextScreen(window,'End of Phase 4',[1 1 1],'key');

%% PHASE 5: FATIGUED CHOICE------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% load('Gambles_12_5.mat');
% gambles = Gambles_12_5;
% [r,~] = size(gambles);
% gambleShuffled = gambles(randperm(r),:);

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);

TextScreen(window,'Phase 5: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

gambleShuffled_1 = gambles(randperm(r),:);
MVCFatiguePercent = 60;
FailureThreshold = 50;
numFatigueTrials = 2; %%%%%%%%%%%%%%HOW MANY DO WE DO? (TEST THIS)
minFatigueContractions = 10;
numFatiguedChoiceTrials = r;
choiceFatiguedChoiceTrial = [];
reacttimeFatiguedChoiceTrial = [];

for i = 1:numFatigueTrials
    success = 0;
    failure = 0;
    % iniial mandatory trials (adjusted by minFatigueContractions)
    for n = 1:minFatigueContractions
        outcome = ThermScreen(window,sensor,baseline,MVC,MVCFatiguePercent/100,'horizontal',4);
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],1);
            success = success+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],1);
            failure = failure+1;
        end
        FixationCross(window,3);
    end
    % conditional extra trials - if 50% failure, then criteria for fatigue
    % is met (changed by altering FailureThreshold)
    while success/failure > (100-FailureThreshold)/FailureThreshold
        outcome = ThermScreen(window,sensor,baseline,MVC,MVCFatiguePercent/100,'horizontal',4);
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],1);
            success = success+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],1);
            failure = failure+1;
        end
        FixationCross(window,3);
    end
    
    TextScreen(window,'GET READY',[1 1 1],1.5);
    
    % Post-Fatigue Choice Trials
    TempFatiguedChoice = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
    % NOTE: numFatiguedChoiceTrials/numFatigueTrials only works if it's an
    % integer
    TempReacttime = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
    for j = 1:numFatiguedChoiceTrials/numFatigueTrials
        flip = gambleShuffled_1(j,2);
        sure = gambleShuffled_1(j,1);
        [choice,ReactTime] = GambleScreen(window,flip,sure,4);
        FixationCross(window,1+3*rand);
        TempFatiguedChoice(j) = choice; %NOTE: 1 = flip, 0 = sure
        TempReacttime(j) = ReactTime;
    end
    choiceFatiguedChoiceTrial = append(choiceFatiguedChoiceTrial,TempFatiguedChoice);
    reacttimeFatiguedChoiceTrial = append(reacttimeFatiguedChoiceTrial,TempReacttime);
end

FatiguedChoiceTrial = [gambleShuffled_1(:,[1 2]) choiceFatiguedChoiceTrial' ...
    reacttimeFatiguedChoiceTrial];
% ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
% column4-reaction time

TextScreen(window,'End of Phase 5',[1 1 1],'key');

%% PHASE 6: TRIAL SELECTION------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% load('Gambles_12_5.mat');
% gambles = Gambles_12_5;
% [r,~] = size(gambles);
% gambleShuffled = gambles(randperm(r),:);
% gambleShuffled_1 = gambles(randperm(r),:);

TextScreen(window,'Phase 6: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

% Randomly select 5 choice trials from pre/post fatigue
PreTrials = zeros(5,1);
PostTrials = zeros(5,1);
for i = randi(numChoiceTrials,[1 5]) 
    % NOTE: here, numChoiceTrials is the same as numFatiguedChoiceTrials, 
    % so both are in the same for loop. If the number of gambles for each 
    % phase is different, this needs to be changed.
    if choiceChoiceTrial(i) == 1 %Random seed to determine 0 or flip value
        seed = rand;
        if seed < 0.5
            PreTrials(i) = gambleShuffled(i,2);
        elseif seed >= 0.5
            PreTrials(i) = 0;
        end
    elseif choiceChoiceTrial(i) == 0
        PreTrials(i) = gambleShuffled(i,1);
    end
    
    if choiceFatiguedChoiceTrial(i) == 1
        seed = rand;
        if seed < 0.5
            PostTrials(i) = gambleShuffled_1(i,2);
        elseif seed >= 0.5
            PostTrials(i) = 0;
        end
    elseif choiceFatiguedChoiceTrial(i) == 0
        PostTrials(i) = gambleShuffled_1(i,1);
    end
end

% Play Out Gambles (1 success or 5 fails per gamble)
PreVoltTrial = NaN(5,1000);
PostVoltTrial = NaN(5,1000);
PreTimingTrial = NaN(5,1000);
PostTimingTrial = NaN(5,1000);
% ^NOTE: may not be completely filled if subjects succeed before 5th try
for i = 1:5
    count = 0;
    lever = 0;
    while lever == 0 && count < 5
        [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,PreTrials(i),'horizontal',4);
        PreVoltTrial(i,:) = volt;
        PreTimingTrial(i,:) = timing;
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],2)
            lever = 1;
            count = count+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],2)
            count = count+1;
        end
    end
    
    count = 0;
    lever = 0;
    while lever == 0 && count < 5
        [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,PostTrials(i),'horizontal',4);
        PostVoltTrial(i,:) = volt;
        PostTimingTrial(i,:) = timing;
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],2)
            lever = 1;
            count = count+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],2)
            count = count+1;
        end
    end
end



%% END