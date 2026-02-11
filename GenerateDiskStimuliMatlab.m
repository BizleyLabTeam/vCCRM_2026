

audioPath = 'C:\lib\Lida\vCCRM_nouns\sentences\spkDS';
cd(audioPath)
d = dir('*.wav');
cd('c:\Lib\Lida')
[y,fs] = audioread([audioPath '\' d(100).name]);

% start smoothing with a window that is half the frame rate
a = envelope(y,round(fs*0.033),'rms');
f = find(a<0.0025);
a(f) = 0;
% note code below has a faster frame rate than the mp4s lida was using

%%
% resample to frame rate;
ringSig = resample(a(:,1),60,fs);
%ringSig = smooth(ringSig,5);
ringSig = ringSig.* (1/max(ringSig));
f = find(ringSig<0);
ringSig(f) = 0;
close all;

m = figure;
set(gcf,'PaperPositionMode','manual')
set(gcf,'units','points')
set(gcf,'position',[1,1,1600,900])
m.Color ='k';
xlim([-800 800])
ylim([-450 450])
rad = (ringSig*50)+5;
axis off

v = VideoWriter('test','MPEG-4');
%v.Quality = 100;
v.FrameRate = 60;
open(v)

pause(1)
for ii = 1:length(rad)
    h = circle2(0,0,rad(ii));
    h.FaceColor = [0.5 0.5 0.5];
    h.EdgeColor = [0.9 0.9 0.9];
    h.LineWidth = 2.5
    frame = getframe(gcf);
    writeVideo(v,frame)
    %pause(0.03)
    cla
end
close(v)



%% see if it works
trial=1
videoReader = VideoReader('test.mp4');
if trial == 1
    % launch the videoPlayer
    screensize = get(0, 'screensize');
    % make wholse screen
    videoPlayer = vision.VideoPlayer('Position', [screensize]);
    % display first frame and rewind
    videoPlayer(readFrame(videoReader));
    % activate the 'scale to window' option - this only needs
    set(0,'showHiddenHandles','on')
    fig_handle = gcf ;
    fig_handle.findobj % to view all the linked objects with the vision.VideoPlayer
    ftw = fig_handle.findobj ('TooltipString', 'Maintain fit to window');   % this will search the object in the figure which has the respective 'TooltipString' parameter.
    ftw.ClickedCallback()  % execute the callback linked with this object
else
    videoPlayer(readFrame(videoReader));
end

audioWriter = audioDeviceWriter(fs, 'SupportVariableSizeInput', true, 'BufferSize', 512);
[audio,fs] = audioread([audioPath '\' d(100).name]);
done = playMovie(videoReader,videoPlayer,audioWriter,audio,fs,1);

%% OK, pretty happy with this now, will batch process!
cd sentences\
audioDir = cd;
videoDir = 'C:\lib\Lida\vCCRM_nouns\Video\'
talkers = dir('spk*');
for tt = 2:length(talkers)
    if talkers(tt).isdir
        cd(talkers(tt).name);
        if ~exist('disk')
        mkdir([videoDir talkers(tt).name '\disk'])
        end
        savePath = [videoDir talkers(tt).name '\disk\'];
        files = dir('*.wav');
        for ff = 1:300%538: length(files) %301
            [y,fs] = audioread([files(ff).name]);
            % extract the envelope
            a = envelope(y,round(fs*0.033),'rms'); % RMS at 1/2 frame rate
            f = find(a<0.0025);
            a(f) = 0;
            a = a.* (1/max(a(:,1)));
            % resample to frame rate;
            ringSig = resample(a(:,1),60,fs);
            %ringSig = smooth(ringSig,5);
            ringSig = ringSig.* (1/max(ringSig)); % renormalise
            f = find(ringSig<0); % make sure any negative numbers are removed
            ringSig(f) = 0;
            close all; clear y a 
            % make a figure that is the size of the laptop screen
            m = figure;
            set(gcf,'PaperPositionMode','manual')
            set(gcf,'units','points')
            set(gcf,'position',[1,1,1600,900])
            m.Color ='k';
            xlim([-800 800])
            ylim([-450 450])
            % define the radius changes
            rad = (ringSig*50)+5;
            axis off
            fileName = [savePath 'disk-' files(ff).name(1:end-4)];
            v = VideoWriter(fileName,'MPEG-4');
            %v.Quality = 100;
            v.FrameRate = 60;
            open(v)

            for ii = 1:length(rad)
                h = circle2(0,0,rad(ii));
                h.FaceColor = [0.5 0.5 0.5];
                h.EdgeColor = [0.9 0.9 0.9];
                h.LineWidth = 2.5
                frame = getframe(gcf);
                writeVideo(v,frame)
                %pause(0.03)
                cla
            end
            close(v)
            clear v
        end
        cd ..
    end
end



