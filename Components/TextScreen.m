function [key,volt,timing,MRITiming] = TextScreen(window,message,color,varargin)
% color is in RGB coords (ex. white: [1 1 1], green: [0 1 0], red: [1 0 0])
% varargin is [time], ['key'], [sensor,baseline] or [time,sensor,baseline]
% outputs are the key that's pressed (string), voltage, and timing array

global DAQ DAR TRIGGER

[~,ypix] = Screen('WindowSize',window);

Screen('TextFont',window,'Ariel');
Screen('TextSize',window,round(ypix*0.75/16.875));

if nargin == 4
    volt = NaN;
    timing = NaN;
    if strcmp(varargin{1},'key')
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
        MRITiming = GetSecs-TRIGGER;
        [~,keyCode] = KbStrokeWait(-1);
        key = KbName(keyCode);
    
    elseif isnumeric(varargin{1})
        key = NaN;
        time = varargin{1};
        t0=GetSecs;
        i = 0;
        while GetSecs-t0 <= time
            i = i+1;
            DrawFormattedText(window,message,'center','center',color);
            Screen('Flip',window);
            if i == 1
                MRITiming = GetSecs-TRIGGER;
            end
        end

    
    % for button box
    elseif strcmp(varargin{1},'MRI')
        key = NaN;
        MRITiming = NaN;
        DrawFormattedText(window,message,'center','center',color);
        Screen('Flip',window);
    end
    
    
elseif nargin == 6
    key = NaN;
    time = varargin{1};
    sensor = varargin{2};
    baseline = varargin{3};
    
    if DAQ == 0 %Old Sensor
        freq = Screen('NominalFrameRate', window);
        numSample = freq*time;
        volt = NaN(1,numSample);
        timing = NaN(1,numSample);
        t0=GetSecs;
        i = 1;
        while GetSecs-t0 <= time
            timing(i) = GetSecs-t0;
            volt(i) = getsample(sensor)-baseline;
            DrawFormattedText(window,message,'center','center',color);
            Screen('Flip',window);
            if i == 1
                MRITiming = GetSecs-TRIGGER;
            end
            i = i+1;
        end
        
    elseif DAQ == 1 %New Sensor
        freq = 2000;
        startCollect(time,freq);
        t0=GetSecs;
        i = 1;
        while GetSecs-t0 <= time
            DrawFormattedText(window,message,'center','center',color);
            Screen('Flip',window);
            if i == 1
                MRITiming = GetSecs-TRIGGER;
            end
            i = i+1;
        end
        volt = DAR(2,:)-baseline;
        timing = DAR(1,:);
    end
    

end

end