function[plotRealTime]=STComparison(parameters)

% Initial Values
plotRealTime = parameters.plotrealtime; % If True, then you should zoom using the variables below
startPlot = parameters.from;
endPlot = parameters.to;

maxTemp = parameters.thmax; % Max allowed Temp
ratedTemp = 273 + parameters.thrated; % Rated temp for FAA calculation
multiFactor = parameters.factorpt; % Multiplication factor for input data

% All initial variables of the line, transformer, and power transit
% are stated inside these functions;
thoilNC = parameters.thoil;
thhsNC = parameters.thhs;
thoilC = parameters.thoil;
thhsC = parameters.thhs;
spentLifeTimeC = 0;
spentLifeTimeNC = 0;

[transformerData] = getTransformerData();
[powerTransit, t] = getProfile(multiFactor);

N = length(t);
figure;

% If false we need some arrays
if plotRealTime == false
    thoilCarray = zeros(1, N);
    thoilNCarray = zeros(1, N);
    thhsCarray = zeros(1, N);
    thhsNCarray = zeros(1, N);
    powerTransitCarray = zeros(1, N);
    powerTransitNCarray = zeros(1, N);
    ageingFactorsCarray = zeros(1, N);
    ageingFactorsNCarray = zeros(1, N);
end

for ind=1:N
    
    lastthoilC = thoilC;
    lastthhsC = thhsC;
    lastthoilNC = thoilNC;
    lastthhsNC = thhsNC;
    
    % Controlled
    [thoilC, thhsC, powerTransitC] = simulateTransformer(lastthoilC, lastthhsC, powerTransit(ind), transformerData, maxTemp);

    % Uncontrolled
    [thoilNC, thhsNC, powerTransitNC] = simulateTransformer(lastthoilNC, lastthhsNC, powerTransit(ind), transformerData, false);
    
    % Get Ageing Factors - Controlled
    [ageingFactorC] = getAgeingFactors(lastthhsC, ratedTemp);
    % Get Ageing Factors - Uncontrolled
    [ageingFactorNC] = getAgeingFactors(lastthhsNC, ratedTemp);

    period = 1;

    spentLifeTimeC = spentLifeTimeC + spentLifeTime(ageingFactorC, period);
    spentLifeTimeNC = spentLifeTimeNC + spentLifeTime(ageingFactorNC, period);    
    
    if (plotRealTime == true) && (ind > startPlot) && (ind < endPlot)

        subplot(2, 2, 1)
        plot(ind, thoilC, '^', ind, thhsC, '^', ind, thoilNC, '*', ind, thhsNC, '*')
        title('Temperatures')
        hold on

        subplot(2, 2, 2)
        plot(ind, powerTransitC, '^', ind, powerTransitNC, '*')
        title('Power Transit')
        hold on

        subplot(2, 2, 3)
        plot(ind, ageingFactorC, '^', ind, ageingFactorNC, '*')
        title('Ageing Factor')
        hold on

        subplot(2, 2, 4)
        bar([1,2], [spentLifeTimeC,spentLifeTimeNC])
        title('Cumulative Lost Minutes')
        hold on

        drawnow

    elseif plotRealTime == false
        thoilCarray(ind) = thoilC;
        thoilNCarray(ind) = thoilNC;
        thhsCarray(ind) = thhsC;
        thhsNCarray(ind) = thhsNC;
        powerTransitCarray(ind) = powerTransitC;
        powerTransitNCarray(ind) = powerTransitNC;
        ageingFactorsCarray(ind) = ageingFactorC;
        ageingFactorsNCarray(ind) = ageingFactorNC;
    end
end

if plotRealTime == false

    subplot(2, 2, 1)
    plot(t, thoilCarray, t, thhsCarray, t, thoilNCarray, t, thhsNCarray)
    title('Temperatures')
    
    subplot(2, 2, 2)
    plot(t, powerTransitCarray, t, powerTransitNCarray)
    title('Power Transit')

    subplot(2, 2, 3)
    plot(t, ageingFactorsCarray, t, ageingFactorsNCarray)
    title('Ageing Factor')

    subplot(2, 2, 4)
    bar([1,2], [spentLifeTimeC,spentLifeTimeNC])
    title('Cumulative Lost Minutes')

end



% grid on;
% grid minor;
% xlabel ('Time (s)');
% ylabel ('Collective (inches)');

% figure(1);
% subplot(2, 2, 1)
% plot(t, thoilC, t, thhsC, t, thoilNC, t, thhsNC)
% title('Temperatures')
% 
% subplot(2, 2, 2)
% plot(t, powerTransitC, t, powerTransitNC)
% title('Power Transit')
% 
% subplot(2, 2, 3)
% title('Ageing Factor')
% plot(t, ageingFactorsC, t, ageingFactorsNC)