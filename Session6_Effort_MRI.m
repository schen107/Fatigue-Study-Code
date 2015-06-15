%EFFORT EXPERIMENT: Final Task (No Scanner)
load subj_directory;
cd(subj_directory);
%% 
%RESULTS (Chosen from Gambles)---------------------------------------------
%This last session of the experiment does not need to be scanned with the
%MR machine - this is just the final task where ten gambles are randomly
%selected and then played out.

G1=load('subject_gambles1');G1=G1.subject_data;
G2=load('subject_gambles2');G2=G2.subject_data;
subject_data=[G1(1:85,:);G2(86:end,:)];

%---FOR INITIATING THIS SECTION--------------------------------------------
screen=max(Screen('Screens'));
white=WhiteIndex(screen);
black=BlackIndex(screen);
[window,windowRect]=PsychImaging('OpenWindow',screen,black);
HideCursor(screen);
[xcenter,ycenter]=RectCenter(windowRect);
[xpix,ypix]=Screen('WindowSize',screen);
ifi=Screen('GetFlipInterval',window);
%--------------------------------------------------------------------------
msg_a='Session 6';msg_b='Please Wait for Instructions';
Screen('TextSize',window,40);Screen('TextFont',window,'Ariel');
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
KbStrokeWait;
S6timings.trigger=GetSecs;
%^Currently our stand-in for the actual trigger. This will need to be
%changed so that the code waits for the trigger (rather than the button
%press).
%--------------------------------------------------------------------------

numSecs_GetReady=3;
numFrames_GetReady=round(numSecs_GetReady/ifi);
waitframes=1;

vbl=Screen('Flip',window);
for f=1:numFrames_GetReady
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 70);
    msg1='Get Ready';
    DrawFormattedText(window,msg1,'center','center',white);
    vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
    if f==1
        S6timings.getready=GetSecs-S6timings.trigger;
    end
end
clear f
%--------------------------------------------------------------------------
%---Implement the task with the determined forces--------------------------

%Choose which gambles are to be played out:--------------------------------
num_chosen=10;
gambles_chosen=zeros(num_chosen,3);
lever=1;
while lever==1
    gambles_chosen_index=randi(length(subject_data),1);
    gambles_chosen(1,:)=subject_data(gambles_chosen_index,1:3);
    if (gambles_chosen(1,3)/1)==gambles_chosen(1,3)
        lever=0;
    end
end

%This loop was designed in order to make sure no NaN trials were taken
%from the subject's decision. A NaN occured whenever a subject failed
%to make a choice in the appropriate amount of time.
for z=2:num_chosen
    lever=1;
    while lever==1
        gambles_chosen_index=randi(length(subject_data),1);
        gambles_chosen(z,:)=subject_data(gambles_chosen_index,1:3);
        if (gambles_chosen(z,3)/1)==gambles_chosen(z,3)
            lever=0;
        end
        for u=1:(z-1)
            if gambles_chosen(u,:)==gambles_chosen(z,:)
                lever=1;
            end
        end
    end
end
%---Determine what forces are to be exerted--------------------------------
gambles_EFFORT_set=zeros(num_chosen,1);
for i=1:num_chosen
    if gambles_chosen(i,3)==0
        gambles_EFFORT_set(i)=gambles_chosen(i,1);
    else
        flip=rand(1);
        while flip~=0&&flip~=1
            if flip>0.5
                flip=1;
                gambles_EFFORT_set(i)=gambles_chosen(i,2);
            elseif flip<0.5
                flip=0;
                gambles_EFFORT_set(i)=0;
            else
                flip=rand(1);
            end
        end
    end
end
save('gambles_EFFORT_set','gambles_EFFORT_set');

%It is important to keep in mind that we also need to have "success"
%and "fail" conditions for the task, with continued efforts until the
%task properly achieved.
num_test_trials=length(gambles_EFFORT_set);
forces_gamble=zeros(num_test_trials,4000,2);
success_window=0.05;%As before;

test_therm_height=200;test_therm_width=800;
bg_test_therm=[0 0 test_therm_width test_therm_height];
bg_test_therm=CenterRectOnPointd(bg_test_therm,xcenter,ycenter);

test_therm_top=bg_test_therm(2);
test_therm_bottom=bg_test_therm(4);
test_therm_left=bg_test_therm(1);
test_therm_right=bg_test_therm(3);

bg_test_therm_color=white;

test_ordered=zeros(length(gambles_EFFORT_set),1);

half_length=400;

for n=1:length(gambles_EFFORT_set)

    eff_aim_index=randi(length(gambles_EFFORT_set),1);
    eff_aim=gambles_EFFORT_set(eff_aim_index);
    gambles_EFFORT_set(eff_aim_index)=[];
    %^Once we've acquired our target to be aimed for, we'll have that be
    %the relative "full-bar" for the task.

    if eff_aim==0
        test_therm=[test_therm_left+1 test_therm_top+3 ...
                    test_therm_right-1 test_therm_bottom-3];
        numSecs_Squeeze=4;
        numFrames_Squeeze=round(numSecs_Squeeze/ifi);
        test_therm_color=[0 1 0];
        vbl=Screen('Flip',window);
        for f=1:numFrames_Squeeze
            Screen('FrameRect',window,bg_test_therm_color,bg_test_therm,3);
            Screen('FillRect',window,test_therm_color,test_therm);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            if f==1
                S6timings.squeeze(n)=GetSecs-S6timings.trigger;
            end
        end
        numSecs_Feedback=2;
        numFrames_Feedback=round(numSecs_Feedback/ifi);
        vbl=Screen('Flip',window);
        for f=1:numFrames_Feedback
            Screen('TextSize', window, 70);
            win_msg='Success';
            DrawFormattedText(window,win_msg,'center','center',rect_color_correct);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            if f==1
                S6timings.feedback(n)=GetSecs-S6timings.trigger;
            end
        end
        clear f
    else
        try_again=1;
        while try_again==1
            eff_aim_per=eff_aim/100;
            numSecs_Squeeze=4;
            numFrames_Squeeze=round(numSecs_Squeeze/ifi);
            num_good=0;num_bad=0;

            j=0;
            vbl=Screen('Flip',window);
            for f=1:numFrames_Squeeze
                j=j+1;
                %Acquire Squeeze Test Data
                sample_test=getsample(sensor);
                sample_test=abs(sample_test(1)-baseline);
                forces_gamble(n,j,1)=sample_test;
                forces_gamble(n,j,2)=GetSecs;

                test_target_v=eff_aim_per*mvc_100;
                eff_test_per=sample_test/test_target_v;
                if eff_test_per>1
                    eff_test_pix=800;
                else
                    eff_test_pix=round(eff_test_per*800);
                end
                test_therm=[test_therm_left+1 test_therm_top+3 ...
                    test_therm_left+1+eff_test_pix test_therm_bottom-3];
                %^Get the filled up test-bar for the taken sample.

                per_success=(success_window*100)/eff_aim;

                if eff_test_per<(1-per_success)||eff_test_per>(1+per_success)
                    test_therm_color=[1 0 0];
                    num_bad=num_bad+1;
                else
                    test_therm_color=[0 1 0];
                    num_good=num_good+1;
                end

                linecoords=[0 0 0 0;0 0 -100 100];
                linepos=xcenter+half_length-round(success_window*800);

                Screen('FrameRect',window,bg_test_therm_color,bg_test_therm,3);
                Screen('FillRect',window,test_therm_color,test_therm);
                vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                if f==1
                    S6timings.squeeze(n)=GetSecs-S6timings.trigger;
                end
            end
            clear f

            forces_gamble(n,end,1)=j;%Store number of samples
            forces_gamble(n,end-1,1)=eff_aim;%Store the target effort for the trial;

%---------------Determine and Display if Trial was success or failure------
            rect_color_correct=[0 1 0];rect_color_incorrect=[1 0 0];
            numSecs_Feedback=2;
            numFrames_Feedback=round(numSecs_Feedback/ifi);
            waitframes=1;
            if num_good>2*num_bad
                try_again=0;
                vbl=Screen('Flip',window);
                for f=1:numFrames_Feedback
                    Screen('TextSize', window, 70);
                    win_msg='Success';
                    DrawFormattedText(window,win_msg,'center','center',rect_color_correct);
                    vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                    if f==1
                        S6timings.feedback(n)=GetSecs-S6timings.trigger;
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
                        S6timings.feedback(n)=GetSecs-S6timings.trigger;
                    end
                end
                clear f
            end

%---------------Fixation cross for inter-trial period----------------------
            fix_interval_min=2;
            fix_interval_max=5;
            numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;

%             fix_switch=1;
%             while fix_switch==1
%                 numSecs_Fixation=2+poissrnd(3);
%                 if numSecs_Fixation<=8
%                     fix_switch=0;
%                 end
%             end
            
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
                    S6timings.fix(n)=GetSecs-S6timings.trigger;
                end
            end    
        end
    end
end
clear n

B={'forces_test',subj_id};B=strjoin(B,'_');
save(B,'forces_gamble');
save('S6_TimingData','S6timings');

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='End of Session 6';
DrawFormattedText(window,msg_a,'center','center',white);
Screen('Flip',window);
pause(5);
sca;

clc;
disp('>> EXPERIMENT COMPLETE');
cd('N:/Effort Experiment/MRI SESSIONS');