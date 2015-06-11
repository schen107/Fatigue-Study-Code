function key = KeyGetter(wkspc, key_opts )
%KEYGETTER This presents a module to get a key
%   Given a choice of two of possible keys to press, queries user and 
%   returns which selection. If wrong keys are pressed, reprimands and 
%   tries again

% Throw an error if bad input
if length(key_opts)~=2
    error('KeyGetter:badInput',...
        'Error, need a choice of 2 chars')
end

testStr = sprintf('Please press %c or %c',key_opts{1},key_opts{2});



while 1
    choice = TextScreen(wkspc,testStr,4);
    if isempty(choice) || length(choice)>1
        TextScreen(wkspc,'Please make a single selection',2);
    elseif ~ismember(choice(1),key_opts)
        TextScreen(wkspc,'Please pick a proper option',2);
    else
        TextScreen(wkspc,'Thank you',2);
        break
    end
end

key = choice(1);
end

