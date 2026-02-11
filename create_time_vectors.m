% load nounMaskers
M{ind}  is the filename
we have two points, in samples

Let's create a new directory that matches "M" and has one time per entry

load nounTargets;
load nounMaskers;
load('/Users/bizleyjk/Downloads/spkLG/outputLGtargets_with_points.mat')
d = d_with_shifts_and_points;

d = d_with_points;
for ii = 1:length(d)
    found = 0;
    file = d(ii).name(1:end-4);
    if strfind(file,'dog')
        for ll = 1:length(T)
            if strfind(T{ll},file)
                % this is the right one
                disp('File located');
                targetTimes{ll} = d(ii).targetPoints;
                found = 1;
            end
        end
    else
        for jj = 1:length(M)
            if strfind(M{jj},file)
                % this is the right one
                disp('File located');
                maskerTimes{jj} = d(ii).targetPoints;
                found = 1;
            end
        end
    end
    if found == 0
        disp('Failed to find this file')
    end
end

% points are in audiosamples: should be in frames!


%% second attempt
targetTimes = [];
d=[];
load('/Users/bizleyjk/Downloads/spkLG/outputLGtargets_with_points.mat')
d = d_with_points;
load('/Users/bizleyjk/Downloads/outputDStargets_with_points.mat')
d = [d;d_with_points];
load('/Users/bizleyjk/Downloads/outputGMtargets_with_points.mat')
d = [d;d_with_points];
load('/Users/bizleyjk/Downloads/outputBTtargets_with_points.mat')
d = [d;d_with_points];
load nounTargets;

targetTimes=[];
for ii = 1:length(T)
    for jj = 1:length(d)
        if strfind(T{ii},d(jj).name)
            targetTimes{ii,1} = d(jj).targetPoints;
            break
        end
    end
end

load('/Users/bizleyjk/Downloads/outputLGmaskers_with_shifts_and_points.mat')
d=d_with_shifts_and_points;
load('/Users/bizleyjk/Downloads/outputDSmaskers_with_shifts_and_points.mat')
d=[d;d_with_shifts_and_points];
load('/Users/bizleyjk/Downloads/outputGMmaskers_with_shifts_and_points.mat')
d=[d;d_with_shifts_and_points];
load('/Users/bizleyjk/Downloads/outputBTmaskers_with_shifts_and_points.mat')
d=[d;d_with_shifts_and_points];

maskerTimes = [];
load nounMaskers;
for ii = 1:length(M)
    for jj = 1:length(d)
        if strfind(M{ii},d(jj).name)
            if isempty(d(jj).shift)
                maskerTimes{ii} = d(jj).targetPoints;
            else
                maskerTimes{ii} = d(jj).targetPoints-(d(jj).shift*44100);
            end
            break
        end
    end
end
