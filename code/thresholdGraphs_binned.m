function [plotBins, binTable] = thresholdGraphs_binned(fname)
% Extracts data from Metropsis text file from the Peripheral Acuity Test
%
% Syntax:
%  [plotBins, binTable] = thresholdGraphs_binned(fname)
%
% Description:
%	The Metropsis system implements the Peripheral Acuity Test and outputs
%	the data in a text file. This code reads the data from the text file
%	and separates the responses into bins. It then plots a graph of the
%	percentage correct resembling a sigmoid function.
%
% Inputs:
%	fName                 - Matlab string with filename. Can be relative to
%                           Matlab's current working directory, or
%                           absolute.
%
% Outputs:
%   bins                  - log spaced groups of SF's with ~5 data points
%                           per bin
%   plotBins              - % of responses correct vs 2-mean(log10) of the
%                           SF of each bin
%
% History:
%    07/10/19  jen       Created routine as separate file
%
% Examples:
%{

    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    fname = fullfile(dataBasePath,'Exp_CRCM9','Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt');
    [plotBins, binTable] = thresholdGraphs_binned(fname)
    
%}
 deg = -5
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
table = [carrierSF positionX positionY response]


% Plot percent correct vs 2-mean(log10) of SF bins       
[plotBins, binTable] = getPlot(table,deg);

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

function [plotBins, binTable] = getPlot(table,deg)
    for k = deg
        if table(:,2)==0
            ind = table(:,3) == k;
        else
            ind = table(:,2) == k;  % Extract rows w/desired X position
        end
        tableVal = table(ind,:);   % Create tables from rows        
        [trialMax, ~] = size(tableVal);   % Generate trial #s for tables
        trialNum = (1:trialMax)';
        tableFin = [trialNum tableVal];
        col = tableFin(:,2);
        totalTrial = length(col);
        binNum = (totalTrial/5)+2;      % Calculate # of bins needed
        maxVal = max(col);
        logMax = log10(maxVal);
        bins = logspace(0,logMax, binNum);   % Generate log spaced bins
        [~, cycles] = size(bins);          % Calculate # of iterations needed

        
        % Calculate % correct for each bin        
        for k = 2:cycles
            
            % Create bin ranges
            upperLim = bins(:,k);
            lowerLim = bins(:,k-1);
            rangeInd = tableFin(:,2)<= upperLim;
            tableInt = tableFin(rangeInd,:);
            binInd = tableInt(:,2)>= lowerLim;
            binMat = tableInt(binInd,:);
            
            % Determine how many were correct
            corrects = binMat(:,5) == 1;
            [numCorr, ~] = size(binMat(corrects,:));
            [numTotal, ~] = size(binMat);
            perRight = numCorr/numTotal;
            % Create x values
            limits = [lowerLim, upperLim];
            stim = mean(log10(limits));
            % Create table of x,y points
            valueOfStim(k-1) = stim;
            valueOfRight(k-1) = perRight;
            binTable = [valueOfStim' valueOfRight'];
            % Plot results
            plotBins = plot(2-stim, perRight, 'xk');
            hold on
            axis([0 2 0 1.1])
            ylabel('% correct')
            xlabel('2-mean(log10) of bin')
            title('Exp CRCM9')
        end
    end 
end