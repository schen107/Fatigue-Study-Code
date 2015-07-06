function [outcome,volt,timing] = ThermScreen(window,baseline,MVC,goal,successwindow,orientation,time)
% successwindow is between 0-1
% time is in sec
% orientation is either 'horizontal' or 'vertical'

global DAR IND

% cd('C:\Users\StevenChen\Documents\MATLAB\Fatigue Code\DAQ functions'); %Personal Laptop
cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\DAQ functions'); %Steven's Account

white = WhiteIndex(window); black = BlackIndex(window);
[xpix,ypix] = Screen('WindowSize',window);
xcenter = xpix/2; ycenter = ypix/2;

if strcmp(orientation,'vertical')
    % Draw Thermometer Frame
    ThermHeight = ypix*0.7;
    ThermWidth = xpix*0.15;
    ThermRect = [0 0 ThermWidth ThermHeight];
    ThermRect = CenterRectOnPointd(ThermRect,xcenter,ycenter);
    
    % Thermometer Bar dimensions except top (in while loop below)
    ThermBarBottom = ThermRect(4); ThermBarRight = ThermRect(3);
    ThermBarLeft = ThermRect(1); 
    
    % Draw Success Rectangle
    SuccessWindow = successwindow;
    SuccessHeight = ThermHeight*(SuccessWindow*2);
    SuccessWidth = xpix*0.04;
    SuccessRect = [0 0 SuccessWidth SuccessHeight];
    SuccessXCenter = ThermBarRight+xpix*0.025;
    SuccessYCenter = (ThermHeight*(1-goal))+ThermRect(2);
    SuccessRect = CenterRectOnPointd(SuccessRect,SuccessXCenter,SuccessYCenter);

    LineCoord = [round(SuccessRect(1)) round(SuccessRect(3)); ... 
        round(SuccessYCenter) round(SuccessYCenter)];
    
    PercentMVC = num2str(goal*100);
    PercentMVCX = SuccessRect(3)+10;
    PercentMVCY = SuccessYCenter-16;
    fontsize = 20;
    
%     s = 0;
    i = 0;
    suc = 0;
    freq = 2000;
    startCollect(time,freq);
    t0 = GetSecs;
    while GetSecs-t0 <= time
        i = i+1;
        if IND ~= 0
            data = getData();
            voltNow = data(2)-baseline;
            if voltNow < 0
                voltNow = 0;
            elseif voltNow > MVC
                voltNow = MVC;
            end
            ForcePercent = voltNow/MVC;
    %         Dummy Code
    %         pause(0.01);
    %         [~,~,keyCode]=KbCheck;
    %         if find(keyCode)==32
    %             s=s+1;
    %         else
    %             s=s-1;
    %         end
    %         s=min(s,100);
    %         s=max(s,0);
    %         volt(i) = s;
            
            ThermBarTop = (ThermHeight*(1-ForcePercent))+ThermRect(2);
            ThermBar = [ThermBarLeft ThermBarTop ThermBarRight ThermBarBottom];
            
            Screen('FrameRect',window,white,ThermRect);
            Screen('TextSize', window, fontsize);
            Screen('TextFont',window,'Arial');
            DrawFormattedText(window,PercentMVC,PercentMVCX,PercentMVCY,white);
            Screen('FillRect',window,white,ThermBar);
            if abs(ForcePercent-goal) < SuccessWindow
                Screen('FillRect',window,[0 1 0],SuccessRect);
                suc = suc+1;
            else
                Screen('FillRect',window,[1 0 0],SuccessRect);
            end
            Screen('DrawLines',window,LineCoord,3,white);

        end
        Screen('Flip',window);
    end
    
    volt = DAR(2,:)-baseline;
    timing = DAR(1,:);

    if suc/i > 2/3
        outcome = 1;
    else
        outcome = 0;
    end
    
elseif strcmp(orientation,'horizontal')
    % Draw Thermometer Frame
    ThermHeight = ypix*0.2;
    ThermWidth = xpix*0.7;
    ThermRect = [0 0 ThermWidth ThermHeight];
    ThermRect = CenterRectOnPointd(ThermRect,xcenter,ycenter);
    
    % Thermometer Bar dimensions except right (in while loop below)
    ThermBarBottom = ThermRect(4); ThermBarTop = ThermRect(2);
    ThermBarLeft = ThermRect(1);

%     s = 0;
    i = 0;
    suc = 0;
    freq = 2000;
    startCollect(time,freq);
    t0 = GetSecs;
    while GetSecs-t0 <= time
        i = i+1;
        if IND ~= 0
            data = getData();
            voltNow = data(2)-baseline;
            if voltNow < 0
                voltNow = 0;
            elseif voltNow > MVC
                voltNow = MVC;
            end
            ForcePercent = voltNow/MVC;
%         
%         Dummy Code
%         pause(0.01);
%         [~,~,keyCode]=KbCheck; 
%         if find(keyCode)==32
%             s=s+1;
%         else 
%             s=s-1;
%         end
%         s=min(s,100);
%         s=max(s,0);
%         volt(i) = s;
            ThermBarRight = (ThermWidth*(ForcePercent)/goal)+ThermBarLeft;
            ThermBarRight = min(ThermRect(3),ThermBarRight);
            ThermBar = [ThermBarLeft ThermBarTop ThermBarRight ThermBarBottom];

            Screen('FrameRect',window,white,ThermRect);

            SuccessWindow = 0.05;
            if abs(ForcePercent-goal) < SuccessWindow
                Screen('FillRect',window,[0 1 0],ThermBar);
                suc = suc+1;
            else
                Screen('FillRect',window,[1 0 0],ThermBar);
            end
        end
        Screen('Flip',window);
    end
    
    volt = DAR(2,:)-baseline;
    timing = DAR(1,:);
    
    if suc/i > 2/3
        outcome = 1;
    else
        outcome = 0;
    end
end

cd('C:\Users\Steven\Documents\MATLAB\FatigueCode\Components'); %Steven's Account

end
