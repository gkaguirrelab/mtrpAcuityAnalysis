function plotSingleStaircase = createStaircase(axisAcuityData, varargin)
% Uses data file aquired through readRawMetropsis to plot a staircase graph
%
% Syntax:
%   plotSingleStaircase = createStaircase(axisAcuityData, varargin)
%
% Description:
%   Uses the data structure axisAcuityData to create a graph of stimulus carrier frequency (in cycles per
%   degree) over time (measured by trial number) in one location given by
%   degrees in eccentricity on the X and Y axis.
%
%
%
%
%
%
%

%{
    
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpCompiledDataPath');
    load(fullfile('dataBasePath, 'Example variable structure'))
    [plotStaircase] = createStaircasePlot(axisAcuityData)



load('dataBasePath, 'Example variable structure')
plotSingleStaircase = createStaircase(axisAcuityData)
%}


%% Input location
y = 0;
x = 10;


%% Main 
idx = and((axisAcuityData.posY == y), (axisAcuityData.posX == x));
plotSingleStaircase = plot(1:sum(idx), axisAcuityData.cyclesPerDeg(idx));


end
