clear; clc

% rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data - 2'; %Steven's Comp
rootpath = 'Y:\Fatigue Experiment\Pilot Data - 2'; %KKI Comp

subjects = 1; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - save plot with number of fatigue trials per squeeze phase

if subjects == 1
    SubjectID = {...
%         Pilot Data
%         'KM_72015'...
%         'SM_71515'...
%         'JH_71515'...
%         'RL_71415'...
%         'ND_72115'...
%         'FO_72115'...
%         'SG_72215'...
%         'AG_72215'...

%         Pilot Data - 2
        'AE_72915'...
        'CA_73015'...
        'JB_73015'...
        'SU_72915'...
        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s'); 
end

for i = 1:length(SubjectID)
    SubjectDir = char(fullfile(rootpath,SubjectID(i)));
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
    plot(outcomePlot,'-o');
    if saveit == 1
        saveas(gcf,fullfile(SubjectDir,'FatigueOutcomePlot'),'fig');
    end
end
