%This m-file is used to run a MLE-based analysis to extract behavioral
%parameters from subjects' choice data during phases 4 and 5 (which
%correspond to the effort gamble tasks).

clc;clear;

rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data';

SubjectID={...
    'KM_72015'...
    'SM_71515'...
    'JH_71515'...
    'RL_71415'...
    };

% Bs = [];
% Ps = [];
% Params =[];

for i = 1:size(SubjectID,2)
    
    %Column 1 -- Sure
    %Column 2 -- Flip
%--------------------------------------------------------------------------
    SubjectDir = fullfile(rootpath,SubjectID(i));
    load(fullfile(char(SubjectDir),'ChoicePhase'));
    load(fullfile(char(SubjectDir),'FatiguedChoicePhase'));
    
    PrefatGambles = ChoiceTrial(:,1:3);
    PostfatGambles = FatiguedChoiceTrial(:,1:3);
%--------------------------------------------------------------------------
    %^^[5/1/2015]---Current issue is division of gamble data into two
    %separate sessions. This is remedied above.
    
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
    
    %GLM ON CHOICE DATA [Separate betas for gamble and sure vals]
%--------------------------------------------------------------------------
%     choice=full_gbl(:,4);
%     gambles=full_gbl(:,2:3);
%     
%     [B2,dev,stats] = glmfit([gambles], choice, 'binomial', 'link', 'logit','constant','off');
%     Bs(i,:) = B2';
%     Ps(i,:) = stats.p';
%--------------------------------------------------------------------------

    %MLE ON CHOICE DATA
%--------------------------------------------------------------------------
    P1 = PrefatGambles(:,2:4);
    P2 = PostfatGambles(:,2:4);
    
    options = optimset('MaxFunEvals', 100000);
    
    addpath('C:\Users\Steven\Documents\MATLAB\FatigueCode\Analysis Code');
    
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

%--------------------------------------------------------------------------
% %SAVE RESULTING CURVATURE PARAMETERS
% rho=cell(2,1);
% rho{1}=subjects;
% rho{2}=paramtracker(:,2);
% save(['Y:\Analysis\curvature_parms1.mat'],'rho');