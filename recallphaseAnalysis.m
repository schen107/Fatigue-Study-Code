function recallphaseAnalysis(SubjectID,SubjectDir,RecallTrial,saveit)
    % Function to analyze phase 3 data (recall phase). This determines whether
    % or not the subject adequately understood the experiment.
    % Inputs: 
    % SubjectID - String corresponding to subject ID
    % RecallTrial - 48x4 matrix consisting of data from recall phase
    % save - 0 for no save, 1 for save
    
    SumSquaredError = sum((RecallTrial(:,2)-RecallTrial(:,1)).^2);
    SampMean = mean(RecallTrial(:,2));
    SumSquaredMeanError = sum((RecallTrial(:,2)-SampMean).^2);
    rsquared = 1 - SumSquaredError/SumSquaredMeanError;

    figure;
    set(gcf,'name',SubjectID,'numbertitle','off')
    hold on;
    scatter(RecallTrial(:,1),RecallTrial(:,2),'*');
    line = linspace(0,100,100);
    plot(line,line);
    text(70,10,strjoin({'R^2 =',num2str(rsquared)}));
    axis([0 100 0 100]);
    if saveit == 1
        saveas(gcf,fullfile(SubjectDir,'RecallPhasePlot'),'fig');
    end
end


