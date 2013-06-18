function mpc = case4gs
%CASE4GS  Power flow data for 4 bus, 2 gen case from Grainger & Stevenson.
%   Please see CASEFORMAT for details on the case file format.
%
%   This is the 4 bus example from pp. 337-338 of "Power System Analysis",
%   by John Grainger, Jr., William Stevenson, McGraw-Hill, 1994.

%   MATPOWER
%   $Id: case4gs.m,v 1.4 2010/03/10 18:08:14 ray Exp $

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax
%	Vmin AgentPresence
mpc.bus = [
	1	3	50	0	0	0	1	1	0	230	1	1.1	0.9;
	2	1	50  0	0	0	1	1	0	230	1	1.1	0.9;
	3	1	50	0	0	0	1	1	0	230	1	1.1	0.9;
	4	1	200	0	0	0	1	1	0	230	1	1.1	0.9;
];

mpc.agentsPresence = [
    0;
    0;
    0;
    1;
    ];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	0	0	100	-100	1	100	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0	0.03	0	250	250	250	0	0	1	-360	360;
	1	3	0	0.03    0	250	250	250	0	0	1	-360	360;
	2	4	0	0.03	0	250	250	250	0	0	1	-360	360;
	3	4	0	0.03	0	250	250	250	0	0	1	-360	360;
];

% Perhaps also include the real age of the transformer?!

%% ageing data - incremental!
%	fbus	tbus   ageing
mpc.ageing = [
    1   2   1;
    1   3   1;
    2   4   1;
    3   4   1;
    ];
