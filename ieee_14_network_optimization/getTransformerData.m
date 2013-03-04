function [transformerData]=getTransformerData()

% what are these?
transformerData.thoilrated=75;
transformerData.thhsrated=75+20.3;
transformerData.delthoilrated=38.3;
transformerData.delthhsrated=20.3;
%%

transformerData.n=0.25;
transformerData.mfluid=73887;
transformerData.P=411780+29469+43391;
transformerData.tauoilrated=0.48*transformerData.mfluid* ...
    transformerData.delthoilrated*60/transformerData.P;
transformerData.uthamb=25.6;
transformerData.R=1000;
transformerData.pcudcpu=411780/(411780+29469);
transformerData.pcueddypu=29469/(411780+29469);


transformerData.tauwdgrated=6;
% transformerData.tauwdgrated=30;
% transformerData.h=30;