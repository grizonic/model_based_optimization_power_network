function [thoilNext, thhsNext, powerTransit, umax, ageingFactorC]=simulateTransformerControlled(thoil, thhs, powerTransit, transformerData, ratedTemp, transients)

maxAF = 1;

step = transformerData.h;
[thoilNext, thhsNext] = getNextTemp(thoil, thhs, powerTransit, transformerData, step);
umax = getUMax(thoil, thhs, transformerData, ratedTemp, transients, maxAF);

% Get Ageing Factors - Controlled
ageingFactorC = getAgeingFactors(thhsNext, ratedTemp, transients);

% No Control
if ageingFactorC > maxAF
    [thoilNext, thhsNext] = getNextTemp(thoil, thhs, umax, transformerData, step);
    powerTransit = umax;
end
