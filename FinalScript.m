% Final Script for Fatigue Study
% Created by Steven Chen

clear; clc;
rng('shuffle'); %Generate new random seed
% cd 'C:\Users\Steven Chen\Documents\MATLAB\Fatigue Code\Components' %For personal laptop

%% Setup Subject Data------------------------------------------------------

% rootpath='Y:\Fatigue Experiment'; %Patrick's Account
rootpath = 'C:\Users\mcdonaldme\Desktop'; %Megan's Account
SubjectID=input('Enter Subject Identifier: ','s');
FolderName = 'Pilot Data';
SubjectDir = fullfile(rootpath,FolderName,SubjectID);
mkdir(SubjectDir);
FileName = fullfile(SubjectDir,SubjectID);
save(FileName,'SubjectID');

%% Setup PsychToolBox------------------------------------------------------

% cd('Y:\Fatigue Code\Components') %For KKI computer
PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

%% Setup DAQ---------------------------------------------------------------
% Dummy
% sensor = 1;

sensor = analoginput('mcc'); %Default sample rate: 1000
chans=addchannel(sensor,0);
start(sensor);
TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
% Pausing to be sure that the sensor has time to equilibriate
baseline = getsample(sensor);

%% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION----------------------------------
 
% For running only this phase

% Dummy
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% HideCursor(window);

TextScreen(window,'Phase 1: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

numMVCTrials = 3;
MVCTrial = NaN(numMVCTrials,1000); %rows-trial#, columns-voltages
MVCTiming = NaN(numMVCTrials,1000);
for i = 1:numMVCTrials
    [~,volt,timing] = TextScreen(window,'SQUEEZE!',[1 1 1],4,sensor,baseline);
    MVCTiming(i,:) = timing;
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
% HideCursor(window);

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
for i = AssocTrial'
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
% HideCursor(window);

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
% HideCursor(window);

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

ChoiceTrial = [gambleShuffled(1:numChoiceTrials,[1 2]) choiceChoiceTrial ... 
    reacttimeChoiceTrial];
% ^rows-gamble trial#, column1-snure, column2-flip, column3-choice,
% column4-reaction time

TextScreen(window,'End of Phase 4',[1 1 1],'key');

%% PHASE 5: FATIGUED CHOICE------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;

% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% HideCursor(window);

% load('Gambles_12_5.mat');
% gambles = Gambles_12_5;
% [r,~] = size(gambles);
% gambleShuffled = gambles(randperm(r),:);

TextScreen(window,'Phase 5: Please wait for instructions',[1 1 1],'key');

gambleShuffled_1 = gambles(randperm(r),:);
MVCFatiguePercent = 60;
FailureThreshold = 50;
numFatigueTrials = 2; %%%%%%%%%%%%%%HOW MANY DO WE DO? (TEST THIS)
minFatigueContractions = 10;
numFatiguedChoiceTrials = r;
choiceFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);
reacttimeFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);

for i = 1:numFatigueTrials
    TextScreen(window,'Fatigue Phase: Press any key to continue',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);
    
    % initial mandatory trials (adjusted by minFatigueContractions)
    success = 0;
    failure = 0;
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
    
    TextScreen(window,'Gamble Phase: Press any key to continue',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);
    
    % Post-Fatigue Choice Trials
    
    % NOTE: numFatiguedChoiceTrials/numFatigueTrials only works if it's an
    % integer
    TempLeftIndex = 1+(i-1)*numFatiguedChoiceTrials/numFatigueTrials;
    TempRightIndex = i*numFatiguedChoiceTrials/numFatigueTrials;
    for j = TempLeftIndex:TempRightIndex
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

%% PHASE 6: TRIAL SELECTION------------------------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
HideCursor(window);

% load('Gambles_12_5.mat');
% gambles = Gambles_12_5;
% [r,~] = size(gambles);
% gambleShuffled = gambles(randperm(r),:);
% gambleShuffled_1 = gambles(randperm(r),:);

TextScreen(window,'Phase 6: Please wait for instructions',[1 1 1],'key');
TextScreen(window,'GET READY',[1 1 1],1.5);

% Randomly select 5 choice trials from pre/post fatigue
PreTrial = zeros(5,1);
PostTrial = zeros(5,1);
count = 0;
for i = randi(length(ChoiceTrial),[1 5]) 
    % NOTE: here, length(ChoiceTrial) is the same as length(FatiguedChoiceTrial), 
    % so both are in the same for loop. If the number of gambles for each 
    % phase is different, this needs to be changed.
    % NOTE: there is a very small chance that there will be repeated
    % gambles during this phase.
    count = count+1;
    if ChoiceTrial(i,3) == 1 %Random seed to determine 0 or flip value
        seed = rand;
        if seed < 0.5
            PreTrial(count) = gambleShuffled(i,2);
        elseif seed >= 0.5
            PreTrial(count) = 0;
        end
    elseif ChoiceTrial(i,3) == 0
        PreTrial(count) = gambleShuffled(i,1);
    end
    
    if FatiguedChoiceTrial(i,3) == 1
        seed = rand;
        if seed < 0.5
            PostTrial(count) = gambleShuffled_1(i,2);
        elseif seed >= 0.5
            PostTrial(count) = 0;
        end
    elseif FatiguedChoiceTrial(i,3) == 0
        PostTrial(count) = gambleShuffled_1(i,1);
    end
end

% Play Out Gambles (1 success or 5 fails per gamble)
PreVoltTrial = NaN(5,1000);
PostVoltTrial = NaN(5,1000);
PreTimingTrial = NaN(5,1000);
PostTimingTrial = NaN(5,1000);
% ^NOTE: Only records the 5th trial or success trial
for i = 1:5
    FailCount = 0;
    lever = 0;
    while lever == 0 && FailCount < 5
        TextScreen(window,num2str(PreTrial(i)),[1 1 1],2);
        [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,PreTrial(i)/100,'vertical',4);
        PreVoltTrial(i,:) = volt;
        PreTimingTrial(i,:) = timing;
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],2)
            lever = 1;
            TextScreen(window,'NEXT GAMBLE',[1 1 1],2);
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],2)
            FailCount = FailCount+1;
            if FailCount == 5
                TextScreen(window,'NEXT GAMBLE',[1 1 1],2);
            end
        end
    end
    
    FailCount = 0;
    lever = 0;
    while lever == 0 && FailCount < 5
        TextScreen(window,num2str(PostTrial(i)),[1 1 1],2);
        [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,PostTrial(i)/100,'vertical',4);
        PostVoltTrial(i,:) = volt;
        PostTimingTrial(i,:) = timing;
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],2)
            lever = 1;
            if i == 5
                break;
            else
                TextScreen(window,'NEXT GAMBLE',[1 1 1],2);
            end
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],2)
            FailCount = FailCount+1;
            if FailCount == 5
                if i == 5
                    break;
                else
                    TextScreen(window,'NEXT GAMBLE',[1 1 1],2);
                end
            end
        end
    end
end

TextScreen(window,'End of Phase 6',[1 1 1],'key');

%% SAVE SUBJECT DATA-------------------------------------------------------
MVCFileName = fullfile(SubjectDir,'MVCPhase');
AssocFileName = fullfile(SubjectDir,'AssocPhase');
RecallFileName = fullfile(SubjectDir,'RecallPhase');
ChoiceFileName = fullfile(SubjectDir,'ChoicePhase');
FatiguedChoiceFileName = fullfile(SubjectDir,'FatiguedChoicePhase');
TrialSelectionFileName = fullfile(SubjectDir,'TrialSelectionPhase');

save(MVCFileName,'MVCTrial','MVCTiming');
save(AssocFileName,'AssocTrial','voltAssocTrial','AssocTiming');
save(RecallFileName,'RecallTrial','voltRecallTrial','RecallTiming');
save(ChoiceFileName,'ChoiceTrial');
save(FatiguedChoiceFileName,'FatiguedChoiceTrial');
save(TrialSelectionFileName,'PreTrial','PreVoltTrial','PreTimingTrial', ...
    'PostTrial','PostVoltTrial','PostTimingTrial');


%% END