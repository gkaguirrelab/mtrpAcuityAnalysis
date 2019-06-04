function [v_prime_w, u_prime_w, driftDiscrimination] = WIP_Raw_Data_Code(fName)
% Extracts data from Metropsis text file from the Peripheral Acuity Test


% Description:
%    The Metropsis system implements the Peripheral Acuity Test and outputs
%    the data in a text file. This code reads the text file and extracts 
%    the information necessary to calculate the SF threshold.


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
%
%

    % retrieve values 
    driftDiscrimination = getDriftDiscrimination(fName);
end
 
 
function driftDiscrimination = getDriftDiscrimination(fName)
    
    driftDiscrimination = [];
    
    % Lines we are searching for before we start extracting the azimuths table
    targetLine1 = 'Trials';
    targetLine2 = 'Events';
    targetLine3 = 'Drift Discrimination';
    
    % Open file (read /fid as file name)
    fid = fopen(fName);
    
    % Scan file one line at a time
    tline = fgetl(fid);
    
    while ischar(tline)
        % check for targetLine1
        if contains(tline, targetLine1)
            % check for targetLine2
            tline = fgetl(fid);
            if (contains(tline, targetLine2))
                % check for targetLine3
                tline=fgetl(fid);
                if (contains(tline, targetLine3))
                    keepLooping = true;
                    while (keepLooping)
                        % record the response of "hit" or "miss"
                         character = fscanf(fid, '%hitms'); 
                                if character >= 3
                                   %response = character;
                                else
                                    fprintf('Did not detect line: ''%s''.', targetLine2);
                                end
                            % move to the next line, always Visual Stimulus
                            tline = fget(fid);  
                            % record PositionX
                            % record PositionY                      
                            if (isempty(driftDiscriminationRowVals))
                                % All done
                                keepLooping = false; 
                            end
                     end % while (keepLooping)
                end
            end
        end 
        tline = fgetl(fid);
    end
    fclose(fid); 
end

 
