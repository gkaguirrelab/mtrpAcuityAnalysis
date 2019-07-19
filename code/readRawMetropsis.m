function [axisAcuityData, locate, locateX, blankRes, blankStim] = readRawMetropsis(fname, k, locate, locateX, blankRes, blankStim)
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
%   axisAcuityData
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
    locate = NaN(200,8);
    locateX = NaN(200,8);
    blankRes = NaN(200,8);
    blankStim = NaN(200,8);
    expFolderSet = {'Exp_PRCM0';'Exp_CRCM0';'Exp_PRCM4';'Exp_CRCM4';'Exp_CRCM9';'Exp_PRCM1';'Exp_CRCM1'};
    for k = 1:8
        expFolder = expFolderSet(k,1);
        fnameCell = fullfile(dataBasePath,expFolder,'Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt');
        fname = char(fnameCell)
        [axisAcuityData, locate, locateX, blankRes, blankStim] = readRawMetropsis(fname, k, locate, locateX, blankRes, blankStim)
    end
%}
axisAcuityData = struct;


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
    numResp = hex2dec(responseHex2);
    
    extSp = 200-length(numResp);
    additionRes = NaN(extSp,1);
    totalVecRes = [numResp;additionRes];
    blankRes(:,k) = totalVecRes;
    colVecRes = blankRes(:);
    axisAcuityData.response = rmmissing(colVecRes);
    

retrieveValue = readmatrix(fname);

%Collect Y position

    positionYnan = retrieveValue(:,23);
    posiY = rmmissing(positionYnan);  % Remove Nan from vector
    extraZero = 200-length(posiY);
    addition = NaN(extraZero,1);
    totalVec = [posiY;addition];
    locate(:,k) = totalVec;
    colVec = locate(:);
    axisAcuityData.posY = rmmissing(colVec);
    
   
    
    
% Collect X position
    positionXnan = retrieveValue(:,22);
    posiX = rmmissing(positionXnan);  % Remove Nan from vector
    extraZ = 200-length(posiX);
    additionX = NaN(extraZ,1);
    totalVecX = [posiX;additionX];
    locateX(:,k) = totalVecX;
    colVecX = locateX(:);
    axisAcuityData.posX = rmmissing(colVecX);


numTrials(:,k) = length(posiX)
% Collect spatial frequencies
    carrierSFNan = retrieveValue(:,12);
    carrierSFNa = rmmissing(carrierSFNan);   % Remove Nan from vector
    cPd = carrierSFNa(carrierSFNa ~= 0);
    snipcPd = cPd(1:numTrials,:);
    extra = 200-length(snipcPd);
    additionCPD = NaN(extra,1);
    totalVecCPD = [snipcPd;additionCPD];
    blankStim(:,k) = totalVecCPD;
    colVecCPD = blankStim(:);
    axisAcuityData.cyclesPerDeg = rmmissing(colVecCPD);


end
