function mtrpAcuityAnalysisLocalHook

%  mtrpAcuityAnalysisLocalHook
%
% Configure things for working on the  mtrpAcuityAnalysis project.
%
% For use with the ToolboxToolbox.
%
% If you 'git clone' mtrpAcuityAnalysis into your ToolboxToolbox "projectRoot"
% folder, then run in MATLAB
%   tbUseProject('mtrpAcuityAnalysis')
% ToolboxToolbox will set up mtrpAcuityAnalysis and its dependencies on
% your machine.
%
% As part of the setup process, ToolboxToolbox will copy this file to your
% ToolboxToolbox localToolboxHooks directory (minus the "Template" suffix).
% The defalt location for this would be
%   ~/localToolboxHooks/mtrpAcuityAnalysisLocalHook.m
%
% Each time you run tbUseProject('mtrpAcuityAnalysis'), ToolboxToolbox will
% execute your local copy of this file to do setup for mtrpAcuityAnalysis.
%
% You should edit your local copy with values that are correct for your
% local machine, for example the output directory location.
%


%% Say hello.
fprintf('mtrpAcuityAnalysis local hook.\n');
projectName = 'mtrpAcuityAnalysis';

%% Delete any old prefs
if (ispref(projectName))
    rmpref(projectName);
end

%% Get the userID
[~, userID] = system('whoami');
userID = strtrim(userID);


%% Specify the base path of the data and analysis directories
if ismac
    % Code to run on Mac plaform
    MTRP_dataBasePath = fullfile(filesep,'Users',userID,'Dropbox (Aguirre-Brainard Lab)','MTRP_data');
    MTRP_analysisBasePath = fullfile(filesep,'Users',userID,'Dropbox (Aguirre-Brainard Lab)','MTRP_analysis');
elseif ispc
    % Remove windows prefix from userID
    tmp = strsplit(userID,filesep);
    userID = tmp{2};
    
    % Code to run on Windows platform
    MTRP_dataBasePath = fullfile('C:',filesep,'Users',userID,'Dropbox (Aguirre-Brainard Lab)','MTRP_data');
    MTRP_analysisBasePath = fullfile('C:',filesep,'Users',userID,'Dropbox (Aguirre-Brainard Lab)','MTRP_analysis');
    
else
    disp('What are you using?')
end

%% Set the prefs
setpref(projectName,'mtrpDataPath', MTRP_dataBasePath); 
setpref(projectName,'mtrpAnalysisPath', MTRP_analysisBasePath); 

