function [OutWave, correction] = no_clip(InWave)
%
%	no_clip - correct for any possible sample overloads
%
%	[OutWave, correction] = no_clip(InWave, message)
%
%  correction = dB correction applied

% double max allows for stereo waves
max_sample =  max(max(abs(InWave)));
if max_sample > 0.999	% ---- !! OVERLOAD !! -----
	% figure out degree of attenuation necessary
	ratio = 0.999/max_sample;
	OutWave = InWave * ratio;
   correction=20*log10(ratio);
	fprintf('!! WARNING -- OVERLOAD !! File scaled by %f = %f dB\n', ratio, correction);
else
   correction = 0;
   OutWave = InWave;
end
