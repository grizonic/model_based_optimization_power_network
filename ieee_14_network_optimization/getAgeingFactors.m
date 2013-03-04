function [obj]=getAgeingFactors(obj)

obj.ageingFactor = exp(15000/obj.thhsmax-15000/(obj.thhs + 273));