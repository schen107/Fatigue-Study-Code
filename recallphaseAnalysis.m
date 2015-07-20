clear; clc

rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data';
SubjectID=input('Enter Subject Identifier: ','s'); 
SubjectDir = fullfile(rootpath,SubjectID);
load(fullfile(SubjectDir,'RecallPhase'));

plot(RecallTrial(:,1),RecallTrial(:,2),'o')