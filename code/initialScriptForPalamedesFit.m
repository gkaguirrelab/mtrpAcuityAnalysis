idx = and((axisAcuityData.posY == 0), (axisAcuityData.posX == 20));
idx = find(idx);

alphas = [1:.01:25];
prior = PAL_pdfNormal(alphas,0,2); %Gaussian

%Termination rule
stopcriterion = 'trials';
stoprule = 100;
PFfit = @PAL_Gumbel;    %Shape to be assumed
beta = 2;               %Slope to be assumed
lambda  = 0.01;         %Lapse rate to be assumed
meanmode = 'mean';      %Use mean of posterior as placement rule

%set up procedure
RF = PAL_AMRF_setupRF('priorAlphaRange', alphas, 'prior', prior,...
    'stopcriterion',stopcriterion,'stoprule',stoprule,'beta',beta,...
    'lambda',lambda,'PF',PFfit,'meanmode',meanmode);

for ii=1:length(idx)
RF = PAL_AMRF_updateRF(RF, axisAcuityData.cyclesPerDeg(idx(ii)), axisAcuityData.response(idx(ii)));
end