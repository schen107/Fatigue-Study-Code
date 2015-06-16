% Final Script for Fatigue Study
% Steven Chen

clear; clc;
%% Setup PsychToolBox------------------------------------------------------

PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

%% Setup DAQ---------------------------------------------------------------
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
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% 
% sensor = 1;

% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 1: Please wait for instructions','key');
TextScreen(window,'GET READY',2);

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
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% 
% sensor = 1;

% sensor = analoginput('mcc');%Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5);%Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 2: Please wait for instructions','key');
TextScreen(window,'GET READY',2);

MVClevels = [10 20 30 40 50 60 70 80]';
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

% NOTE: NOT WORKING WITH CURRENT DUMMY CODES

% For running only this phase
PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

sensor = 1;

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 3: Please wait for instructions','key');
TextScreen(window,'GET READY',2);

numRecallTrials = 3;
MVClevels = [10 20 30 40 50 60 70 80]';
MVClevels_3 = repmat(MVClevels,[numRecallTrials,1]);
MVClevel_3_shuffle = MVClevels_3(randperm(numel(MVClevels_3)));
voltRecallTrial = NaN(1000,numel(MVClevels_3)); %DO WE NEED A VOLTAGE HERE?
reportRecallTrial = zeros(numel(MVClevels_3),1);
reacttimeRecallTrial = zeros(numel(MVClevels_3),1);
count = 0;
for i = MVClevelshuffle
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
% PsychDefaultSetup(2);screen=max(Screen('Screens'));
% [window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);
% 
% sensor = 1;

% sensor = analoginput('mcc'); %Default sample rate: 1000
% chans=addchannel(sensor,0);
% start(sensor);
% 
% pause(5); %Pausing to be sure that the sensor has time to equilibriate
% baseline = getsample(sensor);
% baseline = baseline(1);

TextScreen(window,'Phase 4: Please wait for instructions','key');
TextScreen(window,'GET READY',2);

numChoiceTrials = 50;


%% PHASE 5: FATIGUED CHOICE------------------------------------------------

% For running only this phase
PsychDefaultSetup(2);screen=max(Screen('Screens'));
[window,windowRect]=PsychImaging('OpenWindow',screen,[0 0 0]);

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
FailureThreshold = 30;
numFatigueTrials = 3;

for i = 1:numFatigueTrials
    success = 0;
    failure = 0;
    while failure/success<3/7 && success+failure>

%% PHASE 6: TRIAL SELECTION------------------------------------------------

%% END

KbStrokeWait;
sca;