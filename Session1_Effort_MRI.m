%EFFORT EXPERIMENT: MVC and Association Task
rng('shuffle');%Generate new random seed.
cd('N:/Effort Experiment/MRI SESSIONS');
close all; clear all;
%^NOTE: Be careful of this when running individual sections, as an
%accidental F5 could clear the entire workspace, necessitating renewed
%acqusition of MVC as well as other parameters.
%%

%[This set of code (Session#_Effort_MRI.m) created on 1/28/2015 by PSH]
%This use of PsychToolbox is only compatable with Matlab 32-bit version.
%--------------------------------------------------------------------------
%The first of six sessions for the final fMRI experiment, this code
%contains both the MVC component and the association task for the Effort
%Experiment. This session will not be scanned with the MR and will be done
%separately.[Code initially taken from Effort_Exp_RunSCAN_TEST.m]
%--------------------------------------------------------------------------
%DAQ SETUP ----------------------------------------------------------------
%It is important that the force transducer be laying with its side flat on 
%the table with as little possible force being applied. This is for the 
%purposes of calibrating a baseline voltage. To avoid saturation of the 
%force transducer/DAQ setup, gain on the BIOPAC is set to 200.

subj_id=input('Enter Subject Identifier: ','s');
S={'SubjectData',subj_id};S=strjoin(S,'_');

rootpath='N:\Effort Experiment\MRI SESSIONS';
F={rootpath,S};F=strjoin(F,'\');mkdir(F);
subj_directory=F;
cd(subj_directory);
save('subj_id','subj_id');

sensor=analoginput('mcc');%Default sample rate: 1000
chans=addchannel(sensor,0);
start(sensor);

pause(5);%Pausing to be sure that the sensor has time to equilibriate
baseline_sample=getsample(sensor);
baseline=baseline_sample(1);  

%MAXIMUM VOLUNTARY CONTRACTION---------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);screen=max(Screen('Screens'));
white=WhiteIndex(screen);black=BlackIndex(screen);

[window,windowRect]=PsychImaging('OpenWindow',screen,black);
HideCursor(screen);
[xcenter,ycenter]=RectCenter(windowRect);
[xpix,ypix]=Screen('WindowSize',screen);

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='Session 1 - Part 1';
msg_b='Please Wait for Instructions';
DrawFormattedText(window,msg_a,'center','center',[255,255,255,255],0);
DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
Screen('Flip',window);

[z1,z2,z3]=KbStrokeWait;
if find(z2)==27
    sca;
end

%---TRIGGER-INITIATE-------------------------------------------------------
%SESSION 1 will not be performed in the MRI scanner, so the 'trigger' event
%is simply a keystroke most easily accomplished by pressing the space bar.
%The following sessions however (not including Session 6) will wait for the
%trigger from the MRI scanner.
Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='Wait for Trigger';
DrawFormattedText(window,msg_a,'center','center',white);
% Screen('Flip',window);
KbStrokeWait;
S1timings.trigger=GetSecs;
%--------------------------------------------------------------------------

ifi=Screen('GetFlipInterval',window);

numSecs_GetReady=1;%***
numFrames_GetReady=round(numSecs_GetReady/ifi);
waitframes=1;

vbl=Screen('Flip',window);
for f=1:numFrames_GetReady
    if f==1
        S1timings.MVC.getready=GetSecs-S1timings.trigger;
    end
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 70);
    msg1='Get Ready';
    DrawFormattedText(window,msg1,'center','center',white);
    vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
end
clear f

num_mvc_trials=3;
forces_mvc=zeros(num_mvc_trials,4000,2);
mvc_voltage=zeros(num_mvc_trials,1);
for n=1:num_mvc_trials
    j=0;
    numSecs_MVC=4;
    Screen(window,'TextSize',80);
    msg2='Squeeze!';
    DrawFormattedText(window,msg2,'center','center',white);
    Screen('Flip',window);
    
    S1timings.MVC.squeeze(n)=GetSecs-S1timings.trigger;

    %Acquisition of MVC
    tic;
    while toc<numSecs_MVC
        j=j+1;
        sample=getsample(sensor);
        delta_v=abs(sample(1)-baseline);
        forces_mvc(n,j,1)=delta_v;%Get change in voltage of each sample
        forces_mvc(n,j,2)=GetSecs;%Get time of each sample
    end

    mvc_voltage(n)=max(forces_mvc(n,:,1));
    forces_mvc(n,end,1)=j;%Store number of samples taken;

    fix_interval_min=2;
    fix_interval_max=5;
    numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;
    
%     fix_switch=1;
%     while fix_switch==1
%         numSecs_Fixation=2+poissrnd(3);
%         if numSecs_Fixation<=8
%             fix_switch=0;
%         end
%     end

    numFrames_Fixation=round(numSecs_Fixation/ifi);
    waitframes=1;
    %Fixation cross presented for a random number of seconds (over a
    %range of 2-5 seconds)
    for f=1:numFrames_Fixation
        if f==1
            S1timings.MVC.fix(n)=GetSecs-S1timings.trigger;
        end
        fixation_size=25;
        coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
        width=3;
        Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
        vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
    end
    clear f
end

mvc_max=max(max(forces_mvc(:,1:(end-2),1)));
reduce_ratio=0.8;
mvc_100=reduce_ratio*mvc_max;
%^mvc_max represents the highest achieved voltage change during the
%trials of maximum applied force. We are adjusting the 'effort range'
%of 0 to 100 to map from no force, to 80% of the max force (where the
%80% is represented in the variable 'reduce_ratio' which can be
%adjusted if need be).

cd(subj_directory);
A={'forces_mvc',subj_id};A=strjoin(A,'_');
B={'mvc_max',subj_id};B=strjoin(B,'_');

save(A,'forces_mvc');
save(B,'mvc_max','mvc_100');
%^Saving relevant data. In the future, we'll want to clear the
%workspace of unwanted data, to help things run smoothly.
clear forces_mvc;  
%%
%PHASE 2 --- EFFORT FAMILIARIZATION ---------------------------------------
%---FOR INITIATING ONLY THIS SECTION---------------------------------------
% screen=max(Screen('Screens'));
% white=WhiteIndex(screen);
% black=BlackIndex(screen);
% [window,windowRect]=PsychImaging('OpenWindow',screen,black);
% HideCursor(screen);
% [xcenter,ycenter]=RectCenter(windowRect);
% [xpix,ypix]=Screen('WindowSize',screen);
% ifi=Screen('GetFlipInterval',window);
%--------------------------------------------------------------------------
msg_a='Session 1 - Part 2';msg_b='Please Wait for Instructions';
Screen('TextSize',window,40);
Screen('TextFont',window,'Ariel');
DrawFormattedText(window,msg_a,'center','center',white);
DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
Screen('Flip',window);

S1timings.Assoc.intro=GetSecs-S1timings.trigger;

[z1,z2,z3]=KbStrokeWait;
if find(z2)==27
    sca;
end

%NOTE: We want the 'thermometer' representation of effort to be as
%real-time as possible, so keep that in mind; we need to set up a timing
%loop here.        

therm_height=600;therm_width=200;
bg_therm=[0 0 therm_width therm_height];
bg_therm=CenterRectOnPointd(bg_therm,xcenter,ycenter);
therm_top=bg_therm(2);
therm_bottom=bg_therm(4);therm_left=bg_therm(1);therm_right=bg_therm(3);
bg_therm_color=white;

success_window=0.05;
%^Using a more 'precise' definition of success: defining a range of the
%target effort level +/-5 units to be counted towards 'successfull
%samples'.

%Modified Train/Test set and general approach of effort test and
%familiarization: have five sets of the same psuedo-random value
%and then perform the test for that value.

train_targets=[10 20 30 40 50 60 70 80];
nlevel=length(train_targets);
%^Can easily implement a few lines of code that make sure several high
%values will not be tested in a row; this just hasn't been done yet (or
%deemed to be fully necessary).

num_per_target=5;
%^THIS SEEMS SUFFICIENT - MAY NEED TO CHANGE

recall_threshold=3;%Give subjects three trials to get it right.
num_train_trials=num_per_target*length(train_targets);
forces_train=zeros(num_train_trials,4000,2);
forces_recall=zeros(recall_threshold*length(train_targets),4000,2);
N=0;%N keeps track of the training forces;

goodbad_train=zeros(num_train_trials,3);
%^^Right now, we don't know how many trials it will take
%for subjects to get it right, so we can't really pre-allocate this
%matrix. Consider whether or not we want to have them attempt the task
%until they get it.

for i=1:length(train_targets)

    %Display 'Get Ready' Message before each new target value.
    %^^This may also have to be removed if we remove the long pause
    %between the different test-values.
    vbl=Screen('Flip',window);
    for f=1:numFrames_GetReady%(Get Ready for 1 sec)
        if f==1
            S1timings.Assoc.getready(i)=GetSecs-S1timings.trigger;
        end
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 70);
        msg1='Get Ready';
        DrawFormattedText(window,msg1,'center','center',white);
        vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
    end
    clear f

    target_current_ind=randi(length(train_targets),1);
    target_current=train_targets(target_current_ind);
    train_targets(target_current_ind)=[];

    for k=1:num_per_target

        N=N+1;

        num_good_train=0;
        num_bad_train=0;

        eff_aim_int=target_current;
        eff_aim=eff_aim_int/100;%To be determined based on the training trial; randomly selected 
        %values that the subject will try to "hit" by adjusting their applied
        %force.

        %Display the target number...
        aim_msg=num2str(eff_aim_int);
        Screen('TextSize',window,70);
        Screen('TextFont',window,'Ariel');
        DrawFormattedText(window,aim_msg,'center','center',white);
        Screen('Flip',window);
        
        S1timings.Assoc.target(i,k)=GetSecs-S1timings.trigger;

        pause(2);
        %^Two seconds to see the target number.

        aim_dash_l=50;aim_dash_w=3;
        aim_dims=[-aim_dash_l/2 aim_dash_l/2 0 0; 0 0 0 0];
        aim_x=therm_right+aim_dash_l/2+5;aim_y=therm_bottom-round(eff_aim*600);

        win_baserect=[0 0 50 round(success_window*therm_height)];
        win_rect1=CenterRectOnPointd(win_baserect,aim_x,aim_y+round(0.5*win_baserect(4)));
        win_rect2=CenterRectOnPointd(win_baserect,aim_x,aim_y-round(0.5*win_baserect(4)));

        fontsize=20;
        Screen('TextSize', window, fontsize);
        Screen('DrawLines',window,aim_dims,aim_dash_w,white,[aim_x aim_y]);

        aim_msg=num2str(eff_aim_int);
        DrawFormattedText(window,aim_msg,aim_x+fontsize+10,aim_y-fontsize,white);

        numSecs_Train=4;
        %^Number of seconds to train: 4
        numFrames_Train=round(numSecs_Train/ifi);
        waitframes=1;

        j=0;
        vbl=Screen('Flip',window);

        %Image_3=Screen('GetImage',window);

        for f=1:numFrames_Train

            j=j+1;
            eff_sample=getsample(sensor);
            eff_time=GetSecs;

            eff_sample=abs(eff_sample(1)-baseline);
            forces_train(N,j,1)=eff_sample;
            forces_train(N,j,2)=eff_time;
            eff_per=eff_sample/mvc_100;

            if abs(eff_per-eff_aim)<success_window
                num_good_train=num_good_train+1;
                Screen('FillRect',window,[0 1 0],win_rect1);
                Screen('FillRect',window,[0 1 0],win_rect2);
            else
                num_bad_train=num_bad_train+1;
                Screen('FillRect',window,[1 0 0],win_rect1);
                Screen('FillRect',window,[1 0 0],win_rect2);
            end

            %Current timing on real-time force acquisition along with
            %displaying the levels might be a bit tricky - this will be
            %important to get right, so prioritize this once the force
            %transducer is up and running.

            eff_pix=round(eff_per*600);
            therm=[therm_left therm_bottom-eff_pix therm_right therm_bottom];
            therm_color=white;

            %Screen('FillRect',window,bg_therm_color,bg_therm);
            Screen('FrameRect',window,bg_therm_color,bg_therm);
            Screen('FillRect',window,therm_color,therm);
            Screen('TextSize', window, fontsize);
            Screen('DrawLines',window,aim_dims,aim_dash_w,white,[aim_x aim_y]);
            DrawFormattedText(window,aim_msg,aim_x+fontsize+10,aim_y-fontsize,white);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            
            if f==1
                S1timings.Assoc.therm(i,k)=GetSecs-S1timings.trigger;
            end
        end
        clear f

        forces_train(N,end,1)=j;%Store number of samples taken.
        forces_train(N,end-1,1)=eff_aim_int;%Store the target effort;

        %Repeat for an appropriate amount of trials - making sure to iterate to
        %include timing.

        goodbad_train(N,:)=[num_good_train num_bad_train target_current];
        win=0;
        if num_good_train>2*num_bad_train
            win=1;
        end

        rect_color_correct=[0 1 0];rect_color_incorrect=[1 0 0];
        numSecs_Feedback=2;
        numFrames_Feedback=round(numSecs_Feedback/ifi);
        waitframes=1;

        if win
            vbl=Screen('Flip',window);
            for f=1:numFrames_Feedback
                Screen('TextSize', window, 70);
                win_msg='Success';
                DrawFormattedText(window,win_msg,'center','center',rect_color_correct);
                vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                
                if f==1
                    S1timings.Assoc.feedback(i,k)=GetSecs-S1timings.trigger;
                end
            end
            clear f
        else
            vbl=Screen('Flip',window);
            for f=1:numFrames_Feedback
                Screen('TextSize', window, 70);
                loss_msg='Failure';
                DrawFormattedText(window,loss_msg,'center','center',rect_color_incorrect);
                Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                
                if f==1
                    S1timings.Assoc.feedback(i,k)=GetSecs-S1timings.trigger;
                end
            end
            clear f
        end

        %Fixation cross for inter-trial period
        fix_interval_min=2;
        fix_interval_max=5;
        numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;

%         fix_switch=1;
%         while fix_switch==1
%             numSecs_Fixation=2+poissrnd(3);
%             if numSecs_Fixation<=8
%                 fix_switch=0;
%             end
%         end

        numFrames_Fixation=round(numSecs_Fixation/ifi);
        waitframes=1;

        vbl=Screen('Flip',window);
        for f=1:numFrames_Fixation
            fixation_size=25;
            coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
            width=3;
            Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            
            if f==1
                S1timings.Assoc.fix(i,k)=GetSecs-S1timings.trigger;
            end
        end
        clear f
    end

    if i~=nlevel
        msg_rest='Rest';
        Screen('TextSize',window,70);Screen('TextFont',window,'Ariel');
        DrawFormattedText(window,msg_rest,'center','center',white);
        Screen('Flip',window);
        S1timings.Assoc.rest(i)=GetSecs-S1timings.trigger;
        pause(60);%Inter-training rest/recovery period.
        %^Rest period ignored if this is the last set being trained.
    end
end

cd('N:/Effort Experiment/MRI SESSIONS');
save('subj_directory','subj_directory');

cd(subj_directory);
A={'forces_train',subj_id};A=strjoin(A,'_');
C={'goodbad_train',subj_id};C=strjoin(C,'_');

save(A,'forces_train');
save(C,'goodbad_train');

save('S1_TimingData','S1timings');
%^Save timing data

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='End of Session 1';
DrawFormattedText(window,msg_a,'center','center',white);
Screen('Flip',window);
pause(5);

sca;

clc;
disp('>> SESSION 1 COMPLETE');
disp('>> Ready to run: Session2_Effort_MRI.m');

cd('N:/Effort Experiment/MRI SESSIONS');