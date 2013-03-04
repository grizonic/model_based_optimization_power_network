function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 24-Oct-2012 16:54:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structureuntitled with handles and user data (see GUIDATA)

mpc = loadcase(get(handles.network, 'String'));

%%%
step = 1;
prediction = str2double(get(handles.prediction, 'String'));
loadNode = str2double(get(handles.loadNode, 'String'));
initialTemp= str2double(get(handles.initialTemp, 'String'));
maxTemp = str2double(get(handles.maxTemp, 'String'));
action = get(handles.action, 'Value');
dc = get(handles.dc, 'Value');
%%%

[transformerBranches, agents] = getTransformersFromGridBranches(mpc.branch, step, prediction, initialTemp, maxTemp);

[powerTransit, t] = getProfile(str2double(get(handles.factor, 'String')));
N = length(powerTransit);

numberBranches = length(mpc.branch(:, 1));

% Auxiliary variable in case we want to shift the focus period
start = 1;
startIndex = 1000;

% time = zeros
agentsAgeing = zeros(numberBranches, N);
agentsAgeingPrediction = zeros(numberBranches, N);
agentsPT = zeros(numberBranches, N);
agentsTemp = zeros(numberBranches, N);

agentsTaps = zeros(numberBranches, N);

totalPower47 = 0;
totalPower49 = 0;
totalPower56 = 0;
totalAgeing47 = 0;
totalAgeing49 = 0;
totalAgeing56 = 0;
totalPredictionAgeing47 = 0;
totalPredictionAgeing49 = 0;
totalPredictionAgeing56 = 0;

tapMax = 1.15;
tapMin = 0.85;
tapStep = 0.01;

for ind=start:N
    
    now_hours = floor(ind/60);
    now_minutes = ind - now_hours*60;
    now_time = datestr(datenum(0000, 00, 00, now_hours, now_minutes, 00), 'HH:MM');
    
    prediction_hours = floor((ind+prediction)/60);
    prediction_minutes = (ind+prediction) - prediction_hours*60;
    prediction_time = datestr(datenum(0000, 00, 00, prediction_hours, prediction_minutes, 00), 'HH:MM');
    
    % Load of node 13 in MVA
    mpc.bus(loadNode, 3) = powerTransit(ind)*mpc.baseMVA;
    
    % Simulate 14 Bus Grid in DC
    if dc == true
        mpopt = mpoption('PF_DC', 1, 'VERBOSE', 0);
    else
        mpopt = mpoption('PF_DC', 0, 'VERBOSE', 0);
    end
    mpc = runpf(mpc, mpopt);
    % Takes too long!!
    %mpc = runopf(mpc, mpopt);
    
    for branch=1:numberBranches
        
        % If there's a transformer in this branch
        if cellfun('isempty', agents(branch)) == 0
            
            agentsTaps(branch, ind) = mpc.branch(branch, 9);
            
            pt = abs(mpc.branch(branch, 14));
           
            % Calculate the temperature of the next minute and the
            % temperature over the prediction horizon
            agents{branch} = agents{branch}.getAgeingNode(pt/mpc.baseMVA);       
            agentsAgeing(branch, ind) = agents{branch}.ageingFactor;
            agentsAgeingPrediction(branch, ind) = agents{branch}.ageingFactorPrediction;
            agentsPT(branch, ind) = pt/mpc.baseMVA;
            agentsTemp(branch, ind) = agents{branch}.thhs;
            
            if ind > startIndex
                if agents{branch}.fromNode == 4 && agents{branch}.toNode == 7
                    
                    set(handles.ageing47, 'String', num2str(agents{branch}.ageingFactor))
                    set(handles.ageingPrediction47, 'String', num2str(agents{branch}.ageingFactorPrediction))
                    set(handles.currentRatio47, 'String', num2str(mpc.branch(branch, 9)))
                    
                    totalAgeing47 = totalAgeing47 + agents{branch}.ageingFactor;
                    set(handles.totalAgeing47, 'String', num2str(totalAgeing47))
                    totalPredictionAgeing47 = totalPredictionAgeing47 + agents{branch}.ageingFactorPrediction;
                    set(handles.totalPredictionAgeing47, 'String', num2str(totalPredictionAgeing47))
                    
                    totalPower47 = totalPower47 + agentsPT(branch, ind);
                    set(handles.totalPower47, 'String', num2str(totalPower47))
                    
                    updateBackgroundColor(agents{branch}.ageingFactor, handles.ageing47, agents{branch}.ageingFactorPrediction, handles.ageingPrediction47)
                    
                    plot(handles.ageingPlot47, t, agentsAgeing(branch,:), t+prediction, agentsAgeingPrediction(branch,:))
                    
                elseif agents{branch}.fromNode == 4 && agents{branch}.toNode == 9
                    set(handles.ageing49, 'String', num2str(agents{branch}.ageingFactor))
                    set(handles.ageingPrediction49, 'String', num2str(agents{branch}.ageingFactorPrediction))
                    set(handles.currentRatio49, 'String', num2str(mpc.branch(branch, 9)))
                    
                    totalAgeing49 = totalAgeing49 + agents{branch}.ageingFactor;
                    set(handles.totalAgeing49, 'String', num2str(totalAgeing49))
                    totalPredictionAgeing49 = totalPredictionAgeing49 + agents{branch}.ageingFactorPrediction;
                    set(handles.totalPredictionAgeing49, 'String', num2str(totalPredictionAgeing49))
                    
                    totalPower49 = totalPower49 + agentsPT(branch, ind);
                    set(handles.totalPower49, 'String', num2str(totalPower49))
                    
                    updateBackgroundColor(agents{branch}.ageingFactor, handles.ageing49, agents{branch}.ageingFactorPrediction, handles.ageingPrediction49)
                    
                    plot(handles.ageingPlot49, t, agentsAgeing(branch,:), t+prediction, agentsAgeingPrediction(branch,:))
                    
                elseif agents{branch}.fromNode == 5 && agents{branch}.toNode == 6
                    set(handles.ageing56, 'String', num2str(agents{branch}.ageingFactor))
                    set(handles.ageingPrediction56, 'String', num2str(agents{branch}.ageingFactorPrediction))
                    set(handles.currentRatio56, 'String', num2str(mpc.branch(branch, 9)))
                    
                    totalAgeing56 = totalAgeing56 + agents{branch}.ageingFactor;
                    set(handles.totalAgeing56, 'String', num2str(totalAgeing56))
                    totalPredictionAgeing56 = totalPredictionAgeing56 + agents{branch}.ageingFactorPrediction;
                    set(handles.totalPredictionAgeing56, 'String', num2str(totalPredictionAgeing56))
                    
                    totalPower56 = totalPower56 + agentsPT(branch, ind);
                    set(handles.totalPower56, 'String', num2str(totalPower56))
                    
                    updateBackgroundColor(agents{branch}.ageingFactor, handles.ageing56, agents{branch}.ageingFactorPrediction, handles.ageingPrediction56)
                    
                    plot(handles.ageingPlot56, t, agentsAgeing(branch,:), t+prediction, agentsAgeingPrediction(branch,:))
                end
                
                plot(handles.powerPlot, t, agentsPT(branch,:))
                set(handles.time, 'String', now_time)
                set(handles.prediction_time, 'String', prediction_time)
                pause(0.005)
                
            end
            
        end
    end
    ageing47 = str2num(get(handles.ageingPrediction47, 'String'));
    ageing49 = str2num(get(handles.ageingPrediction49, 'String'));
    ageing56 = str2num(get(handles.ageingPrediction56, 'String'));
    averageAgeing = (ageing56+ageing47+ageing49)/3;
    
    
    if action == true
        % All branches calculated, let's now regulate the tap changers
        for branch=1:numberBranches

            % If there's a transformer in this branch
            if cellfun('isempty', agents(branch)) == 0 

                if ind > startIndex
                    if agents{branch}.fromNode == 4 && agents{branch}.toNode == 7

                        if ageing47 > averageAgeing && str2num(get(handles.currentRatio47, 'String')) < tapMax
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) + tapStep;
                            set(handles.currentRatio47, 'String', num2str(mpc.branch(branch, 9)))
                        elseif ageing47 < averageAgeing && str2num(get(handles.currentRatio47, 'String')) > tapMin
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) - tapStep;
                            set(handles.currentRatio47, 'String', num2str(mpc.branch(branch, 9)))
                        end
                    elseif agents{branch}.fromNode == 4 && agents{branch}.toNode == 9

                        if ageing49 > averageAgeing && str2num(get(handles.currentRatio49, 'String')) < tapMax
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) + tapStep;
                            set(handles.currentRatio49, 'String', num2str(mpc.branch(branch, 9)))
                        elseif ageing49 < averageAgeing && str2num(get(handles.currentRatio49, 'String')) > tapMin
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) - tapStep;
                            set(handles.currentRatio49, 'String', num2str(mpc.branch(branch, 9)))
                        end

                    elseif agents{branch}.fromNode == 5 && agents{branch}.toNode == 6

                        if ageing56 > averageAgeing && str2num(get(handles.currentRatio56, 'String')) < tapMax
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) + tapStep;
                            set(handles.currentRatio56, 'String', num2str(mpc.branch(branch, 9)))
                        elseif ageing56 < averageAgeing && str2num(get(handles.currentRatio56, 'String')) > tapMin
                            mpc.branch(branch, 9) = mpc.branch(branch, 9) - tapStep;
                            set(handles.currentRatio56, 'String', num2str(mpc.branch(branch, 9)))
                        end
                    end
                end
            end
        end
    end
end
for branch=1:numberBranches
    if cellfun('isempty', agents(branch)) == 0
        agents{branch}.fromNode
        agents{branch}.toNode
        figure
        plot(t, agentsAgeing(branch,:), t+prediction, agentsAgeingPrediction(branch,:))
        title('Transformer Ageing Factor')
        legend('Ageing', 'Predicted Ageing');
        grid on;
        xlabel ('Time (min)');
        ylabel ('Ageing Factor');
        hold on
        
        figure
        plot(t, agentsPT(branch,:))
        title('Power Flow on Branch')
        legend('Power Flow');
        grid on;
        xlabel ('Time (min)');
        ylabel ('Power (pu)');
        hold on
        
        figure
        plot(t, agentsTaps(branch,:))
        title('Transformer Ratio by use of Tap Changers')
        legend('Transformer Ratio');
        grid on;
        xlabel ('Time (min)');
        ylabel ('Trans. Ratio');
        hold on
        
%         figure
%         plot(t, agentsTemp(branch,:))
%         hold on
    end
end

function updateBackgroundColor(ageingFactor, text, ageingFactorPrediction, textPrediction)
    if ageingFactor > 1
        set(text, 'BackgroundColor', [1, 0, 0])
    else
        set(text, 'BackgroundColor', [1, 1, 1])
    end
    if ageingFactorPrediction > 1
        set(textPrediction, 'BackgroundColor', [1, 0, 0])
    else
        set(textPrediction, 'BackgroundColor', [1, 1, 1])
    end

function ageing56_Callback(hObject, eventdata, handles)
% hObject    handle to ageing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageing56 as text
%        str2double(get(hObject,'String')) returns contents of ageing56 as a double


% --- Executes during object creation, after setting all properties.
function ageing56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ageingPrediction56_Callback(hObject, eventdata, handles)
% hObject    handle to ageingPrediction56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageingPrediction56 as text
%        str2double(get(hObject,'String')) returns contents of ageingPrediction56 as a double


% --- Executes during object creation, after setting all properties.
function ageingPrediction56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageingPrediction56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double


% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function prediction_time_Callback(hObject, eventdata, handles)
% hObject    handle to prediction_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prediction_time as text
%        str2double(get(hObject,'String')) returns contents of prediction_time as a double


% --- Executes during object creation, after setting all properties.
function prediction_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prediction_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ageingPlot56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageingPlot56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ageingPlot56


% --- Executes on selection change in loadNode.
function loadNode_Callback(hObject, eventdata, handles)
% hObject    handle to loadNode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns loadNode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from loadNode


% --- Executes during object creation, after setting all properties.
function loadNode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadNode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on loadNode and none of its controls.
function loadNode_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to loadNode (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over loadNode.
function loadNode_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to loadNode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function network_Callback(hObject, eventdata, handles)
% hObject    handle to network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of network as text
%        str2double(get(hObject,'String')) returns contents of network as a double


% --- Executes during object creation, after setting all properties.
function network_CreateFcn(hObject, eventdata, handles)
% hObject    handle to network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function prediction_Callback(hObject, eventdata, handles)
% hObject    handle to prediction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prediction as text
%        str2double(get(hObject,'String')) returns contents of prediction as a double


% --- Executes during object creation, after setting all properties.
function prediction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prediction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxTemp_Callback(hObject, eventdata, handles)
% hObject    handle to maxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxTemp as text
%        str2double(get(hObject,'String')) returns contents of maxTemp as a double


% --- Executes during object creation, after setting all properties.
function maxTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initialTemp_Callback(hObject, eventdata, handles)
% hObject    handle to initialTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initialTemp as text
%        str2double(get(hObject,'String')) returns contents of initialTemp as a double


% --- Executes during object creation, after setting all properties.
function initialTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initialTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ageing47_Callback(hObject, eventdata, handles)
% hObject    handle to ageing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageing47 as text
%        str2double(get(hObject,'String')) returns contents of ageing47 as a double


% --- Executes during object creation, after setting all properties.
function ageing47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ageing49_Callback(hObject, eventdata, handles)
% hObject    handle to ageing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageing49 as text
%        str2double(get(hObject,'String')) returns contents of ageing49 as a double


% --- Executes during object creation, after setting all properties.
function ageing49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ageingPrediction47_Callback(hObject, eventdata, handles)
% hObject    handle to ageingPrediction47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageingPrediction47 as text
%        str2double(get(hObject,'String')) returns contents of ageingPrediction47 as a double


% --- Executes during object creation, after setting all properties.
function ageingPrediction47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageingPrediction47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ageingPrediction49_Callback(hObject, eventdata, handles)
% hObject    handle to ageingPrediction49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ageingPrediction49 as text
%        str2double(get(hObject,'String')) returns contents of ageingPrediction49 as a double


% --- Executes during object creation, after setting all properties.
function ageingPrediction49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ageingPrediction49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function factor_Callback(hObject, eventdata, handles)
% hObject    handle to factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of factor as text
%        str2double(get(hObject,'String')) returns contents of factor as a double


% --- Executes during object creation, after setting all properties.
function factor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPower56_Callback(hObject, eventdata, handles)
% hObject    handle to totalPower56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPower56 as text
%        str2double(get(hObject,'String')) returns contents of totalPower56 as a double


% --- Executes during object creation, after setting all properties.
function totalPower56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPower56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPower49_Callback(hObject, eventdata, handles)
% hObject    handle to totalPower49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPower49 as text
%        str2double(get(hObject,'String')) returns contents of totalPower49 as a double


% --- Executes during object creation, after setting all properties.
function totalPower49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPower49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPower47_Callback(hObject, eventdata, handles)
% hObject    handle to totalPower47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPower47 as text
%        str2double(get(hObject,'String')) returns contents of totalPower47 as a double


% --- Executes during object creation, after setting all properties.
function totalPower47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPower47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalAgeing56_Callback(hObject, eventdata, handles)
% hObject    handle to totalAgeing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalAgeing56 as text
%        str2double(get(hObject,'String')) returns contents of totalAgeing56 as a double


% --- Executes during object creation, after setting all properties.
function totalAgeing56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalAgeing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPredictionAgeing56_Callback(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPredictionAgeing56 as text
%        str2double(get(hObject,'String')) returns contents of totalPredictionAgeing56 as a double


% --- Executes during object creation, after setting all properties.
function totalPredictionAgeing56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalAgeing49_Callback(hObject, eventdata, handles)
% hObject    handle to totalAgeing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalAgeing49 as text
%        str2double(get(hObject,'String')) returns contents of totalAgeing49 as a double


% --- Executes during object creation, after setting all properties.
function totalAgeing49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalAgeing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentRatio49_Callback(hObject, eventdata, handles)
% hObject    handle to currentRatio49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentRatio49 as text
%        str2double(get(hObject,'String')) returns contents of currentRatio49 as a double


% --- Executes during object creation, after setting all properties.
function currentRatio49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentRatio49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalAgeing47_Callback(hObject, eventdata, handles)
% hObject    handle to totalAgeing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalAgeing47 as text
%        str2double(get(hObject,'String')) returns contents of totalAgeing47 as a double


% --- Executes during object creation, after setting all properties.
function totalAgeing47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalAgeing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentRatio47_Callback(hObject, eventdata, handles)
% hObject    handle to currentRatio47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentRatio47 as text
%        str2double(get(hObject,'String')) returns contents of currentRatio47 as a double


% --- Executes during object creation, after setting all properties.
function currentRatio47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentRatio47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in action.
function action_Callback(hObject, eventdata, handles)
% hObject    handle to action (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of action


% --- Executes on button press in dc.
function dc_Callback(hObject, eventdata, handles)
% hObject    handle to dc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dc


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPredictionAgeing49_Callback(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPredictionAgeing49 as text
%        str2double(get(hObject,'String')) returns contents of totalPredictionAgeing49 as a double


% --- Executes during object creation, after setting all properties.
function totalPredictionAgeing49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalPredictionAgeing47_Callback(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalPredictionAgeing47 as text
%        str2double(get(hObject,'String')) returns contents of totalPredictionAgeing47 as a double


% --- Executes during object creation, after setting all properties.
function totalPredictionAgeing47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalPredictionAgeing47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
