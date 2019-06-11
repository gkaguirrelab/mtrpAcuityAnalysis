function [table] = WIP_Raw_Data_Code(fName)
%change this
fname = 'C:\Users\Jill\Dropbox (Aguirre-Brainard Lab)\MTRP_data\Exp_PRCM4\Subject_JILL NOFZIGER\JILL NOFZIGER_1.txt';
% Extracts data from Metropsis text file from the Peripheral Acuity Test


% Description:
%    The Metropsis system implements the Peripheral Acuity Test and outputs
%    the data in a text file. This code reads the text file and extracts 
%    the information necessary to calculate the SF threshold into a three 
%    column numeric array. 
%


% Inputs
%     fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.


% Outputs:
%     response         - hit or miss  
%     positionX        - measured by degrees of eccentricity along X axis
%     positionY        - measured by degrees of eccentricity along Y axis
%     


% History:
%    05/31/19  jen       Created routine using code provided by dce
%    06/06/19  jen       Added variables positionX and positionY
%    06/11/19  jen       Condensed and completed extraction process
%
%





% Open file
fid = fopen(fname);

% Retrieve all variables
response = getResponseData(fname);
positionY = getPositionY(fname);
positionX = getPositionX(fname);

% Combine data from variables into an 3 column numeric array
table = [positionX positionY response];
end
 
 
function response = getResponseData(fname) 
    % Retrieve text from response column
    
    retrieveValue = readmatrix(fname, 'OutputType', 'string');
    responseTable = retrieveValue(:,24);
    responseNA = rmmissing(responseTable);
    % Delete "NA" responses
    responseChr = responseNA(responseNA ~= 'NA');
    % Convert string array to numeric
    responseHex = regexprep(responseChr, 'Hit', '01');
    responseHex2 = regexprep(responseHex, 'Miss', '00');
    response = hex2dec(responseHex2);
end


function positionY = getPositionY(fname)
    % Retrieve values of Y 
    retrieveValue = readmatrix(fname);
    positionYnan = retrieveValue(:,23);
    % Remove Nan from vector
    positionY = rmmissing(positionYnan);
end

function positionX = getPositionX(fname)
    % Retrieve values of X
    retrieveValue = readmatrix(fname);
    positionXnan = retrieveValue(:,22);
    % Remove Nan from vector
    positionX = rmmissing(positionXnan);
end

