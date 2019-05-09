function varargout = InteractiveSpectra(varargin)
% INTERACTIVESPECTRA MATLAB code for InteractiveSpectra.fig
%      INTERACTIVESPECTRA, by itself, creates a new INTERACTIVESPECTRA or raises the existing
%      singleton*.
%
%      H = INTERACTIVESPECTRA returns the handle to a new INTERACTIVESPECTRA or the handle to
%      the existing singleton*.
%
%      INTERACTIVESPECTRA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERACTIVESPECTRA.M with the given input arguments.
%
%      INTERACTIVESPECTRA('Property','Value',...) creates a new INTERACTIVESPECTRA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InteractiveSpectra_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InteractiveSpectra_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InteractiveSpectra

% Last Modified by GUIDE v2.5 08-Aug-2018 15:34:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InteractiveSpectra_OpeningFcn, ...
                   'gui_OutputFcn',  @InteractiveSpectra_OutputFcn, ...
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


% --- Executes just before InteractiveSpectra is made visible.
function InteractiveSpectra_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InteractiveSpectra (see VARARGIN)

load('GenevaHalphaArrays_16July2018.mat');

handles.inclination = 0;
handles.nindex = 1.5;
handles.rdisk = 5;
handles.logrho = -12;
handles.fluxgrid = flux_grid_M3p0V0p0z0p0X0p3;
handles.fluxarray = flux_array_M3p0V0p0z0p0X0p3;
handles.axis = [6540 6590 0 5.0];
handles.profile = [];
handles.profilename = '';
handles.units = 0;
handles.shift = 0;
handles.mode = 2;
handles.dlambda = 1000;
handles.fom = 0;
handles.wvobs = [];
handles.flobs = [];



[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')

% Choose default command line output for InteractiveSpectra
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InteractiveSpectra wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InteractiveSpectra_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function islider_Callback(hObject, eventdata, handles)
% hObject    handle to islider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%uicontrol('Style', 'Slider', 'Min', 0, 'Max', 90, 'SliderStep', [1/89, 2/90]);

sliderMin = get(hObject, 'Min');
sliderMax = get(hObject, 'Max');
increment = 1/(sliderMax-sliderMin);
set(hObject, 'SliderStep', [increment, 5*increment]);

handles.inclination = get(hObject, 'Value');
set(handles.itext,'String',num2str(handles.inclination));

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function islider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to islider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function nslider_Callback(hObject, eventdata, handles)
% hObject    handle to nslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderMin = get(hObject, 'Min');
sliderMax = get(hObject, 'Max');
increment = 0.1/(sliderMax-sliderMin);
set(hObject, 'SliderStep', [increment, 2*increment]);

handles.nindex = get(hObject, 'Value');
set(handles.ntext,'String',num2str(handles.nindex));

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function nslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function rdslider_Callback(hObject, eventdata, handles)
% hObject    handle to rdslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderMin = get(hObject, 'Min');
sliderMax = get(hObject, 'Max');
increment = 1/(sliderMax-sliderMin);
set(hObject, 'SliderStep', [increment, 4*increment]);

handles.rdisk = get(hObject, 'Value');
set(handles.rdtext,'String',num2str(handles.rdisk));

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rdslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rdslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function logrhoslider_Callback(hObject, eventdata, handles)
% hObject    handle to logrhoslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderMin = get(hObject, 'Min');
sliderMax = get(hObject, 'Max');
increment = 0.1/(sliderMax-sliderMin);
set(hObject, 'SliderStep', [increment, 2*increment]);

handles.logrho = get(hObject, 'Value');
set(handles.logrhotext,'String',num2str(handles.logrho));

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function logrhoslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logrhoslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popup.
function popup_Callback(hObject, eventdata, handles)
% hObject    handle to popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup

load('GenevaHalphaArrays_16July2018.mat');

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val}
    case 'M3p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M3p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M3p0V0p0z0p0X0p3;
    case 'M3p5V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M3p5V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M3p5V0p0z0p0X0p3;
    case 'M4p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M4p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M4p0V0p0z0p0X0p3;
    case 'M4p5V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M4p5V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M4p5V0p0z0p0X0p3;
    case 'M5p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M5p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M5p0V0p0z0p0X0p3;
    case 'M5p5V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M5p5V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M5p5V0p0z0p0X0p3;
    case 'M6p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M6p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M6p0V0p0z0p0X0p3;
    case 'M7p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M7p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M7p0V0p0z0p0X0p3;
    case 'M8p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M8p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M8p0V0p0z0p0X0p3;
    case 'M9p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M9p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M9p0V0p0z0p0X0p3;
    case 'M10p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M10p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M10p0V0p0z0p0X0p3;
    case 'M12p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M12p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M12p0V0p0z0p0X0p3;
    case 'M14p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M14p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M14p0V0p0z0p0X0p3;
    case 'M16p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M16p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M16p0V0p0z0p0X0p3;
    case 'M18p0V0p0z0p0X0p3'
        handles.fluxarray = flux_array_M18p0V0p0z0p0X0p3;
        handles.fluxgrid = flux_grid_M18p0V0p0z0p0X0p3;
    case 'M20p0V0p0z0p0X0p2'
        handles.fluxarray = flux_array_M20p0V0p0z0p0X0p2;
        handles.fluxgrid = flux_grid_M20p0V0p0z0p0X0p2;
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);

        
        
% --- Executes during object creation, after setting all properties.
function popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axisedit_Callback(hObject, eventdata, handles)
% hObject    handle to axisedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of axisedit as text
%        str2double(get(hObject,'String')) returns contents of axisedit as a double

s = get(hObject, 'String');

if isnumeric(str2num(s))
    if isreal(str2num(s))
        coordinates = str2num(s);
        set(handles.msgtext, 'String', '');
    else
        set(handles.msgtext, 'String', 'Please input a non-complex value for axis coordinates');
    end
    
elseif strcmp('[', s(1)) && strcmp(']', s(end))
    if isnumeric(str2num(s(2:end-1)))
        if isreal(str2num(s))
            coordinates = str2num(s(2:end-1));
            set(handles.msgtext, 'String', '');
        else
            set(handles.msgtext, 'String', 'Please input a non-complex value for axis coordinates');
        end
    else
        set(handles.msgtext, 'String', 'Please enter valid axis. (e.g. [6540 6590 0 5.0])');
    end

else
    set(handles.msgtext, 'String', 'Please enter valid axis. (e.g. [6540 6590 0 5.0])');
end

if size(coordinates)== [1 4]
    if (coordinates(1)<coordinates(2) && coordinates(3)<coordinates(4))
        handles.axis = coordinates;
        set(handles.msgtext, 'String', '');
    else
        set(handles.msgtext, 'String', 'Please use a valid axis format [thetamin, thetamax, rmin, rmax]')
    end
else
    set(handles.msgtext, 'String', 'Please enter valid axis. (e.g. [6540 6590 0 5.0])');
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function axisedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axisedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function profileedit_Callback(hObject, eventdata, handles)
% hObject    handle to profileedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of profileedit as text
%        str2double(get(hObject,'String')) returns contents of profileedit as a double
profile = get(hObject, 'String');
currentdir = cd;

if (exist(fullfile(currentdir, profile), 'file'))==2
    handles.profile = load(profile);
    handles.profilename = profile;
    set(handles.popupunits, 'Value', 1)
    set(handles.msgtext, 'String', 'Please select the wv units of your profile.');
elseif (exist(profile, 'file')==2)
    handles.profile = load(profile);
    handles.profilename = profile;
    set(handles.popupunits, 'Value', 1)
    set(handles.msgtext, 'String', 'Please select the wv units of your profile.');
else
    set(handles.msgtext, 'String', 'Please enter a valid profile name/path.');
    handles.profile = [];
    set(handles.popupunits, 'Value', 1)
end

guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function profileedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to profileedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupunits.
function popupunits_Callback(hObject, eventdata, handles)
% hObject    handle to popupunits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupunits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupunits

if isempty(handles.profile)
    set(hObject, 'Value', 1)
    set(handles.msgtext, 'String', 'Please input a profile before selecting wv units in profile.')
else
    str = get(hObject, 'String');
    val = get(hObject,'Value');
    
    set(handles.msgtext, 'String', '')

    switch str{val}
        case 'Choose'
            handles.units = 0;
        case 'Nanometers'
            handles.units = 10;
            handles.profile = [handles.profile(:,1).*10, handles.profile(:,2)];
        case 'Angstroms'
            handles.units = 1;
    end
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);


            


% --- Executes during object creation, after setting all properties.
function popupunits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupunits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dlambdaedit_Callback(hObject, eventdata, handles)
% hObject    handle to dlambdaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dlambdaedit as text
%        str2double(get(hObject,'String')) returns contents of dlambdaedit as a double

dl = get(hObject, 'String');

if (~isempty(handles.profile) & handles.units~=0)
    if isnumeric(str2double(dl))
        deltalambda = str2double(dl);
        if ~isnan(deltalambda)
            if isreal(deltalambda)
                if (deltalambda>0 && ~isinf(deltalambda))
                    handles.dlambda = deltalambda;
                    set(handles.msgtext, 'String', '');
                    
                else
                    handles.dlambda = 1000;
                    set(handles.msgtext, 'String', 'Make sure your delta lambda width is positive and finite.');
                end
            else
                handles.dlambda = 1000;
                set(handles.msgtext, 'String', 'Delta lambda width must be a real number.');
            end
        else
            handles.dlambda = 1000;
            set(handles.msgtext, 'String', 'Delta lambda width is invalid. It must be a single numeric value');
        end
    else
        handles.dlambda = 1000;
        set(handles.msgtext, 'String', 'Delta lambda width must be numeric.');
    end
else
    handles.dlambda = 1000;
    set(handles.msgtext, 'String', 'Please input a profile and select units before inputing a delta lambda width.');
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    hold on
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);

    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function dlambdaedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dlambdaedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fminconbutton.
function fminconbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fminconbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (~isempty(handles.profile) & handles.units~=0)
    set(handles.msgtext, 'String', '');
    [pbest, modelstruct] = match_halpha_profile(3,handles.wvobs,handles.flobs,handles.fluxarray,handles.fluxgrid,'x0', [handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination], 'fom', handles.mode);
    
    if (~isempty(pbest))
        
        set(handles.msgtext, 'String', '');
        
        set(handles.nslider, 'Value', pbest(1))
        set(handles.ntext,'String',num2str(pbest(1)));
        handles.nindex = pbest(1);
        
        set(handles.logrhoslider, 'Value', log10(pbest(2)));
        set(handles.logrhotext,'String',num2str(log10(pbest(2))));
        handles.logrho = log10(pbest(2));
        
        set(handles.rdslider, 'Value', pbest(3));
        set(handles.rdtext,'String',num2str(pbest(3)));
        handles.rdisk = pbest(3);
        
        set(handles.islider, 'Value', pbest(4))
        set(handles.itext,'String',num2str(pbest(4)));
        handles.inclination = pbest(4);
        
        guidata(hObject, handles);

        [handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
        plot(handles.wv,handles.fl,'r-','LineWidth',2);
        
        hold on
        plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
        ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
        set(ht, 'fontsize', 12, 'fontweight', 'bold');
        hold off
        
        xlabel('Wavelength (A)');
        ylabel('Flux');
        axis(handles.axis)
        set(gca, 'FontWeight', 'Bold')
        guidata(hObject, handles);
    
    else
        set(handles.msgtext, 'String', 'Error: Please see match_halpha_profile.m')
    end
       
else
    set(handles.msgtext, 'String', 'Please input a profile with matching units before calling FMINCON.');
end

% --- Executes on selection change in modepopup.
function modepopup_Callback(hObject, eventdata, handles)
% hObject    handle to modepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns modepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modepopup

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val}
    case '-1'
        handles.mode = -1;
    case '0'
        handles.mode = 0;
    case '1'
        handles.mode = 1;
    case '2'
        handles.mode = 2;
    case '3'
        handles.mode = 3;
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function modepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shiftedit_Callback(hObject, eventdata, handles)
% hObject    handle to shiftedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shiftedit as text
%        str2double(get(hObject,'String')) returns contents of shiftedit as a double

sh = get(hObject, 'String');
%shift
if (~isempty(handles.profile) & handles.units~=0)
    if isnumeric(str2double(sh))
        shift = str2double(sh);
        if ~isnan(shift)
            if isreal(shift)
                if ~isinf(shift)
                    handles.shift = shift;
                    set(handles.msgtext, 'String', '');
                else
                    set(handles.msgtext, 'String', 'Shift must not be infinite.');
                end
            else
                set(handles.msgtext, 'String', 'Shift must be a real number.');
            end
        else
            set(handles.msgtext, 'String', 'Shift is invalid. Shift must be a single numeric value');
        end
    else
        set(handles.msgtext, 'String', 'Shift must be numeric.');
    end
else
    set(handles.msgtext, 'String', 'Please input a profile and select units before inputing a shift.');
end

guidata(hObject, handles);

[handles.wv, handles.fl] = profile_interp(handles.fluxarray, handles.fluxgrid, handles.nindex, 10^(handles.logrho), handles.rdisk, handles.inclination);
plot(handles.wv,handles.fl,'k-','LineWidth',2);
if (~isempty(handles.profile) & handles.units~=0)
    [handles.wvobs, handles.flobs] = return_obs_profile(handles.profilename,handles.shift,'wvunit', handles.units, 'vmax', handles.dlambda);
    handles.fom = compare_halpha_profile(handles.wvobs,handles.flobs, handles.wv,handles.fl,handles.mode);
    hold on
    plot(handles.profile(:,1)+handles.shift, handles.profile(:,2),'k:','LineWidth',1)
    ht = text(0.1, 0.9, ['FOM:', num2str(handles.fom,'%6.3f')], 'units', 'normalized');
    set(ht, 'fontsize', 12, 'fontweight', 'bold');
    hold off
end
xlabel('Wavelength (A)');
ylabel('Flux');
axis(handles.axis)
set(gca, 'FontWeight', 'Bold')
guidata(hObject, handles);







% --- Executes during object creation, after setting all properties.
function shiftedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
