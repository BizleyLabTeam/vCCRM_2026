function [sig, Fs, SigAlone, NoiseAlone] = add_distractor(SignalWavFileName, NoiseWavFileName, ...
                        snr, fixed, in_rms, out_rms, HRIRmatFile, Azimuths)
%
%	function [sig, Fs] = add_distractor(SignalWavFileName, NoiseWavFileName, snr, fixed, in_rms, out_rms)
%   [sig, Fs] = add_distractor('p8', 'b5', 0, 'noise', 0, 0.06); sound(sig, Fs)
%
% 	Combine a noise and signal waveform at an arbitrary signal-to-noise ratio
%   Return the wave and the sampling frequency of the WAV files
%	The level of the signal or noise can be fixed, and the output level can be normalised
%	
%
%	SignalWav - the name of a .wav file containing the signal or target
%	NoiseWav - the name of a .wav file containing the noise
%   TestType - 'FixedMasker' or 'VariableMasker'
%	snr - signal-to-noise ratio at which to combine the waveforms
%   fixed - 'noise' or 'signal' to be fixed in level at level specified by in_rms
%   in_rms - if 0, level of signal or noise left unchanged
%	out_rms - rms output of final combined wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to
%		be in the range +/- 1)

% Version 1.0 modified from add_noise.m (December 2001) Dominique
% modified for CCRM testing in Jude's project, essentially properties
% appropriate for TestType of 'VariableMasker'
% January 2006
%
% Version 7.1 -- implement SHaPSMAR measurements for HD-25s
%
% Version 7.5 -- return signal and distractor alone
%
% Stuart Rosen stuart@phon.ucl.ac.uk

%% initialisation for binaural signals
BinauralSignals=0;
if nargin==8 && ~strcmp(HRIRmatFile,'none')
    BinauralSignals=1;
end

%% get signal/target and masker/distractor and their properties
[sig, Fs] = audioread(SignalWavFileName);
% check if stereo -- if so, fail!
StereoTarget=0;
n=size(sig);
if n(2)>1
    %StereoTarget=1;
    sig = 0.5*sum(sig, 2);
    warning('Implementation not yet complete for target signals with 2 channels, mixing to mono!');
end

[nz, Fn] = audioread(NoiseWavFileName);
StereoMasker=0;
n=size(nz);
if n(2)>1
    StereoMasker=1;
    error('Implementation not yet complete for masker signals with 2 channels!');
end

if StereoTarget~=StereoMasker
    error('Both target and masker must be consistently mono or stereo.');
end

if Fs~=Fn,
   error('The sampling rate of the noise and signal waveforms must be equal.');
end

% Calculate the rms levels of the signal and noise
rms_sig = norm(sig)/sqrt(length(sig));
rms_noise = norm(nz)/sqrt(length(nz));

nz_samples=length(nz);
n_samples=length(sig);

%% pad out the shorter of the waves to be equal in duration to the longer
if nz_samples>n_samples
    pad = (nz_samples-n_samples)/2;
    sig = [zeros(1,floor(pad)),sig',zeros(1,ceil(pad))]';
else
    pad = (n_samples-nz_samples)/2;
    nz = [zeros(1,floor(pad)),nz',zeros(1,ceil(pad))]';
end

%% keep a spare copy of signal and noise/distractor
SigAlone = sig;
NoiseAlone=nz;

%% add together the signal and noise in the appropriate ratio
% calculate the multiplicative factor for the signal-to-noise ratio
snr = 10^(snr/20);
if strcmp(fixed, 'signal') % fix the signal level and scale the noise
   error('Fixed signal not yet fully implemented!!');
   if in_rms>0 % scale the signal to the desired level, then scale the level of the noise and add it in to the signal

   else % leave the signal as is, then scale the level of the noise and add it in to the signal
      sig = sig + noise * (rms_sig/(snr * rms_noise));
   end
elseif strcmp(fixed, 'noise') % fix the noise level and scale the signal
   if in_rms>0 % scale the noise to the desired level, then scale the level of the signal and add it to the noise
      sig = (nz * in_rms/rms_noise) + sig * (snr*in_rms)/rms_sig;
      SigAlone = SigAlone * (snr*in_rms)/rms_sig;
      NoiseAlone = NoiseAlone * in_rms/rms_noise;
   else % leave the noise as is, then scale the level of the signal and add it to the noise
      sig = nz + sig * (snr*rms_noise)/rms_sig;
      SigAlone = SigAlone * (snr*rms_noise)/rms_sig;
   end
else
   error('Fixed wave must be signal or noise.');
end

% Test option
% sig = noise * (rms_sig/(snr * rms_noise));

%% exact binaural processing to simulate position change
if BinauralSignals
    % The source was moved in the horizontal plane clockwise around the head.
    % The vertical-polar azimuth goes from 0 deg in steps of 5 deg to 355 deg, i.e.,
    % 0, 5, 10, ... , 355.
    % 0 is in front, 90 at the right ear, 270 at the left, and 355 just left of centre
    %
    % need to upsample all stimuli as HRIRs are at 44.1 kHz
    if Fs~=22050
        error('Binaural implementation only available for sampling frequencies of 22.05 kHz');
    end
    % load IRs for horizontal place
    if strcmp(HRIRmatFile,'SHaPSMAR')
        HRIRmatFile='SHaPSMAR_HD25_06JUNE2009.mat';
    end
    load(HRIRmatFile);
    % define necessary indexing vectors
    azimuths = [-90:45:90];
    HRIRindex = [1:length(azimuths)];
    % do the filtering
    azI = interp1(azimuths,HRIRindex, Azimuths(1), 'nearest');
    wL=filter(left(:,azI),1,SigAlone);
    wR=filter(right(:,azI),1,SigAlone);
    SigAlone=[wL, wR];
    azI = interp1(azimuths,HRIRindex, Azimuths(2), 'nearest');
    wL=filter(left(:,azI),1,NoiseAlone);
    wR=filter(right(:,azI),1,NoiseAlone);
    NoiseAlone=[wL, wR];
    % add together signal + noise
    sig=SigAlone+NoiseAlone;
end

%% see if entire output waveform should be scaled to a particular rms
if (out_rms>0)
   % Calculate rms level of combined signal+noise
   rms_total = max(rms(sig));
   % Scale total to obtain desired rms
   sig = sig * out_rms/rms_total;
   SigAlone = SigAlone * out_rms/rms_total;
   NoiseAlone = NoiseAlone * out_rms/rms_total;
end

%% do something if clipping occurs
[sig, correction] = no_clip(sig);
% correct signal alone for clipping too!
SigAlone = SigAlone * 10^(-correction/20);
NoiseAlone = NoiseAlone * 10^(-correction/20);

if correction<-15 % allow a maximum of 15 dB attenuation
   error('Output signal attenuated by too much.');
end



