function [wavList,isFine] = CheckAllWavsAvailable(wavList, wavType)

isFine = [];
for i=1:length(wavList)
    if ~exist(char(wavList(i)), 'file')
        disp(['Audio file does not exist: ' char(wavList(i))]);
    else
        isFine = [isFine,i];
    end
end
wavList = wavList(isFine);

