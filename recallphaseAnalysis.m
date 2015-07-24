clear; clc

rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data';

% For 1 subject

% SubjectID=input('Enter Subject Identifier: ','s'); 
% SubjectDir = fullfile(rootpath,SubjectID);
% load(fullfile(SubjectDir,'RecallPhase'));
% 
% figure(1);
% hold on;
% scatter(RecallTrial(:,1),RecallTrial(:,2),'*');
% line = linspace(0,90,100);
% plot(line,line);
% axis([0 90 0 90]);


% For multiple subjects

SubjectID = {...
    'KM_72015'...
    'SM_71515'...
    'JH_71515'...
    'RL_71415'...
    'ND_72115'...
    'FO_72115'...
    'SG_72215'...
    'AG_72215'...
%     'patricktest_71715'...
    };

for i = 1:size(SubjectID,2)
    SubjectDir = char(fullfile(rootpath,SubjectID(i)));
    load(fullfile(SubjectDir,'RecallPhase'));
    
    figure(i);
    hold on;
    scatter(RecallTrial(:,1),RecallTrial(:,2),'*');
    line = linspace(0,90,100);
    plot(line,line);
    axis([0 90 0 90]);
    
end

