clear; clc

% rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data - 2'; %Steven's Comp
rootpath = 'Y:\Fatigue Experiment\Pilot Data - 2'; %KKI Comp

subjects = 0; %1 - multiple subjects, 0 - one subject;
save = 0; %1 - save R^2 value and plot

% For 1 subject

SubjectID=input('Enter Subject Identifier: ','s'); 
SubjectDir = fullfile(rootpath,SubjectID);
load(fullfile(SubjectDir,'RecallPhase'));

SumSquaredError = sum((RecallTrial(:,2)-RecallTrial(:,1)).^2);
SampMean = mean(RecallTrial(:,2));
SumSquaredMeanError = sum((RecallTrial(:,2)-SampMean).^2);
rsquared = 1 - SumSquaredError/SumSquaredMeanError; 

figure(1);
hold on;
scatter(RecallTrial(:,1),RecallTrial(:,2),'*');
line = linspace(0,100,100);
plot(line,line);
text(70,10,strjoin({'R^2 =',num2str(rsquared)}));
axis([0 100 0 100]);


% For multiple subjects
% 
% SubjectID = {...
%     'KM_72015'...
%     'SM_71515'...
%     'JH_71515'...
%     'RL_71415'...
%     'ND_72115'...
%     'FO_72115'...
%     'SG_72215'...
%     'AG_72215'...
% %     'patricktest_71715'...
%     };
% 
% for i = 1:size(SubjectID,2)
%     SubjectDir = char(fullfile(rootpath,SubjectID(i)));
%     load(fullfile(SubjectDir,'RecallPhase'));
%     
%     SumSquaredError = sum((RecallTrial(:,2)-RecallTrial(:,1)).^2);
%     SampMean = mean(RecallTrial(:,2));
%     SumSquaredMeanError = sum((RecallTrial(:,2)-SampMean).^2);
%     rsquared = 1 - SumSquaredError/SumSquaredMeanError;
%     
%     figure(i);
%     hold on;
%     scatter(RecallTrial(:,1),RecallTrial(:,2),'*');
%     line = linspace(0,100,100);
%     plot(line,line);
%     text(70,10,strjoin({'R^2 =',num2str(rsquared)}));
%     axis([0 100 0 100]);
% end

