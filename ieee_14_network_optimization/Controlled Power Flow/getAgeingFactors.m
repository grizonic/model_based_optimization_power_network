function [ageingFactors]=getAgeingFactors(thhs, ratedTemp)
ageingFactors = exp(15000/ratedTemp-15000/(thhs + 273));
    