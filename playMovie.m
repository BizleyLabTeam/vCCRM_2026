function done = playMovie(videoReader,videoPlayer,audioWriter,audio,fs,Video);

%JKB '22 remPoints should be in frames

done =[];
videoReader.CurrentTime = 0;
pause(0.5);
% calculate audio and video frame parameters.
if Video ~= 0
    vFrames = floor(videoReader.Duration * videoReader.FrameRate - 0.1);
    
    aFrames = floor((size(audio, 1)/fs)*videoReader.FrameRate);
    if vFrames > aFrames
        % video longer than audio
        nFrames = vFrames;
        vStart = 1;
        aStart = vFrames - aFrames + 1;
    else
        % audio longer than or equal length to video
        nFrames = aFrames;
        vStart = 1;%aFrames - vFrames + 1;%this will offset to sound leading
        aStart = 1;
    end
    
else
    vFrames = 0;    % NoVideo set, display still image
    aFrames = floor(size(audio, 1)/512);
    nFrames = aFrames;
    vStart = 1;
    aStart = 1;
end

    % play the content from start to finish
    vStop = vStart + vFrames;
    aStop = aStart + aFrames;
    frame = 1;
    position = 1;
    frameLen = size(audio, 1)/aFrames;
    while frame <= nFrames
        if frame >= aStart && frame < aStop
            index = round(position);
            position = position + frameLen;
            audioWriter(audio(index:round(position) - 1, :));
        end
        if frame >= vStart && frame < vStop
            videoPlayer(readFrame(videoReader));
        end
        frame = frame + 1;
    end

    % release the video player window
    release(videoPlayer);
    done = 1;
