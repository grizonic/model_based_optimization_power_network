function [transformers, agents]=getTransformersFromGridBranches(branch, step, prediction, initialTemp, maxTemp)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Extrapolates from the branches matrix which branches have transformers
%%%%%%%%%%%%%%%%%%%%%%%%%

% Agents initial data %
thoil = initialTemp;
thhs = initialTemp;
thhsmax = 273 + maxTemp;
%%%%%%%%%%%%%

transformers = zeros(length(branch),1);
agents=cell(length(branch),1);

for i=1:length(branch)
    % If tap ratio != 0 then the line has a transformer!
    if branch(i,9) ~= 0
        fromNode = branch(i, 1);
        toNode = branch(i, 2);
        transformers(i) = true;
        agents{i} = agent(thoil, thhs, thhsmax, step, prediction, fromNode, toNode, i);
    end
end