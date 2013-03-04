function [ageingFactors]=getAgeingFactors(thhs, ratedTemp, transients)
if transients == false
    ageingFactors = exp(15000/ratedTemp-15000/(thhs + 273));
else
    ageingFactors = exp(15000/ratedTemp-15000/(thhs + 273)) * 1.064;
end