function [plotStaircase] = createStaircasePlot(axisAcuityData)


%{
dataBasePath = getpref('mtrpAcuityAnalysis','mtrpDataPath');
    expFolderSet = {'Exp_PRCM0';'Exp_CRCM0';'Exp_PRCM4';'Exp_CRCM4';'Exp_CRCM9';'Exp_PRCM1';'Exp_CRCM1'};
    for k = 1:8
        expFolder = expFolderSet(k,1);
        fnameCell = fullfile(dataBasePath,expFolder,'Subject_JILL NOFZIGER','JILL NOFZIGER_1.txt');
        fname = char(fnameCell)
        axisAcuityData = readRawMetropsis(fname)
        plotStaircase = createStaircasePlot(axisAcuityData)
    end



    load('Example variable structure');
    [plotStaircase] = createStaircasePlot(axisAcuityData)



%}
% load('Example variable structure');
% axisAcuityData = readRawMetropsis(fname)
table = [axisAcuityData.cyclesPerDeg axisAcuityData.posX axisAcuityData.posY  axisAcuityData.response];

for ii = [-20]% -10 -5 -2.5 2.5 5 10 20]
    if table(:,2)==0
        ind = table(:,3) == ii;
    else
        ind = table(:,2) == ii;  % Extract rows w/desired X position
    end
    tableVal = table(ind,:);   % Create tables from rows (all same X val)       
    [trialMax, ~] = size(tableVal);   % Generate trial #s for tables
    trialNum = (1:trialMax)';
    tableFin = [trialNum tableVal];
    indA = tableFin(:,2) ~= 1;      % Remove check tests
    tableNO = tableFin(indA,:)
        if ii == -20 
            left = 0.01;
            height = 0.89;
        elseif ii == -10
            left = 0.12;
            height = 0.78;
        elseif ii == -5
            left = 0.23;
            height = 0.67;
        elseif ii == -2.5
            left = 0.34;
            height = 0.56;
        elseif ii == 2.5
            left = 0.56;
            height = 0.34;
        elseif ii == 5
            left = 0.67;
            height = 0.23;
        elseif ii == 10
            left = 0.78;
            height = 0.12;
        elseif ii == 20
            left = 0.89;
            height = 0.01;
        end
  % Calculate position
  if tableNO(:,2) == tableNO(:,3)

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
    plotStaircase = plot(x, y);
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