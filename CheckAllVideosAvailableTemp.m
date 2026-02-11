function [wavList,isFine] = CheckAllVideosAvailableTemp(wavList, wavType)

vList = [];
for ii = 1:length(wavList)
    if strfind(wavList{ii},'sentences')
        vList{ii} = fullfile('temp', [wavList{ii}(11:end-4) '-s.mp4']);
    else
        vList{ii} = fullfile('temp', [wavList{ii}(9:end-4) '-s.mp4']);
    end
end
isFine = [];
for i=1:length(vList)
    if ~exist(char(vList(i)), 'file')
        disp(['Video does not exist: ' char(vList(i))]);
    else
        isFine = [isFine,i];
    end
end
if length(isFine)<length(wavList)
    warning('Removing missing videos from file list')
else
    disp('All videos located')
end
wavList = wavList(isFine);
