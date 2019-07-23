function [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData, varargin)
% Place staircase performance vector into evenly (log) spaced bins
%
% Syntax:
%  [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData)
%
% Description:
%   Given an axisAcuityData structure and key-value pairs that defined a
%   position, the routine will divide the set of trials at this location
%   into bins that are evenly log spaced and have the number of trials
%   specified by the nPerBin key-value parameter.
%
%   Derived from the function GetAggregatedStairTrials.m, contained in the
%   BrainardLabToolbox.
%
% Inputs:
%   axisAcuityData        - Structure, with the fields:
%       posX              - Measured by degrees of eccentricity along the x
%                           axis
%       posY              - Measured by degrees of eccentricity along the y
%                           axis
%       cyclesPerDeg      - Carrier spatial frequency of stimulus cyc/deg
%       response          - Hit -- 1 Miss -- 0
%
% Optional key/value pairs:
%  'posX', 'posY'         - Scalar(s). The x and y position in degrees of
%                           the stimuli to be plotted.
%  'nPerBin'              - Scalar. The number of trials to attempt to
%                           place within a bin.
%
% Outputs:
%   binCenters            - The center of each bin in linear spatial
%                           frequency units.
%   nCorrect              - 1xn vector. The number of correct responses in
%                           each bin, where n is the number of bins.
%   nTrials               - 1xn vector. The total number of trials in each
%                           bin.
%
% Examples:
%{
    % Bin data from a location from the first mat file in the data directory
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    tmp = dir(fullfile(dataBasePath,'*_axisAcuityData.mat'));
    dataFileName = fullfile(tmp(1).folder,tmp(1).name);
    load(dataFileName,'axisAcuityData')
    [binCenters,nCorrect,nTrials] = binTrials(axisAcuityData);
%}


%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('axisAcuityData',@isstruct);

% Optional params
p.addParameter('nPerBin',10,@isscalar);
p.addParameter('posX',0,@isscalar);
p.addParameter('posY',10,@isscalar);


%% Parse and check the parameters
p.parse(axisAcuityData, varargin{:});


%% Obtain the vector of responses for this position
% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
idx = and(axisAcuityData.posY == p.Results.posY, axisAcuityData.posX == p.Results.posX);
values = axisAcuityData.cyclesPerDeg(idx);
responses = axisAcuityData.response(idx);

% Conver the values to log spatial frequeny
logValues = log10(values);

% Perform the binning
[sortValues,index] = sort(logValues);
sortResponses = responses(index);
outIndex = 1;
bin = 1;
while (outIndex <= length(sortValues))
    logBinCenters(bin) = 0;
    nCorrect(bin) = 0;
    nTrials(bin) = 0;
    binCounter = 0;
    for i = 1:p.Results.nPerBin
        logBinCenters(bin) = logBinCenters(bin) + sortValues(outIndex);
        if (sortResponses(outIndex) == 1)
            nCorrect(bin) = nCorrect(bin) + 1;
        end
        nTrials(bin) = nTrials(bin) + 1;
        binCounter = binCounter + 1;
        outIndex = outIndex + 1;
        if (outIndex > length(sortValues))
            break;
        end
    end
    logBinCenters(bin) = logBinCenters(bin)/binCounter;
    bin = bin + 1;
end

% Convert logBinCenters back to linear units of spatial frequency
binCenters = 10.^logBinCenters;

end

