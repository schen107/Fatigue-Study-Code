clear; clc

rootpath = 'C:\Users\Steven\Documents\Pilot Data';
SubjectID=input('Enter Subject Identifier: ','s'); 
SubjectDir = fullfile(rootpath,SubjectID);
load(fullfile(SubjectDir,'MVCPhase'));
load(fullfile(SubjectDir,'FatiguedChoicePhase'));

MVC = max(MVCTrial');
MVCavg = mean(MVCTrial');

initfatigue = max(initvoltFatiguedChoiceTrial');
initfatigue = initfatigue(1:find(initfatigue,1,'last'));
initfatigueavg = mean(initvoltFatiguedChoiceTrial');
initfatigueavg = initfatigueavg(1:find(initfatigueavg,1,'last'));

fatigue = max(voltFatiguedChoiceTrial');
fatigueavg = mean(voltFatiguedChoiceTrial');

plot([MVC initfatigue fatigue],'bo');
hold on;
plot([MVCavg initfatigueavg fatigueavg],'ro');