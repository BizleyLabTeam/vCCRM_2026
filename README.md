If you use this code, please cite Alamounti et al., 2026, Trends in Hearing.



vCCRM\_nouns

vCCRM modified from Stuart Rosen's CCRM

% this code is adapted from Stuart Rosen's v16.0 CCRM code; many of the options
% available have been removed to streamline the code. Anything elegant in this code
% likely originated from Stuart's.



% vCCRMn uses colour-noun with optional video elements.
% (retro) added in 2025; the ability to have synthetic visual stimuli, the ability
% to have speech shaped noise (or other arbritrary noise) instead of
% competing maskers. J Bizley 08.01.25



% useful inputs:
% "Type" \[options: 'pretest', 'demo' or 'test']

e.g. vCCRMn('pretest')

vCCRMn('demo')





Otherwise to run the main test, with a target talker and two competing maskers (as Alampounti et al) you need a participant ID (letter/number string) and to specify the 'video' option

here 0 = still frame, 1 = full video, 2 = interrupted, 3 = disk (not available yet on git!) 



vCCRMn('AV2026pID','video',0)

vCCRMn('AV2026pID','video',1)

vCCRMn('AV2026pID','video',2)



In each case this will run two tracks in parallel; one with a video that matches the target and one that is masker coherent. Two thresholds are returned at the end (TC, then MC). 



The program generates two spreadsheets - a summary \*that will be wrong for conditions with two tracks\* and the main data file. You should use the main data file for subsequent analysis!



There is also the option to run with speech shaped noise and a match-target video condition : 

vCCRMn('AV2026pID','TestType','SSN','video',0)



Other options : 

% "Tracks" \[1 presents only a single target coherent track, default is two
% simultaneous tracks, one target and one masker coherent videos]
% "TestType" \[options: 'MultiTalker', 'babble', 'SSN']
% "LevittsK" (determines the staircase rule, default 1U1D)
% many other options are defined in vCCRMnparseArgs



This code may not work for you straight out the box!

