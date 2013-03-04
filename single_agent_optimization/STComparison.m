function[transients]=STComparison(parameters)

% Initial Values
transients = parameters.transients;

maxTemp = parameters.thmax; % Max allowed Temp
ratedTemp = 273 + parameters.thrated; % Rated temp for FAA calculation
multiFactor = parameters.factorpt; % Multiplication factor for input data

% All initial variables of the line, transformer, and power transit
% are stated inside these functions;
thoilC = parameters.thoil;
thhsC = parameters.thhs;
thoilNC = parameters.thoil;
thhsNC = parameters.thhs;
spentLifeTimeC = 0;
spentLifeTimeNC = 0;
powerTransitRerouted = 0;
powerTransitTotal = 0;

[transformerData] = getTransformerData();
[powerTransit, t] = getProfile(multiFactor);
transformerData.h = parameters.step;

N = length(t);
figure;
start = 1;

%Controlled Variables
thoilCarray = zeros(1, N-start+1);
thhsCarray = zeros(1, N-start+1);
powerTransitCarray = zeros(1, N-start+1);
ageingFactorsCarray = zeros(1, N-start+1);
umaxarray = zeros(1, N-start+1);

%Uncontrolled Variables
thoilNCarray = zeros(1, N-start+1);
thhsNCarray = zeros(1, N-start+1);
ageingFactorsNCarray = zeros(1, N-start+1);

for ind=start:N
    
    lastthoilC = thoilC;
    lastthhsC = thhsC;
    
    lastthoilNC = thoilNC;
    lastthhsNC = thhsNC;
    
    
    if ((ind-start)/transformerData.h-floor((ind-start)/transformerData.h))*10 == 0        
        % Controlled
        [thoilC, thhsC, powerTransitC, umax, bla] = simulateTransformerControlled(lastthoilC, lastthhsC, powerTransit(ind), transformerData, ratedTemp, transients);
    else 
        umaxarray(ind) = umax;
        % UnControlled
        [thoilC, thhsC, powerTransitC] = simulateTransformerUncontrolled(lastthoilC, lastthhsC, min(powerTransit(ind), umaxarray(ind)), transformerData);
    end
    
    [thoilNC, thhsNC, powerTransitNC] = simulateTransformerUncontrolled(lastthoilNC, lastthhsNC, powerTransit(ind), transformerData);
    
    
    % Get Ageing Factors - Controlled
    [ageingFactorNC] = getAgeingFactors(lastthhsNC, ratedTemp, transients);
    [ageingFactorC] = getAgeingFactors(lastthhsC, ratedTemp, transients);

    period = 1;
    spentLifeTimeC = spentLifeTimeC + spentLifeTime(ageingFactorC, period);
    spentLifeTimeNC = spentLifeTimeNC + spentLifeTime(ageingFactorNC, period);

    thoilCarray(ind) = thoilC;
    thhsCarray(ind) = thhsC;
    powerTransitCarray(ind) = min(powerTransitC, powerTransit(ind));
    
    thoilNCarray(ind) = thoilNC;
    thhsNCarray(ind) = thhsNC;

    if powerTransitC < powerTransit(ind)
        powerTransitRerouted = powerTransitRerouted + powerTransit(ind) - powerTransitC;
    end
    powerTransitTotal = powerTransitTotal + powerTransit(ind);

    ageingFactorsCarray(ind) = ageingFactorC;
    ageingFactorsNCarray(ind) = ageingFactorNC;
    umaxarray(ind) = umax;
    
end

if strcmp(parameters.figures,'all')
    subplot(2, 2, 1)
    plot(t, thoilCarray, t, thhsCarray, t, thoilNCarray, t, thhsNCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Controlled Top-Oil', 'Controlled Hot-Spot', 'Uncontrolled Top-Oil', 'Uncontrolled Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')

    subplot(2, 2, 2)
    plot(t, powerTransitCarray, t, powerTransit)
    title('Power Transit')
    hleg1 = legend('Controlled', 'Uncontrolled');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')

    subplot(2, 2, 3)
    plot(t, ageingFactorsCarray, t, ageingFactorsNCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Controlled AF', 'Uncontrolled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')
    
    subplot(2, 2, 4)
    bar([1, 2], [spentLifeTimeC, spentLifeTimeNC; 0, 0])
    % bar([1, 2], [spentLifeTimeC, spentLifeTimeC; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Controlled LLT', 'Uncontrolled LLT');
    ylabel('LLT (minutes)')
    
elseif strcmp(parameters.figures,'1')
    plot(t, thoilCarray, t, thhsCarray, t, thoilNCarray, t, thhsNCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Controlled Top-Oil', 'Controlled Hot-Spot', 'Uncontrolled Top-Oil', 'Uncontrolled Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')

elseif strcmp(parameters.figures,'2')
    plot(t, powerTransitCarray, t, powerTransit)
    title('Power Transit')
    hleg1 = legend('Controlled', 'Uncontrolled');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')

elseif strcmp(parameters.figures,'3')
    plot(t, ageingFactorsCarray, t, ageingFactorsNCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Controlled AF', 'Uncontrolled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')

elseif strcmp(parameters.figures,'4')
    bar([1, 2], [spentLifeTimeC, spentLifeTimeNC; 0, 0])
    % bar([1, 2], [spentLifeTimeC, spentLifeTimeC; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Controlled LLT', 'Uncontrolled LLT');
    ylabel('LLT (minutes)')
end