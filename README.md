# vCCRM_nouns
 vCCRM modified from Stuart Rosen's CCRM

% this code is adapted from Stuart Rosen's v16.0 CCRM code; many of the options
% available have been removed to streamline the code. Anything elegant in this code 
% likely originated from Stuart's.

% vCCRMn uses colour-noun with optional video elements.
% (retro) added in 2025; the ability to have synthetic visual stimuli, the ability
% to have speech shaped noise (or other arbritrary noise) instead of
% competing maskers. J Bizley 08.01.25

% useful inputs: 
% "Type" [options: 'pretest', 'demo' or 'test']
% "Video" [options: 0 2 3 where 0 is still image 2 is frozen
% during target word presentation 3 is synthetic and 1 or default is full
% movie]
% "Tracks" [1 presents only a single target coherent track, default is two
% simultaneous tracks, one target and one masker coherent videos]
% "TestType" [options: 'MultiTalker', 'babble', 'SSN']
% "LevittsK" (determines the staircase rule, default 1U1D)
% many other options are defined in vCCRMnparseArgs
