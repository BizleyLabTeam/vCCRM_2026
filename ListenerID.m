function varargout = ListenerID(varargin)
% LISTENERID MATLAB code for ListenerID.fig
%      LISTENERID, by itself, creates a new LISTENERID or raises the existing
%      singleton*.
%
%      H = LISTENERID returns the handle to a new LISTENERID or the handle to
%      the existing singleton*.
%
%      LISTENERID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LISTENERID.M with the given input arguments.
%
%      LISTENERID('Property','Value',...) creates a new LISTENERID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ListenerID_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ListenerID_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ListenerID

% Last Modified by GUIDE v2.5 15-Nov-2014 09:37:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ListenerID_OpeningFcn, ...
                   'gui_OutputFcn',  @ListenerID_OutputFcn, ...
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


% --- Executes just before ListenerID is made visible.
function ListenerID_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ListenerID (see VARARGIN)

% Choose default command line output for ListenerID
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Move the GUI to the center of the screen.
movegui(handles.ID, 'center')

% UIWAIT makes ListenerID wait for user response (see UIRESUME)
uiwait(handles.ID);


% --- Outputs from this function are returned to the command line.
function varargout = ListenerID_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
if isempty(handles)
    varargout{1}='quit';
else
    varargout{1} = handles.listenerInitials;
    varargout{2} = handles.listenerDOB;
    if get(handles.femaleButton,'Value')
        varargout{3} = 'F';
    else
        varargout{3} = 'M';
    end
end
%------------------------------
% The figure can be deleted now
delete(handles.ID);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.listenerInitials=get(handles.ListenerInitials,'String');
handles.listenerDOB = get(handles.DateOfBirth,'String');

guidata(hObject, handles); % Save the updated structure
uiresume(handles.ID);


function ListenerInitials_Callback(hObject, eventdata, handles)
% hObject    handle to ListenerInitials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListenerInitials as text
%        str2double(get(hObject,'String')) returns contents of ListenerInitials as a double


% --- Executes during object creation, after setting all properties.
function ListenerInitials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListenerInitials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DateOfBirth_Callback(hObject, eventdata, handles)
% hObject    handle to DateOfBirth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DateOfBirth as text
%        str2double(get(hObject,'String')) returns contents of DateOfBirth as a double


% --- Executes during object creation, after setting all properties.
function DateOfBirth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DateOfBirth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
