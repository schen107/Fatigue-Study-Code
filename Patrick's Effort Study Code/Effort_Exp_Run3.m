% %[File Created 7/23/2014 by PSH]
% %Only compatable with Matlab 32-bit version.
% 
% %Now that certain aspects of the experimental setup are determined
% %(more/less), I'm creating this m-file with the hopes of
% %condensing, cleaning up, and commenting the code. 
% 
% %I have done this twice now, with the ordering of the consecutive m-files 
% %being: "Effort_Exp","Effort_Exp_Run", and now "Effort_Exp_Run2".
% 
% %CHANGES TO BE MADE--------------------------------------------------------
% %The predominant changes that will be made to this file (from the previous
% %version of the experiment) include:
% %---Elimination of the "within-training recall" task
% %---A new test/recall task (taking place of the "post-familiarization retention"
% %   task, wherein a horizontal "thermometer" bar will be filled by the
% %   subject, up to a set force/effort-level (unknown to the subject). The
% %   subject will then report what they percieved to be the effort level,
% %   indicating their answer with a mouse-click on a continuous line,
% %   labelled at 0 and 100. [This is intended to be a stand-in as a test of
% %   succesfully learned/retained force-number mapping.
% %--------------------------------------------------------------------------
% 
% %CHANGES TO BE MADE------------------------------------------------------
% %Need to adjust experimental setup so that outcomes of gamble decisions
% %occur (for both effort and monetary values) at the end of the overall
% %experiment.
% %------------------------------------------------------------------------

rng('shuffle');%Generate new random seed.

cd('N:/Effort Experiment');
%^Change directory if not already appropriate.

%Working Code for Effort/Grip-force Experiment-----------------------------
close all; clear all;
%^NOTE: Be careful of this when running individual sections, as an
%accidental F5 could clear the entire workspace, necessitating renewed
%acqusition of MVC as well as other parameters.

%DAQ SETUP ----------------------------------------------------------------
%It is important that the force transducer be laying with its side flat on 
%the table with as little possible force being applied. This is for the 
%purposes of calibrating a baseline voltage. To avoid saturation of the 
%force transducer/DAQ setup, gain on the BIOPAC is set to 200.

subj_id=input('Enter Subject Identifier: ','s');
S={'SubjectData',subj_id};S=strjoin(S,'_');
mkdir(S);F={'N:/Effort Experiment',S};F=strjoin(F,'/');cd(F);
save('subj_id','subj_id');

sensor=analoginput('mcc');%Default sample rate: 1000
chans=addchannel(sensor,0);
start(sensor);

pause(5);%Pausing to be sure that the sensor has time to equilibrate
baseline_sample=getsample(sensor);
baseline=baseline_sample(1);  

% try
    %PHASE 1 --- MVC ----------------------------------------------------------
    %Components: "Get Ready!"; MVC Acquisition across trials with randomized 
    %intervals between trials "Squeeze!". 
    PsychDefaultSetup(2);
    screen=max(Screen('Screens'));

    white=WhiteIndex(screen);
    black=BlackIndex(screen);

    [window,windowRect]=PsychImaging('OpenWindow',screen,black);
    HideCursor(screen);
    [xcenter,ycenter]=RectCenter(windowRect);
    [xpix,ypix]=Screen('WindowSize',screen);
    
    Screen('TextFont',window,'Ariel');
    Screen('TextSize',window,40);
    msg_a='Part 1';
    msg_b='Press Space Bar to Begin';
    DrawFormattedText(window,msg_a,'center','center',white);
    DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
    Screen('Flip',window);
    [z1,z2,z3]=KbStrokeWait;
    if find(z2)==27
        sca;
    end
    
    ifi=Screen('GetFlipInterval',window);
    
    numSecs_GetReady=1;
    numFrames_GetReady=round(numSecs_GetReady/ifi);

    waitframes=1;

    vbl=Screen('Flip',window);
    for f=1:numFrames_GetReady
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 70);
        msg1='Get Ready';
        DrawFormattedText(window,msg1,'center','center',white);
        vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
        
        %Image_0=Screen('GetImage',window);
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
        
        %Image_1=Screen('GetImage',window);
        
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
        numFrames_Fixation=round(numSecs_Fixation/ifi);
        waitframes=1;
        %Fixation cross presented for a random number of seconds (over a
        %range of 2-5 seconds)
        for f=1:numFrames_Fixation
            fixation_size=25;
            coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
            width=3;
            Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            
            %Image_Fix=Screen('GetImage',window);
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
    
    A={'forces_mvc',subj_id};A=strjoin(A,'_');
    B={'mvc_max',subj_id};B=strjoin(B,'_');
    
    save(A,'forces_mvc');
    save(B,'mvc_max','mvc_100');
    %^Saving relevant data. In the future, we'll want to clear the
    %workspace of unwanted data, to help things run smoothly.
    clear forces_mvc;    
% catch ER
%     sca;
%     disp('An Error Occurred:');
%     disp(ER)
% end

% sca;
%%
%PHASE 2 --- EFFORT FAMILIARIZATION ---------------------------------------
%This cell seems to run without any bugs. For all points and purposes, only
%small changes may need to be made here in the future.

%     screen=max(Screen('Screens'));
%     white=WhiteIndex(screen);
%     black=BlackIndex(screen);
%     [window,windowRect]=PsychImaging('OpenWindow',screen,black);
%     HideCursor(screen);
%     [xcenter,ycenter]=RectCenter(windowRect);
%     [xpix,ypix]=Screen('WindowSize',screen);
%     ifi=Screen('GetFlipInterval',window);

%     msg_ph2='Effort Familiarization - Press Any Key';
    msg_a='Part 2';msg_b='Press Space Bar to Begin';
    Screen('TextSize',window,40);
    Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,msg_a,'center','center',white);
    DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
    Screen('Flip',window);
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
    %^Can easily implement a few lines of code that make sure several high
    %values will not be tested in a row; this just hasn't been done yet (or
    %deemed to be fully necessary).
        
    num_per_target=5;
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
        for f=1:numFrames_GetReady
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
            
            %Image_2=Screen('GetImage',window);
            
            pause(1);

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

            numSecs_Train=5;
            numFrames_Train=round(numSecs_Train/ifi);
            waitframes=1;

            j=0;
            vbl=Screen('Flip',window);
            
            %Image_3=Screen('GetImage',window);
            
            for f=1:numFrames_Train
                %eff_per=0.75;%Percent of maximum effort, read in through force sensor. 
                %^Currently, this is just a set value, but will be changing based on the
                %force applied to the hand-clench transducer.

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
                
%                 if f==10
%                     Image_4=Screen('GetImage',window);
%                 end
%                 
%                 if f==numFrames_Train-10
%                     Image_5=Screen('GetImage',window);
%                 end

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

            rect_color_correct=[0 1 0];
            rect_color_incorrect=[1 0 0];

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
                end
                clear f
                
                %Image_6=Screen('GetImage',window);
                
            else
                vbl=Screen('Flip',window);
                for f=1:numFrames_Feedback
                    Screen('TextSize', window, 70);
                    loss_msg='Failure';
                    DrawFormattedText(window,loss_msg,'center','center',rect_color_incorrect);
                    Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                end
                clear f
                
                %Image_7=Screen('GetImage',window);
                
            end

            %Fixation cross for inter-trial period
            fix_interval_min=2;
            fix_interval_max=5;
            numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;
            numFrames_Fixation=round(numSecs_Fixation/ifi);
            waitframes=1;

            vbl=Screen('Flip',window);
            for f=1:numFrames_Fixation
                fixation_size=25;
                coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
                width=3;
                Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
                vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            end
            clear f
        end
        
        %---REMOVE?---
        %I'm not entirely sure as to whether or not we'll want to remove
        %the rest period from the familiarization phase, as fatigue may
        %still end up being a factor. Perhaps, rather than having a 60
        %second pause every five trials, we increase the inter-trial
        %interval from ~5 seconds to ~10/15 seconds.
        msg_rest='Rest';
        Screen('TextSize',window,70);Screen('TextFont',window,'Ariel');
        DrawFormattedText(window,msg_rest,'center','center',white);
        Screen('Flip',window);
        pause(60);%Inter-training rest/recovery period.
    end

    A={'forces_train',subj_id};A=strjoin(A,'_');
    C={'goodbad_train',subj_id};C=strjoin(C,'_');
    
    save(A,'forces_train');
    save(C,'goodbad_train');
%     sca;
    %%
    %PHASE 3 --- TEST OF FAMILIARIZATION ---------------------------------
    %Want to perform a 'test' to make sure that the subjects have familiarized
    %themselves with the force-number relationship.
    
    %This is where the biggest changes from the previous versions will be
    %occurring - the testing task is to be completely re-designed (the plan
    %is more fully explained in the comments towards the beginning of the
    %file). 

%     screen=max(Screen('Screens'));
%     white=WhiteIndex(screen);
%     black=BlackIndex(screen);
%     [window,windowRect]=PsychImaging('OpenWindow',screen,black);
%     HideCursor(screen);
%     [xcenter,ycenter]=RectCenter(windowRect);
%     [xpix,ypix]=Screen('WindowSize',screen);
%     ifi=Screen('GetFlipInterval',window);
    
%     msg_wait='Test of Retention - Press any key to begin';
    msg_a='Part 3';msg_b='Press Space Bar to Begin';
    Screen('TextSize',window,40);Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,msg_a,'center','center',white);
    DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
    Screen('Flip',window);
    [z1,z2,z3]=KbStrokeWait;
    if find(z2)==27
        sca;
    end

    numSecs_GetReady=3;
    numFrames_GetReady=round(numSecs_GetReady/ifi);
    waitframes=1;

    vbl=Screen('Flip',window);
    for f=1:numFrames_GetReady
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 70);
        DrawFormattedText(window,msg1,'center','center',white);
        vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
    end
    clear f

for dum=1:4
%---From here on out, things will be up for debate-------------------------
    test_set=[10 10 10 20 20 20 30 30 30 40 40 40 50 50 50 60 60 60 70 70 70 80 80 80];
    %^Sets of three, repeated four times.
    num_test_trials=length(test_set);
    forces_test=zeros(num_test_trials,4000,2);
    success_window=0.05;%As before;

    test_therm_height=200;test_therm_width=800;
    bg_test_therm=[0 0 test_therm_width test_therm_height];
    bg_test_therm=CenterRectOnPointd(bg_test_therm,xcenter,ycenter);
    
    test_therm_top=bg_test_therm(2);
    test_therm_bottom=bg_test_therm(4);
    test_therm_left=bg_test_therm(1);
    test_therm_right=bg_test_therm(3);
    
    bg_test_therm_color=white;

    test_ordered=zeros(length(test_set),1);
    data_test=zeros(length(test_set),3);
    
    half_length=400;
    
    for n=1:length(test_set)

        eff_aim_index=randi(length(test_set),1);
        eff_aim=test_set(eff_aim_index);
        test_set(eff_aim_index)=[];
        %^Once we've acquired our target to be aimed for, we'll have that be
        %the relative "full-bar" for the task.
        
        eff_aim_per=eff_aim/100;

        numSecs_Squeeze=5;
        numFrames_Squeeze=round(numSecs_Squeeze/ifi);
        
        j=0;
        vbl=Screen('Flip',window);
        for f=1:numFrames_Squeeze
            j=j+1;
            %Acquire Squeeze Test Data
            sample_test=getsample(sensor);
            sample_test=abs(sample_test(1)-baseline);
            forces_test(n,j,1)=sample_test;
            forces_test(n,j,2)=GetSecs;
            
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
            else
                test_therm_color=[0 1 0];
            end
            
            linecoords=[0 0 0 0;0 0 -100 100];
            linepos=xcenter+half_length-round(success_window*800);
            
            Screen('FrameRect',window,bg_test_therm_color,bg_test_therm,3);
            Screen('FillRect',window,test_therm_color,test_therm);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            
%             if f==20
%                 Image_9=Screen('GetImage',window);
%             elseif f==numFrames_Squeeze-10
%                 Image_10=Screen('GetImage',window);
%             end
            
        end
        clear f

        forces_test(n,end,1)=j;%Store number of samples
        forces_test(n,end-1,1)=eff_aim;%Store the target effort for the trial;

%-------Reporting of percieved value---------------------------------------
        %Want subjects to now report what effort-level/number they think
        %they squeezed.
        click=0;
        half_length=400;margin=0.5*(xpix-2*half_length);
        xrand=margin+round(rand*2*half_length);yrand=round(rand*ypix);
        SetMouse(xrand,yrand);
        tic;
        while ~click(1)
            [xmouse,ymouse,click]=GetMouse(window);
            y=round(ypix/2);
            if xmouse<xcenter-half_length;
                xmouse=xcenter-half_length;
            elseif xmouse>xcenter+half_length;
                xmouse=xcenter+half_length;
            end 
            
            %Setup 'Number-line' from 0 to 100...
            xLine=[-half_length half_length 0 0];yLine=[0 0 0 0];
            LineCoords=[xLine;yLine];
            
            %Setup 0 and 100 dashes...
            xDash=[0 0 0 0];
            yDash=[0 0 -20 20];
            DashCoords=[xDash;yDash];
            
            %Setup 0 and 100 labels...
            label0='0';label100='100';
            xp0=xcenter-half_length;xp100=xcenter+half_length;
            
            %Setup other labels...
            label10='10';label20='20';label30='30';label40='40';
            label50='50';label60='60';label70='70';label80='80';label90='90';
            
            xp10=margin+0.1*800;
            xp20=margin+0.2*800;
            xp30=margin+0.3*800;
            xp40=margin+0.4*800;
            xp50=margin+0.5*800;
            xp60=margin+0.6*800;
            xp70=margin+0.7*800;
            xp80=margin+0.8*800;
            xp90=margin+0.9*800;
            
            %Instructional message...
            msg_instr='Click at the level you just squeezed:';
            
            %Draw everything to screen...
            Screen('TextSize',window,20);
            Screen('TextFont',window,'Ariel');
            DrawFormattedText(window,label0,xp0-8,ycenter+25,white);
            
            xcor=-15;ycor=25;
            DrawFormattedText(window,label10,xp10+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label20,xp20+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label30,xp30+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label40,xp40+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label50,xp50+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label60,xp60+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label70,xp70+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label80,xp80+xcor,ycenter+ycor,white);
            DrawFormattedText(window,label90,xp90+xcor,ycenter+ycor,white);
            
            DrawFormattedText(window,label100,xp100-23,ycenter+25,white);
            Screen('DrawLines',window,DashCoords,2,white,[xcenter-half_length ycenter]);
            
            Screen('TextSize',window,40);
            DrawFormattedText(window,msg_instr,'center',ycenter-round(0.5*ycenter),white);
            
            Screen('DrawLines',window,DashCoords,2,white,[xp10 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp20 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp30 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp40 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp50 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp60 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp70 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp80 ycenter]);
            Screen('DrawLines',window,DashCoords,2,white,[xp90 ycenter]);
            
            Screen('DrawLines',window,DashCoords,2,white,[xcenter+half_length ycenter]);
            Screen('DrawLines',window,LineCoords,2,white,[xcenter ycenter]);
            Screen('DrawDots',window,[xmouse y],20, white,[],2);
            Screen('Flip',window);
            
            %Image_11=Screen('GetImage',window);
            
            perc_pix=xmouse;
        end
        RT_test=toc;
        %Get reaction times.
        
        norm_pix=perc_pix-margin;
        eff_report=100*norm_pix/(2*half_length);
        
        data_test(n,:)=[eff_aim eff_report RT_test];
        
%-------Fixation cross for inter-trial period------------------------------
        fix_interval_min=2;
        fix_interval_max=5;
        numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;
        numFrames_Fixation=round(numSecs_Fixation/ifi);
        waitframes=1;

        vbl=Screen('Flip',window);
        for f=1:numFrames_Fixation
            fixation_size=25;
            coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
            width=3;
            Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
        end      
    end
    clear n
    
    if dum==1
        B={'forces_test_ONE',subj_id};B=strjoin(B,'_');
        C={'test_reported_ONE',subj_id};C=strjoin(C,'_');
        save(B,'forces_test');
        save(C,'data_test');
    elseif dum==2
        B={'forces_test_TWO',subj_id};B=strjoin(B,'_');
        C={'test_reported_TWO',subj_id};C=strjoin(C,'_');
        save(B,'forces_test');
        save(C,'data_test');
    elseif dum==3
        B={'forces_test_THREE',subj_id};B=strjoin(B,'_');
        C={'test_reported_THREE',subj_id};C=strjoin(C,'_');
        save(B,'forces_test');
        save(C,'data_test');
    elseif dum==4
        B={'forces_test_FOUR',subj_id};B=strjoin(B,'_');
        C={'test_reported_FOUR',subj_id};C=strjoin(C,'_');
        save(B,'forces_test');
        save(C,'data_test');
    end
    
    %WAIT INTERVAL
    msg_rest='Rest';
    Screen('TextSize',window,70);Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,msg_rest,'center','center',white);
    Screen('Flip',window);
    pause(180);
end
    
%     sca;
    %%
    %PHASE 4 --- EFFORT GAMBLES -----------------------------------------------
%     screen=max(Screen('Screens'));
%     white=WhiteIndex(screen);
%     black=BlackIndex(screen);
%     [window,windowRect]=PsychImaging('OpenWindow',screen,black);
%     HideCursor(screen);
%     [xcenter,ycenter]=RectCenter(windowRect);
%     [xpix,ypix]=Screen('WindowSize',screen);

%     msg_ph3='Effort Gambles - Press Any Key';
    msg_a='Part 4';msg_b='Press Space Bar to Begin';
    Screen('TextSize',window,40);
    Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,msg_a,'center','center',white);
    DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
    Screen('Flip',window);
    [z1,z2,z3]=KbStrokeWait;
    if find(z2)==27
        sca;
    end

    cd('N:/Effort Experiment');
    load Gambles 
    %The .mat file 'Gambles' contains the un-modified form of the gambles
    %created for this experiment in the m-file GambleGen.m. The gambles are
    %generated by finding pairs of flip and sure values that sweep the space of
    %a ratio, M_star, which represents the ratio of the worst possible outcome,
    %to the sure value.
    subject_gambles=Gambles(:,1:2);
    gambles_reordered=zeros(size(subject_gambles));

    num_trials=length(subject_gambles);
    trial_choices=nan(1,num_trials);
    choice_times=nan(1,num_trials);

    for t=1:num_trials
        
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
        
        %Image_12=Screen('GetImage',window);

        %------------------------------------------------------------------
        %Need to make sure that if a key is miss-hit, the trial doesn't
        %abort until a choice is made or the time runs out.[9/4/2014]
        %FIX ADDED - PSH [9/4/2014]
        %------------------------------------------------------------------

        tic;
        [time,keyboard,del_sec]=KbWait([],0,GetSecs+4);
        if keyboard(77)==true
            %'M' pressed - Sure choice made.
            
            choice_times(t)=toc;
            trial_choices(t)=0;

            %choice_times(t)=del_sec;
        elseif keyboard(78)==true
            %'N' pressed - Flip choice made.
            
            choice_times(t)=toc;
            trial_choices(t)=1;

            %choice_times(t)=del_sec;
        else
            %The following code catches any mis-types - and makes sure to
            %get the overall choice time once a decision is actually made.
            while (keyboard(77)==0)&&(keyboard(78)==0)&&(toc<4)            
                whoops=toc;
                [time,keyboard,del_sec]=KbWait([],0,GetSecs+4-whoops);
                if keyboard(77)==true
                    choice_times(t)=toc;
                    trial_choices(t)=0;
                elseif keyboard(78)==true
                    choice_times(t)=toc;
                    trial_choices(t)=1;
                end
            end
        end

        fixation_size=25;
        coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
        width=3;

        Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
        Screen('Flip',window);

        ITI=2+3*rand;
        pause(ITI);
    end

    subject_data=[gambles_reordered trial_choices' choice_times'];
    %Sure Value/Gamble Value/Choice (1 for Gamble)/Time to choose
    S={'SubjectData',subj_id};S=strjoin(S,'_');
    F={'N:/Effort Experiment',S};F=strjoin(F,'/');cd(F);
    save('subject_gambles','subject_data');

    final_msg='Gambles Complete - Press any key to continue';
    Screen('TextSize',window,40);
    Screen('TextFont',window,'Ariel');
    DrawFormattedText(window,final_msg,'center','center',white);
    Screen('Flip',window);

    [z1,z2,z3]=KbStrokeWait;
    if find(z2)==27
        sca;
    end
    
    %% PHASE 5 - Effort Test (Chosen from Gambles);
    
%     screen=max(Screen('Screens'));
%     white=WhiteIndex(screen);
%     black=BlackIndex(screen);
%     [window,windowRect]=PsychImaging('OpenWindow',screen,black);
%     HideCursor(screen);
%     [xcenter,ycenter]=RectCenter(windowRect);
%     [xpix,ypix]=Screen('WindowSize',screen);
%     ifi=Screen('GetFlipInterval',window);
    
%First we need to choose which gambles decisions we will have the
%subjects perform.
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

% %% PHASE 6 - MONETARY GAMBLES [Added 9/24/2014 by PSH]
% %This portion of the experiment presents monetary gambles in the loss-only
% %domain. Our hope is to get subject data regarding risk-seeking behavior in
% %the loss domain and see if there are intra-subject correlations with the
% %results of the effort gambles.
% 
% %Much of the code is copied from part 4 (as the tasks are essentially the
% %same, so if there's a coding bug - that might be a good place to start).
% 
% %     screen=max(Screen('Screens'));
% %     white=WhiteIndex(screen);
% %     black=BlackIndex(screen);
% %     [window,windowRect]=PsychImaging('OpenWindow',screen,black);
% %     HideCursor(screen);
% %     [xcenter,ycenter]=RectCenter(windowRect);
% %     [xpix,ypix]=Screen('WindowSize',screen);
% %     ifi=Screen('GetFlipInterval',window);
% 
%     msg_a='Monetary Gambles';msg_b='Press Space Bar to Begin';
%     Screen('TextSize',window,40);
%     Screen('TextFont',window,'Ariel');
%     DrawFormattedText(window,msg_a,'center','center',white);
%     DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
%     Screen('Flip',window);
%     [z1,z2,z3]=KbStrokeWait;
%     if find(z2)==27
%         sca;
%     end
% 
%     cd('N:/Effort Experiment');
%     load Monetary_Gambles
%     load gambleGL
%     %The .mat file 'Monetary_Gambles' contains the un-modified form of the gambles
%     %created for this portion of the experiment in the m-file gambles_generate_riskseeking.m. 
%     %The first column corresponds to the flip values [losses], and the second
%     %corresponds to the sure losses.
% 
%     [r,c]=size(GS);
%     loss_only=zeros(r,c+1);loss_only(:,2:3)=GS;
%     gambleGL(:,2)=gambleGL(:,2)*-1;
%     
%     monetary_gambles=[gambleGL;loss_only];
%     m_gambles_reordered=zeros(size(monetary_gambles));
% 
%     num_trials=length(monetary_gambles);
%     trial_choices=nan(1,num_trials);
%     choice_times=nan(1,num_trials);
%     
%     penalty=0;
% 
%     for t=1:num_trials
%         
%         clear gamble_val safe_val
% 
%         [r,c]=size(monetary_gambles);
%         index_trial=randi(r,1);
%         flip_sure_trial=monetary_gambles(index_trial,:);
%         m_gambles_reordered(t,:)=flip_sure_trial;
%         val_1=flip_sure_trial(1);val_2=flip_sure_trial(2);val_3=flip_sure_trial(3);
%         monetary_gambles(index_trial,:)=[];
%         m_gambles_reordered(t,:)=flip_sure_trial;
%         
%         Screen('TextFont', window, 'Ariel');
%         Screen('TextSize', window, 70);
%         
%         msg_1=num2str(abs(val_1),'%.2f');
%         msg_2=num2str(abs(val_2),'%.2f');
%         msg_3=num2str(abs(val_3),'%.2f');
%         
%         %---
%        
%         if val_1<0
%             D1={'-$',msg_1};D1=strjoin(D1,'');msg_1=D1;
%         else
%             D1={'+$',msg_1};D1=strjoin(D1,'');msg_1=D1;
%         end
%         
%         if val_2<0
%             D2={'-$',msg_2};D2=strjoin(D2,'');msg_2=D2;
%         else
%             D2={'+$',msg_2};D2=strjoin(D2,'');msg_2=D2;
%         end
%         
%         if val_3<0
%             D3={'-$',msg_3};D3=strjoin(D3,'');msg_3=D3;
%         else
%             D3={'+$',msg_3};D3=strjoin(D3,'');msg_3=D3;
%         end
%         
%         %---
% 
%         g1x=round(0.35*xpix);g1y=ycenter+150;
%         g0x=round(0.35*xpix);g0y=ycenter-150;
%         sx=round(0.65*xpix);sy=ycenter;
% 
%         base_rect_flip=[0 0 370 500];
%         base_rect_sure=[0 0 370 200];
% 
%         rect_flip=CenterRectOnPointd(base_rect_flip,g1x,ycenter);
%         rect_sure=CenterRectOnPointd(base_rect_sure,sx,ycenter);
% 
%         Screen('FrameRect',window,white,rect_flip,5);
%         Screen('FrameRect',window,white,rect_sure,5);
% 
%         %Formatting...
%         if abs(val_1)<10
%             if val_1>=0
%                 DrawFormattedText(window,msg_1,g0x-150,g0y-0,white);
%             else
%                 DrawFormattedText(window,msg_1,g0x-130,g0y-0,white);
%             end
%         else
%             if val_1>=0
%                 DrawFormattedText(window,msg_1,g0x-175,g0y-0,white);
%             else
%                 DrawFormattedText(window,msg_1,g0x-160,g0y-0,white);
%             end
%         end
% 
%         if abs(val_2)<10
%             if val_2>=0
%                 DrawFormattedText(window,msg_2,g0x-150,sy+50,white);
%             else
%                 DrawFormattedText(window,msg_2,g0x-130,sy+50,white);
%             end
%         else
%             if val_2>=0
%                 DrawFormattedText(window,msg_2,g0x-175,sy+50,white);
%             else
%                 DrawFormattedText(window,msg_2,g0x-160,sy+50,white);
%             end
%         end
%         
%         if abs(val_3)<10
%             if val_3>=0
%                 DrawFormattedText(window,msg_3,sx-150,sy-50,white);
%             else
%                 DrawFormattedText(window,msg_3,sx-130,sy-50,white);
%             end
%         else
%             if val_3>=0
%                 DrawFormattedText(window,msg_3,sx-175,sy-50,white);
%             else
%                 DrawFormattedText(window,msg_3,sx-160,sy-50,white);
%             end
%         end
%         %End formatting...
% 
%         Screen('TextSize',window,50);
%         DrawFormattedText(window,'Flip',g0x-55,g1y+110);
%         DrawFormattedText(window,'Sure',sx-60,g1y-40);
% 
%         Screen('Flip',window);
%         
%         %Image_12=Screen('GetImage',window);
% 
%         %------------------------------------------------------------------
%         %Need to make sure that if a key is miss-hit, the trial doesn't
%         %abort until a choice is made or the time runs out.[9/4/2014]
%         %FIX ADDED - PSH [9/4/2014]
%         %------------------------------------------------------------------
% 
%         tic;
%         [time,keyboard,del_sec]=KbWait([],0,GetSecs+4);
%         if keyboard(77)==true
%             %'M' pressed - Sure choice made.
%             
%             choice_times(t)=toc;
%             trial_choices(t)=0;
% 
%             %choice_times(t)=del_sec;
%         elseif keyboard(78)==true
%             %'N' pressed - Flip choice made.
%             
%             choice_times(t)=toc;
%             trial_choices(t)=1;
% 
%             %choice_times(t)=del_sec;
%         else
%             %The following code catches any mis-types - and makes sure to
%             %get the overall choice time once a decision is actually made.
%             while (keyboard(77)==0)&&(keyboard(78)==0)&&(toc<4)            
%                 whoops=toc;
%                 [time,keyboard,del_sec]=KbWait([],0,GetSecs+4-whoops);
%                 if keyboard(77)==true
%                     choice_times(t)=toc;
%                     trial_choices(t)=0;
%                 elseif keyboard(78)==true
%                     choice_times(t)=toc;
%                     trial_choices(t)=1;
%                 end
%             end
%         end
%         if trial_choices(t)~=1&&trial_choices(t)~=0
%             penalty=penalty+1;
%         end
% 
%         fixation_size=25;
%         coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
%         width=3;
% 
%         Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
%         Screen('Flip',window);
% 
%         ITI=2+3*rand;
%         pause(ITI);
%     end  
% 
% subject_m_data=[m_gambles_reordered trial_choices' choice_times'];
% % %Gamble Value/Sure Value/Choice (1 for Gamble)/Time to choose
% S={'SubjectData',subj_id};S=strjoin(S,'_');
% F={'N:/Effort Experiment',S};F=strjoin(F,'/');cd(F);
% save('subject_m_gambles','subject_m_data');
% 
% %---Have to decide what happens with their choice--------------------------
% %First we need to choose which gambles decisions we will have the
% %subjects perform.
% num_chosen=1;
% gambles_chosen=zeros(num_chosen,4);
% lever=1;
% while lever==1
%     [r,c]=size(subject_m_data);
%     gambles_chosen_index=randi(r,1);
%     gambles_chosen(1,:)=subject_m_data(gambles_chosen_index,1:4);
%     if (gambles_chosen(1,4)/1)==gambles_chosen(1,4)
%         lever=0;
%     end
% end
% %^This loop was designed in order to make sure no NaN trials were taken
% %from the subject's decision. A NaN occured whenever a subject failed
% %to make a choice in the appropriate amount of time.
% 
% gambles_MONEY_set=zeros(num_chosen,1);
% for i=1:num_chosen
%     if gambles_chosen(i,4)==0
%         gambles_MONEY_set(i)=gambles_chosen(i,3);
%     else
%         flip=rand(1);
%         while flip~=0&&flip~=1
%             if flip>0.5
%                 flip=1;
%                 gambles_MONEY_set(i)=gambles_chosen(i,1);
%             elseif flip<0.5
%                 flip=0;
%                 gambles_MONEY_set(i)=gambles_chosen(i,2);
%             else
%                 flip=rand(1);
%             end
%         end
%     end
% end
% save('gambles_MONEY_set','gambles_MONEY_set');
% amount_owed=gambles_MONEY_set-penalty;
% save('amount_owed','amount_owed');
% %--------------------------------------------------------------------------
%% RESULTS (Chosen from Gambles);
msg_a='RESULTS';msg_b='Press Space Bar to Begin';
Screen('TextSize',window,40);Screen('TextFont',window,'Ariel');
DrawFormattedText(window,msg_a,'center','center',white);
DrawFormattedText(window,msg_b,'center',ypix/2+50,white);
Screen('Flip',window);
[z1,z2,z3]=KbStrokeWait;
if find(z2)==27
    sca;
end

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
end
clear f
%--------------------------------------------------------------------------
%---Implement the task with the determined forces--------------------------

%FORCES PREVIOUSLY DETERMINED.

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
        numSecs_Squeeze=5;
        numFrames_Squeeze=round(numSecs_Squeeze/ifi);
        test_therm_color=[0 1 0];
        vbl=Screen('Flip',window);
        for f=1:numFrames_Squeeze
            Screen('FrameRect',window,bg_test_therm_color,bg_test_therm,3);
            Screen('FillRect',window,test_therm_color,test_therm);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
        end
        numSecs_Feedback=2;
        numFrames_Feedback=round(numSecs_Feedback/ifi);
        vbl=Screen('Flip',window);
        for f=1:numFrames_Feedback
            Screen('TextSize', window, 70);
            win_msg='Success';
            DrawFormattedText(window,win_msg,'center','center',rect_color_correct);
            vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
        end
        clear f
    else
        try_again=1;
        while try_again==1
            eff_aim_per=eff_aim/100;
            numSecs_Squeeze=5;
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
                end
                clear f
            else
                vbl=Screen('Flip',window);
                for f=1:numFrames_Feedback
                    Screen('TextSize', window, 70);
                    loss_msg='Failure';
                    DrawFormattedText(window,loss_msg,'center','center',rect_color_incorrect);
                    Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
                end
                clear f
            end

%---------------Fixation cross for inter-trial period----------------------
            fix_interval_min=2;
            fix_interval_max=5;
            numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;
            numFrames_Fixation=round(numSecs_Fixation/ifi);
            waitframes=1;

            vbl=Screen('Flip',window);
            for f=1:numFrames_Fixation
                fixation_size=25;
                coords = [-fixation_size fixation_size 0 0; 0 0 -fixation_size fixation_size];
                width=3;
                Screen('DrawLines',window,coords,width,white,[xcenter ycenter]);
                vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
            end    
        end
    end
end
clear n

B={'forces_test',subj_id};B=strjoin(B,'_');
save(B,'forces_gamble');
%--------------------------------------------------------------------------

% owed_msg={'$',num2str(abs(amount_owed),'%.2f')};owed_msg=strjoin(owed_msg,'');
% 
% if amount_owed<0
%     final_msg='Gambles Complete - You owe:';
% else
%     final_msg='Gambles Complete - You win:';
% end
% Screen('TextSize',window,40);
% Screen('TextFont',window,'Ariel');
% DrawFormattedText(window,final_msg,'center',ypix/2-60,white);
% DrawFormattedText(window,owed_msg,'center',ypix/2+20,white);
% Screen('Flip',window);
% 
% %Image_13=Screen('GetImage',window);
% 
% [z1,z2,z3]=KbStrokeWait;
% if find(z2)==27
%     sca;
% end
    
% Final Closing of Psychtoolbox Window

msg_end='Experiment Complete - Thank you!';
Screen('TextSize',window,40);Screen('TextFont',window,'Ariel');
DrawFormattedText(window,msg_end,'center','center',white);
Screen('Flip',window);
KbStrokeWait;
sca;

clc;
   