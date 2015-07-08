clear; clc

rootpath = 'C:\Users\Steven\Documents\Pilot Data';
SubjectID=input('Enter Subject Identifier: ','s'); 
SubjectDir = fullfile(rootpath,SubjectID);
load(fullfile(SubjectDir,'MVCPhase'));
load(fullfile(SubjectDir,'FatiguedChoicePhase'));

numTrials = 17;

MVC = max(voltMVCTrial');
MVCavg = mean(voltMVCTrial');

fatigue = [];
fatigueavg = [];

outcomePlot = zeros(1,numTrials);
for i = 1:numTrials
    fatigue = [fatigue max(voltFatiguedChoiceTrial(:,:,i)')];
    fatigueavg = [fatigueavg mean(voltFatiguedChoiceTrial(:,:,i)')];
    
    outcome = outcomeFatiguedChoiceTrial(i,:);
    outcome(isnan(outcome)) = [];
    outcomePlot(i) = length(outcome);
end

fatigue(isnan(fatigue)) = [];
fatigueavg(isnan(fatigueavg)) = [];

% plot([MVC fatigue],'bo');
% hold on;
% plot([MVCavg fatigueavg],'ro');
% 
% plot(outcomePlot);