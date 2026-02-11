function varargout = FinishButton(varargin)
% FinishButton M-file for FinishButton.fig
%      FinishButton, by itself, creates a new FinishButton or raises the existing
%      singleton*.
%
%      H = FinishButton returns the handle to a new FinishButton or the handle to
%      the existing singleton*.
%
%      FinishButton('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FinishButton.M with the given input arguments.
%
%      FinishButton('Property','Value',...) creates a new FinishButton or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FinishButton_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FinishButton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FinishButton

% Last Modified by GUIDE v2.5 18-May-2009 08:16:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FinishButton_OpeningFcn, ...
                   'gui_OutputFcn',  @FinishButton_OutputFcn, ...
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


% --- Executes just before FinishButton is made visible.
function FinishButton_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FinishButton (see VARARGIN)

% Choose default command line output for FinishButton
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui('center');

Bouncy = imread('Bouncy.jpg','jpg');
% display Bouncy
axes(handles.axes1);
image(Bouncy)
set(handles.axes1, 'Visible', 'off');

% UIWAIT makes FinishButton wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FinishButton_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in FinishButton.
function FinishButton_Callback(hObject, eventdata, handles)
% hObject    handle to FinishButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1)

