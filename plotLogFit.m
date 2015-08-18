close;clear;clc;

rootpath = 'Z:\Fatigue Experiment\Data';
FolderName = 'Pilot - 3'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjects = 0; %1 - multiple subjects, 0 - one subject;
saveit = 1; %1 - save plot with logistic fits and choice data for pre and post fatigue

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
        
%         Pilot - 3
        'FM_73115'...
        'NF_8315'...
        'TG_8415'...
        'TT_8315'...
        'CJ_8815'...

        };
elseif subjects == 0
    SubjectID = input('Enter Subject Identifier: ','s');
    SubjectID = cellstr(SubjectID);
end

for i = 1:length(SubjectID)
    SubjectDir = char(fullfile(rootpath,FolderName,SubjectID(i)));
    load(fullfile(SubjectDir,'ChoicePhase'));
    load(fullfile(SubjectDir,'FatiguedChoicePhase'));
    load(fullfile(SubjectDir,'parameters'));
    PrefatGambles = ChoiceTrial(:,1:3);
    PostfatGambles = FatiguedChoiceTrial(:,1:3);
    PreRho = parameters(1,2);
    PostRho = parameters(2,2);
    
    %Calculate dEUs
    dEUs = PrefatGambles(:,1).^PreRho - 0.5*PrefatGambles(:,2).^PreRho;
    PrefatGambles = [dEUs PrefatGambles];
    %^^dEU values are now listed in the first column of this 'PreFatGambles'
    %data matrix.
    
    [~,index]=sort(PrefatGambles(:,1));
    PrefatGambles = PrefatGambles(index,:);
    %^^Sort the effort gamble choices based on dEV values.

	%Same thing for PostfatGambles
    dEUs = PostfatGambles(:,1).^PostRho - 0.5*PostfatGambles(:,2).^PostRho;
    PostfatGambles = [dEUs PostfatGambles];
    
    [~,index]=sort(PostfatGambles(:,1));
    PostfatGambles = PostfatGambles(index,:);
    
    PrefatGambles(isnan(PrefatGambles(:,4)),:) = [];
    PostfatGambles(isnan(PostfatGambles(:,4)),:) = [];
    %^^ get rid of NANs
    
    %plotting pre and post-fatigue choice data and logistic functions
    figure(i);
    set(gcf,'name',char(SubjectID(i)),'numbertitle','off')
    xmin = 1.1*min(min(PrefatGambles(:,1)),min(PostfatGambles(:,1)));
    xmax = 1.1*max(max(PrefatGambles(:,1)),max(PostfatGambles(:,1)));
    axis([xmin xmax 0 1])
    
    subplot(2,1,1);
    PreXvector = linspace(xmin,xmax,100000);
    Prelogfunc = (1+exp(-1*parameters(1,1)*PreXvector)).^-1;
    hold on;
    plot(PrefatGambles(:,1),PrefatGambles(:,4),'bo')
    plot(PreXvector,Prelogfunc,'b')
    
    subplot(2,1,2);
    PostXvector = linspace(xmin,xmax,100000);
    Postlogfunc = (1+exp(-1*parameters(1,2)*PostXvector)).^-1;
    hold on;
    plot(PostfatGambles(:,1),PostfatGambles(:,4),'ro')
    plot(PostXvector,Postlogfunc,'r')
    
    if saveit == 1
        saveas(gcf,fullfile(SubjectDir,'LogFitPlot'),'fig');
    end
    
end

