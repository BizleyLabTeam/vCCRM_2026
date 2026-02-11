function vCCRMn(varargin)

%
% Inputs:
% for demo or pretest give only 'demo' or 'pretest' as a single input
% argument. Currently this presents 8 trials (2 of each visual condition)
% in the demo, with SRNs of 20 or 10, and 50% target/masker coherent. The
% role fo the pretest is to check the subject understands the procedure and
% presents 8 trials (6 with no video) and provides a score at the end of
% it. input : vCCRMn('pretest')
%
% otherwise input a subject number and other parameter, value pairs
% "Video" [options: 0 2 3 where 0 is still image 2 is frozen
% during target word presentation 3 is synthetic and 1 or default is full
% movie]
% "Tracks" [1 presents only a single target coherent track, default is two
% simultaneous tracks, one target and one masker coherent videos]
% "TestType" [options: 'MultiTalker', 'babble', 'SSN']
% "LevittsK" (determines the staircase rule, default 1U1D)
% many other options are defined in vCCRMnparseArgs
%
% Code is distributed under CC BY 4
% Please cite Alampounti, Rosen, Cooper and Bizley, Trends in Hearing 2026
% in your publication if you use it.
% This code is adapted from Stuart Rosen's v16.0 CCRM code; many of the options
% available have been removed to streamline the code. Anything elegant in this code
% likely originated from Stuart's.
% vCCRMn uses colour-noun with optional video elements.
% (retro) added in 2025; the ability to have synthetic visual stimuli, the ability
% to have speech shaped noise (or other arbritrary noise) instead of
% competing maskers. J Bizley 08.01.25
% V 3.0 Jan 2026 - changed the way the response app behaves to streamline the task
% and prevent hanging. 
%
% This task works best on a windows machine if you remove the taskbar 'always visible' option 
% from windows.

%% initialisation and fixed parameter values
DEBUG=0;
VERSION=3.0;% JKB

% set some sanity parameters
InitialDescentMinimum = -12;
MAX_SNR_dB = 20; % maximum permitted SNR (note that the overall level is kept constant)
INITIAL_TURNS = 3;
FINAL_TURNS = 6;
IgnoreTrials = 3; % number of initial trials to ignore errors on
OutputDir = 'results';
levitts_index = 1; % default staircase parameter
%CatchTrialSNR=100; % SNR to present on catch trials
% CatchTrials=0;
MaxBumps=3; % times you can hit the MAX_SNR_dB before aborting
% MultipleMaskerType=[];
% MultipleMaskerFiles=[];

% initialise the random number generator on the basis of the time
rand('twister', sum(100*clock));
%tracks = 2;

%% Settings for level to prevent subjects from altering it on the fly
if ispc
    VolumeSettingsFile='VolumeSettings.txt';
    [~, OutRMS]=SetLevels(VolumeSettingsFile);
else ismac
    !osascript set_volume_applescript.scpt
    % VolumeSettingsFile='VolumeSettingsMac.txt';
end

%% get control parameters one way or t'other
if nargin==1 & strcmpi(varargin{1},'pretest')
    SpecifiedArgs=vCCRMnPretestArgs(varargin{1});
    type = 'pretest';
elseif nargin==1 & strcmpi(varargin{1},'demo')
    SpecifiedArgs=vCCRMnDemoArgs(varargin{1});
    type = 'demo';
else % pick up defaults and specified values from args
    if ~rem(nargin,2)
        error('You should not have an even number of input arguments, and the first should be the listener code');
    end
    %SpecifiedArgs=vCCRMnparseArgs(varargin);
    SpecifiedArgs=vCCRMnparseArgs(varargin{1},varargin{2:end});
    type = 'test';
end



if SpecifiedArgs.Video == 0
    SpecifiedArgs.CondCode = 'still';
elseif SpecifiedArgs.Video == 2
    SpecifiedArgs.CondCode = 'movieNoTar';
elseif SpecifiedArgs.Video == 3
    SpecifiedArgs.CondCode = 'disk';
else
    SpecifiedArgs.CondCode = 'movie';
end

if SpecifiedArgs.tracks == 2 & [contains(SpecifiedArgs.TestType, 'babble') | contains(SpecifiedArgs.TestType, 'SSN')]
    display('You requested two tracks but this option only works for multitalker maskers. Changing tracks argument to 1.')
    SpecifiedArgs.tracks = 1;
end
if SpecifiedArgs.tracks == 1 % tracks = 1; run only target coherent,
    %  otherwise will run two tracks with both target coherent and masker coherent
    SpecifiedArgs.CondCode = [SpecifiedArgs.CondCode '-TC'];
else
    SpecifiedArgs.CondCode = [SpecifiedArgs.CondCode '-TCI'];
end
% now set all parameters obtained
fVars=fieldnames(SpecifiedArgs);
for f=1:length(fVars)
    if ischar(eval(['SpecifiedArgs.' char(fVars{f})]))
        eval([char(fVars{f}) '=' '''' eval(['SpecifiedArgs.' char(fVars{f})]) ''';']);
    else % it's a number
        eval([char(fVars{f}) '='  num2str(eval(['SpecifiedArgs.' char(fVars{f})])) ';'])
    end
end
if strcmp(TestType,'babble')
    % code for SST or babble here
    MaskerFile = 'Babble248k.wav'
elseif strcmp(TestType,'SSN')
    MaskerFile = 'SpchNz48k.wav'
else % default to multiple talkers
    nMaskerTalkers=2; % two competing non-target talkers
    MultipleMaskerType = 'VariableMasker'; % maskers can vary trial to trial
end
%% do a number of checks and further initialisations
if (TargetAz>0 || MaskerAz>0) && strcmp(HRTF,'none')
    warning('This code does not yet allow spatialisation.')
    error('You seemed to have specified spatial locations without an HRTF');
end
if ((strcmp(Ear,'OL') || strcmp(Ear,'OR') ) && ~strcmp(HRTF,'none'))
    warning('This code does not yet allow spatialisation.')
    error('You specified opposite ear presentation with an HRTF');
end
if strcmp(ResponseChoices,'ColNoun')
    NounResponse=1;
else
    NounResponse=0; % 'ColOnly'
end
LEVITTS_CONSTANT = [1 LevittsK];
SNR_dB = starting_SNR; % current level

% extend maximum number of trials to account for catch trials
% and throw error if catch trials are tried with a fixed masker
if CatchTrials>1
    if strcmp(FixedSound,'masker')
        error('Catch trials cannot be used with a fixed masker level');
    end
    MAX_TRIALS = MAX_TRIALS + floor(MAX_TRIALS/(CatchTrials+1));
end

% for fixed level testing %% legacy stuart code, no sure if this works!
if START_change_dB==0 || MIN_change_dB == 0
    MIN_change_dB = 0;
    START_change_dB=0;
    INITIAL_TURNS = 99;
    FINAL_TURNS = 99;
    LEVITTS_CONSTANT = [1 1];
    MaxBumps=99;
end

%% read in and permute the order of the targets
if Video==2 || strcmp(type,'pretest') || strcmp(type,'demo')
    load('maskerTimes.mat'); % these are the start and end times (in samples)
    % of the key words so that the video can be 'frozen' to exclude lip
    % reading of the colour and noun
    load('targetTimes.mat');
end
%set up dummy variables for when NoVideo ~=2 (where colour/objet are
%omitted from the video)
%remTimesTarget{1}=nan;
%remTimesMasker{1}=nan;

%remTimesMasker{2}=nan;
if ~exist(TargetsFile, 'file') % targetsFile is defined in vCCRMnparseArgs this is the
    % full list of all talker/dog combinations (total = 358)
    error('Targets file does not exist: %s', TargetsFile)
end
load(TargetsFile);
[T,index] = CheckAllVideosAvailable(T,Video);
if Video==2 || strcmp(type,'pretest')|| strcmp(type,'demo') % all these
    % conditions have 'frozen' trials
    targetTimes = targetTimes(index);
end
for ii = 1:length(T)
    T{ii} = ['sentences/' T{ii}];
end
[targets,index] = CheckAllWavsAvailable(T);
if Video==2 || strcmp(type,'pretest') || strcmp(type,'demo')
    targetTimes = targetTimes(index);
    ind2remove  = [];
    for jj =  1: length(targetTimes)
        if isempty(targetTimes{jj})
            ind2remove=[ind2remove;jj];
        end
    end
    targetTimes(ind2remove) = []; % remove missing entries
    targets(ind2remove) = []; % remove missing entries - hack,
end
TargetOrder = randperm(length(targets));
% check that all wav files exist

%% load masker files

if strcmp(TestType,'MultiTalker');
    load(MaskerFile);

    [M,index] = CheckAllVideosAvailable(M,Video);
    maskers = M;
    [maskers,index] = CheckAllWavsAvailable(maskers);
    % permute the order of the maskers/distractors
    MaskersOrder = randperm(length(maskers));
    iMasker = 0;
else % if using babble or speech shaped noise resample to match speech audio presentation rate
end
%% generate the sections of maskers to be used so as to minimise re-use
if strcmp(TestType,'babble') || strcmp(TestType,'SSN')  || strcmp(MultipleMaskerType,'FixedMasker')
    % multiple maskers (but fixed) left for backwards compatability but not properly coded at the moment
    % this is for the eventuality where competing talkers are just reading
    % text

    % otherwise this is to choose sections of the masker waveform (babble
    % or SSN)

    % all stimuli are processed to be 3 s (and aligned from their ends) so any target will do
    % for sample estimation:
    [x,SampFreq] = audioread(targets{1});
    % check if stereo
    dim=size(x);
    % get number of samples
    n=dim(1);
    MaxDurTargetSamples = length(x);
    %
    % allow for extra length of warning noise -- October 2010
    MaxDurTargetSamples =  MaxDurTargetSamples + round(SampFreq*WarningNoise/1000);
    % generate a set of random sections of the masker wave for possible use later
    [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples);
    PermuteMaskerWave = 1;
    nWavSection =0;
    if strcmp(TestType,'MultiTalker')
        [nSections2, wavSections2]=GenerateWavSections(char(MultipleMaskerFiles(2)), MaxDurTargetSamples);
    end
end

%% read in all the necessary faces for feedback
if ~strcmp(FeedBack, 'None')
    FacesDir = fullfile('Faces',FacePixDir,'');
    SmileyFace = imread(fullfile(FacesDir,'smile24.bmp'),'bmp');
    WinkingFace = imread(fullfile(FacesDir,'wink24.bmp'),'bmp');
    FrownyFace = imread(fullfile(FacesDir,'frown24.bmp'),'bmp');
    %ClosedFace = imread(fullfile(FacesDir,'closed24.bmp'),'bmp');
    %OpenFace = imread(fullfile(FacesDir,'open24.bmp'),'bmp');
    %BlankFace = imread(fullfile(FacesDir,'blank24.bmp'),'bmp');
end

%%	setup a few starting values for adaptive track
previous_change = -1; % assume track is initially moving from easy to hard
num_turns = 0;
num_final_trials = 0;
change = START_change_dB;
inc = (START_change_dB-MIN_change_dB)/INITIAL_TURNS;
limit = 0;
response_count = 0;
trial = 0;
nWavSection=0;
isCatchTrial = 0;% will have to code this in later if we want them

%% uncomment this if you want to manually check the timing of a pair of audio and video files
%TestType = 'TimingCheck' %use this to debug / check timing - it will omit competing talkers
%TestFileName = 'Sentences/spkDS/spkDS_cat_black_bed-s.wav';
%TestVideo = 'testfile.mp4';

if ~exist(OutputDir, 'dir')
    status = mkdir(OutputDir);
    if status==0
        error('Cannot create new output directory for results: %s.\n', OutputDir);
        return;
    end
end

%% determine a code for the feedback type to put in the file name
if strcmp(FeedBack,'None')
    FeedBackCode = '0';
elseif strcmp(FeedBack,'Neutral')
    FeedBackCode = 'N';
elseif strcmp(FeedBack,'Corrective')
    FeedBackCode = 'C';
elseif strcmp(FeedBack,'AlwaysGood')
    FeedBackCode = 'G';
else
    error('Illegal type of Feedback specified');
end

%% get start time and date
StartTime=fix(clock);
StartTimeString=sprintf('%02d:%02d:%02d',...
    StartTime(4),StartTime(5),StartTime(6));
StartDate=date;

%% construct the output data file name
% get the root name of the target and noise files
[~, TargetsFileName, ~] = fileparts(TargetsFile);
[~, MaskerFileName, ~] = fileparts(MaskerFile);
% put masker, date and time on filenames so as to ensure a single file per test
FileNamingStartTime = sprintf('%02d-%02d-%02d',StartTime(4),StartTime(5),StartTime(6));
% FileListenerName=[ListenerName '_' CondCode '_' MaskerFileName '_' StartDate '_' FileNamingStartTime];
% FileListenerName=[ListenerName '_' FeedBackCode '_' MaskerFileName '_' StartDate '_' FileNamingStartTime];
FileListenerName=[ListenerName '_' CondCode '_' TargetsFileName '_' MaskerFileName '_' StartDate '_' FileNamingStartTime];
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);


%% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
fprintf(fout, 'listener,CondCode,date,time,trial,CatchTrial,SNR,correct,target,InQuiet,masker,M1talker,M1colour,M1noun,M1animal,M2talker,M2colour,M2noun,M2animal,Ttalker,Tcolour,Tnoun,Tgender,Track,Video,Rcolour,Rnoun,rTime,rev');
fclose(fout);
%HRTF,T_az,M_az,MskStart,M1type,Ttype
%% wait to start
if strcmp(ResponseChoices,'ColNoun')
    StartMessage = 'Help the dog find the right colour & object!';
    Reminder = 'Remember to focus your attention on the talker that says "show the dog..." and to direct your gaze at the talker''s lips.';
end
GoOrMessageButton('String', StartMessage);
GoOrMessageButton2('String', Reminder);


%% set up rms values to deal properly with control of level,
%   overall vs fixed masker (fixed signal not implemented!!)
if strcmp(FixedSound,'overall')
    rms1 = 0; rms2 = OutRMS;
else % fixed = masker
    rms2 = 0; rms1 = OutRMS;
end
% Note that within all the different scripts that add together signal and
% noise, whether the noise or the signal is to be fixed must be specified.
% Currently (November 2010) the fixed signal option has not been
% implemented. But the noise/masker will not be scaled unless in_rms>0. If
% in_rms=0, then the masker is left at the level read from the file.
% The ~total~ level will be scaled to a fixed rms value if out_rms>0,
% whether or not any previous scaling has happened.

% open the audio device, at the correct sample rate
%(
if strfind(TestType,'MultiTalker')
    [x,Fsm] = audioread(maskers{1});
else
    [x,Fsm] = audioread(MaskerFile);

end
[x,Fst] = audioread(targets{1});

if Fsm == Fst
    Fs = Fsm;
else
    error('Masker and Target files are at different sample rates!');
end
audioWriter = audioDeviceWriter(Fs, 'SupportVariableSizeInput', true, 'BufferSize', 512);

% set up to do two interposed tracks. NOTE, if you set track2done to 1, the
% code should operate as if there is only one track and will present
% congruent target video.
% if 2 tracks are selected, the first track will present congruent video,
% while the second will present a masker video.

reversals =[];
%%	do adaptive tracking until stop criterion */
if tracks>1
    % set up parameters so that each track can operate independently, using
    % the same initial values for each, or setting to zero if they are
    % counters
    LEVITTS_CONSTANT(2,:) = LEVITTS_CONSTANT;
    levitts_index(2) = levitts_index;
    track2done = 0;
    track1done = 0;
    num_turns(2) = num_turns;
    limit(2) = limit(1);
    trialNum(1:2) = 0;
    num_correct(1:2) = 0; num_wrong(1:2) = 0;
    previous_change(2) = previous_change; % assume track is initially moving from easy to hard
    num_turns(1:2) = 0;
    num_final_trials(1:2) = 0;
    change(2) = change(1);
    SNR_dB(2) = SNR_dB;
    %inc = (START_change_dB-MIN_change_dB)/INITIAL_TURNS;
    response_count(2) = 0;
    current_change(1:2) =0;
    IgnoreTrials(1:2) = 2;
else
    track2done = 1;
    track1done = 0;
    trialNum = 0;
    num_correct = 0;num_wrong = 0;
    num_final_turns = 0;
    levitts_index = 1;
    num_turns = 0;
    current_change =0;
end
%try
pretestTracks = [1 1 2 1 2 1 2 1 2];
demoTracks = [1 2 1 2 1 2 1 2];
demoSNR = [20 20 20 20 10 10, 10, 10];
sumCorrect = 0;
pretestVideo = [zeros(1,6) 2 2];
demoVideo = [0, 0, 1, 1, 2, 2, 3, 3];
nInaRow(1:2) = 0;
while track1done == 0 | track2done == 0
    if strcmpi(type,'pretest')
        track = pretestTracks(trial+1);
        Video = pretestVideo(trial+1);
    elseif  strcmpi(type,'demo')
        track = demoTracks(trial+1);
        Video = demoVideo(trial+1);
        SNR_dB(track) = demoSNR(trial+1);

    elseif sum([track1done,track2done])==1 & track1done == 1
        %run track 2
        track = 2;
    elseif sum([track1done,track2done])==1 & track2done == 1
        %run track 1
        track = 1;
    elseif sum([track1done,track2done])<1 & nInaRow(1) < 5 & nInaRow(2) < 5
        % run randomly selected track
        if rand(1)>0.5; % randomly pick a track
            track = 2;
        else
            track = 1;
        end
    elseif sum([track1done,track2done])<1 & nInaRow(1) >= 5
        nInaRow(1) = 0;
        track = 2;
    elseif sum([track1done,track2done])<1 & nInaRow(2) >= 5
        nInaRow(2) = 0;
        track = 1;
    end
    nInaRow(track) = nInaRow(track)+1;
    trial = trial + 1;
    % Stuarts original single track code had two while loops, the first
    % iterated through the Levitts K values (which always start at 1), with
    % the inner loop running through the criterion for that K value
    % at the end of the inner loop the next trials SNR is set, at the end
    % of the outer loop the Levitts parameters are set. Here we replace the
    % while loops with if statments to allow us to operate the two
    % staircases independently.

    %%	do adaptive tracking until stop criterion */
    % note trial refers to the trial number, trialNum refers to the trial
    % number for each track

    % present same level until change criterion reached */
    %   num_correct(track) = 0;
    %   num_wrong(track) = 0;
    trialNum(track)=trialNum(track)+1;

    % is it a catch trial?
    % tmp_SNR=SNR_dB;

    Levitts = LEVITTS_CONSTANT(track,levitts_index(track));


    %% establish target and maskers, and get audio files
    % get target codes using single randomised target list
    TargetCodes=DecodeImperativeFileName(char(targets(TargetOrder(trial))));
    %     if NoVideo == 2 || strcmp(type,'pretest')
    %         remTimesTarget = targetTimes(TargetOrder(trial));
    %     end

    if ~isempty(strcmp(TestType,'DebugStair'))
        % skip all this!

        if strcmp(TestType,'MultiTalker') % maskers are talkers
            if strcmp(MultipleMaskerType,'VariableMasker') &  nMaskerTalkers == 2% which change every trial

                % multiple maskers of separate distractors in MultipleMaskerList
                % and random permutation in  MultipleMaskerOrder
                iMasker = iMasker + 1;
                %                % find a distractor without parts in common with the signal
                MaskerCodes(1)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                % for the first masker we force it to be same gender
                while (AnyCodeEqual(TargetCodes, MaskerCodes(1),0))
                    iMasker = iMasker + 1;
                    if iMasker>length(maskers)
                        iMasker=1;
                    end
                    MaskerCodes(1)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                    %      MaskerCodes
                    %      TargetCodes

                    %                     if NoVideo==2
                    %                         remTimesMasker(1) = maskerTimes(MaskersOrder(iMasker));
                    %                     end
                end
                %                % find the next distractor without common parts to signal or
                %                % 1st masker, and ensure it is a different type!
                % code is set to find Masker 1 to be same gender as target, and
                % masker 2 to be opposite to both
                iMasker = iMasker + 1;
                MaskerCodes(2)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                while (AnyCodeEqual(TargetCodes, MaskerCodes(2),1) ...
                        || AnyCodeEqual(MaskerCodes(1), MaskerCodes(2),1));
                    iMasker = iMasker + 1;
                    if iMasker>length(maskers)
                        iMasker=1;
                    end
                    MaskerCodes(2)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                    %                     if NoVideo==2 || strcmp(type,'pretest')
                    %                         remTimesMasker(2) = maskerTimes(MaskersOrder(iMasker));
                    %                     end
                end
                %                %--------------------------------------------------------------
                %
                % construct the masker made of multiple files
                try
                    [y, Fs, SigAlone, NoiseAlone] = add_2_distractors(char(targets(TargetOrder(trial))), ...
                        MaskerCodes(1).fileName, MaskerCodes(2).fileName,...
                        SNR_dB(track), 'noise', rms1, rms2); % , WarningNoise); -- SEP 2014
                catch
                    keyboard
                end
            elseif strcmp(TestType,'VariableMasker')  &  nMaskerTalkers == 1% which change every trial

                % multiple maskers of separate distractors in MultipleMaskerList
                % and random permutation in  MultipleMaskerOrder
                iMasker = iMasker + 1;
                %                % find a distractor without parts in common with the signal
                MaskerCodes(1)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                % for the first masker we force it to be same gender
                while (AnyCodeEqual(TargetCodes, MaskerCodes(1),0))
                    iMasker = iMasker + 1;
                    if iMasker>length(maskers)
                        iMasker=1;
                    end
                    MaskerCodes(1)=DecodeImperativeFileName(maskers{MaskersOrder(iMasker)});
                end

                % function [sig, Fs] ...
                % = add_distractor(SignalWavFileName, NoiseWavFileName, snr, fixed, in_rms, out_rms)
                [y, Fs, SigAlone, NoiseAlone] = add_distractor(char(targets(TargetOrder(trial))), ...
                    char(maskers(MaskersOrder(iMaskers))), SNR_dB(track), 'noise', rms1, rms2, ...
                    HRTF, [TargetAz MaskerAz]);
            end
        elseif strcmp(TestType,'TimingCheck')
            [y, Fs] = audioread(TestFileName);

        else % fixed masker from which a section is taken
            %   function [sig, Fs] = add_noise(SignalWav, NoiseWav, MaskerWavStart, snr,
            %   duration, fixed, in_rms, out_rms, warning_noise_duration)

            if PermuteMaskerWave % keep track of masker sections used
                nWavSection = nWavSection + 1;
                if nWavSection > nSections
                    nWavSection = 0;
                end
                MaskerWavStart=wavSections(nWavSection);
            else
                MaskerWavStart=-1;
            end
            %    allow specification of warning noise duration -- October 2010
            [y,Fs,MaskerWavStart,SigAlone,NoiseAlone] =add_noise( ...
                char(targets(TargetOrder(trial))), MaskerFile, ...
                MaskerWavStart, SNR_dB(track), 0, 'noise',  rms1, rms2, WarningNoise, ...
                HRTF, [TargetAz MaskerAz] ...
                );
            % function [sig, Fs, start, SigAlone, NoiseAlone] = add_noise(
            %      SignalWav, NoiseWav,
            %      MaskerWavStart, snr, duration, fixed, in_rms, out_rms, warning_noise_duration,
            %      HRIRmatFile, Azimuths)
            %  In order to fix masker level, specify in_rms and set out_rms=0
            %
            if PermuteMaskerWave % keep track of masker sections used
                % need to generate a new selection of noise files
                if nWavSection==nSections
                    nWavSection=0;
                    [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples);
                end
            end
        end

        if strcmp(TestType,'MultiTalker') && strcmp(MultipleMaskerType,'FixedMasker') && strcmp(HRTF,'none')
            % This preserves function of original code, which is not
            % necessarily a good thing!
            % MultiTalker Fixed Masker implies two separate long maskers
            % odd dichotic conditions
            % determine the ear(s) to play out the stimuli
            switch upper(Ear)
                case 'L', y=[y Noise2Alone];
                case 'R', y=[Noise2Alone y];
                case 'B', error('ear for multiple maskers must be one of L, R, Opp L or Opp R')
            end
        elseif strcmp(Ear,'OL')
            y=[SigAlone NoiseAlone];
        elseif strcmp(Ear,'OR')
            y=[NoiseAlone SigAlone];
        else
            if PresentInQuiet
                y=SigAlone;
            end
            % ensure that even diotic stimuli have separate left and right channels
            sizeY=size(y);
            if sizeY(2)==1
                y=[y y];
            end
            % determine the ear(s) to play out the stimuli
            switch upper(Ear)
                case 'L', y(:,2)=zeros(length(y),1);
                case 'R', y(:,1)=zeros(length(y),1);
                case 'B',
                otherwise error('variable ear must be one of L, R, B, Opp L or Opp R')
            end
        end
        if Video <= 1
            vidFolder = 'video\Full'; %TEMP
        elseif Video == 2
            vidFolder = 'video\Freeze';
        elseif Video == 3
            vidFolder = 'video\Disk';
        end
        audio=y;
        %% get video and set up videoPlayer
        % read video content
        if strcmp(TestType,'TimingCheck')
            videoReader = VideoReader([TestVideo]);
        else

            if track == 1 % use target content
                [folder,videoFile]  = strtok(TargetCodes(1).fileName,'/');
                videoFile = [videoFile(1:end-4) '.mp4'];
                videoReader = VideoReader([vidFolder videoFile]);
            elseif track == 2 % use masker - randomly select if there is more than one masker
                if size(MaskerCodes)>1 & rand(1)<0.5
                    %masker 2
                    [folder,videoFile]  = strtok(MaskerCodes(2).fileName,'/');
                    videoFile = [videoFile(1:end-4) '.mp4'];
                    videoReader = VideoReader([vidFolder videoFile]);
                    %  remTimes = remTimesMasker{1};
                else
                    %masker 1

                    [folder,videoFile]  = strtok(MaskerCodes(1).fileName,'/');
                    videoFile = [videoFile(1:end-4) '.mp4'];
                    % videoFile = [videoFile(1:end-4) '-s.mp4'];%TEMP
                    videoReader = VideoReader([vidFolder videoFile]);

                end
            end
        end
        % if its trial 1:
        if trial == 1
            % launch the videoPlayer
            screensize = get(0, 'screensize');
            % make wholse screen
            videoPlayer = vision.VideoPlayer('Position', [screensize]);
            % display first frame and rewind
            videoPlayer(readFrame(videoReader));
            % activate the 'scale to window' option - this only needs
            set(0,'showHiddenHandles','on')
            fig_handle = gcf ;
            fig_handle.findobj % to view all the linked objects with the vision.VideoPlayer
            ftw = fig_handle.findobj ('TooltipString', 'Maintain fit to window');   % this will search the object in the figure which has the respective 'TooltipString' parameter.
            ftw.ClickedCallback()  % execute the callback linked with this object
        else
            videoPlayer(readFrame(videoReader));
        end

        %% play out video and audio and get response
        % play out the audio and video
        TimeOfStim = clock;
        if strcmp(type,'pretest')
            Video = pretestVideo(trial);
            %             if NoVideo == 0
            %                 remTimes = [nan,nan];
            %             end
        end
        done = playMovie(videoReader,videoPlayer,audioWriter,audio,Fs,Video);

        %do you need a pause here, or to monitor 'done'?
        if done ~= 1
            error('Video playback error!')
        else
            % launch the app to register the response, the app will
            % close upon response, and the video reader will remain...
            if exist('app') ~=1
                app = responsePadTab;
                app.ResponseColour.Value=[];
                app.ResponseNoun.Value=[];
                app.UIFigure.WindowStyle = 'modal';
            else
                app.UIFigure.WindowStyle = 'modal';
                app.ResponseColour.Value=[];
                app.ResponseNoun.Value=[];
            end
            maxWait = 10; % seconds
            pollRate = 0.1; % seconds
            %30.10.26 fix to stop the task being so laggy; originally coded
            %that the response figure is initiated and deleted on every trial
            for ww= 1:maxWait/pollRate % this is a stupid way of doing this but
                % UIwait can't handle two presses, and closing the figure makes the task very slow
                if ~isempty(app.ResponseColour.Value) & ~isempty(app.ResponseNoun.Value)
                    TimeOfResponse = clock; % this is going to be only roughly accurate
                    disp('response acquired');
                    break
                end
                pause(pollRate)
            end
            if ww == maxWait/pollRate
            %             if ~isempty(app.ResponseColour)
            %                 Cresp = app.ResponseColour.Value;
            %             else
            %                 app = responsePadTab;
            %                 Cresp = app.ResponseColour.Value;
            %             end
            %             if ~isempty(app.ResponseColour)
            %                 Nresp = app.ResponseNoun.Value;
            %             else
            %                 app = responsePadTab;
            Nresp = 'nan';
            Cresp = 'nan';
            else
            Nresp = app.ResponseNoun.Value;
            Cresp = app.ResponseColour.Value;
            end
            Nresp = ['_' Nresp];
            
            % FROM HERE
            correct = strcmp(TargetCodes.colour,Cresp) && strcmp(TargetCodes.noun,Nresp);
        end

        sumCorrect = sumCorrect + correct;

        % give feedback if necessary
        if ~strcmp(FeedBack,'None') && ~DEBUG
            if strcmp(FeedBack,'Neutral')
                %imshow(WinkingFace,'parent',app.UIAxes)
            elseif (correct && strcmp(FeedBack,'Corrective')) | strcmp(FeedBack,'AlwaysGood')
                imshow(SmileyFace,'parent',app.UIAxes)
            else
                imshow(FrownyFace,'parent',app.UIAxes)
            end
            pause(0.1);
            imshow('Bouncy.jpg','parent',app.UIAxes)
        end
        app.UIFigure.WindowStyle = 'normal';
        %delete(app);
        %% write data
        % we've played out the trial and collected the response, now
        % let's save the data with info about which track it is, and
        % make sure that we're set up for the next trial.
    else
        % debug - enter some values here for savinf purposes
        Cresp = 'red';
        Nresp = 'Bin';
        correct = input('correct');
        %         if trial < 12
        %             correct = rand(1)<0.9
        %         else
        %             correct = rand(1)<0.7
        %         end
    end
    fout = fopen(OutFile, 'at');

    % print out relevant information
    %'listener,date,time,trial,SNR,correct,target,InQuiet,masker,
    %    M1colour,M1digit,M2colour,M2digit,Tcolour,Tdigit,
    %    Rcolour,Rdigit,rTime,rev'
    %fprintf(fout, 'listener,CondCode,date,time,trial,CatchTrial,SNR,correct,target,...
    %InQuiet,masker,M1talker,M1colour,M1noun,M2talker,M2colour,M2noun,Ttalker,Tcolour,Tnoun,Video,Track,Rcolour,Rnoun,rTime,rev');
    VideoCond = (10*Video) + track;

    fprintf(fout, '\n%s,%s,%s,%s,%3d,%1d,%+5.1f,%d,%s,%d,%s,%g,%g,', ...
        ListenerName,CondCode,StartDate,StartTimeString,trial,isCatchTrial,SNR_dB(track),correct, ...
        char(targets(TargetOrder(trial))),VideoCond);
    if strcmp(TestType,'MultiTalker') || strcmp(TestType,'DebugStair')
        if strcmp(MultipleMaskerType,'VariableMasker')
            fprintf(fout, '%s:%s,',...
                MaskerCodes(1).fileName,MaskerCodes(2).fileName);
            fprintf(fout, '%s,%s,%s,%s,%s,%s,', ...
                MaskerCodes(1).talker, MaskerCodes(1).colour, MaskerCodes(1).noun,MaskerCodes(1).animal,  ...
                MaskerCodes(2).talker, MaskerCodes(2).colour, MaskerCodes(2).noun,MaskerCodes(2).animal);
        else
            fprintf(fout, '%s,%d,%s,%d,,,', ...
                char(MultipleMaskerFiles(1)),MaskerWavStart(1),...
                char(MultipleMaskerFiles(2)),MaskerWavStart(2));
        end
    else
        % fprintf(fout, '%s,%d,,,,,,,,,', MaskerFile,MaskerWavStart);
    end
    fprintf(fout, '%s,%s,%s,%d,%d,%s,%s,%s,', ...
        TargetCodes.talker, TargetCodes.colour, TargetCodes.noun, TargetCodes.gender,...
        track,videoFile, Cresp, Nresp);
    fprintf(fout, '%02d:%02d:%05.2f',...
        TimeOfResponse(4),TimeOfResponse(5),TimeOfResponse(6));
    % close file for safety
    fclose(fout);

    %% prep for next trial
    % set level back if changed for catch trial
    %       SNR_dB=tmp_SNR;

    % ignore initial errors
    if ~isCatchTrial && trialNum(track)<IgnoreTrials(track) && correct == 0
        % do nothing to scores but prevent getting a 'reversal' due to an incorrect
        % trial
        current_change(track) = previous_change(track);
    else % do the normal thing
        % score the response as correct or wrong */
        if correct
            num_correct(track)=num_correct(track)+1;
        else
            num_wrong(track)=num_wrong(track)+1;
        end

        % also keep track of levels visited: perhaps better
        if ((change-0.001) <= MIN_change_dB) % allow for rounding error
            % we're in the final stretch
            num_final_trials(track) = num_final_trials(track) + 1;
            final_trials(track,num_final_trials(track)) = SNR_dB(track);
        end
    end

    %end % end of Levitt 'while' loop

    %         % test for quitting
    %         if strcmp(Cresp,'quit')
    %             break
    %         end
    %
    % decide in which direction to change levels and change them if they
    % fulfill the levitts requirments
    if (num_correct(track) >= LEVITTS_CONSTANT(track,levitts_index(track)))
        current_change(track) = -1;
        % change stimulus level
    elseif num_wrong(track) >= 1
        current_change(track) = 1;
        % change stimulus level
    end

    % are we at a turnaround? (defined here as any change in direction) If so, do a few things
    if (previous_change(track) ~= current_change(track))
        % move to next value of Levitt's constant if not already done
        if (levitts_index(track)==1)
            levitts_index(track)= 2;
        end
        % reduce step proportion if not minimum */
        if ((change(track)-0.001) > MIN_change_dB) % allow for rounding error
            change(track) = change(track)-inc;
        else % final turnarounds, so start keeping a tally
            num_turns(track) = num_turns(track) + 1;
            reversals(track,num_turns(track))=SNR_dB(track);
            fout = fopen(OutFile, 'at');fprintf(fout,'%s',[',*' num2str(track)]);fclose(fout);

        end
        % reset change indicator
        previous_change(track) = current_change(track);
    end

    % change level only if it needs to be changed
    if (num_correct(track) >= LEVITTS_CONSTANT(track,levitts_index(track))) | num_wrong(track) >=1
        SNR_dB(track) = SNR_dB(track) +  change(track)*current_change(track);
        % now reset the counters:
        num_correct(track) = 0;
        num_wrong(track) = 0;
    end
    %temp = [temp;trial,trialNum(track),track,SNR_dB(track),correct,num_correct(track),num_wrong(track)];

    % if still on initial descent, change rules if SNR too low & change step size
    if (levitts_index(track)==1 && SNR_dB(track)<=InitialDescentMinimum) && previous_change(track) == current_change(track)
        levitts_index(track)=2;
        change(track) = change(track)-inc;
    end

    % ensure that the current stimulus level is within the possible range
    % keep track of hitting the endpoints
    if (SNR_dB(track) > MAX_SNR_dB)
        SNR_dB(track) = MAX_SNR_dB;
        limit(track) = limit(track)+1;
    end
    if (num_turns(track)>=FINAL_TURNS  || limit(track)>MaxBumps || trialNum(track)>MAX_TRIALS || trial>length(targets))
        if track==1;
            track1done = 1;
        elseif track ==2;
            track2done = 1;
        end
    elseif sum(trialNum)==MAX_TRIALS & [strcmpi(type,'pretest')||strcmpi(type,'demo')]
        track1done = 1; track2done = 1;
    end  % end of a single run */

end
% catch
%     fprintf(1,'The identifier was:\n%s',e.identifier);
%         fprintf(1,'There was an error! The message was:\n%s',e.message);
%     keyboard
%end

if ~exist('MultipleMaskerType')
    MultipleMaskerType = 'fixed';
end

EndTime=fix(clock);
EndTimeString=sprintf('%02d:%02d:%02d',EndTime(4),EndTime(5),EndTime(6));
fout = fopen(SummaryOutFile, 'at');
%                  1      2        3        4                 5    6    7     8      9    10           11
fprintf(fout, 'listener,CondCode,TestType,MultipleMaskerType,warn, date,start,end,version,responses,feedback');
%                 12     13        14      15     16       17      18      19  20  21   22     23    24      25    26     27    28     29    30     31
fprintf(fout, ',targets,InQuiet,masker,masker2,CatchTrials,ear,FixedSound,rms,HRTF,T_az,M_az,Levitt,nTrials,finish,uRevs,sdRevs,nRevs,uLevs,sdLevs,nLevs\n');
fprintf(fout, '%s,%s,%s,%s,%d,%s,%s,%s,%4.1f,%s,', ...
    ListenerName,CondCode,TestType,MultipleMaskerType,WarningNoise,StartDate,StartTimeString,EndTimeString,VERSION,ResponseChoices);
% if max(size(MultipleMaskerFiles))>1
%     MaskerFile2=char(MultipleMaskerFiles(2));
% else
MaskerFile2='';
% end
fprintf(fout, '%s,%s,%d,%s,%s,%d,%s,%s,%g,%s,%g,%g,%d,%d,', ...
    FeedBack,TargetsFile,VideoCond,MaskerFile,MaskerFile2,CatchTrials,Ear,FixedSound,OutRMS,HRTF,TargetAz,MaskerAz,LevittsK,trial);

%% print out summary statistics -- how did we get here?
if (limit>=3) % bumped up against the limits
    fprintf(fout,'BUMPED,,,,,,');
else
    if strcmp(Cresp,'quit')  % test for quitting
        fprintf(fout, 'QUIT,');
    elseif (num_turns<FINAL_TURNS)
        fprintf(fout, 'RanOut,');
    else
        fprintf(fout, 'Normal,');
    end
    if num_turns>1
        fprintf(fout, '%5.2f,%5.2f,%d,', ...
            mean(reversals), std(reversals), num_turns);
    else
        fprintf(fout, '0,0,%d,',num_turns);
    end
    if num_final_trials>1
        fprintf(fout, '%5.2f,%5.2f,%d\n', ...
            mean(final_trials), std(final_trials), num_final_trials);
    else
        fprintf(fout, '0,0,%d\n',num_final_trials);
    end
end
fclose('all');

%% clean up

delete(videoPlayer);
close all;
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));
release(audioWriter);
if strcmp(type,'pretest');
    disp(['Total Correct : ' num2str(sumCorrect)]);
    GoOrMessageButton3('String','Practice session complete. Please let the experimenter know that you have finished.');
else
    disp(mean(reversals,2));
end
clear app
%FinishButton; % indicate test is over













