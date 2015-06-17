%EFFORT EXPERIMENT: Recall Task (PART 1)
load subj_directory;
cd(subj_directory);
%%
%PHASE 3 --- TEST OF FAMILIARIZATION --------------------------------------
%Want to perform a 'test' to make sure that the subjects have familiarized
%themselves with the force-number relationship.

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
msg_a='Session 2';msg_b='Please Wait for Instructions';
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
%--------------------------------------------------------------------------
cd('N:\Effort Experiment\MRI SESSIONS');
cedrusopen;
trigger=0;
cedrus.resettimer();
while trigger==0
    [button]=cedrus.getpress();
%     [button time press]=cedrus.getpress();
    if button==6
        S2timings.trigger=GetSecs;
        trigger=1;
    end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% KbStrokeWait;
% S2timings.trigger=GetSecs;
%^Currently our stand-in for the actual trigger. This will need to be
%changed so that the code waits for the trigger (rather than the button
%press).
%--------------------------------------------------------------------------

%---RECALL TASK PART 1-----------------------------------------------------
%The recall task is effectively performed twice (one in this session, and a
%second time in Session 3). Originally we had it setup so that there was a
%three minute or so rest period between recall blocks, but with the 10
%minute time constraint on the sessions, we now split it into two separate
%sessions.

test_set=[10 10 10 20 20 20 30 30 30 40 40 40 ...
    50 50 50 60 60 60 70 70 70 80 80 80];
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
data_test=nan(length(test_set),3);

half_length=400;

for n=1:length(test_set)
    numSecs_GetReady=1;
    numFrames_GetReady=round(numSecs_GetReady/ifi);
    waitframes=1;

    vbl=Screen('Flip',window);
    for f=1:numFrames_GetReady
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 70);
        DrawFormattedText(window,'Get Ready','center','center',white);
        vbl=Screen('Flip',window,vbl+(waitframes-0.5)*ifi);
        if f==1
            S2timings.getready(n)=GetSecs-S2timings.trigger;
        end
    end
    clear f

    eff_aim_index=randi(length(test_set),1);
    eff_aim=test_set(eff_aim_index);
    test_set(eff_aim_index)=[];
    %^Once we've acquired our target to be aimed for, we'll have that be
    %the relative "full-bar" for the task.

    eff_aim_per=eff_aim/100;

    numSecs_Squeeze=4;
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
        if f==1
            S2timings.squeeze(n)=GetSecs-S2timings.trigger;
        end
    end
    clear f

    forces_test(n,end,1)=j;%Store number of samples
    forces_test(n,end-1,1)=eff_aim;%Store the target effort for the trial;

%-------Reporting of percieved value---------------------------------------
    %Want subjects to now report what effort-level/number they think
    %they squeezed.

    half_length=400;margin=0.5*(xpix-2*half_length);
    xrand=margin+round(rand*2*half_length);yrand=round(rand*ypix);
    SetMouse(xrand,yrand);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
    dumdum=1;
    cedrus.releases=1;
    
    t_start=GetSecs;
    t_elapse=0;

    xpos=xrand;left=0;right=0;Nleft=0;Nright=0;dpix=1;
    lev=0;

    direct=0;jpress=0;jrelease=0;
    cedrus.resettimer();
    while lev==0&&(t_elapse<=4)

        t_elapse=GetSecs-t_start;
        a=0.025;C=15;

        [button,time,press]=cedrus.getpress();
        if press==true
            jpress=1;jrelease=0;
            %IF A BUTTON WAS PRESSED DOWN:
            if button==1
                direct=-1;
            elseif button==2
                direct=1;
            end
            
        elseif press==false&&(button~=0)
            jrelease=1;jpress=0;
            %IF A BUTTON WAS RELEASED (and not in hold on/off):
            Nright=0;
            Nleft=0;
        else
            %IF A BUTTON WAS NEITHER PRESSED OR RELEASED:
            if direct==-1&&jpress==1
                Nleft=Nleft+1;
                dpix=floor(C-C*exp(-a*Nleft));
                xpos=xpos-dpix;
            elseif direct==1&&jpress==1
                Nright=Nright+1;
                dpix=floor(C-C*exp(-a*Nright));
                xpos=xpos+dpix;
            end
        end
        
        if xpos<xcenter-half_length;
            xpos=xcenter-half_length;
        elseif xpos>xcenter+half_length;
            xpos=xcenter+half_length;
        end

        y=round(ypix/2);
        
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
        msg_instr='Select the level you just squeezed:';

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
        Screen('DrawDots',window,[xpos y],20, white,[],2);
        Screen('Flip',window);
        
        if dumdum==1
           S2timings.report(n)=GetSecs-S2timings.trigger;
           dumdum=0; 
        end

        perc_pix=xpos;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
        if button==3
            lev=1;
            %Use of button three to select or "lock-in" reported value.
            %Doing so pulls us out of the loop.
        end
        %^CEDRUS
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
    end
    RT_test=(GetSecs-S2timings.trigger)-S2timings.report(n);
    %Get reaction times.

    norm_pix=perc_pix-margin;
    eff_report=100*norm_pix/(2*half_length);

    data_test(n,1)=eff_aim;
    if RT_test<=4
        data_test(n,2)=eff_report;
        data_test(n,3)=RT_test;
    else
        data_test(n,2)=eff_report;
        %Catch 'reported' values even in selection was not made in time.
    end

%-------Fixation cross for inter-trial period------------------------------
%     fix_interval_min=1;
%     fix_interval_max=10;
%     numSecs_Fixation=fix_interval_min+(fix_interval_max-fix_interval_min)*rand;

    fix_switch=1;
    while fix_switch==1
        numSecs_Fixation=2+poissrnd(3);
        if numSecs_Fixation<=8
            fix_switch=0;
        end
    end
    
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
            S2timings.fix(n)=GetSecs-S2timings.trigger;
        end
    end      
end
clear n

cedrus.close();%Close CEDRUS

cd(subj_directory);

B={'forces_test_ONE',subj_id};B=strjoin(B,'_');
C={'test_reported_ONE',subj_id};C=strjoin(C,'_');
save(B,'forces_test');
save(C,'data_test');

save('S2_TimingData','S2timings');
%^Save timing data

%WAIT INTERVAL -> [Removed because we're splitting the two parts of the
%recall task into two different MRI sessions]

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,40);
msg_a='End of Session 2';
DrawFormattedText(window,msg_a,'center','center',white);
Screen('Flip',window);
pause(5);
sca;

clc;
disp('>> SESSION 2 COMPLETE');
disp('>> Ready to run: Session3_Effort_MRI.m');

cd('N:/Effort Experiment/MRI SESSIONS');