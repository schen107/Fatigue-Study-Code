% Final Script for Fatigue Study
% Steven Chen

clear; clc;
%% Setup PsychToolBox------------------------------------------------------

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

%% Setup DAQ---------------------------------------------------------------
% Dummy
sensor = 1;

% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

%% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION----------------------------------

% For running only this phase

% Dummy Vars
% MVC = 1;
% sensor = 1;
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);


% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 1: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

numMVCtrials = 3;
voltMVCTrial = NaN(1000,numMVCtrials);
for i = 1:numMVCtrials
    [~,volt] = TextScreen(window,'SQUEEZE!',4,sensor);
    voltMVCTrial(:,i) = abs(volt-sensor); %-baseline);
    FixationCross(window,1+3*rand) %random duration btwn 1-4 sec
end

MVC = max(max(voltMVCTrial));

TextScreen(window,'End of Phase 1','key');

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
% 
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 2: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

MVClevels = [10 20 30 40 50 60 70 80];
MVClevelshuffle = MVClevels(randperm(numel(MVClevels)));
numAssocTrials = 5;
voltAssocTrial = NaN(numAssocTrials,numel(MVClevels),1000);
count = 0;

for i = MVClevelshuffle
    count = count+1;
    for n = 1:numAssocTrials
        TextScreen(window,num2str(i),2);
        [outcome,volt] = ThermScreen(window,sensor,MVC,i/100,'vertical',4);
        voltAssocTrial(n,count,:) = abs(volt-sensor); %-baseline);
        if outcome == 1
            TextScreen(window,'SUCCESS',2);
        elseif outcome == 0
            TextScreen(window,'FAILURE',2);
        end
        FixationCross(window,1+3*rand);
    end
    
    TextScreen(window,'REST',60);
end

TextScreen(window,'End of Phase 2','key');

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
% baseline = baseline(1);

TextScreen(window,'Phase 3: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

numRecallTrials = 3;
MVClevels = [10 20 30 40 50 60 70 80];
MVClevels_3 = repmat(MVClevels,[numRecallTrials,1]);
MVClevels_3_shuffle = MVClevels_3(randperm(numel(MVClevels_3)));
voltRecallTrial = NaN(1000,numel(MVClevels_3)); %DO WE NEED A VOLTAGE HERE?
reportRecallTrial = zeros(numel(MVClevels_3),1);
reacttimeRecallTrial = zeros(numel(MVClevels_3),1);
count = 0;
for i = MVClevels_3_shuffle
    count = count+1;
    [~,volt] = ThermScreen(window,sensor,MVC,i/100,'horizontal',4);
    voltRecallTrial(:,count) = abs(volt-sensor); %-baseline);
    [EffortReport,ReactTime] = NumberLineScreen(window);
    reportRecallTrial(count) = EffortReport;
    reacttimeRecallTrial(count) = ReactTime;
end

TextScreen(window,'REST',60);
TextScreen(window,'End of Phase 3','key');

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
% 
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 4: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

load('Gambles_12_5.mat');
gambles = Gambles_12_5;
[r,~] = size(gambles);
gambleShuffled = gambles(randperm(r),:);
numChoiceTrials = r;
ChoiceTrial = zeros(numChoiceTrials,1);
reacttimeChoiceTrial = zeros(numChoiceTrials,1);
for i = 1:numChoiceTrials
    flip = gambleShuffled(i,2);
    sure = gambleShuffled(i,1);
    [choice,ReactTime] = GambleScreen(window,flip,sure,4);
    FixationCross(window,1+3*rand);
    reacttimeChoiceTrial(i) = ReactTime;
    ChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
end

TextScreen(window,'End of Phase 4','key');

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
% 
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 5: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

gambleShuffled_1 = gambles(randperm(r),:);
MVCFatiguePercent = 60;
FailureThreshold = 50;
numFatigueTrials = 2;
minFatigueContractions = 10;
numFatiguedChoiceTrials = r;
FatiguedChoiceTrial = [];
reacttimeFatiguedChoiceTrial = [];

for i = 1:numFatigueTrials
    success = 0;
    failure = 0;
    % iniial mandatory trials
    for n = 1:minFatigueContractions
        outcome = ThermScreen(window,sensor,MVC,MVCFatiguePercent/100,'horizontal',4);
        if outcome == 1
            TextScreen(window,'SUCCESS',1);
            success = success+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',1);
            failure = failure+1;
        end
        FixationCross(window,3);
    end
    % conditional extra trials - if 50% failure, then criteria for fatigue
    % is met
    while success/failure > (100-FailureThreshold)/FailureThreshold
        outcome = ThermScreen(window,sensor,MVC,MVCFatiguePercent/100,'horizontal',4);
        if outcome == 1
            TextScreen(window,'SUCCESS',1);
            success = success+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',1);
            failure = failure+1;
        end
        FixationCross(window,3);
    end
    % Post-Fatigue Choice Trials
    TempFatiguedChoice = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
    % NOTE: numFatiguedChoiceTrials/numFatigueTrials only works if it's an
    % integer
    TempReacttime = zeros(numFatiguedChoiceTrials/numFatigueTrials,1);
    for j = 1:numFatiguedChoiceTrials/numFatigueTrials
        flip = gambleShuffled_1(i,2);
        sure = gambleShuffled_1(i,1);
        [choice,ReactTime] = GambleScreen(window,flip,sure,4);
        FixationCross(window,1+3*rand);
        TempFatiguedChoice(j) = choice; %NOTE: 1 = flip, 0 = sure
        TempReacttime(j) = ReactTime;
    end
    FatiguedChoiceTrial = append(FatiguedChoiceTrial,TempFatiguedChoice);
    reacttimeFatiguedChoiceTrial = append(reacttimeFatiguedChoiceTrial,TempReacttime);
end

TextScreen(window,'End of Phase 5','key');

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

TextScreen(window,'Phase 6: Please wait for instructions','key');
TextScreen(window,'GET READY',1.5);

% Select first 5 choice trials from pre/post fatigue
PreTrials = zeros(5,1);
PostTrials = zeros(5,1);
for i = 1:5
    if ChoiceTrial(i) == 1
        PreTrials(i) = gambleShuffled(i,2);
    elseif ChoiceTrial(i) == 0
        PreTrials(i) = gambleShuffled(i,1);
    end
    
    if FatiguedChoiceTrial(i) == 1
        PostTrials(i) = gambleShuffled_1(i,2);
    elseif FatiguedChoiceTrial(i) == 0
        PostTrials(i) = gambleShuffled_1(i,1);
    end
end

% Play Out Gambles (1 success or 5 fails per gamble)

for i = 1:5
    count = 0;
    lever = 0;
    while lever == 0 && count < 5
        [outcome,~] = ThermScreen(window,sensor,MVC,PreTrials(i),'horizontal',4);
        if outcome == 1
            TextScreen(window,'Success',2)
            lever = 1;
            count = count+1;
        elseif outcome == 0
            TextScreen(window,'Failure',2)
            count = count+1;
        end
    end
    
    count = 0;
    lever = 0;
    while lever == 0 && count < 5
        [outcome,~] = ThermScreen(window,sensor,MVC,PostTrials(i),'horizontal',4);
        if outcome == 1
            TextScreen(window,'Success',2)
            lever = 1;
            count = count+1;
        elseif outcome == 0
            TextScreen(window,'Failure',2)
            count = count+1;
        end
    end
end


%% END