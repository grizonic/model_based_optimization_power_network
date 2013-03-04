classdef agent
% write a description of the class here.

    properties
    % define the properties of the class here, (like fields of a struct)
        transformerData;
        thhsmax;
        fromNode;
        toNode;
        branch;
        
        % These variables contain the temperature of a 'step'wise
        % prediction
        thoil;
        thhs;
        step;
        ageingFactor;
        
        % These variables contain the temperature of a 'prediction'wise
        % prediction
        thoilPrediction;
        thhsPrediction;
        prediction;
        ageingFactorPrediction;
        
    end

    methods
    % methods, including the constructor are defined in this block

        function obj = agent(thoil, thhs, thhsmax, step, prediction, fromNode, toNode, branch)
            % class constructor
            obj.transformerData = getTransformerData();
            obj.thoil = thoil;
            obj.thhs = thhs;
            obj.thoilPrediction = thoil;
            obj.thhsPrediction = thhs;
            obj.thhsmax = thhsmax;
            obj.step = step;
            obj.prediction = prediction;
            obj.fromNode = fromNode;
            obj.toNode = toNode;
            obj.branch = branch;
        end

        function obj = getAgeingNode(obj, powerTransit)

            % Get Ageing Factors - Controlled
            obj = getAgeingFactors(obj);
            obj = getPredictionAgeingFactors(obj);
            obj = getNextPredictionTemp(obj, powerTransit);
            obj = getNextTemp(obj, powerTransit);
            
        end

    end
end