NoiseWav='1kHz.wav';
NoiseWav='SpchNz.wav';
NoiseRMS=.03;

SoundMasterLevel=46535;
SoundWaveLevel=65535;


objSC= actxserver('SoundControl.General');
invoke(objSC,'SetMasterLevel',SoundMasterLevel);
invoke(objSC,'SetWaveLevel',SoundWaveLevel);

invoke(objSC,'SetMasterLevel',40535);
invoke(objSC,'SetWaveLevel',65535);

RISE_FALL = 0;
[nz, Fn] = audioread(NoiseWav);
noise=taper(nz, RISE_FALL, RISE_FALL, Fn);
rms_noise = norm(noise)/sqrt(length(noise));
noise = (noise * NoiseRMS/rms_noise);
% noise=[ zeros(1,length(noise))' noise]; % right ear only
for i=1:1
    playerCCRM = audioplayer(noise,Fn);
    playblocking(playerCCRM);
    % wavplay(noise,Fn,'sync');
    % pause(1);
end
