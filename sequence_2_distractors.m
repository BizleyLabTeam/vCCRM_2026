function [sig, Fs, SigAlone, NoiseAlone] = ...
    sequence_2_distractors(SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2, ...
                    snr, fixed, in_rms, out_rms, warning_noise_duration)
%
%   Moddified from add_2_distractors -- October 2010
%
% 	Combine a noise (made up of two waveforms concatenated)
%   and signal waveform at an arbitrary signal-to-noise ratio
%   Return the wave and the sampling frequency of the WAV files
%	The level of the signal or noise can be fixed,
%   and the output level can be normalised
%
%	SignalWav - the name of a .wav file containing the signal or target
%	NoiseWavFileName1 - the name of a .wav file containing noise 1
%	NoiseWavFileName2 - the name of a .wav file containing noise 2
%	snr - signal-to-noise ratio at which to combine the waveforms
%   fixed - 'noise' or 'signal' to be fixed in level at level specified by in_rms
%   in_rms - if 0, level of signal or noise left unchanged
%	out_rms - rms output of final combined wave. Signal unchanged if rms=0
%		(Note! rms values are calculated Matlab style with waveform values assumed to
%		be in the range +/- 1)
%   warning_noise_duration - extra section of noise to serve as precursor to stimulus word (ms)
%
% Stuart Rosen stuart@phon.ucl.ac.uk

if nargin<8
    warning_noise_duration=0;
end

RISE_FALL = 10;     % taper the noise on and off, adding this duration to start and finish of signal
                    % This is in addition to the warning noise duration

[sig, Fs] = audioread(SignalWavFileName);
[nz1, Fn1] = audioread(NoiseWavFileName1);
[nz2, Fn2] = audioread(NoiseWavFileName2);

if Fs~=Fn1 || Fs~=Fn2 || Fn2~=Fn1
   fprintf('Concerning files: %s  %s  %s\n', SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2);
   error('The sampling rate of the noise and signal waveforms must be equal.');
end

%% Construct the concatenated masker
% First -- equalise the two waveforms separately to the rms value
%           of the concatenated waveforms
rmsTotal=rms([nz1;nz2]);
nz1=rmsTotal*nz1/rms(nz1);
nz2=rmsTotal*nz2/rms(nz2);
% concatenate
nz = [nz1;nz2];
nz_samples=length(nz);
% calculate rms levels
rms_noise = rms(nz);
rms_sig = rms(sig);

%%  add extra time for rises and falls, and extra silences
rise_fall = floor(Fs * RISE_FALL/1000); % number of sample points for rise and fall
if RISE_FALL>0 || warning_noise_duration>0
   warning_noise_duration = floor(Fs * warning_noise_duration/1000);
                            % number of sample points for extra noise
   % augment signal with zeros at start and finish zeros(duration-n_samples,size(sig,2))
   sig = [  zeros(rise_fall,size(sig,2)); ...
            zeros(warning_noise_duration,size(sig,2)); ...
            sig; ...
            zeros(rise_fall,size(sig,2))];
end
n_samples=length(sig);

if nz_samples<n_samples
   error('The concatenated noise waveform is not long enough.');
end

%% keep a spare copy of signal
SigAlone = sig;

%% select a random portion of the concatenated masker, of the appropriate length
% allowing for the warning noise duration
start = floor((nz_samples-n_samples)*rand);
% copy the original noise waveform
noise = nz;
% and delete the unwanted samples
noise(1:start-1,:)=[];
noise(n_samples+1:length(noise),:)=[];
% put rises and falls on to the noise/masker
noise=NewTaper(noise, RISE_FALL, RISE_FALL, Fs);
% extra copy of noise
NoiseAlone=noise;

%% now the standard addition of the signal and masker can take place
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
      sig = (noise * in_rms/rms_noise) + sig * (snr*in_rms)/rms_sig;
      SigAlone = SigAlone * (snr*in_rms)/rms_sig;
      NoiseAlone = NoiseAlone * in_rms/rms_noise;
   else % leave the noise as is, then scale the level of the signal and add it to the noise
      sig = noise +   sig * (snr*rms_noise)/rms_sig;
      SigAlone = SigAlone * (snr*rms_noise)/rms_sig;
   end
else
   error('Fixed wave must be signal or noise.');
end

% Test option
% sig = noise * (rms_sig/(snr * rms_noise));

% See if entire output waveform should be scaled to a particular rms
% consider restricting calcualtion of rms to exclude warning noise?
if (out_rms>0)
   % Calculate rms level of combined signal+noise
   rms_total = rms(sig);
   % Scale total to obtain desired rms
   sig = sig * out_rms/rms_total;
end

% do something if clipping occurs
[sig, correction] = no_clip(sig);
if correction<-15 % allow a maximum of 15 dB attenuation
   error('Output signal attenuated by too much.');
end



