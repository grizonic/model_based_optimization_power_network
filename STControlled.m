function[transients]=STControlled(parameters)

% Initial Values
transients = parameters.transients;

maxTemp = parameters.thmax; % Max allowed Temp
ratedTemp = 273 + parameters.thrated; % Rated temp for FAA calculation
multiFactor = parameters.factorpt; % Multiplication factor for input data

% All initial variables of the line, transformer, and power transit
% are stated inside these functions;
thoilC = parameters.thoil;
thhsC = parameters.thhs;
spentLifeTimeC = 0;
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

for ind=start:N
    
    lastthoilC = thoilC;
    lastthhsC = thhsC;
    
    if ((ind-start)/transformerData.h-floor((ind-start)/transformerData.h))*10 == 0
        % Controlled
        [thoilC, thhsC, powerTransitC, umax] = simulateTransformerControlled(lastthoilC, lastthhsC, powerTransit(ind), transformerData, ratedTemp, transients);
    else 
        umaxarray(ind) = umax;
        % Uncontrolled
        [thoilC, thhsC, powerTransitC] = simulateTransformerUncontrolled(lastthoilC, lastthhsC, min(powerTransit(ind), umaxarray(ind)), transformerData);
    end

    thoilCarray(ind) = thoilC;
    thhsCarray(ind) = thhsC;
    powerTransitCarray(ind) = min(powerTransitC, powerTransit(ind));

    if powerTransitC < powerTransit(ind)
        powerTransitRerouted = powerTransitRerouted + powerTransit(ind) - powerTransitC;
    end
    powerTransitTotal = powerTransitTotal + powerTransit(ind);
    
        
    % Get Ageing Factors - Controlled
    [ageingFactorC] = getAgeingFactors(lastthhsC, ratedTemp, transients);

    % Increase ageingFactor if transients are present
    if transients == true
        ageingFactorC = ageingFactorC * 1.064; % Bart's result
    end
        
    ageingFactorsCarray(ind) = ageingFactorC;
      
    spentLifeTimeC = spentLifeTimeC + spentLifeTime(ageingFactorC, 1);
        
    umaxarray(ind) = umax;
end

if strcmp(parameters.figures,'all')
    
    subplot(2, 2, 1)
    plot(t, thoilCarray, t, thhsCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Top-Oil', 'Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')

    subplot(2, 2, 2)
    plot(t, powerTransitCarray, t, powerTransit, t, umaxarray)
    title('Power Transit')
    hleg1 = legend('Controlled', 'Uncontrolled', 'Maximum');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')

    subplot(2, 2, 3)
    plot(t, ageingFactorsCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Controlled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')

    subplot(2, 2, 4)
    bar([1, 2], [spentLifeTimeC 0; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Controlled LLT');
    ylabel('LLT (minutes)')
    
elseif strcmp(parameters.figures,'1')
    plot(t, thoilCarray, t, thhsCarray)
    title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
    hleg1 = legend('Top-Oil', 'Hot-Spot');
    xlabel('Time (Minutes)')
    ylabel('Temperature (Celsius)')
    
elseif strcmp(parameters.figures,'2')
    plot(t, powerTransitCarray, t, powerTransit, t, umaxarray)
    title('Power Transit')
    hleg1 = legend('Controlled', 'Uncontrolled', 'Maximum');
    xlabel('time (minutes)')
    ylabel('power transit (pu)')
    
elseif strcmp(parameters.figures,'3')
    plot(t, ageingFactorsCarray)
    title('Ageing Factor (AF)')
    hleg1 = legend('Controlled AF', 'Uncontrolled AF');
    xlabel('time (minutes)')
    ylabel('ageing factor')
    
elseif strcmp(parameters.figures,'4')
    bar([1, 2], [spentLifeTimeC 0; 0, 0])
    title('Lost Life Time (LLT)')
    hleg1 = legend('Controlled LLT');
    ylabel('LLT (minutes)')
end

powerTransitTotal
powerTransitRerouted
spentLifeTimeC


% grid on;
% grid minor;
% xlabel ('Time (s)');
% ylabel ('Collective (inches)');

% figure(1);
% subplot(2, 2, 1)
% plot(t, thoilC, t, thhsC, t, thoilNC, t, thhsNC)
% title('Temperatures')
% en/
% subplot(2, 2, 2)
% plot(t, powerTransitC, t, powerTransitNC)
% title('Power Transit')
% 
% subplot(2, 2, 3)
% title('Ageing Factor')
% plot(t, ageingFactorsC, t, ageingFactorsNC)