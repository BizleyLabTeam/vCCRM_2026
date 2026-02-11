function SpecifiedArgs=vCCRMnPretestArgs(ListenerName,varargin)

% There is probably a smarter way to deal with numeric parameters being
% passed and converted, yet still allow the checking of the variable type
% November 2010 -- strategic decision to do it dumbly!

% get arguments for vCCRMn

p = inputParser;
p.addRequired('ListenerName', @ischar);
p.addParamValue('TargetsFile', 'nounTargets.mat', @ischar);
%p.addParamValue('videoTargetsFile', 'nounTargetsVideo.mat', @ischar);
p.addParamValue('MaskerFile', 'nounMaskersPretest.mat', @ischar);
p.addParamValue('starting_SNR',20, @isnumeric);
%p.addParamValue('START_change_dB', 9, @isnumeric);
p.addParamValue('START_change_dB', 0, @isnumeric);
p.addParamValue('MIN_change_dB', 0, @isnumeric);
% p.addParamValue('MIN_change_dB', 3);
% p.addParamValue('MAX_TRIALS', 30, @isnumeric);
p.addParamValue('MAX_TRIALS', 8);% note code implements this + 1 trial 
p.addParamValue('LevittsK', 10, @isnumeric);
% p.addParamValue('CatchTrials', 0, @isnumeric);
p.addParamValue('CatchTrials', 0);
p.addParamValue('ResponseChoices', 'ColNoun',  @(x)any(strcmpi(x,{'ColNoun','ColOnly'})));
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
p.addParamValue('Video', 0, @isnumeric);
p.addParamValue('tracks', 2, @isnumeric);
p.addParamValue('TestType','MultiTalker',@ischar);

p.parse(ListenerName, varargin{:});

SpecifiedArgs=p.Results;

%     [ListenerName,TargetsFile,MaskerFile,starting_SNR,START_change_dB,MIN_change_dB,...
%         MAX_TRIALS,LevittsK,ResponseChoices,PresentInQuiet,HRTF,TargetAz,MaskerAz,CatchTrials, Ear]...
%         =SpecifyTestOrders;
