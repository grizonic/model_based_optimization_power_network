function [thoil, thhs, powerTransit]=simulateTransformer(thoil, thhs, powerTransit, transformerData, maxTemp)

[thoil, thhs] = getNextTemp(thoil, thhs, powerTransit, transformerData);

% No Control
if (maxTemp ~= false) && (thhs > maxTemp)
    umax = getUMax(thoil, thhs, maxTemp, transformerData);
    [thoil, thhs] = getNextTemp(thoil, thhs, umax, transformerData);
    powerTransit = umax;
end