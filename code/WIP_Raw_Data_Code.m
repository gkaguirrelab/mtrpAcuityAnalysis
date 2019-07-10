function [binPlot, perRight] = WIP_Raw_Data_Code(fname)
% Extracts data from Metropsis text file from the Peripheral Acuity Test
%
% Syntax:
%  [plotData] = WIP_Raw_Data_Code(fname)
%
% Description:
%	The Metropsis system implements the Peripheral Acuity Test and outputs
%	the data in a text file. This code reads the text file and extracts the
%	information necessary to calculate the SF threshold into a four column
%	numeric array.
%
% Inputs:
%	fName                 - Matlab string with filename. Can be relative to
%                           Matlab's current working directory, or
%                           absolute.
%
% Outputs:
%	response              - hit or miss  
%	positionX             - measured by degrees of eccentricity along X
%                           axis
%	positionY             - measured by degrees of eccentricity along Y
%                           axis
%	carrierSF             - cycles per second(?)
%   plotData              - trial # v carrier SF for each graph in the
%                           location of where in the visual field the 
%                           measurement was taken
%
% History:
%    05/31/19  jen       Created routine using code provided by dce
%    06/06/19  jen       Added variables positionX and positionY
%    06/11/19  jen       Condensed and completed extraction process
%    06/25/19  jen       Added graphing of SF in cycles/degree v Trial #
%
% Examples:
%{
Original (works for sure)
    dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    fname = fullfile(dataBasePath,'Exp_CRCM9','Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt')
    [plotData, tableFin] = WIP_Raw_Data_Code(fname)


dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    fname = fullfile(dataBasePath,'Exp_CRCM9','Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt')
    [binPlot, perRight] = WIP_Raw_Data_Code(fname)


Experimental (where is your God now?)
dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
   expFolderSet = {'Exp_PRCM0';'Exp_CRCM0';'Exp_PRCM4';'Exp_CRCM4';'Exp_CRCM9';'Exp_PRCM1';'Exp_CRCM1'};
    for k = 1:8
        expFolder = expFolderSet(k,1)
        fnameCell = fullfile(dataBasePath,expFolder,'Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt');
        fname = char(fnameCell)
        [plotData, tableFin] = WIP_Raw_Data_Code(fname)
    end
%}


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
        
        % Location plot
%     [plotData, tableFin] = getPlot(table);
        % Bin plot
    [binPlot, perRight] = getBinPlot(table)
%     
%             % Location plot
%     [plotData, tableFin] = getPlot(table);
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

function [plotData, tableFin] = getPlot(table)
    for k = [-20 -10 -5 -2.5 2.5 5 ]%10 20]
        if table(:,2)==0
            ind = table(:,3) == k;
        else
            ind = table(:,2) == k;  % Extract rows w/desired X position
        end
        tableVal = table(ind,:);   % Create tables from rows        
        [trialMax, ~] = size(tableVal);   % Generate trial #s for tables
        trialNum = (1:trialMax)';
        tableFin = [trialNum tableVal];
        indA = tableFin(:,2) ~= 1;      % Remove check tests
        tableNO = tableFin(indA,:);
            if k == -20
                left = 0.01;
                height = 0.89;
            elseif k == -10
                left = 0.12;
                height = 0.78;
            elseif k == -5
                left = 0.23;
                height = 0.67;
            elseif k == -2.5
                left = 0.34;
                height = 0.56;
            elseif k == 2.5
                left = 0.56;
                height = 0.34;
            elseif k == 5
                left = 0.67;
                height = 0.23;
            elseif k == 10
                left = 0.78;
                height = 0.12;
            elseif k == 20
                left = 0.89;
                height = 0.01;
            end
      % Calculate position
      if table(:,2) == table(:,3)
          pos = [left left 0.10 0.10];
      elseif table(:,2) == (table(:,3)*(-1))
          pos = [left height 0.1 0.1];
      elseif table(:,2) == 0
          pos = [0.45 left 0.1 0.1];
      else 
          pos = [left 0.45 0.1 0.1];
      end
        x = tableNO(:,1);               % Plot graph
        y = tableNO(:,2);
        subplot('position', pos);
        plotData = plot(x, y);
        set(gca, 'visible', 'off');
        line([1, 25], [5,5], 'LineWidth', .1, 'Color', 'k');
        line([1,1], [0, 25], 'LineWidth', .1, 'Color', 'k');
        xint = '5';
        ymax = '25';
        xmax = '25';
        text(-1, 5, xint, 'FontSize', 7); 
        text(-2, 25, ymax, 'FontSize', 7);
        text(24, 1, xmax, 'FontSize', 7);
        hold off
    end
    
end

function [binPlot, perRight] = getBinPlot(table)
    for k = [5]
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
            % Create x axis
            limits = [lowerLim, upperLim];
            stim = mean(log10(limits));
            % Plot results
            
            binPlot = plot(2-stim, perRight, 'xk')
            hold on
            axis([0 2 0 1.1])
            ylabel('% correct')
            xlabel('2-mean(log10) of bin')
            title('Exp CRCM9')
        end
    end 
end

