clear; clc

rootpath = 'C:\Users\Steven\Documents\Pilot Data';
SubjectID=input('Enter Subject Identifier: ','s'); 
SubjectDir = fullfile(rootpath,SubjectID);
load(fullfile(SubjectDir,'MVCPhase'));
load(fullfile(SubjectDir,'FatiguedChoicePhase'));

MVC = max(MVCTrial');

initfatigue = max(initvoltFatiguedChoiceTrial');
initfatigue = initfatigue(1:find(initfatigue,1,'last'));

fatigue = max(voltFatiguedChoiceTrial');

plot([MVC initfatigue fatigue],'o');