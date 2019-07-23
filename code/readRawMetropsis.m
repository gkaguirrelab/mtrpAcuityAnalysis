function axisAcuityData = readRawMetropsis(fname, varargin)
% Extracts data from a Metropsis text file from the Peripheral Acuity Test
%
% Syntax:
%  axisAcuityData = readRawMetropsis(fname)
%
% Description:
%	The Metropsis system implements the Peripheral Acuity Test and outputs
%	the data in a text file. This code reads the text file and extracts the
%	information into data structures.
%
% Inputs:
%	fName                 - Char vector or string. Path to the text file to
%                           be read. Can be relative to Matlab's current
%                           working directory, or absolute.
%
% Optional key-value pairs
%  'responseColumn'       - Scalar. Specifies the column in the metropsis
%                           data text file that contains subject responses
%                           on each trial.
%  'yPosColumn'           - Scalar. Column with the stimulus y position.
%  'xPosColumn'           - Scalar. Column with the stimulus y position.
%  'spatialFreqColumn'    - Scalar. Column with the stimulus carrier freq.
%
% Outputs:
%   axisAcuityData        - Structure, with the fields:
%       posX              - Measured by degrees of eccentricity along the x
%                           axis
%       posY              - Measured by degrees of eccentricity along the y
%                           axis
%       cyclesPerDeg      - Carrier spatial frequency of stimulus cyc/deg
%       response          - Hit -- 1 Miss -- 0
%
% History:
%    07/10/19  jen       Created module from previous code
%    07/19/19  jen/gka   Comments and even more modular
%
% Examples:
%{
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    subject = 'Subject_JILL NOFZIGER';
    acquisition = 'JILL NOFZIGER_1.txt';
    expFolderSet = {'Exp_PRCM0';'Exp_CRCM0';'Exp_PRCM4';'Exp_CRCM4';'Exp_CRCM9';'Exp_PRCM9';'Exp_PRCM1';'Exp_CRCM1'};
    for ii = 1:length(expFolderSet)
        expFolder = expFolderSet{ii};
        fname = fullfile(dataBasePath,expFolder,subject,acquisition);
        tmpAcuityData = readRawMetropsis(fname);
        if ii==1
            axisAcuityData = tmpAcuityData;
        else
            axisAcuityData = cell2struct(cellfun(@vertcat,struct2cell(axisAcuityData),struct2cell(tmpAcuityData),'uni',0),fieldnames(axisAcuityData),1);
        end
    end

    % Save the axisAcuityData in the data directory for this project
    thisFuncPath = which('readRawMetropsis');
    tmp = strsplit(thisFuncPath,'code');
    savePath = fullfile(tmp{1},'data',[subject,'_axisAcuityData.mat']);
    save(savePath,'axisAcuityData');
%}


%% Parse vargin for options passed here
p = inputParser; p.KeepUnmatched = false;

% Required
p.addRequired('fname',@ischar);

% Optional params
p.addParameter('responseColumn',24,@isscalar);
p.addParameter('yPosColumn',23,@isscalar);
p.addParameter('xPosColumn',22,@isscalar);
p.addParameter('spatialFreqColumn',12,@isscalar);


%% Parse and check the parameters
p.parse(fname, varargin{:});


%% Main

% Pre-allocate the return variable
axisAcuityData = struct;

% Open for reading the identified file
fileID = fopen(fname);

% Read in the entire contents of the text file as strings
retrieveValueStr = readmatrix(fname, 'OutputType', 'string');

% Extact the subject responses
responseTable = retrieveValueStr(:,p.Results.responseColumn);

% Delete "NA" responses
responseNA = rmmissing(responseTable);
responseChr = responseNA(responseNA ~= 'NA');

% Convert string array to numeric and store in axisAcuityData
responseHex = regexprep(responseChr, 'Hit', '01');
responseHex2 = regexprep(responseHex, 'Miss', '00');
responseHex3 = regexprep(responseHex2, 'No Response', '02');
responseDec = hex2dec(responseHex3);
responseDec(responseDec == 2) = nan;
axisAcuityData.response = responseDec;

% Read in the text file again, now as numeric values
retrieveValue = readmatrix(fname);

% Extract the Y position of the stimulus
positionYnan = retrieveValue(:,p.Results.yPosColumn);
axisAcuityData.posY = rmmissing(positionYnan);  % Remove Nan from vector

% Extract the X position of the stimulus
positionXnan = retrieveValue(:,p.Results.xPosColumn);
axisAcuityData.posX = rmmissing(positionXnan);  % Remove Nan from vector

% Extract the carrier spatial frequency of the stimulus
carrierSFRaw = retrieveValue(:,p.Results.spatialFreqColumn);
carrierSFRaw = rmmissing(carrierSFRaw);   % Remove Nan from vector
carrierSFRaw = carrierSFRaw(carrierSFRaw ~= 0); % Remove entries with zero

% This column contains both the spatial frequency values as well as some
% psychometric derived value. We just retain the first n rows, where n is
% equal to the number of entries in the spatial position variables.
carrierSFRaw = carrierSFRaw(1:length(axisAcuityData.posX));
axisAcuityData.cyclesPerDeg = carrierSFRaw;

% Close the text file file
fclose(fileID);

end
