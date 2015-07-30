clear; clc

% rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data - 2'; %Steven's Comp
rootpath = 'Y:\Fatigue Experiment\Pilot Data - 2'; %KKI Comp

subjects = 1; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - save plot with R^2 value

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
    load(fullfile(SubjectDir,'RecallPhase'));

    SumSquaredError = sum((RecallTrial(:,2)-RecallTrial(:,1)).^2);
    SampMean = mean(RecallTrial(:,2));
    SumSquaredMeanError = sum((RecallTrial(:,2)-SampMean).^2);
    rsquared = 1 - SumSquaredError/SumSquaredMeanError;

    figure(i);
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


