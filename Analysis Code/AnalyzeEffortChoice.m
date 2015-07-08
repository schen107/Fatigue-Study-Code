%This m-file is used to run a MLE-based analysis to extract behavioral
%parameters from subjects' choice data during MRI sessions 4 and 5 (which
%correspond to the effort gamble tasks).

clc;clear;

subjects={...
    'sbj_EF_NE_002'...
    'sbj_EF_LP_003'...
    'sbj_EF_AT_004'...
    'sbj_EF_JS_005'...
    'sbj_EF_NR_006'...
    'sbj_EF_JD_007'...
    'sbj_EF_GA_008'...
    'sbj_EF_MT_009'...
    'sbj_EF_KJ_010'...
    'sbj_EF_MT_011'...
    'sbj_EF_KS_012'...
    'sbj_EF_JR_013'};

rootPath='Y:\Data';

Bs = [];
Ps = [];
Params =[];

for i = 1:size(subjects,2)
    
    %Column 1 -- Sure
    %Column 2 -- Flip
%--------------------------------------------------------------------------
    sess4_gbl=load([rootPath, filesep, subjects{i} '\behavioral\subject_gambles1.mat']);
    sess5_gbl=load([rootPath, filesep, subjects{i} '\behavioral\subject_gambles2.mat']);
    
    full_gbl=zeros(size(sess4_gbl.subject_data));
    ind4=find(sess4_gbl.subject_data(:,2));
    ind5=find(sess5_gbl.subject_data(:,2));
    full_gbl(ind4,:)=sess4_gbl.subject_data(ind4,:);
    full_gbl(ind5,:)=sess5_gbl.subject_data(ind5,:);
    
    clear sess4_gbl sess5_gbl
%--------------------------------------------------------------------------
    %^^[5/1/2015]---Current issue is division of gamble data into two
    %separate sessions. This is remedied above.
    
    %Calculate dEVs
    dEVs = full_gbl(:,1) - 0.5*full_gbl(:,2);
    full_gbl = [dEVs full_gbl];
    %^^dEV values are now listed in the first column of this 'full_gbl'
    %data matrix.
    
    [a,idx]=sort(full_gbl(:,1));
    full_gbl = full_gbl(idx,:);
    %^^Sort the effort gamble choices based on dEV values.
    
    %Remove NANs
    rmnan = find(isnan(full_gbl(:,4)));
    if isempty(rmnan) == 0
        full_gbl(rmnan,:)=[];
    end

    %GLM ON CHOICE DATA [Separate betas for gamble and sure vals]
%--------------------------------------------------------------------------
    choice=full_gbl(:,4);
    gambles=full_gbl(:,2:3);
    
    [B2,dev,stats] = glmfit([gambles], choice, 'binomial', 'link', 'logit','constant','off');
    Bs(i,:) = B2';
    Ps(i,:) = stats.p';
%--------------------------------------------------------------------------

    %MLE ON CHOICE DATA
%--------------------------------------------------------------------------
    P = full_gbl(:,2:4);
    options = optimset('MaxFunEvals', 100000);

    addpath('Y:\Analysis');
    paramtracker(i,:)=fminsearch(@loglikelihood_rhomulam_effort,[.1 1],options, P);    
    lltracker(1,i)=(loglikelihood_rhomulam_effort(paramtracker(i,:),P));
    %This evaluates the function value at the maximized parameter estimates
    %from above.  This acts as the fitted log likelihood for the choice data. 
    
    paramtracker2(i,:)=fminsearch(@loglikelihood_null_effort,[.1],options, P);
    lltrackernull(1,i)=(loglikelihood_null_effort(paramtracker2(i,:),P));
    %For validation of these values, the likelihood under the null
    %assumptions (with the curvature parameter being one), is determined in
    %the same manner.
    
    %From this, we obtain the parameters that describe the subjects'
    %subjective effort preferences (temperature parameter being the first
    %column and curvature parameter being the second).
%--------------------------------------------------------------------------
end

%Test Statistics using the log-liklihood ratio.
D = -2*(lltracker-lltrackernull);
% Pvals = chi2pdf(D,1);

Pvals = 1-chi2cdf(D,1);
%^THIS IS RIGHT. Obtain p-values for these observations.

%--------------------------------------------------------------------------
%SAVE RESULTING CURVATURE PARAMETERS
rho=cell(2,1);
rho{1}=subjects;
rho{2}=paramtracker(:,2);
save(['Y:\Analysis\curvature_parms1.mat'],'rho');