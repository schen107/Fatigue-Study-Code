time=10;

s=0;
t0=GetSecs;
while GetSecs-t0<time
%     vnow=getsample(sensor);
%--------------------------------------------------------------------------
    pause(0.01);
    [~,~,keyCode]=KbCheck; 
    if find(keyCode)==32
        s=s+2;
    else 
        s=s-2;
    end
    s=min(s,100);
    s=max(s,0);
%--------------------------------------------------------------------------
end