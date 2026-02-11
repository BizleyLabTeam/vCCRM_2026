%% construct the argument cell array
function ArgArray = ConstructArgArray(s, SS, MessagePrefix)
%
% go through the specified arguments, convert strings that are numbers to
% strings, and add any desired prefixes to the message
% Future version: skip over unnecessary arguments.
ArgArray=cell(1,2*(size(SS,2)-2));
for col=3:size(SS,2)
    ArgArray{2*col-5}=SS{1,col};
    if strcmp('StartMessage', SS{1,col})
        ArgArray{2*col-4}=[MessagePrefix SS{s,col}];
    else
        maybeNumber = str2double(SS{s,col});
        if isnan(maybeNumber)
            ArgArray{2*col-4}=SS{s,col};
        else
            ArgArray{2*col-4}=maybeNumber;
        end
    end
end
