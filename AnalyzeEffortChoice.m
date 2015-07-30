%This m-file is used to run a MLE-based analysis to extract behavioral
%parameters from subjects' choice data during phases 4 and 5 (which
%correspond to the effort gamble tasks).

clc;clear;

rootpath = 'Z:\Fatigue Experiment\Data';
FolderName = 'Pilot - 3'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = 1; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - save parameter values

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
        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s'); 
end

for i = 1:length(SubjectID)
    
    %Column 1 -- Sure
    %Column 2 -- Flip
%--------------------------------------------------------------------------
    SubjectDir = char(fullfile(rootpath,FolderName,SubjectID(i)));
    load(fullfile(SubjectDir,'ChoicePhase'));
    load(fullfile(SubjectDir,'FatiguedChoicePhase'));
    
    PrefatGambles = ChoiceTrial(:,1:3);
    PostfatGambles = FatiguedChoiceTrial(:,1:3);
%--------------------------------------------------------------------------
    %Calculate dEVs
    dEVs = PrefatGambles(:,1) - 0.5*PrefatGambles(:,2);
    PrefatGambles = [dEVs PrefatGambles];
    %^^dEV values are now listed in the first column of this 'PreFatGambles'
    %data matrix.
    
    [~,index]=sort(PrefatGambles(:,1));
    PrefatGambles = PrefatGambles(index,:);
    %^^Sort the effort gamble choices based on dEV values.

	%Same thing for PostfatGambles
    dEVs = PostfatGambles(:,1) - 0.5*PostfatGambles(:,2);
    PostfatGambles = [dEVs PostfatGambles];
    
    [~,index]=sort(PostfatGambles(:,1));
    PostfatGambles = PostfatGambles(index,:);
    
    PrefatGambles(isnan(PrefatGambles(:,4)),:) = [];
    PostfatGambles(isnan(PostfatGambles(:,4)),:) = [];
    %^^ get rid of NANs
    
%--------------------------------------------------------------------------
    %MLE ON CHOICE DATA
%--------------------------------------------------------------------------
    P1 = PrefatGambles(:,2:4);
    P2 = PostfatGambles(:,2:4);
    
    options = optimset('MaxFunEvals', 100000);

    addpath('Z:\Fatigue Experiment\Code\Analysis Functions');
    
    paramtracker1(i,:) = fminsearch(@loglikelihood_rhomulam_effort,[.1 1],options, P1);
    lltracker1(1,i) = (loglikelihood_rhomulam_effort(paramtracker1(i,:),P1));
    %This evaluates the function value at the maximized parameter estimates
    %from above.  This acts as the fitted log likelihood for the choice data. 
    
    paramtracker2(i,:) = fminsearch(@loglikelihood_rhomulam_effort,[.1 1],options, P2);    
    lltracker2(1,i) = (loglikelihood_rhomulam_effort(paramtracker2(i,:),P2));
    %Same for P2
    
    paramtrackernull1(i,:) = fminsearch(@loglikelihood_null_effort,[.1],options, P1);
    lltrackernull1(1,i) = (loglikelihood_null_effort(paramtrackernull1(i,:),P1));
    paramtrackernull2(i,:) = fminsearch(@loglikelihood_null_effort,[.1],options, P2);
    lltrackernull2(1,i) = (loglikelihood_null_effort(paramtrackernull2(i,:),P2));
    %For validation of these values, the likelihood under the null
    %assumptions (with the curvature parameter being one), is determined in
    %the same manner.
    
    %From this, we obtain the parameters that describe the subjects'
    %subjective effort preferences (temperature parameter being the first
    %column and curvature parameter being the second).
    
    %Save resulting parameters
    parameters = zeros(2,2);
    parameters(1,:) = paramtracker1(i,:);
    parameters(2,:) = paramtracker2(i,:);
    
    if saveit == 1
        save(fullfile(SubjectDir,'parameters'),'parameters');
    end
%--------------------------------------------------------------------------
end

%Test Statistics using the log-liklihood ratio.
D1 = -2*(lltracker1-lltrackernull1);
D2 = -2*(lltracker2-lltrackernull2);
DCompare = -2*(lltracker2-lltracker1);
% Pvals = chi2pdf(D,1);

Pvals1 = 1-chi2cdf(D1,1);
Pvals2 = 1-chi2cdf(D2,1);
PvalsCompare = 1-chi2cdf(DCompare,1);
%^THIS IS RIGHT. Obtain p-values for these observations.
