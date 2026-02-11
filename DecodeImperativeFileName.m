function imperative = DecodeImperativeFileName(FileName)
%
% decode a file name into its component parts
% Vs for noun task - also return talker (directory name) and decode gender

[pathstr, name, ext] = fileparts(FileName);

[imperative.talker, rem] = strtok(name,'_');
[imperative.animal, rem] = strtok(rem,'_');
[imperative.colour, rem] = strtok(rem,'_');
[imperative.noun, rem] = strtok(rem,'-');% hack due to the -s files
imperative.fileName = FileName;
% hardcode gender
if strcmp(imperative.talker,'spkDS') | strcmp(imperative.talker,'spkLG')
    imperative.gender = 1;
elseif strcmp(imperative.talker,'spkGM') | strcmp(imperative.talker,'spkBT')
    imperative.gender = 2;
else
    warning('Talker initials unrecognised, gender not assigned');
end
%
% spkDS = F
% spkGM = M
% spkLG = F
% spkBT = M
