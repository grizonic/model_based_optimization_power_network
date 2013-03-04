function [obj]=getNextTemp(obj, powerTransit)

thhs = obj.thhs;
thoil = obj.thoil;
transformerData = obj.transformerData;
step = obj.step;

mupu=exp(2797.3/(thoil+273))/exp(2797.3/(transformerData.thoilrated+273));

pcupu=transformerData.pcudcpu*(235+thhs)/(235+transformerData.thhsrated) ...
    +transformerData.pcueddypu*(235+transformerData.thhsrated)/(235+thhs);

thoilNext = thoil + ...
    step/(mupu^transformerData.n*transformerData.tauoilrated) * ...
    ((1+transformerData.R*powerTransit^2)/(1+transformerData.R)*mupu^transformerData.n*transformerData.delthoilrated - ...
    ((thoil-transformerData.uthamb)^(1+transformerData.n))/(transformerData.delthoilrated^transformerData.n));

thhsNext = thhs + ...
    step/(mupu^transformerData.n*transformerData.tauwdgrated) *...
    (powerTransit^2*pcupu*mupu^transformerData.n*transformerData.delthhsrated - ...
    ((thhs-thoil)^(transformerData.n+1))/(transformerData.delthhsrated^transformerData.n));

if thhsNext < thoilNext
    thhsNext = thoilNext;
end

obj.thhs = thhsNext;
obj.thoil = thoilNext;
