% runCCRMseq(ListenerName, OrderFile)
ListenerName='SR';
OrderFile='MySeqList.csv';
runCCRMseq(ListenerName, OrderFile)
return

% function CCRMrun(TargetsFile, MaskerFile,starting_SNR,START_change_dB,MIN_change_dB)

% in speech-shaped noise
% function CCRMrun(TargetsFile, MaskerFile,     starting_SNR, START_change_dB,MIN_change_dB)
CCRMrun('S1DogNo7.txt', 'SpchNz.wav',20,10,2)

% against another talker
% function CCRMrun(TargetsFile, MaskerFile,     starting_SNR, START_change_dB,MIN_change_dB)
        CCRMrun('S1DogNo7.txt','S4NoDogNo7.txt',    20,           10,            4)

% in speech-modulated speech-shaped noise
% function CCRMrun(TargetsFile, MaskerFile,     starting_SNR, START_change_dB,MIN_change_dB)
        CCRMrun('S1DogNo7.txt','S4_1ch_NoDogNo7.txt',    20,           10,            5)

% in babble
% CCRMrun('S1DogNo7.txt', 'IHRbabble.wav',20,10,5,3)



