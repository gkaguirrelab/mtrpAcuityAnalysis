function myData = readRawMetropsis(fname)
% Extracts data from Metropsis text file from the Peripheral Acuity Test
%
% Syntax:
%  myData = readRawMetropsis(fname)
%
% Description:
%	The Metropsis system implements the Peripheral Acuity Test and outputs
%	the data in a text file. This code reads the text file and extracts the
%	information into data structures.
%
% Inputs:
%	fName                 - Matlab string with filename. Can be relative to
%                           Matlab's current working directory, or
%                           absolute.
%
% Outputs:
%   myData
%       posX              - Measured by degrees of eccentricity along the x
%                           axis
%       posY              - Measured by degrees of eccentricity along the y
%                           axis
%       cyclesPerDeg      - Carrier spatial frequency of stimulus
%       response          - Hit -- 1 Miss -- 0 
%
% History:
%    07/10/19  jen       Created module from previous code
%
% Examples:
%{

    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    fname = fullfile(dataBasePath,'Exp_CRCM9','Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt');
    myData = readRawMetropsis(fname)
%}
myData = struct;


fid = fopen(fname);
% Collect correct responses
    % Retrieve text from response column
    retrieveValueStr = readmatrix(fname, 'OutputType', 'string');
    responseTable = retrieveValueStr(:,24);
    responseNA = rmmissing(responseTable);
    % Delete "NA" responses
    responseChr = responseNA(responseNA ~= 'NA');
    % Convert string array to numeric
    responseHex = regexprep(responseChr, 'Hit', '01');
    responseHex2 = regexprep(responseHex, 'Miss', '00');
    myData.response = hex2dec(responseHex2);

retrieveValue = readmatrix(fname);

%Collect Y position
    positionYnan = retrieveValue(:,23);
    myData.posY = rmmissing(positionYnan);  % Remove Nan from vector
    
% Collect X position
    positionXnan = retrieveValue(:,22);
    myData.posX = rmmissing(positionXnan);  % Remove Nan from vector

tableSize = length(myData.posX);

% Collect spatial frequencies
    carrierSFNan = retrieveValue(:,12);
    carrierSFNa = rmmissing(carrierSFNan);   % Remove Nan from vector
    carrierSFNorm = carrierSFNa(carrierSFNa ~= 0);
    myData.cyclesPerDeg = carrierSFNorm(1:tableSize,:);

end
