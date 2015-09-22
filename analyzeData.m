clear; clc

rootpath = 'Z:\Fatigue Experiment\Data';
FolderName = 'Pilot - 3'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('Z:\Fatigue Experiment\Code\Analysis Functions');

subjects = 1; %1 - multiple subjects, 0 - one subject;

if subjects == 1
    SubjectID = {...
%         Pilot
%         'KM_72015'...
%         'SM_71515'...
%         'JH_71515'... %don't trust data
%         'RL_71415'... %don't trust data
%         'ND_72115'...
%         'FO_72115'... %don't trust data
%         'SG_72215'... %don't trust data
%         'AG_72215'... %don't trust data

%         Pilot - 2
%         'AE_72915'...
%         'CA_73015'... %don't trust data
%         'JB_73015'...
%         'SU_72915'...
        
%         Pilot - 3
        'FM_73115'...
        'NF_8315'...
        'TG_8415'...
        'TT_8315'...
        'CJ_8815'...
        'PT_81015'... %don't trust data
        'AA_81415'...
        'KV_82015'... %don't trust data
        'BS_92215'...

        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s');
    SubjectID = cellstr(SubjectID);
end

parameter_array = zeros(length(SubjectID),2);
for i = 1:length(SubjectID)
    SubjectDir = fullfile(rootpath,FolderName,SubjectID{i});
    load(fullfile(SubjectDir,'RecallPhase'));
    load(fullfile(SubjectDir,'FatiguedChoicePhase'));
    load(fullfile(SubjectDir,'ChoicePhase'));
    
    recallphaseAnalysis(SubjectID{i},RecallTrial,0);
    fatiguephaseAnalysis(SubjectID{i},outcomeFatiguedChoiceTrial,0);
    [parameters, Pvals] = AnalyzeEffortChoice(SubjectID{i},ChoiceTrial,FatiguedChoiceTrial,0);
    if subjects == 1
        parameter_array(i,:) = parameters(:,2);
    end
end

%Paired TTest
if subjects == 1
    [reject, PvalsCompare] = ttest(parameter_array(:,1),parameter_array(:,2));
end
