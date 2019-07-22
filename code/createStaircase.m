function plotSingleStaircase = createStaircase(axisAcuityData)
% Uses data file aquired through readRawMetropsis to plot a staircase graph
%
% Syntax:
%   plotSingleStaircase = createStaircase(axisAcuityData)
%
% Description:
%   Uses the data structure axisAcuityData to create a graph of stimulus carrier frequency (in cycles per
%   degree) over time (measured by trial number) in one location given by
%   degrees in eccentricity on the X and Y axis.
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
%
% Outputs:
%   plotSingleStaircase  - Staircase plot of carrier spatial frequencies in
%                          cycles per degree relative to trial number.
%                          
%
% History:
%    07/19/19  jen       Created module from previous code
% 
% Examples 
%{
    
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    load(fullfile('dataBasePath, 'data', 'Example variable structure'))
    [plotStaircase] = createStaircasePlot(axisAcuityData)

%}


%% Input location
degY = 0;
degX = 10;


%% Main 
idx = and((axisAcuityData.posY == degY), (axisAcuityData.posX == degX));
plotSingleStaircase = plot(1:sum(idx), axisAcuityData.cyclesPerDeg(idx));


end
