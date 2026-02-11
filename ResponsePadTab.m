function varargout = ResponsePadTab(varargin)
% RESPONSEPADTAB M-file for ResponsePadTab.fig
%      RESPONSEPADTAB, by itself, creates a new RESPONSEPADTAB or raises the existing
%      singleton*.
%
%      H = RESPONSEPADTAB returns the handle to a new RESPONSEPADTAB or the handle to
%      the existing singleton*.
%
%      RESPONSEPADTAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESPONSEPADTAB.M with the given input arguments.
%
%      RESPONSEPADTAB('Property','Value',...) creates a new RESPONSEPADTAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ResponsePad_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ResponsePadTab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ResponsePadTab

% Last Modified by GUIDE v2.5 31-May-2012 09:34:50
%
% varargin                   1           2     3           4       5     6
% y=ResponsePadTab(AnimalImage,audioWriter,audio,videoReader,NoVideo,trial)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ResponsePadTab_OpeningFcn, ...
                   'gui_OutputFcn',  @ResponsePadTab_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ResponsePadTab is made visible.
function ResponsePadTab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ResponsePadTab (see VARARGIN)

% Choose default command line output for ResponsePadTab
% handles.output = hObject; % initial version
% handles.output = 'quit1';

% handles.output = 'NULL';
% Update handles structure
% guidata(hObject, handles);
movegui('center');

% display the specific animal picture desired
axes(handles.axes1);
% set(gca,'DefaultImageVisible','off')
image(varargin{1})
set(handles.axes1, 'Visible', 'off');

if varargin{6}==1 % the first trial
    pause(2)
end

if isobject(varargin{4})
    % audio/video - create and centre a video player
    screensize = get(0, 'screensize');
    width = max(varargin{4}.width + 20, 1050);  % obscure GUI.
    height = max(varargin{4}.height + 30, 640);
    xpos = max(0, (screensize(3) - width)/2);
    ypos = max(0, (screensize(4) - height)/2);
    videoPlayer = vision.VideoPlayer('Position', [xpos ypos width height]);
    % display first frame and rewind
    videoPlayer(readFrame(varargin{4}));
    varargin{4}.CurrentTime = 0;
    pause(0.5);
    % calculate audio and video frame parameters.
    if varargin{5} == 0
        vFrames = floor(varargin{4}.Duration*varargin{4}.FrameRate - 0.1);
    else
        vFrames = 0;    % NoVideo set, display still image
    end
    aFrames = floor((size(varargin{3}, 1)/22050)*varargin{4}.FrameRate);
    if vFrames > aFrames
        % video longer than audio
        nFrames = vFrames;
        vStart = 1;
        aStart = vFrames - aFrames + 1;
    else
        % audio longer than or equal length to video
        nFrames = aFrames;
        vStart = aFrames - vFrames + 1;
        aStart = 1;
    end
else
    % audio only - calculate audio and video frame parameters.
    vFrames = 0;
    aFrames = floor(size(varargin{3}, 1)/512);
    nFrames = aFrames;
    vStart = 1;
    aStart = 1;
end

% play the content
vStop = vStart + vFrames;
aStop = aStart + aFrames;
frame = 1;
position = 1;
frameLen = size(varargin{3}, 1)/aFrames;
while frame <= nFrames
    if frame >= aStart && frame < aStop
        index = round(position);
        position = position + frameLen;
        varargin{2}(varargin{3}(index:round(position) - 1, :));
    end
    if frame >= vStart && frame < vStop
        videoPlayer(readFrame(varargin{4}));
    end
    frame = frame + 1;
end

% close the video player window
if exist('videoPlayer', 'var')
    release(videoPlayer);
    delete(videoPlayer);
end

% UIWAIT makes ResponsePadTab wait for user response (see UIRESUME)
uiwait(handles.figure1);

% UIWAIT might have returned because the window was deleted using
% the close box - in that case, return 'X' as the answer, and
% don't bother deleting the window!
% if ~ishandle(handles.figure1)
%   answer = 'quit';
% else
%   % otherwise, we got here because the user pushed one of the two buttons.
%   % retrieve the latest copy of the 'handles' struct, and return the answer.
%   % Also, we need to delete the window.
%   guidata(hObject, handles);
%   answer = handles.response;
% %	  delete(fig);
% end

% --- Outputs from this function are returned to the command line.
function varargout = ResponsePadTab_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}='quit';
    varargout{2}=0;
else
    varargout{1} = handles.output(1:length(handles.output)-1);
    varargout{2} = str2num(handles.output(length(handles.output)));
end

% --- Executes on button press in black1.
function black1_Callback(hObject, eventdata, handles)
% hObject    handle to black1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black2.
function black2_Callback(hObject, eventdata, handles)
% hObject    handle to black2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black3.
function black3_Callback(hObject, eventdata, handles)
% hObject    handle to black3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black4.
function black4_Callback(hObject, eventdata, handles)
% hObject    handle to black4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black5.
function black5_Callback(hObject, eventdata, handles)
% hObject    handle to black5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black6.
function black6_Callback(hObject, eventdata, handles)
% hObject    handle to black6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black8.
function black8_Callback(hObject, eventdata, handles)
% hObject    handle to black8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in black9.
function black9_Callback(hObject, eventdata, handles)
% hObject    handle to black9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);



% --- Executes on button press in red5.
function red5_Callback(hObject, eventdata, handles)
% hObject    handle to red5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red6.
function red6_Callback(hObject, eventdata, handles)
% hObject    handle to red6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red8.
function red8_Callback(hObject, eventdata, handles)
% hObject    handle to red8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red9.
function red9_Callback(hObject, eventdata, handles)
% hObject    handle to red9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red1.
function red1_Callback(hObject, eventdata, handles)
% hObject    handle to red1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red2.
function red2_Callback(hObject, eventdata, handles)
% hObject    handle to red2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red3.
function red3_Callback(hObject, eventdata, handles)
% hObject    handle to red3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in red4.
function red4_Callback(hObject, eventdata, handles)
% hObject    handle to red4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);



% --- Executes on button press in white5.
function white5_Callback(hObject, eventdata, handles)
% hObject    handle to white5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white6.
function white6_Callback(hObject, eventdata, handles)
% hObject    handle to white6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white8.
function white8_Callback(hObject, eventdata, handles)
% hObject    handle to white8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white9.
function white9_Callback(hObject, eventdata, handles)
% hObject    handle to white9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white1.
function white1_Callback(hObject, eventdata, handles)
% hObject    handle to white1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white2.
function white2_Callback(hObject, eventdata, handles)
% hObject    handle to white2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white3.
function white3_Callback(hObject, eventdata, handles)
% hObject    handle to white3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue5.
function blue5_Callback(hObject, eventdata, handles)
% hObject    handle to blue5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue6.
function blue6_Callback(hObject, eventdata, handles)
% hObject    handle to blue6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue1.
function blue1_Callback(hObject, eventdata, handles)
% hObject    handle to blue1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue2.
function blue2_Callback(hObject, eventdata, handles)
% hObject    handle to blue2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue3.
function blue3_Callback(hObject, eventdata, handles)
% hObject    handle to blue3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue8.
function blue8_Callback(hObject, eventdata, handles)
% hObject    handle to blue8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue9.
function blue9_Callback(hObject, eventdata, handles)
% hObject    handle to blue9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in blue4.
function blue4_Callback(hObject, eventdata, handles)
% hObject    handle to blue4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in white4.
function white4_Callback(hObject, eventdata, handles)
% hObject    handle to white4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green5.
function green5_Callback(hObject, eventdata, handles)
% hObject    handle to green5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green6.
function green6_Callback(hObject, eventdata, handles)
% hObject    handle to green6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green9.
function green9_Callback(hObject, eventdata, handles)
% hObject    handle to green9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green1.
function green1_Callback(hObject, eventdata, handles)
% hObject    handle to green1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green2.
function green2_Callback(hObject, eventdata, handles)
% hObject    handle to green2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green3.
function green3_Callback(hObject, eventdata, handles)
% hObject    handle to green3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink2.
function pink2_Callback(hObject, eventdata, handles)
% hObject    handle to pink2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green8.
function green8_Callback(hObject, eventdata, handles)
% hObject    handle to green8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink5.
function pink5_Callback(hObject, eventdata, handles)
% hObject    handle to pink5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink6.
function pink6_Callback(hObject, eventdata, handles)
% hObject    handle to pink6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink1.
function pink1_Callback(hObject, eventdata, handles)
% hObject    handle to pink1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink3.
function pink3_Callback(hObject, eventdata, handles)
% hObject    handle to pink3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink8.
function pink8_Callback(hObject, eventdata, handles)
% hObject    handle to pink8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink9.
function pink9_Callback(hObject, eventdata, handles)
% hObject    handle to pink9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in pink4.
function pink4_Callback(hObject, eventdata, handles)
% hObject    handle to pink4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in green4.
function green4_Callback(hObject, eventdata, handles)
% hObject    handle to green4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output=get(hObject,'Tag');
guidata(hObject, handles);
uiresume(handles.figure1);

