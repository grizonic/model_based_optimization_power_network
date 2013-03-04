%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Runs a case datafile from MPC and enables agents in all nodes with
%   transformers;
%
%%%%%%%%%%%%%%%

function mainProcess(gridData)

mpc = loadcase(gridData);

%%%
step = 1;
prediction = 60;
[transformerBranches, agents] = getTransformersFromGridBranches(mpc.branch, step, prediction);

[powerTransit, t] = getProfile(2);
N = length(powerTransit);

numberBranches = length(mpc.branch(:, 1));

% Auxiliary variable in case we want to shift the focus period
start = 1;

% time = zeros
agentsAgeing = zeros(numberBranches, N);
agentsAgeingPrediction = zeros(numberBranches, N);
agentsPT = zeros(numberBranches, N);
agentsTemp = zeros(numberBranches, N);

% %% define named indices into bus, gen, branch matrices
% [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
%     VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
% [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
%     MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
%     QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
% [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
%     TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
%     ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

for ind=start:N
    
    % Load of node 13 in MVA
    mpc.bus(13, 3) = powerTransit(ind)*mpc.baseMVA;
    
    % Simulate 14 Bus Grid in DC
    mpopt = mpoption('PF_DC', 1, 'VERBOSE', 0);
    mpc = runpf(mpc, mpopt);
    
    for branch=1:numberBranches
        
        % If there's a transformer in this branch
        if cellfun('isempty', agents(branch)) == 0
            
            pt = abs(mpc.branch(branch, 14));
           
            % Calculate the temperature of the next minute and the
            % temperature over the prediction horizon
            agents{branch} = agents{branch}.getAgeingNode(pt/mpc.baseMVA);       
            agentsAgeing(branch, ind) = agents{branch}.ageingFactor;
            agentsAgeingPrediction(branch, ind) = agents{branch}.ageingFactorPrediction;
            agentsPT(branch, ind) = pt/mpc.baseMVA;
            agentsTemp(branch, ind) = agents{branch}.thhs;
            
            
        end
    end
end


%%%%%%%%%%%%%%% SUMMARY %%%%%%%%%%%%%%%%


for branch=1:numberBranches
    if cellfun('isempty', agents(branch)) == 0
        figure
        plot(t, agentsAgeing(branch,:), t+prediction, agentsAgeingPrediction(branch,:))
        hold on
        figure
        plot(t, agentsPT(branch,:))
        hold on
%         figure
%         plot(t, agentsTemp(branch,:))
%         hold on
    end
end


