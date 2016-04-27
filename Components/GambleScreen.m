function [choice,ReactTime,timing] = GambleScreen(window,cedrus,flip,sure,time)
% inputs: cedrus - dummy if not running on MRI
% flip - gamble value (0-100)
% sure - safe value(0-100)
% time - time limit for choosing
% outputs: choice - flip (1) vs sure (0)
% ReactTime - time it took to make the choice (s)

global TRIGGER MRI

white = WhiteIndex(window);
[xpix,ypix] = Screen('WindowSize',window);
ycenter = ypix/2;

Screen('TextFont', window, 'Ariel');
if MRI == 1
    Screen('TextSize', window, 50);
else
    Screen('TextSize', window, 70);
end

FlipString1 = num2str(flip,'%.2f');
FlipString2 = num2str(0);
SureString = num2str(sure,'%.2f');

F1_x = round(0.35*xpix); F1_y = ycenter-round(ypix/9);
F2_x = round(0.35*xpix); F2_y = ycenter+round(ypix/9);
S_x = round(0.65*xpix); S_y = ycenter;

FlipRect = [0 0 round(300/1440*xpix) round(500/900*ypix)];
SureRect = [0 0 round(300/1440*xpix) round(200/900*ypix)];

FlipRect = CenterRectOnPointd(FlipRect,F1_x,ycenter);
SureRect = CenterRectOnPointd(SureRect,S_x,ycenter);

Screen('FrameRect',window,white,FlipRect,5);
Screen('FrameRect',window,white,SureRect,5);

%Formatting...
if flip < 10
    DrawFormattedText(window,FlipString1,F1_x-round(90/1440*xpix), ...
        F1_y-round(90/900*ypix),white);
else
    DrawFormattedText(window,FlipString1,F1_x-round(115/1440*xpix), ...
        F1_y-round(90/900*ypix),white);
end
DrawFormattedText(window,FlipString2,F2_x-round(25/1440*xpix), ...
    F2_y-round(20/900*ypix),white);

if sure < 10
    DrawFormattedText(window,SureString,S_x-round(85/1440*xpix), ...
        S_y-round(50/900*ypix),white);
else
    DrawFormattedText(window,SureString,S_x-round(115/1440*xpix), ...
        S_y-round(50/900*ypix),white);
end
%End formatting...

Screen('TextSize', window, round(ypix*0.75/13.5));
DrawFormattedText(window,'Flip',0.31*xpix,0.78*ypix);
DrawFormattedText(window,'Sure',0.6*xpix,0.61*ypix);

Screen('Flip',window);
timing = GetSecs-TRIGGER;

t0=GetSecs;
choice = nan;
ReactTime = nan;

if MRI == 0
    KbName('UnifyKeyNames');
    RestrictKeysForKbCheck([77,78]);
    [~,keyCode] = KbStrokeWait(-1,t0+time);
    if KbName(keyCode) == 'n' %flip
        choice = 1;
        ReactTime = GetSecs-t0;
    elseif KbName(keyCode) == 'm' %sure
        choice = 0;
        ReactTime = GetSecs-t0;
    end
    RestrictKeysForKbCheck([]);
elseif MRI == 1
    cedrus.resettimer();
    while GetSecs-t0 < time
        button = cedrus.getpress();
        if button == 1 %flip
            choice = 1;
            ReactTime = GetSecs-t0;
            break
        elseif button == 2 %sure
            choice = 0;
            ReactTime = GetSecs-t0;
            break
        end
    end
end

end
