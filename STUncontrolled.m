function[transients]=STUncontrolled(parameters)

% Initial Values
transients = parameters.transients;

maxTemp = parameters.thmax; % Max allowed Temp
ratedTemp = 273 + parameters.thrated; % Rated temp for FAA calculation
multiFactor = parameters.factorpt; % Multiplication factor for input data

% All initial variables of the line, transformer, and power transit
% are stated inside these functions;
thoilNC = parameters.thoil;
thhsNC = parameters.thhs;
spentLifeTimeNC = 0;
powerTransitTotal = 0;

[transformerData] = getTransformerData();
[powerTransit, t] = getProfile(multiFactor);
transformerData.h = parameters.step;

N = length(t);
figure;
start = 1;

%Uncontrolled Variables
thoilNCarray = zeros(1, N-start+1);
thhsNCarray = zeros(1, N-start+1);
ageingFactorsNCarray = zeros(1, N-start+1);

for ind=start:N
    
    lastthoilNC = thoilNC;
    lastthhsNC = thhsNC;
    [thoilNC, thhsNC, powerTransitNC] = simulateTransformerUncontrolled(lastthoilNC, lastthhsNC, powerTransit(ind), transformerData);
    
    % Get Ageing Factors - Controlled
    [ageingFactorNC] = getAgeingFactors(lastthhsNC, ratedTemp, transients);

    % Increase ageingFactor if transients are present
    if transients == true
        ageingFactorNC = ageingFactorNC * 1.064; % Bart's result
    end

    period = 1;
    spentLifeTimeNC = spentLifeTimeNC + spentLifeTime(ageingFactorNC, period);
    
    thoilNCarray(ind) = thoilNC;
    thhsNCarray(ind) = thhsNC;

    powerTransitTotal = powerTransitTotal + powerTransit(ind);

    ageingFactorsNCarray(ind) = ageingFactorNC;
end

if strcmp(parameters.figures,'all')
    subplot(2, 2, 1)
    plot(t, thoilNCarray, t, thhsNCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Top-Oil', 'Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')

    subplot(2, 2, 2)
    plot(t, powerTransit)
    title('Power Transit')
    hleg1 = legend('Uncontrolled');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')

    subplot(2, 2, 3)
    plot(t, ageingFactorsNCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Uncontrolled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')

    subplot(2, 2, 4)
    bar([1, 2], [spentLifeTimeNC, 0; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Uncontrolled LLT');
    ylabel('LLT (minutes)')
    
elseif strcmp(parameters.figures,'1')    
    plot(t, thoilNCarray, t, thhsNCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Top-Oil', 'Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')
    
elseif strcmp(parameters.figures,'2')
    plot(t, powerTransit)
    title('Power Transit')
    hleg1 = legend('Uncontrolled');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')
    
elseif strcmp(parameters.figures,'3')
    plot(t, ageingFactorsNCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Uncontrolled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')
    
elseif strcmp(parameters.figures,'4')
    bar([1, 2], [spentLifeTimeNC, 0; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Uncontrolled LLT');
    ylabel('LLT (minutes)')
end