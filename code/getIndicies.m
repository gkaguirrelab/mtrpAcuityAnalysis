function idx = getIndicies(axisAcuityData, position, varargin)
% Find the indicies in axisAcuityData for a specified position
%
% Syntax:
%   plotSingleStaircase = plotStaircase(axisAcuityData)
%
% Description:
%   Uses the data structure axisAcuityData to create a graph of stimulus
%   carrier frequency (in cycles per degree) over time (measured by trial
%   number) in one location given by degrees in eccentricity on the X and Y
%   axis.
%
% Inputs:
%   axisAcuityData        - Structure, with the fields:
%       posX                - Measured by degrees of eccentricity along the
%                             x-axis
%       posY                - Measured by degrees of eccentricity along the
%                             y-axis
%       cyclesPerDeg        - Carrier spatial frequency of stimulus cyc/deg
%       response            - Hit -- 1 Miss -- 0
%   position              - Numeric or cell array. Each entry is a 1x2
%                           vector that provides the [x, y] position in
%                           degrees of the stimuli to be plotted.
%
% Optional key/value pairs:
%  'posMatchTolerance'    - Scalar. How far away from the specified
%                           position can a stimulus position be and still
%                           be called a match? Needed because Metropsis
%                           will assign different stimuli slightly
%                           different position values due to rounding
%                           effects.
%
% Outputs:
%   idx                   - 1xn vector of logical values. Indicates the
%                           trials in axisAcuityData that have one of the
%                           specified positions.
%
% Examples
%{
%}



%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('axisAcuityData',@isstruct);
p.addRequired('position', @(x)(isnumeric(x) | iscell(x)));

% Optional params
p.addParameter('posMatchTolerance',0.1, @isscalar);


%% Parse and check the parameters
p.parse(axisAcuityData, position, varargin{:});


%% Obtain the vector of responses for this position
% Find the indices in axisAcuityData with stimuli at the specified location
% on the screen in degrees.
if isnumeric(position)
    position = {position};
end
idx = false(size(axisAcuityData.posX));
for ii=1:length(position)
    thisPos = position{ii};
    idx(and(abs(axisAcuityData.posX-thisPos(1))<p.Results.posMatchTolerance, ...
        abs(axisAcuityData.posY-thisPos(2))<p.Results.posMatchTolerance))=true;
end


end