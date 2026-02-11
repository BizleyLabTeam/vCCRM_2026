function [targets, maskers, starts, initials, finals, max_trials, catch_trials, warns, fRevs]=ReadConditions()
%% read in the list of masker conditions and associated parameters,
%% and return appropriate values from the file
%% Also get (separate) list of target conditions
TargetLists=robustcsvread('TargetsList.csv');
nTargets=size(TargetLists,1);
targets=cell(nTargets-1,1);
for c=2:nTargets
    targets{c-1}=TargetLists{c,1};
end

conditions=robustcsvread('MaskerConditionsList.csv');
nConditions=size(conditions,1);
maskers=cell(nConditions-1,1);
starts=[]; initials=[]; finals=[]; max_trials=[]; catch_trials=[];
warns=[]; fRevs = [];
for c=2:nConditions
    maskers{c-1}=conditions{c,1};
    starts=[starts str2double(conditions{c,2})];
    initials=[initials str2double(conditions{c,3})];
    finals=[finals str2double(conditions{c,4})];
    max_trials=[max_trials str2double(conditions{c,5})];
    catch_trials=[catch_trials str2double(conditions{c,6})];
    warns=[warns str2double(conditions{c,7})];
    fRevs=[fRevs str2double(conditions{c,8})];
end

