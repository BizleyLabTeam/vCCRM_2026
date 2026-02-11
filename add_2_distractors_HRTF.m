function [sig, Fs, SigAlone, nz1Alone,  nz2Alone] = ...
    add_2_distractors_HRTF(SignalWavFileName, NoiseWavFileName1, NoiseWavFileName2, ...
    snr, fixed, in_rms, out_rms,  HRIRmatFile, Azimuths)
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
% This c ode is not currently used in teh vCCRM
% SigAlone & NoiseAlone returned as separate waves: November 2010
%
% Implement spatialisation -- 9 September 2014
%
% Stuart Rosen stuart@phon.ucl.ac.uk

%% checks for binaural signals
if isempty(HRIRmatFile) || strcmp(HRIRmatFile,'none') || (length(Azimuths)~=3)
    error('Need HRIR file specified and/or azimuths for spatialisation');
end

[sig, Fs] = audioread(SignalWavFileName);
[nz1, Fn1] = audioread(NoiseWavFileName1);
[nz2, Fn2] = audioread(NoiseWavFileName2);

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
    nz2 = [nz2', zeros(1,nz1_samples-nz2_samples)]';
else
    nz1 = [nz1', zeros(1,nz2_samples-nz1_samples)]';
end
% add the two noises together after scaling for equal rms
nz=nz1/rms_noise1 + nz2/rms_noise2;
% but also save away the two noises separately
nz1Alone=nz1/rms_noise1;
nz2Alone=nz2/rms_noise2;

%% now the standard procedure can take place
% Calculate the rms levels of the signal and noises
rms_sig = norm(sig)/sqrt(length(sig));
rms_noise = norm(nz)/sqrt(length(nz));

n_samples=length(sig);
nz_samples=length(nz);

% pad out the shorter of the waves to be equal in duration to the longer
if nz_samples>n_samples
    sig = [sig', zeros(1,nz_samples-n_samples)]';
else
    nz = [nz', zeros(1,n_samples-nz_samples)]';
    % and the individual noises too, if necessary
    nz1Alone = [nz1Alone', zeros(1,n_samples-nz_samples)]';
    nz2Alone = [nz2Alone', zeros(1,n_samples-nz_samples)]';
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
        nz1Alone = nz1Alone * in_rms/rms_noise;
        nz2Alone = nz2Alone * in_rms/rms_noise;
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
    % and scale all the constituent waves
    SigAlone = SigAlone * out_rms/rms_total;
    nz1Alone = nz1Alone *  out_rms/rms_total;
    nz2Alone = nz2Alone *  out_rms/rms_total;
end

%% Now do the spatialisation!
% The source was moved in the horizontal plane clockwise around the head.
% The vertical-polar azimuth goes from 0 deg in steps of 5 deg to 355 deg, i.e.,
% 0, 5, 10, ... , 355.
% 0 is in front, 90 at the right ear, 270 at the left, and 355 just left of centre
%
% need to upsample all stimuli as HRIRs are at 44.1 kHz (This can't be right!)
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
%% do the filtering
% target
azI = interp1(azimuths,HRIRindex, Azimuths(1), 'nearest');
wL=filter(left(:,azI),1,SigAlone);
wR=filter(right(:,azI),1,SigAlone);
SigAlone=[wL, wR];
% noise 1
azI = interp1(azimuths,HRIRindex, Azimuths(2), 'nearest');
wL=filter(left(:,azI),1,nz1Alone);
wR=filter(right(:,azI),1,nz1Alone);
nz1Alone=[wL, wR];
% noise 2
azI = interp1(azimuths,HRIRindex, Azimuths(3), 'nearest');
wL=filter(left(:,azI),1,nz2Alone);
wR=filter(right(:,azI),1,nz2Alone);
nz2Alone=[wL, wR];
% add together signal + noise
sig=SigAlone+nz1Alone+nz2Alone;

%% do something if clipping occurs
[sig, correction] = no_clip(sig);
% correct signal alone for clipping too!
SigAlone = SigAlone * 10^(-correction/20);
nz1Alone = nz1Alone * 10^(-correction/20);
nz2Alone = nz2Alone * 10^(-correction/20);

if correction<-15 % allow a maximum of 15 dB attenuation
   error('Output signal attenuated by too much.');
end


