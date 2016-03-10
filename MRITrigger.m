function MRITrigger(window,cedrus)
% Activates the trigger initialization for an MRI session; cedrus already
% open
% Uses TRIGGER global variable

global TRIGGER

TextScreen(window,'Wait for Trigger',[1 1 1],'MRI');
cedrus.resettimer();
button = 0;
while button ~= 6 %Wait for button 6 for trigger
    button = cedrus.getpress();
    if button==6
        TRIGGER=GetSecs;
    end
end


end

