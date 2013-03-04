function simulateGrid(gridData)


mpc = loadcase(gridData);
[powerTransit, t] = getProfile(1.55);

[transformerData] = getTransformerData();

thoil = 40.3;
thhs = 40.3;
thhsrated = 273 + 120;

N = length(powerTransit);

figure;
start = 1;

%Controlled Variables
thoilArray = zeros(1, N-start+1);
thhsArray = zeros(1, N-start+1);

%tmp
pfArray = zeros(1, N-start+1);
ageingArray = zeros(1, N-start+1);

load1 = zeros(1, N-start+1);
load2 = zeros(1, N-start+1);
load3 = zeros(1, N-start+1);
load4 = zeros(1, N-start+1);


for ind=start:N
    
    lastthoil = thoil;
    lastthhs = thhs;
    
    % Load of node 4 in MVA
    mpc.bus(4, 3) = powerTransit(ind)*mpc.baseMVA;
    mpopt = mpoption('PF_DC', 1, 'VERBOSE', 0);
    mpc = runpf(mpc, mpopt);

    for bus=1:length(mpc.bus(:, 1))
        if mpc.agentsPresence(bus) == 1
            [ageing, thhs, thoil] = GetAgeingNode(mpc.bus(bus, 3)/mpc.baseMVA, lastthhs, lastthoil, transformerData, thhsrated);
            %Hardcoded!
            %if ageing > 1
            mpc.ageing(2, 3) = 1+(ageing/2);
            mpc.ageing(4, 3) = 1+(ageing/2);
            %end
        end
    end
    
    thoilArray(ind) = thoil;
    thhsArray(ind) = thhs;
    
    pfArray(ind) = mpc.bus(bus, 3)/mpc.baseMVA;
    ageingArray(ind) = ageing;
    
    load1(ind) = -mpc.branch(1,16);
    load2(ind) = -mpc.branch(2,16);
    load3(ind) = -mpc.branch(3,16);
    load4(ind) = -mpc.branch(4,16);
    
end

% plot(t, thoilArray, t, thhsArray)
plot(t, load1, t, load2, t, load3, t, load4)
hleg1 = legend('Load 1->2', 'Load 1->3', 'Load 2->4', 'Load 3->4');

figure
plot(t, pfArray)
hold on
figure
plot(t, thhsArray)
hold on
figure
plot(t, ageingArray)
hold on






% % Initial ValuesV
% transients = parameters.transients;
% 
% maxTemp = parameters.thmax; % Max allowed Temp
% ratedTemp = 273 + parameters.thrated; % Rated temp for FAA calculation
% multiFactor = parameters.factorpt; % Multiplication factor for input data
% 
% % All initial variables of the line, transformer, and power transit
% % are stated inside these functions;
% thoilC = parameters.thoil;
% thhsC = parameters.thhs;
% spentLifeTimeC = 0;
% powerTransitRerouted = 0;
% powerTransitTotal = 0;
% 
% [transformerData] = getTransformerData();
% [powerTransit, t] = getProfile(multiFactor);
% transformerData.h = parameters.step;
% 
% N = length(t);
% figure;
% start = 1;
% 
% %Controlled Variables
% thoilCarray = zeros(1, N-start+1);
% thhsCarray = zeros(1, N-start+1);
% powerTransitCarray = zeros(1, N-start+1);
% ageingFactorsCarray = zeros(1, N-start+1);
% umaxarray = zeros(1, N-start+1);
% 
% for ind=start:N
%     
%     lastthoilC = thoilC;
%     lastthhsC = thhsC;
%     
%     if ((ind-start)/transformerData.h-floor((ind-start)/transformerData.h))*10 == 0
%         % Controlled
%         [thoilC, thhsC, powerTransitC, umax] = simulateTransformerControlled(lastthoilC, lastthhsC, powerTransit(ind), transformerData, maxTemp);
%     else 
%         umaxarray(ind) = umax;
%         % Uncontrolled
%         [thoilC, thhsC, powerTransitC] = simulateTransformerUncontrolled(lastthoilC, lastthhsC, min(powerTransit(ind), umaxarray(ind)), transformerData);
%     end
% 
%     thoilCarray(ind) = thoilC;
%     thhsCarray(ind) = thhsC;
%     powerTransitCarray(ind) = min(powerTransitC, powerTransit(ind));
% 
%     if powerTransitC < powerTransit(ind)
%         powerTransitRerouted = powerTransitRerouted + powerTransit(ind) - powerTransitC;
%     end
%     powerTransitTotal = powerTransitTotal + powerTransit(ind);
%     
%         
%     % Get Ageing Factors - Controlled
%     [ageingFactorC] = getAgeingFactors(lastthhsC, ratedTemp);
% 
%     % Increase ageingFactor if transients are present
%     if transients == true
%         ageingFactorC = ageingFactorC * 1.064; % Bart's result
%     end
%         
%     ageingFactorsCarray(ind) = ageingFactorC;
%       
%     spentLifeTimeC = spentLifeTimeC + spentLifeTime(ageingFactorC, 1);
%         
%     umaxarray(ind) = umax;
% end
% 
% if strcmp(parameters.figures,'all')
%     
%     subplot(2, 2, 1)
%     plot(t, thoilCarray, t, thhsCarray)
%     title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
%     hleg1 = legend('Top-Oil', 'Hot-Spot');
%     xlabel('Time (Minutes)')
%     ylabel('Temperature (Celsius)')
% 
%     subplot(2, 2, 2)
%     plot(t, powerTransitCarray, t, powerTransit, t, umaxarray)
%     title('Power Transit')
%     hleg1 = legend('Controlled', 'Uncontrolled', 'Maximum');
%     xlabel('time (minutes)')
%     ylabel('power transit (pu)')
% 
%     subplot(2, 2, 3)
%     plot(t, ageingFactorsCarray)
%     title('Ageing Factor (AF)')
%     hleg1 = legend('Controlled AF');
%     xlabel('time (minutes)')
%     ylabel('ageing factor')
% 
%     subplot(2, 2, 4)
%     bar([1, 2], [spentLifeTimeC 0; 0, 0])
%     title('Lost Life Time (LLT)')
%     hleg1 = legend('Controlled LLT');
%     ylabel('LLT (minutes)')
%     
% elseif strcmp(parameters.figures,'1')
%     plot(t, thoilCarray, t, thhsCarray)
%     title('Top-Oil (TO) and Hot-Spot (HS) Temperatures')
%     hleg1 = legend('Top-Oil', 'Hot-Spot');
%     xlabel('Time (Minutes)')
%     ylabel('Temperature (Celsius)')
%     
% elseif strcmp(parameters.figures,'2')
%     plot(t, powerTransitCarray, t, powerTransit, t, umaxarray)
%     title('Power Transit')
%     hleg1 = legend('Controlled', 'Uncontrolled', 'Maximum');
%     xlabel('time (minutes)')
%     ylabel('power transit (pu)')
%     
% elseif strcmp(parameters.figures,'3')
%     plot(t, ageingFactorsCarray)
%     title('Ageing Factor (AF)')
%     hleg1 = legend('Controlled AF', 'Uncontrolled AF');
%     xlabel('time (minutes)')
%     ylabel('ageing factor')
%     
% elseif strcmp(parameters.figures,'4')
%     bar([1, 2], [spentLifeTimeC 0; 0, 0])
%     title('Lost Life Time (LLT)')
%     hleg1 = legend('Controlled LLT');
%     ylabel('LLT (minutes)')
% end