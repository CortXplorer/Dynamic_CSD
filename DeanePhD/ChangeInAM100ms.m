function ChangeInAM100ms(homedir)

% This script takes *.mat files out of the DATA/ folder. It checks the
% condition names and finds the measurements associated with repeated
% stimuli (currently clicks only). It then produces a table for Julia
% statistics to see the flow of Avrec/layer sinks 100ms x 10

%Input:     D:\MyCode\Dynamic_CSD_Analysis\DATA -> *DATA.mat
%Output:    Table in main folder containing rms for every 

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
AM_RMS100msx10 = array2table(zeros(0,8));

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
                    % Layers take the nan-sourced CSD! (flip it also)
                    avgchan = Data(iMeas).SglTrl_CSD{1, iStim}(str2num(Layer.(layers{iLay}){thisA}),:,:) *-1;
                    avgchan(avgchan < 0) = NaN;
                    avgchan = nanmean(avgchan);
                    % to get a consecutive line after calculating the peaks
                    % with NaN sources, we replace NaNs with zeros
                    avgchan(isnan(avgchan)) = 0;
                end
                if isnan(avgchan(1)) %some supragranular layers not there
                    continue
                end
                avgchan = avgchan(:,1:1377,:); %standard size here, some stretch to 1390 (KIC14)
                                
                for itrial = 1:size(avgchan,3)
                    
                    curtrial = avgchan(:,:,itrial);
                    count  = 200;
                    
                    for itab = 1:10
                        
                        curRms = rms(curtrial(count:count+100));
                        
                        count = count + 100;
                        
                        CurAMData = table({name(1:3)}, {name}, {layers{iLay}}, ...
                            {Data(iMeas).Condition},CLstimlist(iStim), ...
                            {itab}, {itrial}, {curRms});
                        
                        AM_RMS100msx10 = [AM_RMS100msx10; CurAMData];
                                                
                    end % table entry
                end % trial
            end % measurement
        end % stimulus type (2 Hz, 5 Hz)           
    end % layer
end % entry

% give the table variable names after everything is collected
AM_RMS100msx10.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','Which100ms','TrialNumber','RMS'};

% save the table in the main folder - needs to be moved to the Julia folder
% for stats
cd(homedir)
writetable(AM_RMS100msx10,'AM_RMS100msx10.csv')
