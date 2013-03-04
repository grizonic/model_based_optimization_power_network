function [thoilNext, thhsNext, powerTransit]=simulateTransformerUncontrolled(thoil, thhs, powerTransit, transformerData)

step = 1;
[thoilNext, thhsNext] = getNextTemp(thoil, thhs, powerTransit, transformerData, step);