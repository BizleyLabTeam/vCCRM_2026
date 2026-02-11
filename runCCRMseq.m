function runCCRMseq(ListenerName, OrderFile)
%
% in the current implementation, nBlocks must be first in row!
% All the other arguments can come in any order, as defined by the first row
%
% runCCRMseq('test', 'LucySeqList.csv')

%% read in the sequence and do some checks
SS=robustcsvread(OrderFile);
nBlockIndex=strmatch('nBlocks',strvcat(SS{1,:}));
if nBlockIndex>1
    error('nBlocks, the number of blocks to run must be in the first column');
end
nPracticeTrialsIndex=strmatch('nPracticeTrials',strvcat(SS{1,:}));
if nPracticeTrialsIndex~=2
    error('nPracticeTrials, the number of practice trials to run must be in the second column');
end

if strcmp(ListenerName,'XX')
    [I, DOB, sex] = ListenerID();
    ListenerName = [I, '_', DOB,'_', sex];
end

for s=2:size(SS,1)
    % do practice trials, if required
    nPracticeTrials=str2double(SS(s,nPracticeTrialsIndex));
    if nPracticeTrials>0
        % add a little extra on to the message
        nStartMessageIndex=strmatch('StartMessage ',char(SS{1,:}));
        if ~isempty(nStartMessageIndex)
            MessagePrefix=['This is for practice. '];
        else
            MessagePrefix=[];
        end
        ArgArray = [[ListenerName '_Prac'] ConstructArgArray(s, SS, MessagePrefix)];
        % set number of trials
        ArgArray{find(strcmp('MAX_TRIALS', ArgArray))+1}=str2double(SS{s,2});
        CCRM(ArgArray{1:length(ArgArray)})
    end
    for nB=1:str2double(SS{s,nBlockIndex});
        % add a little extra on to the message
        nStartMessageIndex=strmatch('StartMessage ',char(SS{1,:}));
        if ~isempty(nStartMessageIndex)
            MessagePrefix=['This is for real. '];
        else
            MessagePrefix=[];
        end
        ArgArray = [ListenerName ConstructArgArray(s, SS, MessagePrefix)];
        CCRM(ArgArray{1:length(ArgArray)})
    end
end

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






