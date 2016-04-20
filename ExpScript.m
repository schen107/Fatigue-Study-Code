%% Final Experiment Script for Fatigue Study
% Created by Steven Chen

clear; clc;

% For switching between force sensors (DAQ) and MRI compatibilty (MRI)
global DAQ MRI

% For data collection in the new force sensor (DAQ = 1)
global DAR

% For experimental image timings in both behavioral and MRI settings,
% TRIGGER is initialized at the start of each phase or session.
global TRIGGER

DAQ = 0; %1 - New Sensor, 0 - MRI Sensor
MRI = 1; %1 - yes MRI, 0 - No MRI


%% General Setup-------------------------------------------------------
rng('shuffle'); %Generate new random seed
% Screen('Preference', 'SkipSyncTests', 1);
cd('C:\Users\ChenSt\Desktop\FatigueCode');
addpath('C:\Users\ChenSt\Desktop\FatigueCode\Components');
addpath('C:\Users\ChenSt\Desktop\FatigueCode\DAQ functions');
%% Setup Subject Data--------------------------------------------------
if MRI == 0
    rootpath = 'Z:\Fatigue Experiment\Data';
elseif MRI == 1
    rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
end
SubjectID=input('Enter Subject Identifier: ','s');
FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjectDir = fullfile(rootpath,FolderName,SubjectID);
mkdir(SubjectDir);
FileName = fullfile(SubjectDir,SubjectID);
save(FileName,'SubjectID');

try
    %% Setup PsychToolBox--------------------------------------------------
    PsychDefaultSetup(2);screen=max(Screen('Screens'));
    [window,~]=PsychImaging('OpenWindow',screen,[0 0 0]);
    HideCursor(window);

    %% Setup DAQ-----------------------------------------------------------
    % sensor = 1; %Dummy sensor
    [sensor, baseline, chans] = setupDaq(window);

    %% PHASE 1: MAXIMUM VOLUNTARY CONTRACTION------------------------------
    % Here we are testing the subject's MVC, and using that value to 
    % normalize the forces exerted in the subsequent parts of the 
    % experiment.
    %
    % For running only this phase
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);

    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    TRIGGER = GetSecs;
    P1Timings.trigger = TRIGGER;
    [~,~,~,P1Timings.instructions] = TextScreen( ...
        window,'Phase 1: Please wait for instructions',[1 1 1],'key');
    [~,~,~,P1Timings.getready] = TextScreen( ...
        window,'Get Ready',[1 1 1],1.5);

    time = 4;
    if DAQ == 0
        freq = Screen('NominalFrameRate', window) ;
    elseif DAQ == 1
        freq = 2000;
    end
    numMVCTrials = 3; %3
    voltMVCTrial = NaN(numMVCTrials,time*freq);
    timingMVCTrial = NaN(numMVCTrials,time*freq);
    for i = 1:numMVCTrials
        [~,volt,timing,P1Timings.MVC(i)] = TextScreen(window, ...
            'Squeeze!',[1 1 1],time,sensor,baseline);
        timingMVCTrial(i,:) = timing;
        voltMVCTrial(i,:) = volt;
        % random duration btwn 1-4 sec
        P1Timings.fixcross(i) = FixationCross(window,1+3*rand);
    end

    MVC = max(max(voltMVCTrial));
    MVC = 0.8*MVC;
    % ^We are adjusting the 'effort range' of 0 to 100 to map from no force
    % to 80% of the max force

    [~,~,~,P1Timings.end] = TextScreen(window, ...
        'End of Phase 1',[1 1 1],'key');

    % save data
    MVCFileName = fullfile(SubjectDir,'MVCPhase');
    save(MVCFileName,'MVC','voltMVCTrial','timingMVCTrial','P1Timings');

    %% PHASE 2: ASSOCIATION------------------------------------------------
    % Here, we are getting the subject to associate the amount of force
    % he/she exerts, and a number presented to them on the screen.
    % 
    % For running only this phase
    % Dummy Vars
    % MVC = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);
    
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
    
    TRIGGER = GetSecs;
    P2Timings.trigger = TRIGGER;
    [~,~,~,P2Timings.instructions] = TextScreen(window, ...
        'Phase 2: Please wait for instructions',[1 1 1],'key');
    [~,~,~,P2Timings.getready] = TextScreen( ...
        window,'Get Ready',[1 1 1],1.5);

    time = 4;
    if DAQ == 0
        freq = Screen('NominalFrameRate', window) ;
    elseif DAQ == 1
        freq = 2000;
    end
    numAssocTrials = 5; %5
    PercentMVClevels = [10 20 30 40 50 60 70 80];
    PercentMVClevelshuffle = PercentMVClevels(randperm( ...
        numel(PercentMVClevels)));
    AssocTrial = repmat(PercentMVClevelshuffle,[numAssocTrials 1]);
    AssocTrial = AssocTrial(:);
    voltAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^rows-trial#, columns-voltages
    timingAssocTrial = NaN(numel(AssocTrial),time*freq);
    % ^timings associated with voltages
    outcomeAssocTrial = NaN(numel(AssocTrial),1);
    count = 0;
    count_1 = 0;
    count_2 = 0;
    for i = AssocTrial'
        count = count+1;
        count_1 = count_1+1;
        [~,~,~,P2Timings.number(count)] = TextScreen( ...
            window,num2str(i),[1 1 1],2);
        [outcome,volt,timing,P2Timings.therm(count)] = ThermScreen( ...
            window,sensor,baseline,MVC,i/100,0.05,'vertical',time);
        voltAssocTrial(count,:) = volt;
        timingAssocTrial(count,:) = timing;
        outcomeAssocTrial(count) = outcome;
        if outcome == 1
            [~,~,~,P2Timings.outcome(count)] = TextScreen( ...
                window,'Success',[0 1 0],2);
        elseif outcome == 0
            [~,~,~,P2Timings.outcome(count)] = TextScreen( ...
                window,'Failure',[1 0 0],2);
        end
        P2Timings.fixcross(count) = FixationCross(window,1+3*rand);
        if count_1 == numAssocTrials
            count_2 = count_2+1;
            [~,~,~,P2Timings.rest(count_2)] = TextScreen( ...
                window,'Rest',[1 1 1],60);
            count_1 = 0;
        end
    end

    AssocTrial = [AssocTrial outcomeAssocTrial];
    % ^40x2 representing each individual trial and their outcomes
    [~,~,~,P2Timings.end] = TextScreen( ...
        window,'End of Phase 2',[1 1 1],'key');

    % save data
    AssocFileName = fullfile(SubjectDir,'AssocPhase');
    save(AssocFileName,'AssocTrial','voltAssocTrial', ...
        'timingAssocTrial','P2Timings');

    %% PHASE 3: RECALL---------------------------------------------------------
    % Here, we test to see if the subject has associated the numbers with
    % the force exerted.
    % 
    % For running only this phase
    % 
    % Dummy Vars
    % MVC = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);
    
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
    
    TRIGGER = GetSecs;
    P3Timings.trigger = TRIGGER;
    [~,~,~,P3Timings.instructions] = TextScreen( ...
        window,'Phase 3: Please wait for instructions',[1 1 1],'key');

    time = 4;
    if DAQ == 0
        freq = Screen('NominalFrameRate', window) ;
    elseif DAQ == 1
        freq = 2000;
    end
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
        [~,~,~,P3Timings.getready(i)] = TextScreen( ...
            window,'Get Ready',[1 1 1],1.5);
        PercentMVClevels = [10 20 30 40 50 60 70 80];
        PercentMVClevels_3 = repmat(PercentMVClevels,[numRecallTrials,1]);
        PercentMVClevels_3_shuffle = PercentMVClevels_3( ...
            randperm(numel(PercentMVClevels_3)));
        for j = PercentMVClevels_3_shuffle
            count = count+1;
            [outcome,volt,timing,P3Timings.therm(count)] = ThermScreen( ...
                window,sensor,baseline,MVC,j/100,0.05,'horizontal',time);
            voltRecallTrial(count,:) = volt;
            timingRecallTrial(count,:) = timing;
            outcomeRecallTrial(count) = outcome;
            [EffortReport,ReactTime,P3Timings.numline(count)] = ...
                NumberLineScreen(window);
            reportRecallTrial(count) = EffortReport;
            reacttimeRecallTrial(count) = ReactTime;
            PercentMVClevels_6_shuffle(count) = j;
        end
        [~,~,~,MRITimings.P3.rest(i)] = TextScreen( ...
            window,'Rest',[1 1 1],60);
    end

    RecallTrial = [PercentMVClevels_6_shuffle reportRecallTrial ... 
        reacttimeRecallTrial outcomeRecallTrial];
    % ^rows-recall trial#, column1-actual MVC percentage, column2-reported MVC
    % percentage, column3-reaction time, column4-success or failure of
    % trial

    [~,~,~,P3Timings.end] = TextScreen( ...
        window,'End of Phase 3',[1 1 1],'key');

    % save data
    RecallFileName = fullfile(SubjectDir,'RecallPhase');
    save(RecallFileName,'RecallTrial','voltRecallTrial', ...
        'timingRecallTrial','P3Timings');

    if MRI == 1
        sca;
        disp('Ready for MRI Session 1');
        return
    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close();
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase1to3');
    save(FileName);
end
    %% PHASE 4: CHOICE-----------------------------------------------------
    % Here, we have the subjects choose between an effort gamble and a sure
    % value in order to get their inherent risk preferences in the effort
    % domain.
    % 
    % For running only this phase
    % Dummy Vars
    % MVC = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);
    
try
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load('C:\Users\ChenSt\Desktop\FatigueCode\Gambles_12_5.mat');
    gambles = Gambles_12_5;
    [r,~] = size(gambles);
    gambleShuffled = gambles(randperm(r),:);

    if MRI == 0
        cedrus = 0; %dummy, means nothing
        TRIGGER = GetSecs;
        P4Timings.trigger = TRIGGER;
        [~,~,~,P4Timings.instructions] = TextScreen( ...
            window,'Phase 4: Please wait for instructions',[1 1 1],'key');
        [~,~,~,P4Timings.getready] = TextScreen( ...
            window,'Get Ready',[1 1 1],1.5);

        numChoiceTrials = r; %r
        choiceChoiceTrial = NaN(numChoiceTrials,1);
        reacttimeChoiceTrial = NaN(numChoiceTrials,1);
        for i = 1:numChoiceTrials
            flip = gambleShuffled(i,2);
            sure = gambleShuffled(i,1);
            [choice,ReactTime,P4Timings.gamble(i)] = GambleScreen( ...
                window,cedrus,flip,sure,4);
            RestrictKeysForKbCheck([]);
            P4Timings.fixcross(i) = FixationCross(window,1+3*rand);
            reacttimeChoiceTrial(i) = ReactTime;
            choiceChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
        end

        ChoiceTrial = [gambleShuffled(1:numChoiceTrials,[1 2]) ...
            choiceChoiceTrial reacttimeChoiceTrial];
        % ^rows-gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        [~,~,~,P4Timings.end(i)] = TextScreen( ...
            window,'End of Phase 4',[1 1 1],'key');

        % save data
        ChoiceFileName = fullfile(SubjectDir,'ChoicePhase');
        save(ChoiceFileName,'ChoiceTrial','P4Timings');
        save(fullfile(SubjectDir,'gambleShuffled'),'gambleShuffled');

    % session 1 MRI
    elseif MRI == 1
        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);
        
        TextScreen(window,'Phase 4 Session 1: Please wait for instructions', ...
            [1 1 1],'key');
        
        cedrusopen;
        MRITrigger(window,cedrus);
        S1Timings.trigger = TRIGGER;

        [~,~,~,S1Timings.getready] = TextScreen( ...
            window,'Get Ready',[1 1 1],1.5);

        numChoiceTrials = r/2; %2 sessions of equal length
        choiceChoiceTrial = NaN(numChoiceTrials,1);
        reacttimeChoiceTrial = NaN(numChoiceTrials,1);

        for i = 1:numChoiceTrials
            flip = gambleShuffled(i,2);
            sure = gambleShuffled(i,1);
            [choice,ReactTime,S1Timings.gamble(i)] = GambleScreen( ...
                window,cedrus,flip,sure,4);
            RestrictKeysForKbCheck([]);
            S1Timings.fixcross(i) = FixationCross(window,1+3*rand);
            reacttimeChoiceTrial(i) = ReactTime;
            choiceChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
        end

        ChoiceTrialSession1 = [gambleShuffled(1:numChoiceTrials,[1 2]) ...
            choiceChoiceTrial reacttimeChoiceTrial];
        % ^rows-gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        [~,~,~,S1Timings.end(i)] = TextScreen( ...
            window,'End of Phase 4 Session 1',[1 1 1],'key');

        % save data
        ChoiceFileName = fullfile(SubjectDir,'ChoicePhaseSession1');
        save(ChoiceFileName,'ChoiceTrialSession1','S1Timings');
        save(fullfile(SubjectDir,'gambleShuffled'),'gambleShuffled');

        sca;
        cedrus.close();
        disp('Ready for MRI Session 2');
        return
    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close();
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase4P1');
    save(FileName);
end

    %% Session 2 MRI (PHASE 4 PART 2)--------------------------------------
try
    if MRI == 1
        if ~exist('rootpath','var')
            if MRI == 0
                rootpath = 'Z:\Fatigue Experiment\Data';
            elseif MRI == 1
                rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
            end
            SubjectID=input('Enter Subject Identifier: ','s');
            FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            SubjectDir = fullfile(rootpath,FolderName,SubjectID);
            FileName = fullfile(SubjectDir,SubjectID);
        end
    
        % ensure same random gamble order between phase 4 sessions.
        load(fullfile(SubjectDir,'gambleShuffled'),'gambleShuffled');

        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);

        TextScreen(window,'Phase 4 Session 2: Please wait for instructions', ...
            [1 1 1],'key');
        
        cedrusopen;
        MRITrigger(window,cedrus);
        S2Timings.trigger = TRIGGER;

        [~,~,~,S2Timings.getready] = TextScreen( ...
            window,'Get Ready',[1 1 1],1.5);

        numChoiceTrials = r/2; %2 sessions of equal length
        choiceChoiceTrial = NaN(numChoiceTrials,1);
        reacttimeChoiceTrial = NaN(numChoiceTrials,1);

        for i = 1:numChoiceTrials
            % second half of gambles
            flip = gambleShuffled(i+numChoiceTrials,2);
            sure = gambleShuffled(i+numChoiceTrials,1);
            [choice,ReactTime,S2Timings.gamble(i)] = GambleScreen( ...
                window,cedrus,flip,sure,4);
            RestrictKeysForKbCheck([]);
            S2Timings.fixcross(i) = FixationCross(window,1+3*rand);
            reacttimeChoiceTrial(i) = ReactTime;
            choiceChoiceTrial(i) = choice; %NOTE: 1 = flip, 0 = sure
        end

        ChoiceTrialSession2 = [gambleShuffled(numChoiceTrials+1:r,[1 2]) ...
            choiceChoiceTrial reacttimeChoiceTrial];
        % ^rows-gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        [~,~,~,S2Timings.end(i)] = TextScreen( ...
            window,'End of Phase 4 Session 2',[1 1 1],'key');

        % save data
        ChoiceFileName = fullfile(SubjectDir,'ChoicePhaseSession2');
        save(ChoiceFileName,'ChoiceTrialSession2','S2Timings');

        sca;
        cedrus.close();
        disp('Ready for MRI Session 3');
        return
    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close()
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase4P2');
    save(FileName);
end

    %% PHASE 5: FATIGUED CHOICE--------------------------------------------
    % Here, we have the subjects make the same choices they made in phase
    % 4, but now they are being kept at a consistent level of motor fatigue,
    % achieved by doing repetitive squeeze tasks in between their choice 
    % inputs.
    % 
    % For running only this phase
    % 
    % Dummy Vars
    % MVC = 1;
    %     
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);
    % 
%     load('C:\Users\ChenSt\Desktop\FatigueCode\Gambles_12_5.mat');
%     gambles = Gambles_12_5;
%     [r,~] = size(gambles);
%     gambleShuffled = gambles(randperm(r),:);
try
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
    
    time = 4;
    if DAQ == 0
        freq = Screen('NominalFrameRate', window) ;
    elseif DAQ == 1
        freq = 2000;
    end
    gambleShuffled_1 = gambles(randperm(r),:);
    MVCFatiguePercent = 80; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FailureThreshold = 75; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numChoicesPerTrial = 10;

    if MRI == 0
        TRIGGER = GetSecs;
        P5Timings.trigger = TRIGGER;
        numFatigueTrials = r/numChoicesPerTrial;
        numFatiguedChoiceTrials = r;
        choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        voltFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        timingFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        outcomeFatiguedChoiceTrial = NaN(numFatigueTrials,300);
        cedrus = 0;
        P5Timings.trigger = GetSecs;
        [~,~,~,P5Timings.instructions] = TextScreen( ...
            window,'Phase 5: Please wait for instructions',[1 1 1],'key');

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
            trial = ['trial' num2str(i)];
            [~,~,~,P5Timings.squeezeintro(i)] = TextScreen( ...
                window,'Squeeze Phase',[1 1 1],2);
            [~,~,~,P5Timings.squeezegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            % min reps
            for j = 1:minFatigueReps
                [outcome,volt,timing,P5Timings.therm(i,j)] = ThermScreen( ...
                    window,sensor,baseline,MVC,MVCFatiguePercent/100,0.05, ...
                    'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                P5Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end
            % until failure threshold
            j = minFatigueReps;
            while success/failure > (100-FailureThreshold)/FailureThreshold
                j = j+1;
                [outcome,volt,timing,P5Timings.therm(i,j)] = ThermScreen( ...
                    window,sensor,baseline,MVC,MVCFatiguePercent/100,0.05, ...
                    'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                P5Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end

            % Post-Fatigue Choice Trials
            [~,~,~,P5Timings.gambleintro(i)] = TextScreen( ...
                window,'Gamble Phase',[1 1 1],2);
            [~,~,~,P5Timings.gamblegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            ChoiceLeftIndex = (i-1)*numChoicesPerTrial+1;
            ChoiceRightIndex = i*numChoicesPerTrial;
            count = 0;
            for k = ChoiceLeftIndex:ChoiceRightIndex
                count = count+1;
                flip = gambleShuffled_1(k,2);
                sure = gambleShuffled_1(k,1);
                [choice,ReactTime,P5Timings.gamble(i,count)] = ...
                    GambleScreen(window,cedrus,flip,sure,4);
                RestrictKeysForKbCheck([]);
                P5Timings.gamblefixcross(i,count) = ...
                    FixationCross(window,1+3*rand);
                choiceFatiguedChoiceTrial(k) = choice; %NOTE: 1 = flip, 0 = sure
                reacttimeFatiguedChoiceTrial(k) = ReactTime;
            end
        end

        [~,~,~,P5Timings.end] = TextScreen( ...
            window,'End of Phase 5',[1 1 1],'key');

        FatiguedChoiceTrial = [gambleShuffled_1(:,[1 2]) ...
            choiceFatiguedChoiceTrial reacttimeFatiguedChoiceTrial];
        % ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        % save data
        FatiguedChoiceFileName = fullfile( ...
            SubjectDir,'FatiguedChoicePhase');
        save(FatiguedChoiceFileName,'FatiguedChoiceTrial', ...
            'timingFatiguedChoiceTrial', 'voltFatiguedChoiceTrial', ...
            'outcomeFatiguedChoiceTrial', 'P5Timings');
        save(fullfile(SubjectDir,'gambleShuffled_1'),'gambleShuffled_1');

    % MRI Session 3
    % Note: the number of trials per session is hard-coded to be (5, 6, 6)
    elseif MRI == 1
        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);

        numFatigueTrials = 5;
        numFatiguedChoiceTrials = numFatigueTrials*numChoicesPerTrial;
        choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        voltFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        timingFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        outcomeFatiguedChoiceTrial = NaN(numFatigueTrials,300);

        TextScreen(window,'Phase 5 Session 3: Please wait for instructions', ...
            [1 1 1],'key');
        
        cedrusopen;
        MRITrigger(window,cedrus);
        S3Timings.trigger = TRIGGER;

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
            trial = ['trial' num2str(i)];
            [~,~,~,S3Timings.squeezeintro(i)] = TextScreen( ...
                window,'Squeeze Phase',[1 1 1],2);
            [~,~,~,S3Timings.squeezegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            % min reps
            for j = 1:minFatigueReps
                [outcome,volt,timing,S3Timings.therm(i,j)] = ThermScreen( ...
                    window,sensor,baseline,MVC,MVCFatiguePercent/100,0.05, ...
                    'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S3Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end
            % until failure threshold
            j = minFatigueReps;
            while success/failure > (100-FailureThreshold)/FailureThreshold
                j = j+1;
                [outcome,volt,timing,S3Timings.therm(i,j)] = ThermScreen( ...
                    window,sensor,baseline,MVC,MVCFatiguePercent/100,0.05, ...
                    'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S3Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end

            % Post-Fatigue Choice Trials
            [~,~,~,S3Timings.gambleintro(i)] = TextScreen( ...
                window,'Gamble Phase',[1 1 1],2);
            [~,~,~,S3Timings.gamblegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            ChoiceLeftIndex = (i-1)*numChoicesPerTrial+1;
            ChoiceRightIndex = i*numChoicesPerTrial;
            count = 0;
            for k = ChoiceLeftIndex:ChoiceRightIndex
                count = count+1;
                flip = gambleShuffled_1(k,2);
                sure = gambleShuffled_1(k,1);
                [choice,ReactTime,S3Timings.gamble(i,count)] ...
                    = GambleScreen(window,cedrus,flip,sure,4);
                RestrictKeysForKbCheck([]);
                S3Timings.gamblefixcross(i,count) ...
                    = FixationCross(window,1+3*rand);
                choiceFatiguedChoiceTrial(k) = choice; %NOTE: 1 = flip, 0 = sure
                reacttimeFatiguedChoiceTrial(k) = ReactTime;
            end
        end

        [~,~,~,S3Timings.end] = TextScreen( ...
            window,'End of Phase 5 Session 3',[1 1 1],'key');

        FatiguedChoiceTrialSession3 = [gambleShuffled_1( ...
            1:numFatiguedChoiceTrials,[1 2]) choiceFatiguedChoiceTrial ...
            reacttimeFatiguedChoiceTrial];
        % ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        % save data
        FatiguedChoiceFileName = fullfile(SubjectDir,'FatiguedChoicePhaseSession3');
        save(FatiguedChoiceFileName,'FatiguedChoiceTrialSession3', ...
            'timingFatiguedChoiceTrial', 'voltFatiguedChoiceTrial', ...
            'outcomeFatiguedChoiceTrial', 'S3Timings');
        save(fullfile(SubjectDir,'gambleShuffled_1'),'gambleShuffled_1');

        cedrus.close();
        sca;
        disp('Ready for MRI Session 4');

        return;
    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close()
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase5P1');
    save(FileName);
end
    %% Session 4 MRI (PHASE 5 PART 2)------------------------------------------
    % Note: the number of trials per session is hard-coded to be (5, 6, 6)
try
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
        
    if MRI == 1
        load(fullfile(SubjectDir,'gambleShuffled_1'),'gambleShuffled_1');
        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);
        
        time = 4;
        if DAQ == 0
            freq = Screen('NominalFrameRate', window) ;
        elseif DAQ == 1
            freq = 2000;
        end
        MVCFatiguePercent = 80; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FailureThreshold = 75; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        numChoicesPerTrial = 10;

        numFatigueTrials = 6;
        numFatiguedChoiceTrials = numFatigueTrials*numChoicesPerTrial;
        choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        voltFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        timingFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        outcomeFatiguedChoiceTrial = NaN(numFatigueTrials,300);

        TextScreen(window,'Phase 5 Session 4: Please wait for instructions', ...
            [1 1 1],'key');
        
        cedrusopen;
        MRITrigger(window,cedrus);
        S4Timings.trigger = TRIGGER;

        for i = 1:numFatigueTrials
            success = 0;
            failure = 0;
            minFatigueReps = 5;
            trial = ['trial' num2str(i)];
            [~,~,~,S4Timings.squeezeintro(i)] = TextScreen( ...
                window,'Squeeze Phase',[1 1 1],2);
            [~,~,~,S4Timings.squeezegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            % min reps
            for j = 1:minFatigueReps
                [outcome,volt,timing,S4Timings.therm(i,j)] ...
                    = ThermScreen(window,sensor,baseline,MVC, ...
                    MVCFatiguePercent/100,0.05,'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S4Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end
            % until failure threshold
            j = minFatigueReps;
            while success/failure > (100-FailureThreshold)/FailureThreshold
                j = j+1;
                [outcome,volt,timing,S4Timings.therm(i,j)] ...
                    = ThermScreen(window,sensor,baseline,MVC, ...
                    MVCFatiguePercent/100,0.05,'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S4Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end

            % Post-Fatigue Choice Trials
            [~,~,~,S4Timings.gambleintro(i)] = TextScreen( ...
                window,'Gamble Phase',[1 1 1],2);
            [~,~,~,S4Timings.gamblegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            ChoiceLeftIndex = (i+4)*numChoicesPerTrial+1;
            ChoiceRightIndex = (i+5)*numChoicesPerTrial;
            count = 0;
            for k = ChoiceLeftIndex:ChoiceRightIndex
                count = count+1;
                flip = gambleShuffled_1(k,2);
                sure = gambleShuffled_1(k,1);
                [choice,ReactTime,S4Timings.gamble(i,count)] ...
                    = GambleScreen(window,cedrus,flip,sure,4);
                RestrictKeysForKbCheck([]);
                S4Timings.gamblefixcross(i,count) ...
                    = FixationCross(window,1+3*rand);
                choiceFatiguedChoiceTrial(count) = choice; %NOTE: 1 = flip, 0 = sure
                reacttimeFatiguedChoiceTrial(count) = ReactTime;
            end
        end

        [~,~,~,S4Timings.end] = TextScreen( ...
            window,'End of Phase 5 Session 4',[1 1 1],'key');

        FatiguedChoiceTrialSession4 = [ ...
            gambleShuffled_1(51:50+numFatiguedChoiceTrials,[1 2]) ...
            choiceFatiguedChoiceTrial reacttimeFatiguedChoiceTrial];
        % ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        % save data
        FatiguedChoiceFileName = fullfile( ...
            SubjectDir,'FatiguedChoicePhaseSession4');
        save(FatiguedChoiceFileName,'FatiguedChoiceTrialSession4', ...
            'timingFatiguedChoiceTrial', 'voltFatiguedChoiceTrial', ...
            'outcomeFatiguedChoiceTrial', 'S4Timings');

        cedrus.close();
        sca;
        disp('Ready for MRI Session 5');
        return;

    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close()
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase5P2');
    save(FileName);
end
    %% Session 5 MRI (PHASE 5 PART 3)------------------------------------------
    % Note: the number of trials per session is hard-coded to be (5, 6, 6)
try
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
    
    if MRI == 1
        load(fullfile(SubjectDir,'gambleShuffled_1'),'gambleShuffled_1');
        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);

        time = 4;
        if DAQ == 0
            freq = Screen('NominalFrameRate', window) ;
        elseif DAQ == 1
            freq = 2000;
        end
        MVCFatiguePercent = 80; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        FailureThreshold = 75; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        numChoicesPerTrial = 10;
        
        numFatigueTrials = 6;
        numFatiguedChoiceTrials = numFatigueTrials*numChoicesPerTrial;
        choiceFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        reacttimeFatiguedChoiceTrial = NaN(numFatiguedChoiceTrials,1);
        voltFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        timingFatiguedChoiceTrial = NaN(300,time*freq,numFatigueTrials);
        outcomeFatiguedChoiceTrial = NaN(numFatigueTrials,300);

        TextScreen(window,'Phase 5 Session 5: Please wait for instructions', ...
            [1 1 1],'key');
        
        cedrusopen;
        MRITrigger(window,cedrus);
        S5Timings.trigger = TRIGGER;

        for i = 1:numFatigueTrials
            success = 0;
            failure = 0;
            minFatigueReps = 5;
            trial = ['trial' num2str(i)];
            [~,~,~,S5Timings.squeezeintro(i)] = TextScreen( ...
                window,'Squeeze Phase',[1 1 1],2);
            [~,~,~,S5Timings.squeezegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            % min reps
            for j = 1:minFatigueReps
                [outcome,volt,timing,S5Timings.therm(i,j)] ...
                    = ThermScreen(window,sensor,baseline,MVC, ...
                    MVCFatiguePercent/100,0.05,'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S5Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end
            % until failure threshold
            j = minFatigueReps;
            while success/failure > (100-FailureThreshold)/FailureThreshold
                j = j+1;
                [outcome,volt,timing,S5Timings.therm(i,j)] ...
                    = ThermScreen(window,sensor,baseline,MVC, ...
                    MVCFatiguePercent/100,0.05,'horizontal',time);
                voltFatiguedChoiceTrial(j,:,i) = volt;
                timingFatiguedChoiceTrial(j,:,i) = timing;
                outcomeFatiguedChoiceTrial(i,j) = outcome;
                if outcome == 1
                    success = success+1;
                elseif outcome == 0
                    failure = failure+1;
                end
                S5Timings.squeezefixcross(i,j) = FixationCross(window,3);
            end

            % Post-Fatigue Choice Trials
            [~,~,~,S5Timings.gambleintro(i)] = TextScreen( ...
                window,'Gamble Phase',[1 1 1],2);
            [~,~,~,S5Timings.gamblegetready(i)] = TextScreen( ...
                window,'Get Ready',[1 1 1],1.5);
            ChoiceLeftIndex = (i+10)*numChoicesPerTrial+1;
            ChoiceRightIndex = (i+11)*numChoicesPerTrial;
            count = 0;
            for k = ChoiceLeftIndex:ChoiceRightIndex
                count = count+1;
                flip = gambleShuffled_1(k,2);
                sure = gambleShuffled_1(k,1);
                [choice,ReactTime,S5Timings.gamble(i,count)] ...
                    = GambleScreen(window,cedrus,flip,sure,4);
                RestrictKeysForKbCheck([]);
                S5Timings.gamblefixcross(i,count) = FixationCross( ...
                    window,1+3*rand);
                choiceFatiguedChoiceTrial(count) = choice; %NOTE: 1 = flip, 0 = sure
                reacttimeFatiguedChoiceTrial(count) = ReactTime;
            end
        end

        [~,~,~,S5Timings.end] = TextScreen( ...
            window,'End of Phase 5 Session 5',[1 1 1],'key');

        FatiguedChoiceTrialSession5 = [ ...
            gambleShuffled_1(111:110+numFatiguedChoiceTrials,[1 2]) ...
            choiceFatiguedChoiceTrial reacttimeFatiguedChoiceTrial];
        % ^rows-fatigued gamble trial#, column1-sure, column2-flip, column3-choice,
        % column4-reaction time

        % save data
        FatiguedChoiceFileName = fullfile( ...
            SubjectDir,'FatiguedChoicePhaseSession5');
        save(FatiguedChoiceFileName,'FatiguedChoiceTrialSession5', ...
            'timingFatiguedChoiceTrial', 'voltFatiguedChoiceTrial', ...
            'outcomeFatiguedChoiceTrial', 'S5Timings');

        cedrus.close();
        sca;
        disp('Done MRI sessions!');
        return;
    end
catch
    sca;
    if isstruct(cedrus)
        cedrus.close()
    end
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogPhase5P3');
    save(FileName);
end
try
    %% PHASE 6: TRIAL SELECTION--------------------------------------------
    % Here, we play out 10 of the choices that were made in the previous 2
    % phases, in order to validate that the subject is treating each
    % choice made in the previous phases independently from one another,
    % and with potential consequences.
    % 
    % For running only this phase
    % 
    % Dummy Vars
    % MVC = 1;
    % 
    % PsychDefaultSetup(2);screen=max(Screen('Screens'));
    % [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
    % HideCursor(window);
    % 
    % load('Z:\Fatigue Experiment\Code\Gambles_12_5.mat');
    % gambles = Gambles_12_5;
    % [r,~] = size(gambles);
    % gambleShuffled = gambles(randperm(r),:);
    % gambleShuffled_1 = gambles(randperm(r),:);
    if ~exist('sensor','var')
        [sensor, baseline, chans] = setupDaq(window);
    end
    
    if ~exist('rootpath','var')
        if MRI == 0
            rootpath = 'Z:\Fatigue Experiment\Data';
        elseif MRI == 1
            rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
        end
        SubjectID=input('Enter Subject Identifier: ','s');
        FolderName = 'Pilot - MRI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        SubjectDir = fullfile(rootpath,FolderName,SubjectID);
        FileName = fullfile(SubjectDir,SubjectID);
    end
    
    load(fullfile(SubjectDir,'MVCPhase'));
    load(fullfile(SubjectDir,'gambleShuffled'),'gambleShuffled');
    load(fullfile(SubjectDir,'gambleShuffled_1'),'gambleShuffled_1');
    
    if MRI == 1
        PsychDefaultSetup(2);screen=max(Screen('Screens'));
        [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
        HideCursor(window);
    end

    TRIGGER = GetSecs;
    P6Timings.trigger = TRIGGER;
    [~,~,~,P6Timings.instructions] = TextScreen( ...
        window,'Phase 6: Please wait for instructions',[1 1 1],'key');
    [~,~,~,P6Timings.getready] = TextScreen( ...
        window,'Get Ready',[1 1 1],1.5);

    time = 4;
    if DAQ == 0
        freq = Screen('NominalFrameRate', window) ;
    elseif DAQ == 1
        freq = 2000;
    end
    % Randomly select 10 choice trials from pre/post fatigue
    if MRI == 0
        CombinedTrial = [ChoiceTrial; FatiguedChoiceTrial];
    elseif MRI == 1
        CombinedTrial = [ChoiceTrialSession1; ChoiceTrialSession2; ...
            FatiguedChoiceTrialSession3; FatiguedChoiceTrialSession4; ...
            FatiguedChoiceTrialSession5];
    end
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
            [outcome,volt,timing] = ThermScreen( ...
                window,sensor,baseline,MVC,TrialSelectionTrial(i)/100, ...
                0.05,'horizontal',4);
            voltTrialSelectionTrial(FailCount+1,:,i) = volt;
            timingTrialSelectionTrial(FailCount+1,:,i) = timing;
            if outcome == 1
                [~,~,~,P6Timings.outcome(i,FailCount+1)] = TextScreen( ...
                    window,'Success',[0 1 0],2);
                lever = 1;
                if i == length(TrialSelectionTrial)
                    break;
                else
                    [~,~,~,P6Timings.nextgamble(i)] = TextScreen( ...
                        window,'Next Gamble',[1 1 1],2);
                end
            elseif outcome == 0
                FailCount = FailCount+1;
                [~,~,~,P6Timings.outcome(i,FailCount)] = TextScreen( ...
                    window,'Failure',[1 0 0],2);
                if FailCount == 5
                    if i == length(TrialSelectionTrial)
                        break;
                    else
                        [~,~,~,P6Timings.nextgamble(i)] = TextScreen( ...
                            window,'Next Gamble',[1 1 1],2);
                    end
                end
            end
        end
    end

    [~,~,~,P6Timings.end] = TextScreen( ...
        window,'End of Phase 6',[1 1 1],'key');

    % save data
    TrialSelectionFileName = fullfile(SubjectDir,'TrialSelectionPhase');
    save(TrialSelectionFileName,'P6Timings','TrialSelectionTrial', ...
        'voltTrialSelectionTrial','timingTrialSelectionTrial');

    sca;

catch
    sca;
    SubjectDir = fullfile(rootpath,FolderName,SubjectID);
    FileName = fullfile(SubjectDir,'errorLogP6');
    save(FileName);
end