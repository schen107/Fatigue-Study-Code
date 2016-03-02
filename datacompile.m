clear; close; clc
% This script file saves .mat files with subject ID, fatigue number of
% reps, recall phase data, choice data, and parameter data for all subjects
% specified in the SubjectID field.


rootpath = 'C:\Users\Steven\Desktop\Fatigue Experiment\Data';
FolderName = {'Pilot' 'Pilot - 2' 'Pilot - 3'};


% 0 - don't trust data, 1 - trust
SubjectID = {...
%         Pilot
        {{'KM_72015', 1}
        {'SM_71515', 1}
        {'JH_71515', 0} %don't trust data
        {'RL_71415', 0} %don't trust data
        {'ND_72115', 1}
        {'FO_72115', 0} %don't trust data
        {'SG_72215', 0} %don't trust data
        {'AG_72215', 0} %don't trust data
}
%         Pilot - 2
        {{'AE_72915', 1}
        {'CA_73015', 0} %don't trust data
        {'JB_73015', 1}
        {'SU_72915', 1}
}
%         Pilot - 3
        {{'FM_73115', 0} %lab member
        {'NF_8315', 0} %lab member
        {'TG_8415', 0} %lab member
        {'TT_8315', 0} %lab member
        {'CJ_8815', 1}
        {'PT_81015', 0} %don't trust data
        {'AA_81415', 0} %don't trust data
        {'KV_82015', 0} %don't trust data
        {'BS_92215', 1}
        {'LS_92415', 1}
        {'AA_92415', 0} %don't trust data
        {'CW_101315', 0} %don't trust data
        {'TM_101315', 0} %don't trust data
        {'YG_10152015', 1}
        {'PY_10222015', 0} %don't use data
        {'CT_102715', 1}
        {'Os_10302015', 1}
        {'AI_1242015', 1}
        {'AP_1282015', 1}
        {'AL_1282015', 1}
        {'IK_1282015', 1}
        {'DA2_12102015', 1}
        {'RH_12112015', 1}
        {'PL_12112015', 1}
        {'JL_2102016', 1}
        {'KJ_02112016', 1}
        {'ca_2112016', 1}
        {'rv_2112015', 1}
        {'JO_02122016', 1}
        {'AH_2162016', 0} %don't trust data
        {'CH_02172016', 1}
        {'JY_2172016', 1}
        }
    };

for i = 1:length(SubjectID) % for each pilot phase
    if i == 1
        recall_all = zeros(24,4,length(SubjectID{i}));
    else
        recall_all = zeros(48,4,length(SubjectID{i}));
    end
    parameter_all = zeros(length(SubjectID{i}),4);
    outcome_all = zeros(length(SubjectID{i}),17); %17 - number of trials
    choice_all = zeros(170,4,length(SubjectID{i}));
    fatiguedchoice_all = zeros(170,4,length(SubjectID{i}));
    for j = 1:length(SubjectID{i}) % for each subject
        SubjectDir = fullfile(rootpath,FolderName{i},SubjectID{i}{j}{1});
        load(fullfile(SubjectDir,'RecallPhase'));
        load(fullfile(SubjectDir,'ChoicePhase'));
        load(fullfile(SubjectDir,'FatiguedChoicePhase'));
        load(fullfile(SubjectDir,'parameters'));

        recall_all(:,:,j) = RecallTrial;
        choice_all(:,:,j) = ChoiceTrial;
        fatiguedchoice_all(:,:,j) = FatiguedChoiceTrial;
        parameter_all(j,:) = [parameters(1,1) parameters(1,2) ...
            parameters(2,1) parameters(2,2)];
        
        % number of outcomes per fatigue trial
        outcome = zeros(size(outcomeFatiguedChoiceTrial,1),1);
        for k = 1:length(outcome)
            outcome(k) = sum(~isnan(outcomeFatiguedChoiceTrial(k,:)));
        end
        
        outcome_all(j,:) = outcome;
    end
    sid = SubjectID{i};
    save([FolderName{i} '_data.mat'],'sid','recall_all', ...
        'parameter_all','outcome_all', 'choice_all', 'fatiguedchoice_all');
    
end