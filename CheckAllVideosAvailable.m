function [wavList,isFine] = CheckAllVideosAvailable(wavList, Video)

vList = [];
for ii = 1:length(wavList)
    if Video == 2
        if strfind(wavList{ii},'sentences')
            vList{ii} = fullfile('video','Freeze', [wavList{ii}(11:end-4) '.mp4']);
        else
            vList{ii} = fullfile('video','Freeze', [wavList{ii}(1:end-4) '.mp4']);
        end
    
    elseif Video == 3
         if strfind(wavList{ii},'sentences')
            vList{ii} = fullfile('video','Disk', [wavList{ii}(11:end-4) '.mp4']);
        else
            vList{ii} = fullfile('video','Disk', [wavList{ii}(1:end-4) '.mp4']);
         end
    else
        if strfind(wavList{ii},'sentences')
            vList{ii} = fullfile('video','Full', [wavList{ii}(11:end-4) '.mp4']);
        else
            vList{ii} = fullfile('video','Full', [wavList{ii}(1:end-4) '.mp4']);
        end
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
    warning('Removing missing videos from file list. You should expect about 25 missing videos for the interupted condition, and 4 for the others. More than this should worry you!')
else
    disp('All videos located')
end
wavList = wavList(isFine);
