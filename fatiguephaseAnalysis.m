clear; clc

rootpath = 'Z:\Fatigue Experiment\Data';
FolderName = 'Pilot - 3'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = 0; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - save plot with number of fatigue trials per squeeze phase

if subjects == 1
    SubjectID = {...
%         Pilot
%         'KM_72015'...
%         'SM_71515'...
%         'JH_71515'...
%         'RL_71415'...
%         'ND_72115'...
%         'FO_72115'...
%         'SG_72215'...
%         'AG_72215'...

%         Pilot - 2
%         'AE_72915'...
%         'CA_73015'...
%         'JB_73015'...
%         'SU_72915'...
        
%         Pilot - 3
        'FM_73115'...
        'NF_8315'...
        'TG_8415'...
        'TT_8315'...
        'CJ_8815'...

        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s');
    SubjectID = cellstr(SubjectID);
end

for i = 1:length(SubjectID)
    SubjectDir = char(fullfile(rootpath,FolderName,SubjectID(i)));
    load(fullfile(SubjectDir,'FatiguedChoicePhase'));

    numTrials = 17;
    fatigue = [];
    fatigueavg = [];
    outcomePlot = zeros(1,numTrials);
    for j = 1:numTrials
        fatigue = [fatigue max(voltFatiguedChoiceTrial(:,:,j)')];
        fatigueavg = [fatigueavg mean(voltFatiguedChoiceTrial(:,:,j)')];

        outcome = outcomeFatiguedChoiceTrial(j,:);
        outcome(isnan(outcome)) = [];
        outcomePlot(j) = length(outcome);
    end

    fatigue(isnan(fatigue)) = [];
    fatigueavg(isnan(fatigueavg)) = [];
    
    figure(i);
    set(gcf,'name',char(SubjectID(i)),'numbertitle','off')
    plot(outcomePlot,'-o');
    if saveit == 1
        saveas(gcf,fullfile(SubjectDir,'FatigueOutcomePlot'),'fig');
    end
end
