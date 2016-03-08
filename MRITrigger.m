function MRITrigger()
%MRITRIGGER Activates the trigger initialization for an MRI session, and
%opens cedrus (the button box)
% Uses MRI global variable

global TRIGGER

TextScreen(window,'Wait for Trigger',[1 1 1],'MRI');
cedrusopen;
cedrus.resettimer();
button = 0;
while button ~= 6 %Wait for button 6 for trigger
    button = cedrus.getpress();
    TRIGGER = GetSecs;
end

end

