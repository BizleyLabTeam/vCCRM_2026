function [sig, Fs, SigAlone, NoiseAlone] = ...
    add_2_distractors(SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2, ...
                    snr, fixed, in_rms, out_rms)
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
% SigAlone & NoiseAlone returned as separate waves: November 2010
%
% Stuart Rosen stuart@phon.ucl.ac.uk

[sig, Fs] = audioread(SignalWavFileName);
[nz1, Fn1] = audioread(NoiseWavFileName1);
[nz2, Fn2] = audioread(NoiseWavFileName2);

n=size(sig);
if n(2)>1
    sig = 0.5*sum(sig, 2);
 %   warning('Implementation not yet complete for target signals with 2 channels, mixing to mono!');
end

if Fs~=Fn1 || Fs~=Fn2 || Fn2~=Fn1
   fprintf('Concerning files: %s  %s  %s\n', SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2);
   error('The sampling rate of the noise and signal waveforms must be equal.');
end

%% First -- add together the two noise waveforms
nz1_samples=length(nz1);
nz2_samples=length(nz2);
% calculate rms levels before any possible padding
rms_noise1 = rms(nz1);
rms_noise2 = rms(nz2);
% pad out the shorter of the two noise waves to be equal in duration to the longer
if nz1_samples>nz2_samples
    pad = (nz1_samples-nz2_samples)/2;
    nz2 = [zeros(1,floor(pad)),nz2',zeros(1,ceil(pad))]';
else
    pad = (nz2_samples-nz1_samples)/2;
    nz1 = [zeros(1,floor(pad)),nz1',zeros(1,ceil(pad))]';
end
% add the two noises together after scaling for equal rms
nz=nz1/rms_noise1 + nz2/rms_noise2;

%% now the standard procedure can take place
% Calculate the rms levels of the signal and noises
rms_sig = norm(sig)/sqrt(length(sig));
rms_noise = norm(nz)/sqrt(length(nz));

n_samples=length(sig);
nz_samples=length(nz);

% pad out the shorter of the waves to be equal in duration to the longer
if nz_samples>n_samples
    pad = (nz_samples-n_samples)/2;
    sig = [zeros(1,floor(pad)),sig',zeros(1,ceil(pad))]';
else
    pad = (n_samples-nz_samples)/2;
    nz = [zeros(1,floor(pad)),nz',zeros(1,ceil(pad))]';
end


%% keep a spare copy of signal and noise
SigAlone = sig;
% extra copy of noise
NoiseAlone=nz;

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

% See if entire output waveform should be scaled to a particular rms
if (out_rms>0)
   % Calculate rms level of combined signal+noise
   rms_total = norm(sig)/sqrt(length(sig));
   % Scale total to obtain desired rms
   sig = sig * out_rms/rms_total;
end

% do something if clipping occurs
[sig, correction] = no_clip(sig);
if correction<-15 % allow a maximum of 15 dB attenuation
   error('Output signal attenuated by too much.');
end



