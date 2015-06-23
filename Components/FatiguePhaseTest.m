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

time = 4;
freq = 2000;
gambleShuffled_1 = gambles(randperm(r),:);
MVCFatiguePercent = 80;
FailureThreshold = 50;
numFatigueTrials = r/10; %%%%%%%%%%%%%%HOW MANY DO WE DO? (TEST THIS)
minFatigueContractions = 10;
numFatiguedChoiceTrials = r;
choiceFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);
reacttimeFatiguedChoiceTrial = zeros(numFatiguedChoiceTrials,1);
voltFatiguedChoiceTrial = zeros(500,time*freq);
FatiguedChoiceTiming = zeros(500,time*freq);

for i = 1:numFatigueTrials
    TextScreen(window,'Fatigue Phase: Press any key to continue',[1 1 1],'key');
    TextScreen(window,'GET READY',[1 1 1],1.5);
    
    % initial mandatory trials (adjusted by minFatigueContractions)
    success = 0;
    failure = 0;
    for n = 1:minFatigueContractions
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
        voltFatiguedChoiceTrial(n,:) = volt;
        FatiguedChoiceTiming(n,:) = timing;
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
    n = minFatigueContractions;
    while success/failure > (100-FailureThreshold)/FailureThreshold
        n = n+1;
        [outcome,volt,timing] = ThermScreen(window,baseline,MVC,MVCFatiguePercent/100,'horizontal',time);
        voltFatiguedChoiceTrial(n,:) = volt;
        FatiguedChoiceTiming(n,:) = timing;
        if outcome == 1
            TextScreen(window,'SUCCESS',[0 1 0],1);
            success = success+1;
        elseif outcome == 0
            TextScreen(window,'FAILURE',[1 0 0],1);
            failure = failure+1;
        end
        FixationCross(window,3);
    end 
end