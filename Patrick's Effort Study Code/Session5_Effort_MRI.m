%EFFORT EXPERIMENT: Effort Gambles (PART 2)
load subj_directory;
cd(subj_directory);
%%
%PHASE 4 --- EFFORT GAMBLES -----------------------------------------------
%Our goal here is to get at subjects' inherent risk preferences in the
%effort domain by evaluating choices made over a series of behaviorally
%relevant effort gambles. This is achieved in two parts (sessions 4 and 5).

%---FOR INITIATING THIS SECTION--------------------------------------------
screen=max(Screen('Screens'));
white=WhiteIndex(screen);
black=BlackIndex(screen);
[window,windowRect]=PsychImaging('OpenWindow',screen,black);
HideCursor(screen);
[xcenter,ycenter]=RectCenter(windowRect);
[xpix,ypix]=Screen('WindowSize',screen);
%--------------------------------------------------------------------------

msg_a='Session 5';msg_b='Please Wait for Instructions';
Screen('TextSize',window,40);
Screen('TextFont',window,'Ariel');
DrawFormattedText(window,msg_a,'center','center',white);
DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
Screen('Flip',window);
[z1,z2,z3]=KbStrokeWait;
if find(z2)==27
    sca;
end

%---TRIGGER-INITIATE-------------------------------------------------------
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='Wait for Trigger';
DrawFormattedText(window,msg_a,'center','center',white);
Screen('Flip',window);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
cd('N:\Effort Experiment\MRI SESSIONS');
cedrusopen;
trigger=0;
cedrus.resettimer();
while trigger==0
    [button]=cedrus.getpress();
%     [button time press]=cedrus.getpress();
    if button==6
        S5timings.trigger=GetSecs;
        trigger=1;
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% KbStrokeWait;
% S5timings.trigger=GetSecs;
%^Currently our stand-in for the actual trigger. This will need to be
%changed so that the code waits for the trigger (rather than the button
%press).
%--------------------------------------------------------------------------

% cd('N:/Effort Experiment');
% load Gambles_12_5 
%The .mat file 'Gambles_12_5' contains the un-modified form of the gambles
%created for this experiment in the m-file GambleGen.m. The gambles are
%generated by finding pairs of flip and sure values that sweep the space of
%a ratio, M_star, which represents the ratio of the worst possible outcome,
%to the sure value. 

%The new version of the gambles file, Gambles_12_5 (updated on December
%5th, 2014) contains an extra 70 gambles obtained by dividing the
%gamble value in half - and removing the situations where the gamble
%amount is less than the sure amount.

% Gambles=Gambles_12_5;
% subject_gambles=Gambles(:,1:2);
% gambles_reordered=zeros(size(subject_gambles));

% load Gamble_Data_Workspace
%^BAD --- NEED TO FIX

cd(subj_directory);
load rem_gambles
num_trials=length(subject_gambles);%Number of REMAINING trials 
%^(Gambles not yet performed)

gambles_reordered=zeros(2*num_trials,2);
choice_times=nan(2*num_trials,1);
trial_choices=nan(2*num_trials,1);

for t=(num_trials+1):2*num_trials

    clear gamble_val safe_val

    [r,c]=size(subject_gambles);
    index_trial=randi(r,1);
    sure_flip_trial=subject_gambles(index_trial,:);
    
    gambles_reordered(t,:)=sure_flip_trial;
    sure_val=sure_flip_trial(1);flip_val=sure_flip_trial(2);
    subject_gambles(index_trial,:)=[];
    gambles_reordered(t,:)=sure_flip_trial;

    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 70);

    msg_flip1=num2str(flip_val,'%.2f');msg_flip0=num2str(0);
    msg_sure=num2str(sure_val,'%.2f');

    g1x=round(0.35*xpix);g1y=ycenter-100;
    g0x=round(0.35*xpix);g0y=ycenter+100;
    sx=round(0.65*xpix);sy=ycenter;

    base_rect_flip=[0 0 300 500];
    base_rect_sure=[0 0 300 200];

    rect_flip=CenterRectOnPointd(base_rect_flip,g1x,ycenter);
    rect_sure=CenterRectOnPointd(base_rect_sure,sx,ycenter);

    Screen('FrameRect',window,white,rect_flip,5);
    Screen('FrameRect',window,white,rect_sure,5);

    %Formatting...
    if flip_val<10
        DrawFormattedText(window,msg_flip1,g1x-90,g1y-90,white);
    else
        DrawFormattedText(window,msg_flip1,g1x-115,g1y-90,white);
    end
    DrawFormattedText(window,msg_flip0,g0x-25,g0y-20,white);

    if sure_val<10
        DrawFormattedText(window,msg_sure,sx-90,sy-50,white);
    else
        DrawFormattedText(window,msg_sure,sx-115,sy-50,white);
    end
    %End formatting...

    Screen('TextSize',window,50);
    DrawFormattedText(window,'Flip',g0x-50,g1y+360);
    DrawFormattedText(window,'Sure',sx-70,g1y+210);

    Screen('Flip',window);
    S5timings.gamble(t-num_trials)=GetSecs-S5timings.trigger;
    
    t_elapse=0;t0=GetSecs;
    choice=0;
    cedrus.resettimer();
    while choice==0&&(t_elapse<=4)
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
        t_elapse=GetSecs-t0;
        [button]=cedrus.getpress();
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    %     [time,keyboard,del_sec]=KbWait([],0,GetSecs+4);
    %     if keyboard(77)==true
        if button==2%CEDRUS
            %'M' pressed - Sure choice made.
            choice_times(t)=(GetSecs-S5timings.trigger)-S5timings.gamble(t-num_trials);
            trial_choices(t)=0;
            choice=1;
            %choice_times(t)=del_sec;
    %     elseif keyboard(78)==true%KEYBOARD
        elseif button==1%CEDRUS
            %'N' pressed - Flip choice made.
            choice_times(t)=(GetSecs-S5timings.trigger)-S5timings.gamble(t-num_trials);
            trial_choices(t)=1;
            choice=1;
            %choice_times(t)=del_sec;
    %--------------------------------------------------------------------------
    %CEDRUS: Can comment out the 'mistypes' because there are only three
    %available buttons.
    %     else
    %         %The following code catches any mis-types - and makes sure to
    %         %get the overall choice time once a decision is actually made.
    %         while (keyboard(77)==0)&&(keyboard(78)==0)&&(toc<4)            
    %             whoops=toc;
    %             [time,keyboard,del_sec]=KbWait([],0,GetSecs+4-whoops);
    %             if keyboard(77)==true
    %                 choice_times(t)=(GetSecs-S5timings.trigger)-S5timings.gamble(t-num_trials);
    %                 trial_choices(t)=0;
    %             elseif keyboard(78)==true
    %                 choice_times(t)=(GetSecs-S5timings.trigger)-S5timings.gamble(t-num_trials);
    %                 trial_choices(t)=1;
    %             end
    %         end
    %--------------------------------------------------------------------------
        end
    end

    fixation_size=25;
    coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
    width=3;

    Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
    Screen('Flip',window);
    S5timings.fix(t-num_trials)=GetSecs-S5timings.trigger;

%     ITI=2+3*rand;
    fix_switch=1;
    while fix_switch==1
        numSecs_Fixation=2+poissrnd(3);
        if numSecs_Fixation<=8
            fix_switch=0;
        end
    end    
    pause(numSecs_Fixation);
    
end

cedrus.close();

cd(subj_directory);
subject_data=[gambles_reordered trial_choices choice_times];
%Sure Value/Gamble Value/Choice (1 for Gamble)/Time to choose
save('subject_gambles2','subject_data');
save('S5_TimingData','S5timings');

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='End of Session 5';
DrawFormattedText(window,msg_a,'center','center',white);
Screen('Flip',window);
pause(5);
sca;

clc;
disp('>> SESSION 5 COMPLETE');
disp('>> Ready to run: Session6_Effort_MRI.m');

cd('N:/Effort Experiment/MRI SESSIONS');