function ChangeInAvrecST(homedir)

% This script takes *.mat files out of the DATA/ folder. It checks the
% condition names and finds the measurements associated with repeated
% stimuli (currently clicks only). It then produces a table for Julia
% statistics and figure output with the peak amp and latency per single
% trial

%Input:     D:\MyCode\Dynamic_CSD_Analysis\DATA -> *DATA.mat
%Output:    Table in main folder containing peak amp and lat at a single
%           trial level

%% standard operations
warning('OFF');
dbstop if error

cd (homedir),cd DATA;

%% Load in
input = dir('*.mat');
entries = length(input);
layers = {'All', 'I_II', 'IV', 'V', 'VI'};
CLstimlist = [2,5,10];

% set up simple cell sheets to hold all data: avrec of total/layers and
% peaks of pre conditions
CLPeakData = array2table(zeros(0,10));
CLPeakDataFull = array2table(zeros(0,10));
AMPeakData = array2table(zeros(0,10));
AMPeakDataFull = array2table(zeros(0,10));

% loop through number of Data mats in folder
for i_In = 1:entries
    
    if contains(input(i_In).name,'Spikes')
        continue
    end
    
    clear Data
    load(input(i_In).name);
    name = input(i_In).name(1:5);
    
    % load in Group .m for layer info and point to correct animal
    cd (homedir),cd groups;
    thisG = [input(i_In).name(1:3) '.m'];
    run(thisG);
    thisA = find(contains(animals,name));
    if isempty(thisA)
        continue
    end
      
    %% Clicks
    for iLay = 1:length(layers)       
        for iStim = 1:length(CLstimlist)            
            for iMeas = 1:size(Data,2)
                
                if isempty(Data(iMeas).measurement)
                    continue
                end
                
                if ~contains((Data(iMeas).Condition),'CL_')
                    continue
                end
                
                % take an average of all channels at each trial
                if contains(layers{iLay}, 'All')
                    avgchan = mean(Data(iMeas).SingleRecCSD{1, iStim}); 
                else
                    avgchan = mean(Data(iMeas).SingleRecCSD{1, iStim}(str2num(Layer.(layers{iLay}){thisA}),:));
                end
                if isnan(avgchan(1)) %some supragranular layers not there
                    continue
                end
                avgchan = avgchan(1:1377); %standard size here, some stretch to 1390 (KIC14)
                % plot it if wanted
                % plot(squeeze(avgchan))
                
                for itrial = 1:size(avgchan,3)
                    [peakout,latencyout,rmsout] = consec_peaksST(avgchan(:,:,itrial), ...
                        CLstimlist(iStim), 1000, 1, 200);
                    for itab = 1:CLstimlist(iStim)
                        % the full data table gets every row - don't take if
                        % data was straight line (mechanical artifact)
                        if isnan(rmsout(itab))
                            continue
                        end
                        CurPeakData = table({name(1:3)}, {name}, {layers{iLay}}, ...
                            {Data(iMeas).Condition},CLstimlist(iStim), ...
                            {itab}, {itrial}, peakout(itab), latencyout(itab), rmsout(itab));
                        CLPeakDataFull = [CLPeakDataFull; CurPeakData];
                        
                        % only take data for this set if the peak is detected
                        if isnan(peakout(itab))
                            continue
                        end
                        CLPeakData = [CLPeakData; CurPeakData];
                    end % table entry
                end % trial      
            end % measurement
        end % stimulus type (2 Hz, 5 Hz)               
    end % layer
    
    %% Amplitude Modulation
    for iLay = 1:length(layers)       
        for iStim = 1:length(CLstimlist)            
            for iMeas = 1:size(Data,2)
                
                if isempty(Data(iMeas).measurement)
                    continue
                end
                
                if ~contains((Data(iMeas).Condition),'AM_')
                    continue
                end
                
                % take an average of all channels at each trial
                if contains(layers{iLay}, 'All')
                    avgchan = mean(Data(iMeas).SingleRecCSD{1, iStim}); 
                else
                    avgchan = mean(Data(iMeas).SingleRecCSD{1, iStim}(str2num(Layer.(layers{iLay}){thisA}),:));
                end
                if isnan(avgchan(1)) %some supragranular layers not there
                    continue
                end
                avgchan = avgchan(1:1377); %standard size here, some stretch to 1390 (KIC14)
                % plot it if wanted
                % plot(squeeze(avgchan))
                
                for itrial = 1:size(avgchan,3)
                    [peakout,latencyout,rmsout] = consec_peaksST(avgchan(:,:,itrial), ...
                        CLstimlist(iStim), 1000, 1, 200);
                    for itab = 1:CLstimlist(iStim)
                        % the full data table gets every row - don't take if
                        % data was straight line (mechanical artifact)
                        if isnan(rmsout(itab))
                            continue
                        end
                        CurPeakData = table({name(1:3)}, {name}, {layers{iLay}}, ...
                            {Data(iMeas).Condition},CLstimlist(iStim), ...
                            {itab}, {itrial}, peakout(itab), latencyout(itab), rmsout(itab));
                        AMPeakDataFull = [AMPeakDataFull; CurPeakData];
                        
                        % only take data for this set if the peak is detected
                        if isnan(peakout(itab))
                            continue
                        end
                        AMPeakData = [AMPeakData; CurPeakData];
                    end % table entry
                end % trial      
            end % measurement
        end % stimulus type (2 Hz, 5 Hz)               
    end % layer
end % entry

% give the table variable names after everything is collected
CLPeakDataFull.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','PeakAmp','PeakLat','RMS'};
CLPeakData.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','PeakAmp','PeakLat','RMS'};

AMPeakDataFull.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','PeakAmp','PeakLat','RMS'};
AMPeakData.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','PeakAmp','PeakLat','RMS'};

% save the table in the main folder - needs to be moved to the Julia folder
% for stats
cd(homedir)
writetable(CLPeakData,'AVRECPeakCLST.csv')
writetable(CLPeakDataFull,'AVRECPeakCLSTFull.csv')
writetable(AMPeakData,'AVRECPeakAMST.csv')
writetable(AMPeakDataFull,'AVRECPeakAMSTFull.csv')