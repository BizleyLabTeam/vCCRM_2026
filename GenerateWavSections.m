function [nSections, wavSections]=GenerateWavSections(MaskerFile, MaxDurTargetSamples)

[nz, Fn] = audioread(MaskerFile);
nz_samples=length(nz);

% choose a random starting point within the first section of the masker
starts = floor((MaxDurTargetSamples)*rand);

% This appears to be playing extremely safe by restricting noise segments
% to be roughly twice as long as they need to be (but not accounting for
% rises and falls, etc. warning_noise_duration is accounted for.
while (starts(end)+2*MaxDurTargetSamples)<nz_samples
    starts = [starts starts(end)+MaxDurTargetSamples];
end

nSections=length(starts);
wavSections=starts(randperm(nSections));

