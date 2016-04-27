function [rootpath,SubjectID,FolderName,SubjectDir] = setup(experimentFolderName)
% general initial setup upon opening MATLAB

global MRI

rng('shuffle'); %Generate new random seed
% Screen('Preference', 'SkipSyncTests', 1);
addpath('C:\Users\ChenSt\Desktop\FatigueCode\Components');
addpath('C:\Users\ChenSt\Desktop\FatigueCode\DAQ functions');

load('MRI');

if MRI == 0
    rootpath = 'Z:\Fatigue Experiment\Data';
elseif MRI == 1
    rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
end
SubjectID=input('Enter Subject Identifier: ','s');
FolderName = experimentFolderName;
SubjectDir = fullfile(rootpath,FolderName,SubjectID);
end

