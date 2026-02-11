% all wav files need to be shifted and resaved so that they are
% appropriately mixed during the audio generation in vCCRMn.m

% video files either need to be remade or read out reliably in a wrapped
% way

% if shift is not divisible by audio shift
fr = videoReader.FrameRate;
lastFrame = floor(videoReader.duration * fr);

firstFrame = lastFrame - round(shift * fr);
padEnd = lastFrame;
start = 1;
last = firstFrame-1;
imageSeq = [firstFrame : padEnd, start: last];

%shifts are always backwards for distractors in time so take the last shift frames and play
%them first before playing the beginning ones




load('/Users/bizleyjk/Downloads/outputDSmaskers_with_shifts_and_points.mat')
d = d_with_shifts_and_points;
cd temp
cd spkDS



for ss = 1 : 4
    if ss== 1
        cd('spkDS')
        spkdir = cd;
        load('/Users/bizleyjk/Downloads/outputDStargets_with_points.mat')
        d = d_with_points;
    elseif ss==2
        cd('spkLG')
        spkdir = cd;
        load('/Users/bizleyjk/Downloads/outputLGtargets_with_points.mat')
        d = d_with_points;
    elseif ss==3
        cd('spkGM')
        spkdir = cd;
        load('/Users/bizleyjk/Downloads/outputGMtargets_with_points.mat')
        d = d_with_points;
    else
        cd('spkBT');
        spkdir = cd;
        load('/Users/bizleyjk/Downloads/outputBTtargets_with_points.mat')
        d = d_with_points;
    end
    workingDir = 'noLips';

    mkdir(workingDir)
    mkdir(workingDir,'images')
    for jj = 1: length(d)
        % if ~isempty(d(jj).shift)
        try
            vid = VideoReader([d(jj).name(1:end-3) 'mp4']);

            while hasFrame(vid)
                img = readFrame(vid);
                filename = [sprintf('%03d',ii) '.jpg'];
                fullname = fullfile(workingDir,'images',filename);
                imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
                ii = ii+1;
            end

            imageNames = dir(fullfile(workingDir,'images','*.jpg'));
            imageNames = {imageNames.name}';
            outputVideo = VideoWriter(fullfile(workingDir,[d(jj).name(1:end-4)]),'MPEG-4');
            outputVideo.FrameRate = vid.FrameRate;
            open(outputVideo)

            fr = vid.FrameRate;
            lastFrame = length(imageNames);
            %             if ~isempty(d(jj).shift)
            %                 shift = d(jj).shift;
            %                 last = lastFrame - round(shift * fr);
            %                 pad = last+1 : lastFrame;
            %                 start = 1;
            %                 imageSeq = [pad, 1 : last];
            %             else
            imageSeq = 1 : lastFrame;
            %             end

            remPoints = d(jj).targetPoints./44100; % into seconds
            remPoints = remPoints * videoReader.FrameRate;
            p1 = floor(remPoints(1));p2 = ceil(remPoints(2));
            imageSeq(p1:p2) = p1;
            for ii = 1:length(imageNames)
                img = imread(fullfile(workingDir,'images',imageNames{imageSeq(ii)}));
                writeVideo(outputVideo,img)
            end

            close(outputVideo)
            cd (fullfile(workingDir,'images'));
            delete *.jpg
            cd ..
            cd ..
        catch
            d(jj).failed = 1;
        end
        %end
    end
    %save fileInfoNoLips d
    cd ..

end


videoReader = VideoReader('processing/spkDS_cat_black_bed-s.mp4');

vFrames = floor(videoReader.Duration * videoReader.FrameRate - 0.1);

nFrames = vFrames;
vStart = 1;

% play the content from start to finish
vStop = vStart + vFrames;
frame = 1;
position = 1;
while frame <= nFrames

    if frame >= vStart && frame < vStop
        videoPlayer(readFrame(videoReader));
    end
    frame = frame + 1;
end



%% audio
%cd wav
for ss = 1 : 4
    if ss== 1
        cd('C:\Lib\vCCRM_nouns')
        load('outputDSmaskers_with_shifts_and_points.mat')

        cd('C:\Lib\vCCRM_nouns_archive\sentences\spkDS')
        savepath  = 'C:\Lib\vCCRM_nouns\sentences\spkDS\'
        %   load('/Users/bizleyjk/Downloads/outputDSmaskers_with_shifts_and_points.mat')
        d = d_with_shifts;
    elseif ss==2
        cd('C:\Lib\vCCRM_nouns')

        load('outputLGmaskers_with_shifts_and_points.mat')
        cd('C:\Lib\vCCRM_nouns_archive\sentences\spkLG')

        savepath  = 'C:\Lib\vCCRM_nouns\sentences\spkLG\'
        %   load('/Users/bizleyjk/Downloads/outputLGmaskers_with_shifts_and_points.mat')
        d = d_with_shifts_and_points;
    elseif ss==3
        cd('C:\Lib\vCCRM_nouns')

        load('outputGMmaskers_with_shifts_and_points.mat')

        cd('C:\Lib\vCCRM_nouns_archive\sentences\spkGM')
        %  load('/Users/bizleyjk/Downloads/outputGMmaskers_with_shifts_and_points.mat')

        savepath  = 'C:\Lib\vCCRM_nouns\sentences\spkGM\'
        d = d_with_shifts_and_points;
    else
        cd('C:\Lib\vCCRM_nouns')
        load('outputBTmaskers_with_shifts_and_points.mat')
        cd('C:\Lib\vCCRM_nouns_archive\sentences\spkBT');

        savepath  = 'C:\Lib\vCCRM_nouns\sentences\spkBT\'    %   load('/Users/bizleyjk/Downloads/outputBTmaskers_with_shifts_and_points.mat')

        d = d_with_shifts_and_points;
    end

    for jj = 1: length(d)
        if ~isempty(d(jj).shift)

            [w,fs]= audioread(d(jj).name);

            w2 = circshift(w,round(d(jj).shift*fs),1);
            audiowrite([savepath d(jj).name(1:end-4) '-s.wav'],w2,fs);

            audiowrite([savepath d(jj).name(1:end-4) '.wav'],w2,fs);
        %    plot(w);hold on; plot(w2);pause;clf
        end
    end
    disp(['done  ' num2str(ss)])
end

%% generate test set to check if it works
M=[];
ind=1;
cd video

cd ..
cd spkDS %spkLG %spkGM %spkBT %
d = dir('*.mp4');
for ii = 1: length(d)
    M{ind} = ['sentences/spkDS/' d(ii).name(1:end-4) '.wav'];
    ind = ind+1;


end

