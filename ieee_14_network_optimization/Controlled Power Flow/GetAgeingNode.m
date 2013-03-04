function [ageingFactor, thhsNext, thoilNext] = GetAgeingNode(powerTransit, thhs, thoil, transformerData, thhsrated)

% Get Ageing Factors - Controlled
[ageingFactor] = getAgeingFactors(thhs, thhsrated);
[thoilNext, thhsNext] = getNextTemp(thoil, thhs, powerTransit, transformerData, 1);