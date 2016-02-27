function fatiguephaseAnalysis(SubjectID,SubjectDir,outcomeFatiguedChoiceTrial,saveit)
    % Function for plotting fatigue phase outcome data
    % Inputs: 
    % SubjectID - String corresponding to subject ID
    % outcomeFatiguedChoiceTrial - 17x300 matrix consisting of outcome data
    % from fatigue phase
    % save - 0 for no save, 1 for save
    
    numTrials = size(outcomeFatiguedChoiceTrial,1);
    outcomePlot = zeros(1,numTrials);
    for j = 1:numTrials
        outcome = outcomeFatiguedChoiceTrial(j,:);
        outcome(isnan(outcome)) = [];
        outcomePlot(j) = length(outcome);
    end
    figure;
    set(gcf,'name',SubjectID,'numbertitle','off')
    plot(outcomePlot,'-o');
    if saveit == 1
        saveas(gcf,fullfile(SubjectDir,'FatigueOutcomePlot'),'fig');
    end
end