% import file names
p = 'sentences';
d = dir('*/*.wav');
ind = 1; clear M;
for ii=1:length(d)
if d(ii).name(1)=='s' & isempty(strfind(d(ii).name,'dog'))
M{ind}=fullfile(p,d(ii).folder(end-4:end),d(ii).name);
ind = ind+1;
end
end

cell2csv('nounMaskers.csv',M');
save nounMaskers M
p = 'video';
d = dir('*/*.wav');
ind = 1; clear T;
for ii=1:length(d)
    if d(ii).name(1)=='s' & ~isempty(strfind(d(ii).name,'dog'))
        T{ind}=fullfile(d(ii).folder(end-4:end),d(ii).name);
        ind = ind+1;
    end
end
save nounTargets T

cell2csv('nounTargets.csv',T');
spkDS = F
spkGM = M
spkLG = F
spkBT = M
