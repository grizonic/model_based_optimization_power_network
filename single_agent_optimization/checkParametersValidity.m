function [parameters]=checkParametersValidity(handles)

% Possible variable ranges
thambMin = 0;
thambMax = 50;
thoilMin = 0;
thoilMax = 150;
thhsMin = 0;
thhsMax = 150;
factorptMin = 0;
factorptMax = 5;
thratedMin = 0;
thratedMax = 150;
thmaxMin = 0;
thmaxMax = 150;
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get variables
parameters.thamb = str2num(get(handles.thamb, 'String'));
parameters.thoil = str2num(get(handles.thoil, 'String'));
parameters.thhs = str2num(get(handles.thhs, 'String'));
parameters.thmax = str2num(get(handles.thmax, 'String'));
parameters.thrated = str2num(get(handles.thrated, 'String'));
parameters.factorpt = str2num(get(handles.factorpt, 'String'));

parameters.transients = get(handles.transients, 'Value');

parameters.step = str2num(get(handles.step, 'String'));

% Assume valid
parameters.valid = false;

% Check Validity!
if isempty(parameters.thamb) || (thambMin > parameters.thamb) || (parameters.thamb > thambMax)
    errordlg(['Oh no! Undefined ThAmb or out of bounders [' num2str(thambMin) ', ' num2str(thambMax) ']'],'Error');
elseif isempty(parameters.thoil) || (thoilMin > parameters.thoil) || (parameters.thoil > thoilMax)
    errordlg(['Oh no! Undefined thoil or out of bounders [' num2str(thoilMin) ', ' num2str(thoilMax) ']'],'Error');
elseif isempty(parameters.thhs) || (thhsMin > parameters.thhs) || (parameters.thhs > thhsMax)
    errordlg(['Oh no! Undefined thhs or out of bounders [' num2str(thhsMin) ', ' num2str(thhsMax) ']'],'Error');
elseif parameters.thhs < parameters.thoil
    errordlg('Oh no! HS tempoerature can never be less than the OIL temperature','Error');
elseif isempty(parameters.factorpt) || (factorptMin > parameters.factorpt) || (parameters.factorpt > factorptMax)
    errordlg(['Oh no! Undefined factorpt or out of bounders [' num2str(factorptMin) ', ' num2str(factorptMax) ']'],'Error');
elseif isempty(parameters.thmax) || (thmaxMin > parameters.thmax) || (parameters.thmax > thmaxMax)
    errordlg(['Oh no! Undefined thmax or out of bounders [' num2str(thmaxMin) ', ' num2str(thmaxMax) ']'],'Error');
elseif isempty(parameters.thrated) || (thratedMin > parameters.thrated) || (parameters.thrated > thratedMax)
    errordlg(['Oh no! Undefined thrated or out of bounders [' num2str(thratedMin) ', ' num2str(thratedMax) ']'],'Error');
else
    parameters.valid = true;
end