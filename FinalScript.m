% Final Script for Fatigue Study
% Created by Steven Chen

try
    clear; clc;
    rng('shuffle'); %Generate new random seed

    %% Setup Subject Data--------------------------------------------------
    % rootpath='Y:\Fatigue Experiment'; %Patrick's Account
    % rootpath = 'C:\Users\mcdonaldme\Desktop'; %Megan's Account
    rootpath = 'C:\Users\Steven\Documents'; %Steven's Account
    SubjectID=input('Enter Subject Identifier: ','s');
    FolderName = 'Pilot Data';
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    mkdir(SubjectDir);
    FileName = fullfile(SubjectDir,SubjectID);
    save(FileName,'SubjectID');

    %% Setup PsychToolBox--------------------------------------------------
    PsychDefaultSetup(2);screen=max(Screen('Screens'));
    [window,~]=PsychImaging('OpenWindow',screen,[0 0 0]);
    HideCursor(window);

    %% Setup DAQ-----------------------------------------------------------
    % Dummy
    % sensor = 1;
    global DAR
    % Old DAQ
    % sensor = analoginput('mcc'); %Default sample rate: 1000
    % chans=addchannel(sensor,0);
    % start(sensor);
    % TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
    % % Pausing to be sure that the sensor has time to equilibriate
    % baseline = getsample(sensor);

    % New DAQ
    % Personal Laptop
    % cd('C:\Users\StevenChen\Documents\MATLAB\Fatigue Code\DAQ functions');
    % Steven's Account
    cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions'); 
    time = 5;
    freq = 2000;
    startCollect(time,freq);

    % pause(5);
    % KKI Computer
    % cd('Y:\Fatigue Code\Components')
    % Personal Laptop
    % cd 'C:\Users\Steven Chen\Documents\MATLAB\Fatigue Code\Components'
    % Steven's Computer
    cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\Components')
    TextScreen(window,'Calibrating - Dont touch the sensor!',[1 1 1],5);
    baseline = mode(DAR(2,:));

    %% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION----------------------------------

    % For running only this phase

    % Dummy
    % sensor = 1;

    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);

    TextScreen(window,'Phase 1: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    numMVCTrials = 3; %3
    voltMVCTrial = NaN(numMVCTrials,time*freq); %rows-trial#, columns-voltages
    timingMVCTrial = NaN(numMVCTrials,time*freq);
    for i = 1:numMVCTrials
        [~,volt,timing] = TextScreen(window,'SQUEEZE!',[1 1 1],time,'DAQ',baseline);
        timingMVCTrial(i,:) = timing;
        voltMVCTrial(i,:) = volt;
        FixationCross(window,1+3*rand) %random duration btwn 1-4 sec
    end

    MVC = max(max(voltMVCTrial));
    MVC = 0.8*MVC;
    % ^We are adjusting the 'effort range' of 0 to 100 to map from no force, 
    % to 80% of the max force

    TextScreen(window,'End of Phase 1',[1 1 1],'key');

    %% PHASE 2: ASSOCIATION----------------------------------------------------

    % For running only this phase
    % Dummy Vars
    % MVC = 1;
    % sensor = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);

    TextScreen(window,'Phase 2: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    numAssocTrials = 5; %5
    PercentMVClevels = [10 20 30 40 50 60 70 80];
    PercentMVClevelshuffle = PercentMVClevels(randperm(numel(PercentMVClevels)));
    AssocTrial = repmat(PercentMVClevelshuffle,[numAssocTrials 1]);
    AssocTrial = AssocTrial(:);
    % ^40x1 representing each individual trial
    voltAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^rows-trial#, columns-voltages
    timingAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^timings associated with voltages

    count = 0;
    count_1 = 0;
    for i = AssocTrial'
        count = count+1;
        count_1 = count_1+1;
        TextScreen(window,num2str(i),[1 1 1],2);
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,i/100,0.05,'vertical',time);
        voltAssocTrial(count,:) = volt;
        timingAssocTrial(count,:) = timing;
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

    time = 4;
    freq = 2000;
    numRecallTrials = 3; %3
    PercentMVClevels = [10 20 30 40 50 60 70 80];
    PercentMVClevels_3 = repmat(PercentMVClevels,[numRecallTrials,1]);
    PercentMVClevels_3_shuffle = PercentMVClevels_3(randperm(numel(PercentMVClevels_3)));
    voltRecallTrial = NaN(numel(PercentMVClevels_3),time*freq);
    reportRecallTrial = NaN(numel(PercentMVClevels_3),1);
    reacttimeRecallTrial = NaN(numel(PercentMVClevels_3),1);
    timingRecallTrial = NaN(numel(PercentMVClevels_3),time*freq);
    count = 0;
    for i = PercentMVClevels_3_shuffle
        count = count+1;
        [~,volt,timing] = ThermScreen(window,baseline,MVC,i/100,0.05,'horizontal',time);
        voltRecallTrial(count,:) = volt;
        timingRecallTrial(count,:) = timing;
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

    PsychDefaultSetup(2);screen=max(Screen('Screens'));
    [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    HideCursor(window);

    TextScreen(window,'Phase 4: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);

    load('C:\Users\Steven\Documents\MATLAB\FatigueCode\Gambles_12_5.mat');
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

    %% PHASE 5: FATIGUED CHOICE------------------------------------------------

    % For running only this phase

    % Dummy Vars
    % MVC = 1;
    % sensor = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);

    % load('C:\Users\Steven\Documents\MATLAB\FatigueCode\Gambles_12_5.mat');
    % gambles = Gambles_12_5;
    % [r,~] = size(gambles);
    % gambleShuffled = gambles(randperm(r),:);

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
    voltFatiguedChoiceTrial = NaN(100,time*freq,numFatigueTrials);
    timingFatiguedChoiceTrial = NaN(100,time*freq,numFatigueTrials);
    outcomeFatiguedChoiceTrial = NaN(100,numFatigueTrials);
    
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
        TextScreen(window,'SQUEEZE PHASE',[1 1 1],2);
        TextScreen(window,'GET READY',[1 1 1],1.5);
        % min reps
        for n = 1:minFatigueReps
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,0.05,'horizontal',time);
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
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,0.05,'horizontal',time);
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

    %% PHASE 6: TRIAL SELECTION------------------------------------------------

    % For running only this phase

    % Dummy Vars
    % MVC = 1;
    % sensor = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);

    % load('C:\Users\Steven\Documents\MATLAB\FatigueCode\Gambles_12_5.mat');
    % gambles = Gambles_12_5;
    % [r,~] = size(gambles);
    % gambleShuffled = gambles(randperm(r),:);
    % gambleShuffled_1 = gambles(randperm(r),:);

    TextScreen(window,'Phase 6: Please wait for instructions',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);

    time = 4;
    freq = 2000;
    % Randomly select 5 choice trials from pre/post fatigue
    PreTrial = NaN(5,1);
    PostTrial = NaN(5,1);
    count = 0;
    for i = randperm(length(ChoiceTrial),5) 
        % NOTE: here, length(ChoiceTrial) is the same as length(FatiguedChoiceTrial), 
        % so both are in the same for loop. If the number of gambles for each 
        % phase is different, this needs to be changed.
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
    voltPreTrial = NaN(5,time*freq);
    voltPostTrial = NaN(5,time*freq);
    timingPreTrial = NaN(5,time*freq);
    timingPostTrial = NaN(5,time*freq);
    % ^NOTE: Only records the 5th trial or success trial
    for i = 1:5
        FailCount = 0;
        lever = 0;
        while lever == 0 && FailCount < 5
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,PreTrial(i)/100,0.05,'horizontal',time);
            voltPreTrial(i,:) = volt;
            timingPreTrial(i,:) = timing;
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
            [outcome,volt,timing] = ThermScreen(window,baseline,MVC,PostTrial(i)/100,0.05,'horizontal',4);
            voltPostTrial(i,:) = volt;
            timingPostTrial(i,:) = timing;
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
    save(FatiguedChoiceFileName,'FatiguedChoiceTrial','timingFatiguedChoiceTrial', ...
        'voltFatiguedChoiceTrial','outcomeFatiguedChoiceTrial');
    save(TrialSelectionFileName,'PreTrial','voltPreTrial','timingPreTrial', ...
        'PostTrial','voltPostTrial','timingPostTrial');
catch
    sca;
end

%% END