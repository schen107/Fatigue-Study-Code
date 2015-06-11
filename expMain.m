%%This is a script file for running experiment. I tend to code the main
%%components as scripts to allow me to easily access variables. This can be
%%a function. 


%% Setup

%refresh the workspace to act like a function
clc
clear

%include all files in lib
addpath(genpath('./lib'))

%get my settings from file
P = settings();

%Set Screen Options
Screen('Preference', 'SkipSyncTests', 1);


%% Start Experiment

%Start Screen
try
    MaxPriority(['GetSecs'],['KbCheck'],['KbWait'],['GetClicks']);
    KbName('UnifyKeyNames');
    ListenChar(2);
    HideCursor;
    whichScreen = 1;
    [wkspc, windowRect] = Screen(whichScreen, 'OpenWindow');
catch E
    endScreen;
    rethrow(E);
end

%% Run a phase
try
    % run 10 times
    numRuns = 10;
    % list of choices 
    list = {'a','s','d','f'};
    
    %set up bin
    outs = cell(numRuns,1);
    
    % perm choose two and run numRuns times
    for i = 1:numRuns
        inds = randperm(length(list));
        outs{i} = KeyGetter(wkspc,{list{inds(1)},list{inds(2)}});
    end
catch E
    endScreen;
    rethrow(E);
end



%% End Experiment
endScreen;


