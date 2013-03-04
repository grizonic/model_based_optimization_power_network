function [obj]=getPredictionAgeingFactors(obj)

obj.ageingFactorPrediction = exp(15000/obj.thhsmax-15000/(obj.thhsPrediction + 273));