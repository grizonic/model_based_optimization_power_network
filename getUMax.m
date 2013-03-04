function umax=getUMax(thoil, thhs, transformerData, ratedTemp, transients, maxAF)

if transients == true
    transientsFactor = 1.064;
else
    transientsFactor = 1;
end

mupu=exp(2797.3./(thoil+273))/exp(2797.3/(transformerData.thoilrated+273));

pcupu=transformerData.pcudcpu*(235+thhs)/(235+transformerData.thhsrated)+ ... 
    transformerData.pcueddypu*(235+transformerData.thhsrated)/(235+thhs);

maxTemp = 15000 / ((15000/ratedTemp) - log(maxAF/transientsFactor)) - 273;

umax = sqrt(((maxTemp-thhs)*mupu.^transformerData.n* ...
    transformerData.tauwdgrated/transformerData.h+(thhs-thoil).^ ...
    (transformerData.n+1)./transformerData.delthhsrated^transformerData.n)/ ...
    (pcupu.*mupu.^transformerData.n*transformerData.delthhsrated));
