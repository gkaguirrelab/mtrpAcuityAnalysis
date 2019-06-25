function [plotData, table] = WIP_Raw_Data_Code(fname)

% Extracts data from Metropsis text file from the Peripheral Acuity Test


% Description:
%    The Metropsis system implements the Peripheral Acuity Test and outputs
%    the data in a text file. This code reads the text file and extracts 
%    the information necessary to calculate the SF threshold into a four 
%    column numeric array. 
%


% Inputs
%     fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.


% Outputs:
%     response         - hit or miss  
%     positionX        - measured by degrees of eccentricity along X axis
%     positionY        - measured by degrees of eccentricity along Y axis
%     carrierSF        - cycles per second(?)
%


% History:
%    05/31/19  jen       Created routine using code provided by dce
%    06/06/19  jen       Added variables positionX and positionY
%    06/11/19  jen       Condensed and completed extraction process
%    06/25/19  jen       Added graphing of SF in cycles/degree v Trial #
%
%


%change this
fname = 'C:\Users\Jill\Dropbox (Aguirre-Brainard Lab)\MTRP_data\Exp_PRCM0\Subject_JILL NOFZIGER\JILL NOFZIGER_1.txt';


% Open file
fid = fopen(fname);



% Retrieve all variables
response = getResponseData(fname);
retrieveValue = readmatrix(fname);
positionY = getPositionY(retrieveValue);
positionX = getPositionX(retrieveValue);
tableSize = size(positionX,1);
carrierSF = getCarrierSF(retrieveValue, tableSize);


% Combine data from variables into an 4 column numeric array
table = [carrierSF positionX positionY response];


% Create tables of values for the different locations
        
        % peripheral data
    [plotData] = getPlot(table);

        % central data
%     [tableFin5 tableFinNeg5 tableFin25 tableFinNeg25, trialMaxCen] = getEccTablesCen(table);
end
 
 
function response = getResponseData(fname) 
    % Retrieve text from response column
    retrieveValueStr = readmatrix(fname, 'OutputType', 'string');
    responseTable = retrieveValueStr(:,24);
    responseNA = rmmissing(responseTable);
    % Delete "NA" responses
    responseChr = responseNA(responseNA ~= 'NA');
    % Convert string array to numeric
    responseHex = regexprep(responseChr, 'Hit', '01');
    responseHex2 = regexprep(responseHex, 'Miss', '00');
    response = hex2dec(responseHex2);
end


function positionY = getPositionY(retrieveValue)
    % Retrieve values of Y 
    positionYnan = retrieveValue(:,23);
    % Remove Nan from vector
    positionY = rmmissing(positionYnan);
end

function positionX = getPositionX(retrieveValue)
    % Retrieve values of X
    positionXnan = retrieveValue(:,22);
    % Remove Nan from vector
    positionX = rmmissing(positionXnan);
end


function carrierSF = getCarrierSF(retrieveValue, tableSize)
    % Retrieve SF vales
    carrierSFNan = retrieveValue(:,12);
    % Remove Nan from vector
    carrierSFNa = rmmissing(carrierSFNan);
    carrierSFNorm = carrierSFNa(carrierSFNa ~= 0);
    carrierSF = carrierSFNorm(1:tableSize,:);
    
end

function [plotData] = getPlot(table)
    for k = [-20 -10 10 20]
        ind = table(:,2) == k;  % Extract rows w/desired X position
        tableVal = table(ind,:);   % Create tables from rows        
        [trialMax, ~] = size(tableVal);   % Generate trial #s for tables
        trialNum = (1:trialMax)';
        tableFin = [trialNum tableVal];
        indA = tableFin(:,2) ~= 1;      % Remove check tests
        tableNO = tableFin(indA,:);
            if k == -20
                i = 0;
                left = 0.01;
            elseif k == -10
                i = 1;
                left = 0.13;
            elseif k == 10
                i = 2;
                left = .76;
            elseif k == 20
                i = 3;
                left = .88;
            end
                % Calculate position
        pos = [left 0.45 0.1 0.1];
        x = tableNO(:,1);               % Plot graph
        y = tableNO(:,2);
        subplot('position', pos);
        plotData = plot(x, y);
        set(gca, 'visible', 'off');
        line([1, 25], [3,3], 'LineWidth', 0.1, 'Color', 'k');
        line([1,1], [0, 15], 'LineWidth', 0.1, 'Color', 'k');
        hold off
        % trialMax = max([trialMax10 trialMaxNeg10 trialMax20 trialMaxNeg20]);
    end
end
