 
% load('nounMaskers.mat')
% current masker formant: M{1} = 'sentences/spkBT/spkBT_cat_black_bed.wav'

% load('nounTargets.mat')
% T{1} 'spkBT/spkBT_dog_black_bed.wav'

% total maskers = 1816, total targets = 364

% target/masker lists have been edited to ensure that there is overlap
% between the colour and noun targets and the masker sentences.

load('D:\MATLAB_folders\outputBTtargets.mat')
T = [];
ind = 1;

load('D:\MATLAB_folders\outputDStargets.mat')
load('D:\MATLAB_folders\outputGMtargets.mat')
load('D:\MATLAB_folders\outputLGtargets.mat')

for ii = 1: length(d)
    if d(ii).result == 1
        T{ind} = ['spkLG/' d(ii).name];
        ind = ind+1;
    end
end

M = [];
ind  = 1;


load('D:\MATLAB_folders\outputBTmaskers.mat')

load('D:\MATLAB_folders\outputDSmaskers.mat')
load('D:\MATLAB_folders\outputGMmaskers.mat')
load('D:\MATLAB_folders\outputLGmaskers.mat')

for ii = 1: length(d)
    if d(ii).result == 1
        T{ind} = ['sentences/spkLG/' d(ii).name];
        ind = ind+1;
    end
end

% M is 1168


