function [positionX, positionY, response] = WIP_Raw_Data_Code(fName)
% Extracts data from Metropsis text file from the Peripheral Acuity Test


% Description:
%    The Metropsis system implements the Peripheral Acuity Test and outputs
%    the data in a text file. This code reads the text file and extracts 
%    the information necessary to calculate the SF threshold.


% Inputs
%     fName          - Matlab string with filename. Can be relative to
%                      Matlab's current working directory, or absolute.


% Outputs:
%     response         - hit(1) or miss(0)  
%     positionX        - measured by degrees of eccentricity along X axis
%     positionY        - measured by degrees of eccentricity along Y axis
%     


% History:
%    05/31/19  jen       Created routine using code provided by dce
%
%

    % Retrieve values 
    response = getDriftDiscrimination(fName);
end
 
 
function response = getDriftDiscrimination(fname)
% Creates an empty matrix "response"
response = [];
    % Lines to search for before beginning the data pull
    targetLine1 = 'Trials';
    targetLine2 = 'Events';
    targetLine3 = 'Drift Discrimination';
    
    % Open the file
    fid = fopen(fname);
    
    % Read file one line at a time
    tline = fgetl(fid);

    while ischar(tline)
        if contains(tline, targetLine1)
            tline = fgetl(fid);
            if contains(tline, targetLine2)
                tline = fgetl(fid);
                if contains(tline, targetLine3)
                    keepLooping = true;
                    while (keepLooping)
                        % Run the code from the function below, store output as
                        % response (0,1)
                        response = getResponseData(fgetl(fid), 'Response');
                        % Read the next line (always Visual Stimulus)
                        tline = fgetl(fid);
                        % Record PositionX
                        % Record PositionY
                    end
                end
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

function val = getResponseData(lineString, propertyName)
    % Pull data from specified lineString that is either Hit or miss
    % and if miss, output = 0, if hit output = 1
    out = regexp(lineString, '(Hit|Miss)\w', 'match');
    if out == 'Miss'
        val = 0;
    else
        val = 1;
    end
end


% fname = 'C:\Users\Jill\Dropbox (Aguirre-Brainard Lab)\MTRP_data\Exp_PRCM0\Subject_JILL NOFZIGER\JILL NOFZIGER_1.txt';
% fid = fopen('C:\Users\Jill\Dropbox (Aguirre-Brainard Lab)\MTRP_data\Exp_PRCM0\Subject_JILL NOFZIGER\JILL NOFZIGER_1.txt');
A = readmatrix(fname);
positionXnan = A(:,22);
positionX = rmmissing(positionXnan);

positionYnan = A(:,23);
positionY = rmmissing(positionYnan);

responseNan = A(:,24);
response = rmmissing(responseNan);

results = [positionX positionY response]
fclose(fid);
