function CCRM(varargin)
% Run an experiment using pre-computed CCRM stimuli
%
% If masker file name begins with a number, read in multiple files of
%   distractors (e.g., 2talk45.txt)
% If MaskerFile is text, use the files named as the maskers
% If MaskerFile is a wave, use it directly
% Version 1.0

% Version 2.0 -- July 2008 -- K Mair's project
%   seed random number generator with time and save away
%   add time and date to results file names
%   one test result per file
%   modify format of summary output file
%   allow automatic responding for debugging purposes
%   new form for entering filename

% Version 3.0 -- December 2008 -- Zoe Lyall's project
%   new form for entering conditions and other information
%   limit initial descent down to -10
%   add OutRMS reading to VolumeSettings.txt

% Version 4.0 -- January 2009
%   include specification of maximum trials on gui
%   if step size is 0, make initial reversals large so that test length is
%       determined by maximum number of trials

% Version 5.0 -- March 2009
%   allow possibility of requiring response of both colour and number

% Version 6.0 -- March 2009
%   control which sections of long noise wave get played out to minimise
%   repeated playing of particular sections

% Version 6.1 -- March 2009
%   minor change to ensure that setting START_change_dB=0 also sets
%   MIN_change_dB=0, so as to get all testing at a fixed SNR

% Version 7.0 -- April 2009
%   Allow a test to be run in quiet by manipulating targets as if they are
%   presented in a background of noise, but actually are not.
%   Only implemented for a long noise file (*.wav specified)
%       TestType = 'FixedMasker'
%       with the word 'silence' added to file name, e.g. 'SpchNzSILENCE'
%
% Version 7.1 -- April 2009
%   Allow drop down list of targets list files
%
% Version 8.0 -- April 2009
%   Allow spatial separation of targets and masker through HRTFs
%   Filtering is done at run time
%   implemented for a long wav masker only

% Version 8.1 -- May 2009
%   ignore errors on initial IgnoreTrials trials
%
% Version 9.0 -- May 2009
%   Change name to CCRM!
%   option to start test without GUI, by specifying arguments directly
%   new Go button function with option to display text
%
% Version 9.1 -- May 2009
%   add CondCode to output
%
% Version 10.0 -- June 2009
%   allow catch trials
%   fix errors in fixed level testing
%
% Version 11.0 -- April 2010
%   allow selection of which ear to play stimuli to
%   and to put signal and noise in opposite ears
%
% Version 11.5 -- May 2010
%   allow target signal and sentence distractor in opposite ears
%
% Version 11.6 -- July 2010
%   allow fixing the level of the masking noise in final output
%   This necessitated putting rms level onto the GUI, along with a check box
%
% Version 12.0 -- July 2010
%   allow the use of a masker in ipsi- as well as contra-lateral ear
%
% Version 12.1 -- July 2010
%   correct error in permuting multiple masker waves that are of different lengths
%   add information to summary files
%   allow choice of target ear for multitalker maskers
%
% Version 12.2 -- July 2010
%   allow specification of targets to go to L or R ears in opposite ears
%       presentation
%
% Version 13.0 -- October 2010
%   Implement possibility of 2 distractor sentences being ~concatenated~,
%   rather than being added together. This piggybacks on to the feature of
%   being able to add together distractor sentences from 2 talkers, and is
%   indicated by '_seq' for sequential in the file name.
%
%   Check that all wav files listed, both as maskers and targets, exist
%
% Version 13.0 -- November 2010
%
% Version 13.5 -- November 2010
%   change CatchTrialSNR to 100 but only allow catch trials to operate when
%   the overall level is fixed, because a high SNR with a fixed masker may
%   lead to target that is too loud. Throw an error for now and think about
%   how to deal with this later. Perhaps add parameter to GUI.
%
% Version 13.6 -- November 2010
%   check for existence of VolumeSettings.txt and throw appropriate error
%
% Version 13.7 -- June 2011
%   add specification of final turns to GUI and sequence running
%
% Version 13.8 -- June 2011
%   Add control of Windows 7 volume through the size of the numbers in the
%   VolumeSettings.txt file
%
% Version 14.0 -- October 2011
%   Allow different kinds of feedback, also using different faces for it
%
% Version 14.5 -- November 2011
%   get feedback type into summary file
%   put a feedback code into file name (at least for now)
%
% Version 16.0 -- June 2012
%   use response pad for digits that is appropriate for the tablet
%   bigger buttons and labels on them suit all PCs, probably
%   fiddle a little with ResponsePadTab and fileparts()
%
% Version 16.5 -- December 2013
%   implement better volume controls
%
% Version 16.6 -- September 2014
%   slight correction to add_2_distractors.m
%   extend add_2_distractors.m to do spatialisation
%
% Version 16.7 -- September 2014
%   add indicator to GUI for multiple masker locations
%   add indicator for ITD: Then 'azimuths' = the ITDs
%
% Version 17.0 -- September 2014
%   allow more than two separate talker as maskers but only use 2
%   ensure masker talker is never the same as target talker
%   (can happen when target talker is randomised by specifying multiple
%   target talkers in targets file)
%   Introduce a variable nMaskerTalkers, to specify number of simutaneous
%   talkers in the masker when there are multiple ones. Currently fixed but
%   could be put on the GUI
%
% Vs 18 for Lucy Crook -- display appropriate image
%
% To consider -- if CCRM is started with an even number of args, then put
%   all specified args into the GUI and start by showing the GUI so other
%   aspects can be altered (e.g, listener name). This would prevent the
%   necessity of recompiling for changed defaults. Or could add further
%   variables to MaskerConditionsList.csv

%% initialisation and fixed parameter values
DEBUG=0;
VERSION=20.0;
PermuteMaskerWave=1; % minimise repeated playing of sections of masker wav
InitialDescentMinimum=-10;
MAX_SNR_dB = 40;
INITIAL_TURNS = 3;
% FINAL_TURNS = 6;
IgnoreTrials=3; % number of initial trials to ignore errors on
OutputDir = 'results';
levitts_index = 1;
CatchTrialSNR=100; % SNR to present on catch trials
% CatchTrials=0;
MaxBumps=3;
MultipleMaskerType=[];
MultipleMaskerFiles=[];
nMaskerTalkers=2; % when TestType='MultiTalker' & MultipleMaskerType = 'VariableMasker
% initialise the random number generator on the basis of the time
rand('twister', sum(100*clock));

%% Settings for level
if ispc
    VolumeSettingsFile='VolumeSettings.txt';
    [~, OutRMS]=SetLevels(VolumeSettingsFile);
else ismac
    !osascript set_volume_applescript.scpt
    % VolumeSettingsFile='VolumeSettingsMac.txt';
end

%% get control parameters one way or t'other
if nargin==0
    StartMessage='none';
    CondCode='GUI';
        [I, DOB, sex] = ListenerID();
        ListenerName = [I, '_', DOB,'_', sex];
    [ListenerName,TargetsFile,MaskerFile,starting_SNR,START_change_dB,MIN_change_dB,...
        MAX_TRIALS,LevittsK,ResponseChoices,PresentInQuiet,...
        HRTF,TargetAz,MaskerAz,CatchTrials, Ear, FixedSound, ...
        OutRMS, WarningNoise, FINAL_TURNS, FeedBack, FacePixDir, ...
        MaskerLocations, NoVideo]=SpecifyTestOrders('Listener',ListenerName);
else % pick up defaults and specified values from args
    if ~rem(nargin,2)
        error('You should not have an even number of input arguments');
    end
    SpecifiedArgs=CCRMparseArgs(varargin{1},varargin{2:end});
    % now set all parameters obtained
    fVars=fieldnames(SpecifiedArgs);
    for f=1:length(fVars)
        if ischar(eval(['SpecifiedArgs.' char(fVars{f})]))
            eval([char(fVars{f}) '=' '''' eval(['SpecifiedArgs.' char(fVars{f})]) ''';']);
        else % it's a number
            eval([char(fVars{f}) '='  num2str(eval(['SpecifiedArgs.' char(fVars{f})])) ';'])
        end
    end
end

%% do a number of checks and further initialisations
if (TargetAz>0 || MaskerAz>0) && strcmp(HRTF,'none')
    error('You seemed to have specified spatial locations without an HRTF');
end
if ((strcmp(Ear,'OL') || strcmp(Ear,'OR') ) && ~strcmp(HRTF,'none'))
    error('You specified opposite ear presentation with an HRTF');
end
if strcmp(ResponseChoices,'ColDig')
    DigitResponse=1;
else
    DigitResponse=0; % 'ColOnly'
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

% for fixed level testing
if START_change_dB==0 || MIN_change_dB == 0
    MIN_change_dB = 0;
    START_change_dB=0;
    INITIAL_TURNS = 99;
    FINAL_TURNS = 99;
    LEVITTS_CONSTANT = [1 1];
    MaxBumps=99;
end

%% read in and permute the order of the targets
if ~exist(TargetsFile, 'file')
    error('Targets file does not exist: %s', TargetsFile)
end
targets = textread(TargetsFile, '%s');
TargetOrder = randperm(length(targets));
% check that all wav files exist
CheckAllWavsAvailable(targets, 'target')

%% determine what kind of maskers are to be used
if ~isempty(regexp(MaskerFile(1), '[0-9]', 'once' ))
    % a digit in the file name has been found
    TestType = 'MultiTalker';
    % this file contains names of other files
    if ~exist(MaskerFile, 'file')
        error('Targets file does not exist: %s', MaskerFile)
    end
    MultipleMaskerFiles=textread(MaskerFile, '%s');
    % if these two are .txt files, they contain the list of distractors
    % if wav files, they are the maskers from which sections must be extracted
    [tmp, tmp, ext] = fileparts(char(MultipleMaskerFiles(1)));
    if strcmp(ext, '.wav')
        MultipleMaskerType = 'FixedMasker';
        MaskerFile = char(MultipleMaskerFiles(1)); % for later use in permuting masker
    else % assume the file contains a list
        MultipleMaskerType = 'VariableMasker';
        MultipleMaskerSeq = 0;
        MultipleMaskerList = [];
        % original code assumed only 2 masker files - revised October 2014
        % ensure that all masker files exist
        maskers=cell(length(MultipleMaskerFiles),1);
        for mmf=1:length(MultipleMaskerFiles)
            if ~exist(char(MultipleMaskerFiles(mmf)), 'file')
                error('Masker file does not exist: %s', char(MultipleMaskerFiles(mmf)))
            end
            MultipleMaskerList = [MultipleMaskerList; textread(char(MultipleMaskerFiles(mmf)), '%s')];
            maskers{mmf}= textread(char(MultipleMaskerFiles(1)), '%s');
            % check that all wav files exist
            CheckAllWavsAvailable(maskers{mmf}, ['masker' num2str(mmf)])
            % may not need this
            % MaskersOrder{mmf} = randperm(length(maskers{mmf}));
        end
        % may not need this
        % imaskers=zeros(1,length(MultipleMaskerFiles));
        % check that all wav files exist
        CheckAllWavsAvailable(MultipleMaskerList, 'MultipleMaskerFiles')
        MultipleMaskerOrder = randperm(length(MultipleMaskerList));
        iMasker=0;
%         maskers1 = textread(char(MultipleMaskerFiles(1)), '%s');
%         maskers2 = textread(char(MultipleMaskerFiles(2)), '%s');
%         % permute the order of the maskers/distractors
%         MaskersOrder1 = randperm(length(maskers1));
%         MaskersOrder2 = randperm(length(maskers2));
%         iMaskers1 = 0;
%         iMaskers2 = 0;
        % if _seq is in the file name, the two maskers should be
        % concatenated sequentially, instead of added together
        if  ~isempty(regexp(MaskerFile, '_seq', 'once' ))
             MultipleMaskerSeq = 1; % an indicator for later
        end
    end
else
    [pathstr, name, ext] = fileparts(MaskerFile);
    if strcmp(ext, '.wav')
       TestType = 'FixedMasker';
       %   determine if targets should be presented in silence
       if ~isempty(findstr(MaskerFile, 'SILENCE'))
           MaskerFile = strrep(MaskerFile,'SILENCE','');
           PresentInQuiet=1;
       end
    else % assume the file contains a list
       TestType = 'VariableMasker';
       maskers = textread(MaskerFile, '%s');
        % check that all wav files exist
        CheckAllWavsAvailable(maskers, 'masker')
       % permute the order of the maskers/distractors
       MaskersOrder = randperm(length(maskers));
       iMaskers = 0;
    end
end

%% generate the sections of maskers to be used so as to minimise re-use
if strcmp(TestType,'FixedMasker') || strcmp(MultipleMaskerType,'FixedMasker')
       % find longest duration target
       MaxDurTargetSamples=0;
       for i=1:length(targets)
           [x,SampFreq] = audioread(targets{i});
           % check if stereo
           dim=size(x);
           % get number of samples
           n=dim(1);
           MaxDurTargetSamples=max(MaxDurTargetSamples,n);
       end
       % allow for extra length of warning noise -- October 2010
       MaxDurTargetSamples =  MaxDurTargetSamples + round(SampFreq*WarningNoise/1000);
       % generate a set of random sections of the masker wave for possible use later
       [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples);
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
FileListenerName=[ListenerName '_' TargetsFileName '_' MaskerFileName '_' StartDate '_' FileNamingStartTime];
OutFile = fullfile(OutputDir, [FileListenerName '.csv']);
SummaryOutFile = fullfile(OutputDir, [FileListenerName '_sum.csv']);


%% write some headings and preliminary information to the output file
fout = fopen(OutFile, 'at');
fprintf(fout, 'listener,CondCode,date,time,trial,CatchTrial,SNR,correct,target,InQuiet,HRTF,T_az,M_az,masker,MskStart,M1talker,M1colour,M1digit,M1type,M2talker,M2colour,M2digit,M2type,Ttalker,Tcolour,Tdigit,Ttype,Rcolour,Rdigit,rTime,rev');
fclose(fout);

%% wait to start
GoOrMessageButton('String', StartMessage)

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

% open the audio device, currently all content is sampled at 22.05 kHz
audioWriter = audioDeviceWriter(22050, 'SupportVariableSizeInput', true, 'BufferSize', 512);

%%	do adaptive tracking until stop criterion */
while (num_turns<FINAL_TURNS  && limit<=MaxBumps && trial<MAX_TRIALS && trial<length(targets))
    num_correct = 0; num_wrong = 0;
    % present same level until change criterion reached */
	while ((num_correct < LEVITTS_CONSTANT(levitts_index)) && (num_wrong==0))
       trial=trial+1;
       % is it a catch trial?
       tmp_SNR=SNR_dB;
       if CatchTrials>0 && rem(trial,CatchTrials+1)==0
           isCatchTrial=1;
           SNR_dB = CatchTrialSNR;
       else
           isCatchTrial=0;
       end

       nWavSection=nWavSection+1;
       % function imperative = DecodeImperativeFileName(FileName)
       TargetCodes=DecodeImperativeFileName(char(targets(TargetOrder(trial))));

        % read video content if available
        [tmp, tmp, ext] = fileparts(char(targets(TargetOrder(trial))));
        if strcmp(ext, '.mp4')
            videoReader = VideoReader(char(targets(TargetOrder(trial))));
        else
            videoReader = 0;
        end

        % get the image for the correct condition
        if  TargetsFileName(2)=='M'
            AnimalImage = imread('man+dog.jpg','jpg');
        else
            AnimalImage = imread('woman+dog.jpg','jpg');
        end
       % --------------------------------------
       % find the right animal image -- must be jpg
       % AnimalImage = imread([char(TargetCodes.animal) '.jpg'],'jpg');

       if strcmp(TestType,'MultiTalker')
           if strcmp(MultipleMaskerType,'VariableMasker')
               % multiple maskers of separate distractors in MultipleMaskerList
               % and random permutation in  MultipleMaskerOrder
               iMasker = iMasker + 1;
%                %--------------------------------------------------------------
%                %  The start of a clever way but I cannot figure it out
%                %  It might make sense to write a routine that compares
%                %  all parts of the Codes structure
%                %--------------------------------------------------------------
%                for nTlk = 1:nMaskerTalkers
%                    MaskerCodes(nTlk)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
%                    % find a distractor without parts in common with the target or previously chosen maskers
%                    % check that the colour isn't repeated from the target
%                    while strcmp(TargetCodes.colour,MaskerCodes(nTlk).colour)
%                        iMasker = iMasker + 1;
%                        if iMasker>length(MultipleMaskerList)
%                            iMasker=1;
%                        end
%                        MaskerCodes(nTlk)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
%                    end
%                    % or from all previous maskers
%                    for nn = 1:nTlk-1
%                        while strcmp(MaskerCodes(nn).colour,MaskerCodes(nTlk).colour)
%                            iMasker = iMasker + 1;
%                            if iMasker>length(MultipleMaskerList)
%                                iMasker=1;
%                            end
%                            MaskerCodes(nTlk)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
%                        end
%                    end
%                end
%                %-----------------------------------------------------------------------------

               %--------------------------------------------------------------
               % The easier (but dumb!) way
               % find a distractor without parts in common with the signal
               MaskerCodes(1)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
               while (AnyCodeEqual(TargetCodes, MaskerCodes(1)))
                   iMasker = iMasker + 1;
                   if iMasker>length(MultipleMaskerList)
                       iMasker=1;
                   end
                   MaskerCodes(1)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
               end
               % find the next distractor without common parts to signal or
               % 1st masker, and ensure it is a different type!
               iMasker = iMasker + 1;
               MaskerCodes(2)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
               while (AnyCodeEqual(TargetCodes, MaskerCodes(2)) ...
                       || AnyCodeEqual(MaskerCodes(1), MaskerCodes(2)) ...
                       || ~TalkerTypeDifferent(MaskerCodes(1), MaskerCodes(2)))
                   iMasker = iMasker + 1;
                   if iMasker>length(MultipleMaskerList)
                       iMasker=1;
                   end
                   MaskerCodes(2)=DecodeImperativeFileName(char(MultipleMaskerList(MultipleMaskerOrder(iMasker))));
               end
               %--------------------------------------------------------------

               % construct the masker made of multiple files
               % There are now 2 possibilities -- sequential or added
               if MultipleMaskerSeq % !!!OBS need to fix this for naming of the two maskers -- see next statement
                   [y, Fs, SigAlone, NoiseAlone] = sequence_2_distractors(char(targets(TargetOrder(trial))), ...
                       char(maskers1(MaskersOrder1(iMaskers1))), char(maskers2(MaskersOrder2(iMaskers2))),...
                       SNR_dB, 'noise', rms1, rms2, WarningNoise);
               else
                   if strcmp(HRTF,'none')
                       % function [sig, Fs] = ...
                       %     sequence_2_distractors(SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2, ...
                       %                     snr, fixed, in_rms, out_rms, warning_noise_duration)
                       [y, Fs, SigAlone, NoiseAlone] = add_2_distractors(char(targets(TargetOrder(trial))), ...
                           MaskerCodes(1).fileName, MaskerCodes(2).fileName,...
                           SNR_dB, 'noise', rms1, rms2); % , WarningNoise); -- SEP 2014
                   else
                       % mirror one masker position across the midline from
                       % the other
                       [y, Fs, SigAlone, nz1Alone, nz2Alone] = add_2_distractors_HRTF(char(targets(TargetOrder(trial))), ...
                           char(maskers1(MaskersOrder1(iMaskers1))), char(maskers2(MaskersOrder2(iMaskers2))),...
                           SNR_dB, 'noise', rms1, rms2, HRTF, [TargetAz MaskerAz -MaskerAz]);

                   end
               end
           else % this is MultiTalker Fixed Masker (two separate long maskers)
               for i=1:2
                   if PermuteMaskerWave % keep track of masker sections used
                       if i==1
                           MaskerWavStart(i)=wavSections(nWavSection);
                       else % messy, messy, messy!
                           MaskerWavStart(i)=wavSections2(nWavSection);
                       end
                   else
                       MaskerWavStart(i)=-1;
                   end
               end
               % function [sig, Fs, start, SigAlone, NoiseAlone, Noise2Alone] = AddNoiseReturnSecond(
               %   SignalWav, NoiseWav, Noise2Wav, MaskerWavStart, ...
               %   snr, duration, fixed, in_rms, out_rms, warning_noise_duration, HRIRmatFile, Azimuths)
               [y,Fs,MaskerWavStart,SigAlone,NoiseAlone,Noise2Alone] = AddNoiseReturnSecond( ...
                   char(targets(TargetOrder(trial))), char(MultipleMaskerFiles(1)), char(MultipleMaskerFiles(2)),...
                   MaskerWavStart, SNR_dB, 0, 'noise', rms1, rms2,  WarningNoise, ...
                   HRTF, [TargetAz MaskerAz]);
               if PermuteMaskerWave % keep track of masker sections used
                   % need to generate a new selection of noise files
                   % here, if either masker runs out, new sections of both are generated
                   if nWavSection==nSections || nWavSection==nSections2
                       nWavSection=0;
                       [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples);
                       [nSections2, wavSections2]=GenerateWavSections(char(MultipleMaskerFiles(2)), MaxDurTargetSamples);
                   end
               end
           end
       elseif strcmp(TestType,'VariableMasker')
           iMaskers = iMaskers + 1;
           % find a distractor without common parts
           MaskerCodes=DecodeImperativeFileName(char(maskers(MaskersOrder(iMaskers))));
           while (strcmp(TargetCodes.animal,MaskerCodes.animal) ...
                   || strcmp(TargetCodes.colour,MaskerCodes.colour) ...
                   || TargetCodes.digit==MaskerCodes.digit)
               iMaskers = iMaskers + 1;
               MaskerCodes=DecodeImperativeFileName(char(maskers(MaskersOrder(iMaskers))));
           end
           % function [sig, Fs] ...
           % = add_distractor(SignalWavFileName, NoiseWavFileName, snr, fixed, in_rms, out_rms)
           [y, Fs, SigAlone, NoiseAlone] = add_distractor(char(targets(TargetOrder(trial))), ...
               char(maskers(MaskersOrder(iMaskers))), SNR_dB, 'noise', rms1, rms2, ...
               HRTF, [TargetAz MaskerAz]);
       else % fixed masker from which a section is taken
           %   function [sig, Fs] = add_noise(SignalWav, NoiseWav, MaskerWavStart, snr,
           %   duration, fixed, in_rms, out_rms, warning_noise_duration)

           if PermuteMaskerWave % keep track of masker sections used
               MaskerWavStart=wavSections(nWavSection);
           else
               MaskerWavStart=-1;
           end
           %    allow specification of warning noise duration -- October 2010
           [y,Fs,MaskerWavStart,SigAlone,NoiseAlone] =add_noise( ...
               char(targets(TargetOrder(trial))), MaskerFile, ...
               MaskerWavStart, SNR_dB, 0, 'noise',  rms1, rms2, WarningNoise, ...
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
%            switch upper(Ear)
%                case 'L', y(:,2)=zeros(length(y),1);
%                case 'R', y(:,1)=zeros(length(y),1);
%                case 'B',
%                otherwise error('variable ear must be one of L, R, B, Opp L or Opp R')
%            end
       end

       % play it out and score it.
       if ~DEBUG
               %[Cresp,Dresp] = ResponsePadTab(AnimalImage,audioWriter,y,videoReader,NoVideo,trial);
               app =  responsePadTab(AnimalImage,audioWriter,y,videoReader,NoVideo,trial);
               [Cresp,Dresp]
               correct = strcmp(char(TargetCodes.colour),Cresp)&&(TargetCodes.noun==Dresp);
           end
       else
           % get 2 right at start of session,
           % then ensure correct response 0.7 the time thereafter
           % otherwise guess 'pink' and 8
           Dresp='';
           if trial<=2 || (rand(1)<0.7)
               Cresp=char(TargetCodes.colour);
               if DigitResponse
                   Dresp=TargetCodes.digit;
               end
           else
               Cresp='pink';
               if DigitResponse
                   Dresp=8;
               end
           end
           if DigitResponse
               correct = strcmp(char(TargetCodes.colour),Cresp)&&(TargetCodes.digit==Dresp);
           else
               correct = strcmp(char(TargetCodes.colour),Cresp);
           end
       end
       TimeOfResponse = clock;

       % test for quitting
       if strcmp(Cresp,'quit')
          break
       end

       % give feedback if necessary
       if ~strcmp(FeedBack,'None') && ~DEBUG
           if strcmp(FeedBack,'Neutral')
               image(WinkingFace);
           elseif (correct && strcmp(FeedBack,'Corrective')) | strcmp(FeedBack,'AlwaysGood')
               image(SmileyFace);
           else
               image(FrownyFace);
           end
           set(gca,'Visible','off')
           pause(0.5)
           image(AnimalImage)
           set(gca,'Visible','off')
       end

       fout = fopen(OutFile, 'at');
       % print out relevant information
       %'listener,date,time,trial,SNR,correct,target,InQuiet,masker,
       %    M1colour,M1digit,M2colour,M2digit,Tcolour,Tdigit,
       %    Rcolour,Rdigit,rTime,rev'
       fprintf(fout, '\n%s,%s,%s,%s,%3d,%1d,%+5.1f,%d,%s,%d,%s,%g,%g,', ...
          ListenerName,CondCode,StartDate,StartTimeString,trial,isCatchTrial,SNR_dB,correct, ...
          char(targets(TargetOrder(trial))),PresentInQuiet,HRTF,TargetAz,MaskerAz);
       if strcmp(TestType,'MultiTalker')
           if strcmp(MultipleMaskerType,'VariableMasker')
               fprintf(fout, '%s:%s,,',...
                   MaskerCodes(1).fileName,MaskerCodes(2).fileName);
               fprintf(fout, '%s,%s,%d,%s,%s,%s,%d,%s,', ...
                   MaskerCodes(1).talker, MaskerCodes(1).colour, MaskerCodes(1).digit, MaskerCodes(1).talkerType, ....
                   MaskerCodes(2).talker, MaskerCodes(2).colour, MaskerCodes(2).digit, MaskerCodes(2).talkerType);
           else
               fprintf(fout, '%s,%d,%s,%d,,,', ...
                    char(MultipleMaskerFiles(1)),MaskerWavStart(1),...
                    char(MultipleMaskerFiles(2)),MaskerWavStart(2));
           end
       elseif strcmp(TestType,'VariableMasker')
           fprintf(fout, '%s,,', char(maskers(MaskersOrder(iMaskers))));
           fprintf(fout, '%s,%d,,,', MaskerCodes.colour, MaskerCodes.digit);
       else
           fprintf(fout, '%s,%d,,,,,,,,,', MaskerFile,MaskerWavStart);
       end
       fprintf(fout, '%s,%s,%d,%s,%s,%d,', ...
           TargetCodes.talker, TargetCodes.colour, TargetCodes.digit, TargetCodes.talkerType, Cresp, Dresp);
       fprintf(fout, '%02d:%02d:%05.2f',...
          TimeOfResponse(4),TimeOfResponse(5),TimeOfResponse(6));
      % close file for safety
      fclose(fout);

      % set level back if changed for catch trial
      SNR_dB=tmp_SNR;

      % ignore initial errors
      if ~isCatchTrial && ((trial>IgnoreTrials) || correct) % do the normal thing
          % score the response as correct or wrong */
          if correct
              num_correct=num_correct+1;
          else
              num_wrong=num_wrong+1;
          end
          
          % also keep track of levels visited: perhaps better
          if ((change-0.001) <= MIN_change_dB) % allow for rounding error
              % we're in the final stretch
              num_final_trials = num_final_trials + 1;
              final_trials(num_final_trials) = SNR_dB;
          end
      end
      
end % end of Levitt 'while' loop

% test for quitting
if strcmp(Cresp,'quit')
    break
end

% decide in which direction to change levels
if (num_correct == LEVITTS_CONSTANT(levitts_index))
    current_change = -1;
    
else
    current_change = 1;
end

% are we at a turnaround? (defined here as any change in direction) If so, do a few things
if (previous_change ~= current_change)
    % move to next value of Levitt's constant if not already done
    if (levitts_index==1)
        levitts_index=2;
    end
    % reduce step proportion if not minimum */
    if ((change-0.001) > MIN_change_dB) % allow for rounding error
        change = change-inc;
    else % final turnarounds, so start keeping a tally
        num_turns = num_turns + 1;
        reversals(num_turns)=SNR_dB;
        fout = fopen(OutFile, 'at');fprintf(fout,',*');fclose(fout);
    end
    % reset change indicator
    previous_change = current_change;
end


       % if still on initial descent, change rules if SNR too low & change step size
       if (levitts_index==1 && SNR_dB<=InitialDescentMinimum)
           levitts_index=2;
           % change = change-inc;
       end

       % ensure that the current stimulus level is within the possible range
       % keep track of hitting the endpoints
       if (SNR_dB > MAX_SNR_dB)
          SNR_dB = MAX_SNR_dB;
            limit = limit+1;
       end
end  % end of a single run */

EndTime=fix(clock);
EndTimeString=sprintf('%02d:%02d:%02d',EndTime(4),EndTime(5),EndTime(6));
fout = fopen(SummaryOutFile, 'at');
%                  1      2        3        4                 5    6    7     8      9    10           11
fprintf(fout, 'listener,CondCode,TestType,MultipleMaskerType,warn, date,start,end,version,responses,feedback');
%                 12     13        14      15     16       17      18      19  20  21   22     23    24      25    26     27    28     29    30     31
fprintf(fout, ',targets,InQuiet,masker,masker2,CatchTrials,ear,FixedSound,rms,HRTF,T_az,M_az,Levitt,nTrials,finish,uRevs,sdRevs,nRevs,uLevs,sdLevs,nLevs\n');
fprintf(fout, '%s,%s,%s,%s,%d,%s,%s,%s,%4.1f,%s,', ...
          ListenerName,CondCode,TestType,MultipleMaskerType,WarningNoise,StartDate,StartTimeString,EndTimeString,VERSION,ResponseChoices);
if max(size(MultipleMaskerFiles))>1
    MaskerFile2=char(MultipleMaskerFiles(2));
else
    MaskerFile2='';
end
fprintf(fout, '%s,%s,%d,%s,%s,%d,%s,%s,%g,%s,%g,%g,%d,%d,', ...
          FeedBack,TargetsFile,PresentInQuiet,MaskerFile,MaskerFile2,CatchTrials,Ear,FixedSound,OutRMS,HRTF,TargetAz,MaskerAz,LevittsK,trial);

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
set(0,'ShowHiddenHandles','on');
delete(findobj('Type','figure'));
release(audioWriter);
FinishButton; % indicate test is over
