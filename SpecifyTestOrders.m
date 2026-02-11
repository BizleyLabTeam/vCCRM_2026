function varargout = SpecifyTestOrders(varargin)
% SPECIFYTESTORDERS M-file for SpecifyTestOrders.fig
%      SPECIFYTESTORDERS, by itself, creates a new SPECIFYTESTORDERS or raises the existing
%      singleton*.
%
%      H = SPECIFYTESTORDERS returns the handle to a new SPECIFYTESTORDERS or the handle to
%      the existing singleton*.
%
%      SPECIFYTESTORDERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECIFYTESTORDERS.M with the given input arguments.
%
%      SPECIFYTESTORDERS('Property','Value',...) creates a new SPECIFYTESTORDERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpecifyTestOrders_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpecifyTestOrders_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpecifyTestOrders

% Last Modified by GUIDE v2.5 10-Jun-2020 12:20:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpecifyTestOrders_OpeningFcn, ...
                   'gui_OutputFcn',  @SpecifyTestOrders_OutputFcn, ...
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


% --- Executes just before SpecifyTestOrders is made visible.
function SpecifyTestOrders_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpecifyTestOrders (see VARARGIN)

% Choose default command line output for SpecifyTestOrders
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Move the GUI to the center of the screen.
movegui(handles.figure1,'center')

% process any arguments to re-set the TestSpecs GUI
if length(varargin)>1
    for index=1:2:length(varargin)
        if length(varargin) < index+1
            break;
        elseif strcmp('Listener', varargin{1})
            set(handles.OutFileName,'String',char(varargin{2}));
        end
    end
end

% put all conditions possibilities into box
[targets, maskers, starts, initials, finals, maxtrials, catchtrials, warns,fRevs]=ReadConditions();
set(handles.TargetsFileName, 'String', targets);
set(handles.MaskerFileName, 'String', maskers);
index=get(handles.MaskerFileName,'Value');
set(handles.StartingSNR,'String',starts(index));
set(handles.InitialStep,'String',initials(index));
set(handles.FinalStep,'String',finals(index));
set(handles.MaxTrials,'String',maxtrials(index));
set(handles.CatchTrials,'String',catchtrials(index));
set(handles.warnNz,'String',warns(index));
set(handles.FinalRevs,'String',fRevs(index));

% UIWAIT makes SpecifyTestOrders wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = SpecifyTestOrders_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles)
    varargout{1}='quit';
else
    varargout{1} = handles.outfilename;
    varargout{2} = handles.targetsfilename;
    varargout{3} = handles.maskerfilename;
    varargout{4} = str2double(handles.start);
    varargout{5} = str2double(handles.initial);
    varargout{6} = str2double(handles.final);
    varargout{7} = str2double(handles.maxtrials);
    varargout{8} = str2double(handles.LevittsK);
    if get(handles.ColourDigit,'Value')
        varargout{9} = 'ColDig';
    else
        varargout{9} = 'ColOnly';
    end
    if get(handles.Noise,'Value')
        varargout{10} = 0;
    else
        varargout{10} = 1;
    end
    varargout{11} = handles.HRTF;
    varargout{12} = str2double(handles.targetazimuth);
    varargout{13} = str2double(handles.maskerazimuth);
    varargout{14} = str2double(handles.catchtrials);
    varargout{15} = handles.ear;
    varargout{16} = handles.fixed;
    varargout{17} = str2double(handles.rmsValue);
    varargout{18} = str2double(handles.warn);
    varargout{19} = str2double(handles.fRevs);
    varargout{20} = handles.F;
    varargout{21} = handles.Faces;
    varargout{22} = handles.MaskerLocations;
    varargout{23} = handles.novideo;

    % The figure can be deleted now
    delete(handles.figure1);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.maskerfilename=get(handles.MaskerFileName,'String');
handles.maskerfilename=handles.maskerfilename{get(handles.MaskerFileName,'Value')};
handles.targetsfilename= get(handles.TargetsFileName,'String');
handles.targetsfilename=handles.targetsfilename{get(handles.TargetsFileName,'Value')};
handles.outfilename=get(handles.OutFileName,'String');
handles.start=get(handles.StartingSNR,'String');
handles.initial=get(handles.InitialStep,'String');
handles.final=get(handles.FinalStep,'String');
handles.catchtrials=get(handles.CatchTrials,'String');
handles.maxtrials=get(handles.MaxTrials,'String');
handles.LevittsK=get(handles.LevittsK,'String');
handles.HRTF=get(handles.HRTFfile,'String');
handles.HRTF=handles.HRTF{get(handles.HRTFfile,'Value')};
handles.targetazimuth=get(handles.TargetAzimuth,'String');
handles.maskerazimuth=get(handles.MaskerAzimuth,'String');
if get(handles.Both,'Value')
    handles.ear='B';
elseif get(handles.Left,'Value')
    handles.ear='L';
elseif get(handles.Right,'Value')
    handles.ear='R';
elseif get(handles.Opposite,'Value')
    handles.ear='OL';
elseif get(handles.OppositeR,'Value')
    handles.ear='OR';
else
    handles.ear='Other';
end
if get(handles.OverallFixed,'Value')
    handles.fixed = 'overall';
else
    handles.fixed = 'masker';
end
% two part masker split or in one place
if get(handles.TwoLocations,'Value')
    handles.MaskerLocations = 1;
else
    handles.MaskerLocations = 2;
end

handles.rmsValue=get(handles.rms,'String');
handles.warn=get(handles.warnNz,'String');
handles.fRevs=get(handles.FinalRevs,'String');
% specify the type of feedback
if get(handles.AlwaysGood,'Value')
    handles.F='AlwaysGood';
elseif get(handles.Neutral,'Value')
    handles.F='Neutral';
elseif get(handles.Corrective,'Value')
    handles.F='Corrective';
else
    handles.F='None';
end
% specify the feedback faces
if get(handles.Bears,'Value')
    handles.Faces='Bears';
elseif get(handles.Pinky,'Value')
    handles.Faces='Pinky';
else
    handles.Faces='Other';
end
handles.novideo=get(handles.NoVideo,'Value');
guidata(hObject, handles); % Save the updated structure
uiresume(handles.figure1);

function TargetsFileName_Callback(hObject, eventdata, handles)
% hObject    handle to TargetsFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetsFileName as text
%        str2double(get(hObject,'String')) returns contents of TargetsFileName as a double
handles.targetsfilename=get(hObject,'String');
guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function TargetsFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetsFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OutFileName_Callback(hObject, eventdata, handles)
% hObject    handle to OutFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutFileName as text
%        str2double(get(hObject,'String')) returns contents of OutFileName as a double
handles.outfilename=get(hObject,'String');
guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function OutFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StartingSNR_Callback(hObject, eventdata, handles)
% hObject    handle to StartingSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartingSNR as text
%        str2double(get(hObject,'String')) returns contents of StartingSNR as a double
handles.startingsnr=get(hObject,'String');
guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function StartingSNR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartingSNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in MaskerFileName.
function MaskerFileName_Callback(hObject, eventdata, handles)
% hObject    handle to MaskerFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MaskerFileName contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MaskerFileName
[targets, maskers, starts, initials, finals, maxtrials,catchtrials,warns,fRevs]=ReadConditions();
index=get(handles.MaskerFileName,'Value');
set(handles.StartingSNR,'String',starts(index));
set(handles.InitialStep,'String',initials(index));
set(handles.FinalStep,'String',finals(index));
set(handles.MaxTrials,'String',maxtrials(index));
set(handles.CatchTrials,'String',catchtrials(index));
handles.maskerfilename=get(hObject,'String');
guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function MaskerFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskerFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InitialStep_Callback(hObject, eventdata, handles)
% hObject    handle to InitialStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InitialStep as text
%        str2double(get(hObject,'String')) returns contents of InitialStep as a double


% --- Executes during object creation, after setting all properties.
function InitialStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InitialStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FinalStep_Callback(hObject, eventdata, handles)
% hObject    handle to FinalStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FinalStep as text
%        str2double(get(hObject,'String')) returns contents of FinalStep as a double


% --- Executes during object creation, after setting all properties.
function FinalStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% maximum trials
function MaxTrials_Callback(hObject, eventdata, handles)
% hObject    handle to MaxTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxTrials as text
%        str2double(get(hObject,'String')) returns contents of MaxTrials as a double
% handles.maxtrials=get(hObject,'String');
% guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function MaxTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% Levitt's k
function LevittsK_Callback(hObject, eventdata, handles)
% hObject    handle to LevittsK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LevittsK as text
%        str2double(get(hObject,'String')) returns contents of LevittsK as a double
% handles.LevittsK=get(hObject,'String');
% guidata(hObject, handles); % Save the updated structure

% --- Executes during object creation, after setting all properties.
function LevittsK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LevittsK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ColourOnly.
function ColourOnly_Callback(hObject, eventdata, handles)
% hObject    handle to ColourOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ColourOnly
% set(hObject,'Value',1);
% set(handles.ColourDigit,'Value',0);

% --- Executes on button press in ColourDigit.
function ColourDigit_Callback(hObject, eventdata, handles)
% hObject    handle to ColourDigit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ColourDigit




% --- Executes on selection change in HRTFfile.
function HRTFfile_Callback(hObject, eventdata, handles)
% hObject    handle to HRTFfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns HRTFfile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HRTFfile


% --- Executes during object creation, after setting all properties.
function HRTFfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HRTFfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TargetAzimuth_Callback(hObject, eventdata, handles)
% hObject    handle to TargetAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetAzimuth as text
%        str2double(get(hObject,'String')) returns contents of TargetAzimuth as a double


% --- Executes during object creation, after setting all properties.
function TargetAzimuth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaskerAzimuth_Callback(hObject, eventdata, handles)
% hObject    handle to MaskerAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaskerAzimuth as text
%        str2double(get(hObject,'String')) returns contents of MaskerAzimuth as a double


% --- Executes during object creation, after setting all properties.
function MaskerAzimuth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaskerAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CatchTrials_Callback(hObject, eventdata, handles)
% hObject    handle to CatchTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CatchTrials as text
%        str2double(get(hObject,'String')) returns contents of CatchTrials as a double


% --- Executes during object creation, after setting all properties.
function CatchTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CatchTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rms_Callback(hObject, eventdata, handles)
% hObject    handle to rms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rms as text
%        str2double(get(hObject,'String')) returns contents of rms as a double


% --- Executes during object creation, after setting all properties.
function rms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function warnNz_Callback(hObject, eventdata, handles)
% hObject    handle to warnNz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of warnNz as text
%        str2double(get(hObject,'String')) returns contents of warnNz as a double


% --- Executes during object creation, after setting all properties.
function warnNz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to warnNz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FinalRevs_Callback(hObject, eventdata, handles)
% hObject    handle to FinalRevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FinalRevs as text
%        str2double(get(hObject,'String')) returns contents of FinalRevs as a double


% --- Executes during object creation, after setting all properties.
function FinalRevs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalRevs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NoVideo.
function NoVideo_Callback(hObject, eventdata, handles)
% hObject    handle to NoVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of NoVideo
handles.novideo=get(hObject,'Value');
guidata(hObject, handles); % Save the updated structure
