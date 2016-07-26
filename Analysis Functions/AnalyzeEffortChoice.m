% Original code from Patrick Hogan, modified by Steven Chen

% This m-file is used to run a MLE-based analysis to extract behavioral
% parameters from subjects' choice data during phases 4 and 5 (which
% correspond to the effort gamble tasks).

function [parameters, Pvals] = AnalyzeEffortChoice(SubjectID, ...
    SubjectDir,ChoiceTrial,FatiguedChoiceTrial,saveit)

    PrefatGambles = ChoiceTrial(:,1:3);
    PostfatGambles = FatiguedChoiceTrial(:,1:3);
%--------------------------------------------------------------------------
    % Calculate dEVs
    dEVs = PrefatGambles(:,1) - 0.5*PrefatGambles(:,2);
    % dEV values are now listed in the first column of this 'PreFatGambles'
    % data matrix.
    PrefatGambles = [dEVs PrefatGambles];
    
    % Sort the effort gamble choices based on dEV values.    
    [~,index]=sort(PrefatGambles(:,1));
    PrefatGambles = PrefatGambles(index,:);

	%Same thing for PostfatGambles
    dEVs = PostfatGambles(:,1) - 0.5*PostfatGambles(:,2);
    PostfatGambles = [dEVs PostfatGambles];
    
    [~,index]=sort(PostfatGambles(:,1));
    PostfatGambles = PostfatGambles(index,:);
    
    % get rid of NANs
    PrefatGambles(isnan(PrefatGambles(:,4)),:) = [];
    PostfatGambles(isnan(PostfatGambles(:,4)),:) = [];
    
%--------------------------------------------------------------------------
    %MLE ON CHOICE DATA
%--------------------------------------------------------------------------
    P1 = PrefatGambles(:,2:4);
    P2 = PostfatGambles(:,2:4);
    
    options = optimset('MaxFunEvals', 100000);
    
    paramtracker1 = zeros(1,2);
    paramtracker1(:) = fminsearch(@loglikelihood_rhomulam_effort,[.1 1], ...
        options, P1);
    lltracker1 = (loglikelihood_rhomulam_effort(paramtracker1(:),P1));
    %This evaluates the function value at the maximized parameter estimates
    %from above.  This acts as the fitted log likelihood for the choice data. 
    
    paramtracker2 = zeros(1,2);
    paramtracker2(:) = fminsearch(@loglikelihood_rhomulam_effort,[.1 1],options, P2);    
    lltracker2 = (loglikelihood_rhomulam_effort(paramtracker2(:),P2));
    %Same for P2
    
    paramtrackernull1 = fminsearch(@loglikelihood_null_effort,.1,options, P1);
    lltrackernull1 = (loglikelihood_null_effort(paramtrackernull1,P1));
    paramtrackernull2 = fminsearch(@loglikelihood_null_effort,.1,options, P2);
    lltrackernull2 = (loglikelihood_null_effort(paramtrackernull2,P2));
    %For validation of these values, the likelihood under the null
    %assumptions (with the curvature parameter being one), is determined in
    %the same manner.
    
    %From this, we obtain the parameters that describe the subjects'
    %subjective effort preferences (temperature parameter being the first
    %column and curvature parameter being the second).
    
    %Save resulting parameters
    parameters = zeros(2,2);
    parameters(1,:) = paramtracker1(:);
    parameters(2,:) = paramtracker2(:);
%--------------------------------------------------------------------------

    %Test Statistics using the log-liklihood ratio.
    D1 = -2*(lltracker1-lltrackernull1);
    D2 = -2*(lltracker2-lltrackernull2);

    Pvals = zeros(2,1);
    Pvals(1) = 1-chi2cdf(D1,1);
    Pvals(2) = 1-chi2cdf(D2,1);
    %^THIS IS RIGHT. Obtain p-values for these observations.
%--------------------------------------------------------------------------

    %Plotting pre and post-fatigue choice data and logistic functions
    figure;
    set(gcf,'name',SubjectID,'numbertitle','off')
    xmin = 1.1*min(min(PrefatGambles(:,1)),min(PostfatGambles(:,1)));
    xmax = 1.1*max(max(PrefatGambles(:,1)),max(PostfatGambles(:,1)));
    axis([xmin xmax 0 1])
    
    subplot(2,1,1);
    PreXvector = linspace(xmin,xmax,100000);
    Prelogfunc = (1+exp(-1*parameters(1,2)*PreXvector)).^-1;
    hold on;
    plot(PrefatGambles(:,1),PrefatGambles(:,4),'bo')
    plot(PreXvector,Prelogfunc,'b')
    
    subplot(2,1,2);
    PostXvector = linspace(xmin,xmax,100000);
    Postlogfunc = (1+exp(-1*parameters(2,2)*PostXvector)).^-1;
    hold on;
    plot(PostfatGambles(:,1),PostfatGambles(:,4),'ro')
    plot(PostXvector,Postlogfunc,'r')
    
%--------------------------------------------------------------------------
    %saving parameters and plots
    if saveit == 1
        save(fullfile(SubjectDir,'parameters'),'parameters');
        saveas(gcf,fullfile(SubjectDir,'LogFitPlot'),'fig');
    end

end
