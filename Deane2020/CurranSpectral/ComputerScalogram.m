% Compute scalogram

% Generated by MATLAB(R) 9.6 and Signal Processing Toolbox 8.2.
% Generated on: 27-Apr-2019 13:18:07

% Parameters
thisFold = 'C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD\DATA\Spectral\GKD_02\AnesthetizedPre';
thisFold2 = 'C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD\DATA\Spectral\GKD_02\Muscimol';
thisFile = 'toneNumber5_2000Hz';
if ~exist('lfpDat')
    anes = load([thisFold thisFile]);
    musci = load([thisFold2 thisFile]);
end
sampleRate = 1000; % Hz
startTime = -0.2; % seconds
timeLimits = [-0.2 0.399]; % seconds
frequencyLimits = [0 sampleRate/2]; % Hz
voicesPerOctave = 8;
timeBandWidth = 54;

seeCWT(anes.lfpDat,sampleRate,startTime,timeLimits,frequencyLimits,voicesPerOctave,timeBandWidth,'anes')

seeCWT(musci.lfpDat,sampleRate,startTime,timeLimits,frequencyLimits,voicesPerOctave,timeBandWidth,'musci')


function seeCWT(lfpDat,sampleRate,startTime,timeLimits,frequencyLimits,voicesPerOctave,timeBandWidth,tit)

%%
% Index into signal time region of interest
oneChannel = squeeze(lfpDat.lfpTrials(:,1,:));
ROI = oneChannel(:,6);
timeValues = startTime + (0:length(ROI)-1).'/sampleRate;
minIdx = timeValues >= timeLimits(1);
maxIdx = timeValues <= timeLimits(2);
ROI = ROI(minIdx&maxIdx);
timeValues = timeValues(minIdx&maxIdx);



%%
% Limit the cwt frequency limits
frequencyLimits(1) = max(frequencyLimits(1),...
    cwtfreqbounds(numel(ROI),sampleRate,...
    'TimeBandWidth',timeBandWidth));

% Compute cwt
% Run the function call below without output arguments to plot the results
[WT,F] = cwt(ROI,sampleRate, ...
    'VoicesPerOctave',voicesPerOctave, ...
    'TimeBandWidth',timeBandWidth, ...
    'FrequencyLimits',frequencyLimits);

figure;
cwt(ROI,sampleRate, ...
    'VoicesPerOctave',voicesPerOctave, ...
    'TimeBandWidth',timeBandWidth, ...
    'FrequencyLimits',frequencyLimits);
title(tit)
set(gca,'CLim',[0 0.11])
% To plot myself, follow plotscalogramfreq
% To plot using contours:
[X,Y]=meshgrid(F,0:(size(WT,2)-1));
figure; contour(Y,X,abs(WT)',10)
set(gca,'YScale','log')
title(tit)
set(gca,'CLim',[0 0.11])
colorbar
% Continue looking at contour documentation to check what the output
% returns. Could use to identify bounded ROIs

end