clear; clc;
close all;

%-------CHANGE THESE VARIABLES-------%
kki = 1; % 1 - kki, 0 - personal
subjects = 1; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - yes, 0 - no
mri = 1; %1 - mri
FolderName = 'Pilot - MRI1';

if subjects == 1
    SubjectID = {...
%         Pilot
%         'KM_72015'
%         'SM_71515'
%         'JH_71515' %don't trust data
%         'RL_71415' %don't trust data
%         'ND_72115'
%         'FO_72115' %don't trust data
%         'SG_72215' %don't trust data
%         'AG_72215' %don't trust data

%         Pilot - 2
%         'AE_72915'
%         'CA_73015' %don't trust data
%         'JB_73015'
%         'SU_72915'
        
%         Pilot - 3
%         'FM_73115' %lab member
%         'NF_8315' %lab member
%         'TG_8415' %lab member
%         'TT_8315' %lab member
%         'CJ_8815'
%         'PT_81015' %don't trust data negative parameters
%         'AA_81415' %don't trust data negative parameters
%         'KV_82015' %don't trust data R^2 = 0.04
%         'BS_92215'
%         'LS_92415'
%         'AA_92415' %don't trust data negative parameters
%         'CW_101315' %don't trust data didn't finish experiment
%         'TM_101315' %don't trust data R^2 = 0.26, pulsed during fatiguephase
%         'YG_10152015'
%         'PY_10222015' %don't use data negative parameters
%         'CT_102715'
%         'Os_10302015'
%         'AI_1242015'
%         'AP_1282015'
%         'AL_1282015'
%         'IK_1282015'
%         'DA2_12102015'
%         'RH_12112015'
%         'PL_12112015' %seemed to calculate expected value - fine
%         MRI force sensor
%         'JL_2102016'
%         'KJ_02112016'
%         'ca_2112016'
%         'rv_2112015'
%         'JO_02122016'
%         'AH_2162016' %don't trust data negative parameters
%         'CH_02172016'
%         'JY_2172016' %don't trust data R^2 = 0.414

%         Pilot - fMRI1
        'MP_5416'
        'AW_7116'
        'KS_7112016'
        'JT_7122016'
        'OE_7132016'
        'NM_7142016'
        'TS_7202016'
        'ML_7262016' %don't trust data - sure for all of post-fatigue
        'MJ_7282016'
        'KC_7292016'
        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s');
    SubjectID = cellstr(SubjectID);
end
%------------------------------------%

if kki == 1 
    rootpath = 'C:\Users\ChenSt\Desktop\FatigueData';
    addpath('C:\Users\ChenSt\Desktop\FatigueCode\Analysis Functions');
else
    rootpath = 'C:\Users\Steven\Documents\Research\Chib Lab\Data';
    addpath('C:\Users\Steven\Documents\Research\Chib Lab\Code\Analysis Functions');
end

parameter_array = zeros(length(SubjectID),2);
for i = 1:length(SubjectID)
    SubjectDir = fullfile(rootpath,FolderName,SubjectID{i});
    load(fullfile(SubjectDir,'RecallPhase'));
    temp = [];
    if mri == 1
        load(fullfile(SubjectDir,'ChoicePhaseSession1'));
        load(fullfile(SubjectDir,'ChoicePhaseSession2'));
        load(fullfile(SubjectDir,'FatiguedChoicePhaseSession3'));
        temp = [temp; outcomeFatiguedChoiceTrial];
        load(fullfile(SubjectDir,'FatiguedChoicePhaseSession4'));
        temp = [temp; outcomeFatiguedChoiceTrial];
        load(fullfile(SubjectDir,'FatiguedChoicePhaseSession5'));
        outcomeFatiguedChoiceTrial = [temp; outcomeFatiguedChoiceTrial];
        ChoiceTrial = [ChoiceTrialSession1; ChoiceTrialSession2];
        FatiguedChoiceTrial = [FatiguedChoiceTrialSession3; 
            FatiguedChoiceTrialSession4; FatiguedChoiceTrialSession5];
    else
        load(fullfile(SubjectDir,'ChoicePhase'));
        load(fullfile(SubjectDir,'FatiguedChoicePhase'));
    end
    
    recallphaseAnalysis(SubjectID{i},SubjectDir,RecallTrial,saveit);
    fatiguephaseAnalysis(SubjectID{i},SubjectDir,outcomeFatiguedChoiceTrial,saveit);
    [parameters, Pvals] = AnalyzeEffortChoice(SubjectID{i},SubjectDir,ChoiceTrial,FatiguedChoiceTrial,saveit);
    if subjects == 1
        parameter_array(i,1) = parameters(1,1);
        parameter_array(i,2) = parameters(1,2);
        parameter_array(i,3) = parameters(2,1);
        parameter_array(i,4) = parameters(2,2);
    end
end

%Paired TTest
if subjects == 1
    [reject, PvalsCompare] = ttest(parameter_array(:,2),parameter_array(:,4),'tail','left');
end
