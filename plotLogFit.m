close;clear;clc;

% rootpath = 'C:\Users\Steven\Documents\FatigueStudy\Data\Pilot Data - 2'; %Steven's Comp
rootpath = 'Y:\Fatigue Experiment\Pilot Data - 2'; %KKI Comp

SubjectID = {...
%     'KM_72015'...
%     'SM_71515'...
%     'JH_71515'...
%     'RL_71415'...
%     'ND_72115'...
%     'FO_72115'...
%     'SG_72215'...
%     'AG_72215'...
    'SU_72915'...
    };

for i = 1:size(SubjectID,2)
    SubjectDir = char(fullfile(rootpath,SubjectID(i)));
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
    hold on;
    xmin = 1.1*min(min(PrefatGambles(:,1)),min(PostfatGambles(:,1)));
    xmax = 1.1*max(max(PrefatGambles(:,1)),max(PostfatGambles(:,1)));
    axis([xmin xmax 0 1])
    
    PreXvector = linspace(xmin,xmax,100000);
    Prelogfunc = (1+exp(-1*parameters(1,1)*PreXvector)).^-1;
    plot(PrefatGambles(:,1),PrefatGambles(:,4),'bo')
    plot(PreXvector,Prelogfunc,'b')
    
    PostXvector = linspace(xmin,xmax,100000);
    Postlogfunc = (1+exp(-1*parameters(1,2)*PostXvector)).^-1;
    plot(PostfatGambles(:,1),PostfatGambles(:,4),'ro')
    plot(PostXvector,Postlogfunc,'r')
    
end

