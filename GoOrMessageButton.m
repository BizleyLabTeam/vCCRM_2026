function varargout = GoOrMessageButton(varargin)
% FIGURE1 M-file for figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GoOrMessageButton_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GoOrMessageButton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure1

% Last Modified by GUIDE v2.5 17-May-2022 16:51:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GoOrMessageButton_OpeningFcn, ...
    'gui_OutputFcn',  @GoOrMessageButton_OutputFcn, ...
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


% --- Executes just before figure1 is made visible.
function GoOrMessageButton_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure1 (see VARARGIN)

% Choose default command line output for figure1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if(length(varargin) > 3) && ~strcmp(varargin{4},'none')
    set(handles.axes1, 'Visible', 'off');
    set(handles.text1, 'String', varargin{2});
    set(handles.text1, 'Visible', 'on');
    Bouncy = imread('Bouncy.jpg','jpg');
    % display Bouncy
    axes(handles.axes1);
    image(Bouncy)
    set(handles.axes1, 'Visible', 'off');
elseif(length(varargin) > 3)&& strcmp(varargin{4},'none')
    set(handles.axes1, 'Visible', 'off');
    set(handles.text1, 'String', varargin{2});
    set(handles.text1, 'Visible', 'on');

else
    set(handles.axes1, 'Visible', 'off');
    set(handles.text1, 'String', varargin{2});
    set(handles.text1, 'Visible', 'on');
    
    Bouncy = imread('Bouncy.jpg','jpg');
    % display Bouncy
    axes(handles.axes1);
    image(Bouncy)
    set(handles.axes1, 'Visible', 'off');
end
movegui('center');
% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')


% UIWAIT makes untitled1 wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GoOrMessageButton_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
% The figure can be deleted now
%delete(handles.figure1);
if ~isempty(handles)
    delete(hObject);
end

% --- Executes on button press in OKbutton.
function OKbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OKbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
