function SpecifiedArgs=CCRMparseArgs(ListenerName,varargin)

% There is probably a smarter way to deal with numeric parameters being
% passed and converted, yet still allow the checking of the variable type
% November 2010 -- strategic decision to do it dumbly!

% get arguments for CCRM

p = inputParser;
p.addRequired('ListenerName', @ischar);
p.addParamValue('TargetsFile', 'Female1.txt', @ischar);
p.addParamValue('MaskerFile', 'SpchNz.wav', @ischar);
p.addParamValue('starting_SNR',20, @isnumeric);
%p.addParamValue('START_change_dB', 9, @isnumeric);
p.addParamValue('START_change_dB', 8, @isnumeric);
p.addParamValue('MIN_change_dB', 2, @isnumeric);
% p.addParamValue('MIN_change_dB', 3);
% p.addParamValue('MAX_TRIALS', 30, @isnumeric);
p.addParamValue('MAX_TRIALS', 25);
p.addParamValue('LevittsK', 1, @isnumeric);
% p.addParamValue('CatchTrials', 0, @isnumeric);
p.addParamValue('CatchTrials', 0);
p.addParamValue('ResponseChoices', 'ColDig',  @(x)any(strcmpi(x,{'ColDig','ColOnly'})));
p.addParamValue('HRTF', 'none', @ischar);
p.addParamValue('TargetAz', 0, @isnumeric);
p.addParamValue('MaskerAz', 0, @isnumeric);
p.addParamValue('PresentInQuiet', 0, @(x)x==0 || x==1);
p.addParamValue('CondCode', 'x', @ischar);
p.addParamValue('Ear', 'B', @ischar);
p.addParamValue('StartMessage', 'none', @ischar);
p.addParamValue('FixedSound', 'overall', @ischar);
p.addParamValue('OutRMS', 0.05, @isnumeric);
p.addParamValue('WarningNoise', 0, @isnumeric);
p.addParamValue('FINAL_TURNS', 4, @isnumeric);
p.addParamValue('FeedBack', 'Corrective', @ischar);
p.addParamValue('FacePixDir', 'Bears', @ischar);
p.addParamValue('MaskerLocations', 1, @isnumeric);
p.addParamValue('NoVideo', 1, @isnumeric);

p.parse(ListenerName, varargin{:});

SpecifiedArgs=p.Results;

%     [ListenerName,TargetsFile,MaskerFile,starting_SNR,START_change_dB,MIN_change_dB,...
%         MAX_TRIALS,LevittsK,ResponseChoices,PresentInQuiet,HRTF,TargetAz,MaskerAz,CatchTrials, Ear]...
%         =SpecifyTestOrders;
