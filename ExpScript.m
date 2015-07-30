% Final Experiment Script for Fatigue Study
% Created by Steven Chen

clear; clc;
global DAR

try
    %% General Setup-------------------------------------------------------
    rng('shuffle'); %Generate new random seed
    addpath('Z:\Fatigue Experiment\Code\Components');
    addpath('Z:\Fatigue Experiment\Code\DAQ functions');
    
    %% Setup Subject Data--------------------------------------------------
    rootpath = 'Z:\Fatigue Experiment\Data';
    SubjectID=input('Enter Subject Identifier: ','s');
    FolderName = 'Pilot Data - 3'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    mkdir(SubjectDir);
    FileName = fullfile(SubjectDir,SubjectID);
    save(FileName,'SubjectID');

    %% Setup PsychToolBox--------------------------------------------------
    PsychDefaultSetup(2);screen=max(Screen('Screens'));
    [window,~]=PsychImaging('OpenWindow',screen,[0 0 0]);
    HideCursor(window);

    %% Setup DAQ-----------------------------------------------------------
%     Dummy
%     sensor = 1;
%     Old DAQ
%     sensor = analoginput('mcc'); %Default sample rate: 1000
%     chans=addchannel(sensor,0);
%     start(sensor);
%     TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
%     %Pausing to be sure that the sensor has time to equilibriate
%     baseline = getsample(sensor);

%     New DAQ
    time = 5;
    freq = 2000;
    startCollect(time,freq);

    TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
    baseline = mode(DAR(2,:));

    %% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION------------------------------
%     Here we are testing the subject's MVC, and using that value to
%     normalize the forces exerted in the subsequent parts of the
%     experiment.
%     
%     For running only this phase
% 
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);

    TextScreen(window,'Phase 1: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'Get Ready',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    numMVCTrials = 3; %3
    voltMVCTrial = NaN(numMVCTrials,time*freq);
    timingMVCTrial = NaN(numMVCTrials,time*freq);
    for i = 1:numMVCTrials
        [~,volt,timing] = TextScreen(window,'Squeeze!',[1 1 1],time,'DAQ',baseline);
        timingMVCTrial(i,:) = timing;
        voltMVCTrial(i,:) = volt;
        FixationCross(window,1+3*rand) %random duration btwn 1-4 sec
    end

    MVC = max(max(voltMVCTrial));
    MVC = 0.8*MVC;
    % ^We are adjusting the 'effort range' of 0 to 100 to map from no force, 
    % to 80% of the max force

    TextScreen(window,'End of Phase 1',[1 1 1],'key');

    %% PHASE 2: ASSOCIATION------------------------------------------------
%     Here, we are getting the subject to associate the amount of force
%     he/she exerts, and a number presented to them on the screen.
%     
%     For running only this phase
%     Dummy Vars
%     MVC = 1;
% 
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);

    TextScreen(window,'Phase 2: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'Get Ready',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    numAssocTrials = 5; %5
    PercentMVClevels = [10 20 30 40 50 60 70 80];
    PercentMVClevelshuffle = PercentMVClevels(randperm(numel(PercentMVClevels)));
    AssocTrial = repmat(PercentMVClevelshuffle,[numAssocTrials 1]);
    AssocTrial = AssocTrial(:);
    voltAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^rows-trial#, columns-voltages
    timingAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^timings associated with voltages
    outcomeAssocTrial = NaN(numel(AssocTrial),1);
    count = 0;
    count_1 = 0;
    for i = AssocTrial'
        count = count+1;
        count_1 = count_1+1;
        TextScreen(window,num2str(i),[1 1 1],2);
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,i/100,0.05,'vertical',time);
        voltAssocTrial(count,:) = volt;
        timingAssocTrial(count,:) = timing;
        outcomeAssocTrial(count) = outcome;
        if outcome == 1
            TextScreen(window,'Success',[0 1 0],2);
        elseif outcome == 0
            TextScreen(window,'Failure',[1 0 0],2);
        end
        FixationCross(window,1+3*rand);
        while count_1 == numAssocTrials
            TextScreen(window,'Rest',[1 1 1],60);
            count_1 = 0;
        end
    end
    
    AssocTrial = [AssocTrial outcomeAssocTrial];
    % ^40x2 representing each individual trial and their outcomes
    TextScreen(window,'End of Phase 2',[1 1 1],'key');

    %% PHASE 3: RECALL-----------------------------------------------------
%     Here, we test to see if the subject has associated the numbers with
%     the force exerted.
%     
%     For running only this phase
% 
%     Dummy Vars
%     MVC = 1;
% 
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);

    TextScreen(window,'Phase 3: Please wait for instructions',[1 1 1],'key');

    time = 4;
    freq = 2000;
    numTrialReps = 2; %2
    numRecallTrials = 3; %3
    voltRecallTrial = NaN(8*numRecallTrials*numTrialReps,time*freq);
    reportRecallTrial = NaN(8*numRecallTrials*numTrialReps,1);
    reacttimeRecallTrial = NaN(8*numRecallTrials*numTrialReps,1);
    timingRecallTrial = NaN(8*numRecallTrials*numTrialReps,time*freq);
    outcomeRecallTrial = NaN(8*numRecallTrials*numTrialReps,1);
    PercentMVClevels_6_shuffle = NaN(8*numRecallTrials*numTrialReps,1);
    count = 0;
    for i = 1:numTrialReps
        TextScreen(window,'Get Ready',[1 1 1],1.5);
        PercentMVClevels = [10 20 30 40 50 60 70 80];
        PercentMVClevels_3 = repmat(PercentMVClevels,[numRecallTrials,1]);
        PercentMVClevels_3_shuffle = PercentMVClevels_3(randperm(numel(PercentMVClevels_3)));
        for j = PercentMVClevels_3_shuffle
            count = count+1;
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,j/100,0.05,'horizontal',time);
            voltRecallTrial(count,:) = volt;
            timingRecallTrial(count,:) = timing;
            outcomeRecallTrial(count) = outcome;
            [EffortReport,ReactTime] = NumberLineScreen(window);
            reportRecallTrial(count) = EffortReport;
            reacttimeRecallTrial(count) = ReactTime;
            PercentMVClevels_6_shuffle(count) = j;
        end
        TextScreen(window,'Rest',[1 1 1],60);
    end

    RecallTrial = [PercentMVClevels_6_shuffle reportRecallTrial ... 
        reacttimeRecallTrial outcomeRecallTrial];
    % ^rows-recall trial#, column1-actual MVC percentage, column2-reported MVC
    % percentage, column3-reaction time, column4-success or failure of
    % trial

    TextScreen(window,'End of Phase 3',[1 1 1],'key');

    %% PHASE 4: CHOICE-----------------------------------------------------
%     Here, we have the subjects choose between an effort gamble and a sure
%     value in order to get their inherent risk preferences in the effort
%     domain.
%     
%     For running only this phase
%     Dummy Vars
%     MVC = 1;
% 
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);

    TextScreen(window,'Phase 4: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'Get Ready',[1 1 1],1.5);

    load('Z:\Fatigue Experiment\Code\Gambles_12_5.mat');
    gambles = Gambles_12_5;
    [r,~] = size(gambles);
    gambleShuffled = gambles(randperm(r),:);

    numChoiceTrials = r; %r
    choiceChoiceTrial = NaN(numChoiceTrials,1);
    reacttimeChoiceTrial = NaN(numChoiceTrials,1);
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
    % ^rows-gamble trial#, column1-sure, column2-flip, column3-choice,
    % column4-reaction time

    TextScreen(window,'End of Phase 4',[1 1 1],'key');

    %% PHASE 5: FATIGUED CHOICE--------------------------------------------
%     Here, we have the subjects make the same choices they made in phase
%     4, but now they are bein kept at a consistent level of motor fatigue,
%     achieved by doing repetitive squeeze tasks in between their choice 
%     inputs.
%     
%     For running only this phase
% 
%     Dummy Vars
%     MVC = 1;
%     
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);
% 
%     load('Z:\Fatigue Experiment\Code\Gambles_12_5.mat');
%     gambles = Gambles_12_5;
%     [r,~] = size(gambles);
%     gambleShuffled = gambles(randperm(r),:);

    TextScreen(window,'Phase 5: Please wait for instructions',[1 1 1],'key');
    
    time = 4;
    freq = 2000;
    gambleShuffled_1 = gambles(randperm(r),:);
    MVCFatiguePercent = 80; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FailureThreshold = 75; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numChoicesPerTrial = 10;
    numFatigueTrials = r/numChoicesPerTrial;
    numFatiguedChoiceTrials = r;
    choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
    reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
    voltFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
    timingFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
    outcomeFatiguedChoiceTrial = NaN(numFatigueTrials,300);
    
    for i = 1:numFatigueTrials
        success = 0;
        failure = 0;
        if i == 1
            % Initial Fatigue - minimum of 10 reps
            minFatigueReps = 10;
        else
            % Subsequent Fatigue - minimum of 5 reps
            minFatigueReps = 5;
        end
        TextScreen(window,'Squeeze Phase',[1 1 1],2);
        TextScreen(window,'Get Ready',[1 1 1],1.5);
        % min reps
        for j = 1:minFatigueReps
            [outcome,volt,timing] = ThermScreen(window,sensor,baseline,MVC,MVCFatiguePercent/100,0.05,'horizontal',time);
            voltFatiguedChoiceTrial(j,:,i) = volt;
            timingFatiguedChoiceTrial(j,:,i) = timing;
            outcomeFatiguedChoiceTrial(i,j) = outcome;
            if outcome == 1
                success = success+1;
            elseif outcome == 0
                failure = failure+1;
            end
            FixationCross(window,3);
        end
        % until failure threshold
        j = minFatigueReps;
        while success/failure > (100-FailureThreshold)/FailureThreshold
            j = j+1;
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,0.05,'horizontal',time);
            voltFatiguedChoiceTrial(j,:,i) = volt;
            timingFatiguedChoiceTrial(j,:,i) = timing;
            outcomeFatiguedChoiceTrial(i,j) = outcome;
            if outcome == 1
                success = success+1;
            elseif outcome == 0
                failure = failure+1;
            end
            FixationCross(window,3);
        end

        % Post-Fatigue Choice Trials
        TextScreen(window,'Gamble Phase',[1 1 1],2);
        TextScreen(window,'Get Ready',[1 1 1],1.5);
        ChoiceLeftIndex = (i-1)*numChoicesPerTrial+1;
        ChoiceRightIndex = i*numChoicesPerTrial;
        for k = ChoiceLeftIndex:ChoiceRightIndex
            flip = gambleShuffled_1(k,2);
            sure = gambleShuffled_1(k,1);
            [choice,ReactTime] = GambleScreen(window,flip,sure,4);
            FixationCross(window,1+3*rand);
            choiceFatiguedChoiceTrial(k) = choice; %NOTE: 1 = flip, 0 = sure
            reacttimeFatiguedChoiceTrial(k) = ReactTime;
        end
    end

    FatiguedChoiceTrial = [gambleShuffled_1(:,[1 2]) choiceFatiguedChoiceTrial ...
        reacttimeFatiguedChoiceTrial];
    % ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
    % column4-reaction time

    TextScreen(window,'End of Phase 5',[1 1 1],'key');

    %% PHASE 6: TRIAL SELECTION--------------------------------------------
%     Here, we play out 10 of the choices that were made in the previous 2
%     phases, in order to validate that the subject is treating each
%     choice made in the previous phases independently from one another,
%     and with potential consequences.
%     
%     For running only this phase
% 
%     Dummy Vars
%     MVC = 1;
% 
%     PsychDefaultSetup(2);screen=max(Screen('Screens'));
%     [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
%     HideCursor(window);
%     
%     load('Z:\Fatigue Experiment\Code\Gambles_12_5.mat');
%     gambles = Gambles_12_5;
%     [r,~] = size(gambles);
%     gambleShuffled = gambles(randperm(r),:);
%     gambleShuffled_1 = gambles(randperm(r),:);

    TextScreen(window,'Phase 6: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'Get Ready',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    % Randomly select 10 choice trials from pre/post fatigue
    CombinedTrial = [ChoiceTrial; FatiguedChoiceTrial];
    TrialSelectionTrial = NaN(10,1);
    count = 0;
    for i = randperm(length(CombinedTrial),10)
        while isnan(CombinedTrial(i,3)) == 1
            i = randperm(length(CombinedTrial),1);
        end
        count = count+1;
        if CombinedTrial(i,3) == 1 %Random seed to determine 0 or flip value
            seed = rand;
            if seed < 0.5
                TrialSelectionTrial(count) = CombinedTrial(i,2);
            elseif seed >= 0.5
                TrialSelectionTrial(count) = 0;
            end
        elseif CombinedTrial(i,3) == 0
            TrialSelectionTrial(count) = CombinedTrial(i,1);
        end
    end
    
    % Play Out Gambles (1 success or 5 fails per gamble)
    voltTrialSelectionTrial = NaN(5,time*freq,10);
    timingTrialSelectionTrial = NaN(5,time*freq,10);
    
    for i = 1:length(TrialSelectionTrial)
        FailCount = 0;
        lever = 0;
        while lever == 0 && FailCount < 5
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,TrialSelectionTrial(i)/100,0.05,'horizontal',4);
            voltTrialSelectionTrial(FailCount+1,:,i) = volt;
            timingTrialSelectionTrial(FailCount+1,:,i) = timing;
            if outcome == 1
                TextScreen(window,'Success',[0 1 0],2)
                lever = 1;
                if i == length(TrialSelectionTrial)
                    break;
                else
                    TextScreen(window,'Next Gamble',[1 1 1],2);
                end
            elseif outcome == 0
                TextScreen(window,'Failure',[1 0 0],2)
                FailCount = FailCount+1;
                if FailCount == 5
                    if i == length(TrialSelectionTrial)
                        break;
                    else
                        TextScreen(window,'Next Gamble',[1 1 1],2);
                    end
                end
            end
        end
    end

    TextScreen(window,'End of Phase 6',[1 1 1],'key');

    sca;

    %% SAVE SUBJECT DATA-------------------------------------------------------
    MVCFileName = fullfile(SubjectDir,'MVCPhase');
    AssocFileName = fullfile(SubjectDir,'AssocPhase');
    RecallFileName = fullfile(SubjectDir,'RecallPhase');
    ChoiceFileName = fullfile(SubjectDir,'ChoicePhase');
    FatiguedChoiceFileName = fullfile(SubjectDir,'FatiguedChoicePhase');
    TrialSelectionFileName = fullfile(SubjectDir,'TrialSelectionPhase');

    save(MVCFileName,'voltMVCTrial','timingMVCTrial');
    save(AssocFileName,'AssocTrial','voltAssocTrial','timingAssocTrial');
    save(RecallFileName,'RecallTrial','voltRecallTrial','timingRecallTrial');
    save(ChoiceFileName,'ChoiceTrial');
    save(FatiguedChoiceFileName,'FatiguedChoiceTrial', ...
        'timingFatiguedChoiceTrial', 'voltFatiguedChoiceTrial', ...
        'outcomeFatiguedChoiceTrial');
    save(TrialSelectionFileName,'TrialSelectionTrial', ...
        'voltTrialSelectionTrial','timingTrialSelectionTrial');
catch
    sca;
end

%% END