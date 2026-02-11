cd('/Users/bizleyjk/lib/vCCRM_nouns/sentences/spkGM')
d = dir('*dog*'); % for targets
%d= dir('*.wav'); %for maskers

w = audioread(d(1).name);
allsound = abs(w);
for ii = 2:length(d)
    % uncomment this if maskers
    % if isempty(strfind(d(ii).name,'dog'))
    w = audioread(d(ii).name);
    plot(w)
    hold on;
    yy = ylim;
    xx = xlim;
    plot([128000,128000],yy,'k:')
    %allsound = allsound + abs(w);
    d(ii).result = input('1 for happy; 2 for not; 3 for flag for review later');
    clf
end

%allsoundGM = allsound;

% change 'output here to something sensible like 'outputGMdog'
save output d
% to print out a list of files to be excluded:
for ii = 1:length(d)
    if d(ii).result == 2
        disp(sprintf('%s',d(ii).name))
    end
end


d = dir('*.wav'); %for maskers

%for maskers
%ind = [];
for ii = 1:length(d)
    
    if isempty(strfind(d(ii).name,'dog'))
        w = audioread(d(ii).name);
        if max(find(abs(w(:,1))>0.001)) < 120000
            % ind = [ind;ii, max(find(abs(w(:,1))>0.001))];
            d(ii).result = 2;
        else
            d(ii).result = 1;
        end
    else
        d(ii).result = nan;
    end
end

% print out files to be excluded:
for ii = 1:length(d)
    if d(ii).result == 2
        disp(sprintf('%s',d(ii).name))
    end
end


d = dir('*.wav'); %for maskers
ind = [];

%for maskers
%ind = [];
for ii = 1:length(d)
    
    if isempty(strfind(d(ii).name,'dog'))
        w = audioread(d(ii).name);
        if max(find(abs(w(:,1))>0.001)) < 120000
            d(ii).result = 2;
            ind = [ind;ii, max(find(abs(w(:,1))>0.001))];
            
        else
            d(ii).result = 1;
        end
    end
end
save maskerresults d
disp(['There were ' num2str(length(ind)) ' files that were judged too short, out of a total of ' num2str(length(d)) ' files.'])


%% rescuing maskers that failed earlier quality controls by shifting

load('filenameForMaskerOutput');
%% code for shifting the timing of the maskers that are classified as "too early"
for ii = 1:length(d)
    if isempty(strfind(d(ii).name,'dog')) && d(ii).result == 2 % previously flagged as problematic:
        w = audioread(d(ii).name);
        clf;
        plot(w)
        hold on;
        yy = ylim;
        xx = xlim;
        plot([128000,128000],yy,'k:')
        shift = 0.1;
        plot(circshift(w,round(shift*fs),1));
        i = input('happy(1) with this shift or add more?');
        while isempty(i)
            shift = shift + 0.1;
            plot(circshift(w,round(shift*fs),1));
            i = input('happy(1) with this shift or add more?');
        end
        d(ii).shift = shift;
    end
end
save SOMETHINGSENSIBLE d ii 
    %% optional code to extract the target and noun
%     % now extract the timepoints of the target and the noun
%     w = audioread(d(ii).name);
%     if isfield(d,'shift') && ~isempty(d(ii).shift)
%         w = circshift(w,round(d(ii).shift*fs),1);
%     end
%     clf;
%     plot(w);hold on;
%     g = ginput(2);
%     p = round(g(:,1));
%     soundsc(w([1:p(1),p(2):end],1),fs);
%     i = input('happy(1) or reselect points?');
%     while isempty(i)
%         plot(p(1):p(2),w(p(1):p(2)))
%         g = ginput(2);
%         p = round(g(:,1));
%         soundsc(w([1:p(1),p(2):end],1),fs);
%         i = input('happy(1) or reselect points?');
%     end
%     d(ii).targetPoints = p;
%     save movieData d ii
end


%%  set up your data structures
d = dir('*wav'); %do this once
ii = 0;
save movieDataForStreamingStimulus d ii

%%
load movieDataForStreamingStimulus
% if you want to only do the target sentences
for ii = ii+1:length(d)
    if ~isempty(strfind(d(ii).name,'dog')) % comment this if you want to do target and maskers
        
        % now extract the timepoints of the target and the noun
        w = audioread(d(ii).name);
        if isfield(d,'shift') && ~isempty(d(ii).shift)
            w = circshift(w,round(d(ii).shift*fs),1);
        end
        clf;
        plot(w);hold on;
        g = ginput(2);
        p = round(g(:,1));
        soundsc(w([1:p(1),p(2):end],1),fs);
        i = input('happy(1) or reselect points?');
        while isempty(i)
            plot(p(1):p(2),w(p(1):p(2)))
            g = ginput(2);
            p = round(g(:,1));
            soundsc(w([1:p(1),p(2):end],1),fs);
            i = input('happy(1) or reselect points?');
        end
        d(ii).targetPoints = p;
        save movieDataForStreamingStimulus d ii
    end
end


