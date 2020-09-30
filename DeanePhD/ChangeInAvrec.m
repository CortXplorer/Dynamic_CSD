function ChangeInAvrec(homedir)

% This script takes *.mat files out of the DATA/ folder. It checks the
% condition names and finds the measurements associated with both clicks
% and AMs (seperately). It then plots the Avrecs for each animal over each
% frequency presentation.

%Input:     D:\MyCode\Dynamic_CSD_Analysis\DATA -> *DATA.mat
%Output:    Figures of in "ChangeIn_Avrec"

%Output:    Figures of in "Single_Avrec" Figures coming out are for Click and
%           Spontaneous measurements currently. Data out are for Click and
%           Spont as *.mat files for each type of measurement in 
%           fig/"Group_Avrec". mat files contain sorted AVREC data and the 
%           first peak amp detected for each AVREC. These are for
%           normalization and averaging in group scripts (next step)

%% standard operations
warning('OFF');
dbstop if error

% Change directory to your working folder
if ~exist('homedir','var')
    if exist('D:\MyCode\Dynamic_CSD','dir') == 7
        cd('D:\MyCode\Dynamic_CSD');
    elseif exist('D:\Dynamic_CSD_Analysis','dir') == 7
        cd('D:\Dynamic_CSD_Analysis');
    elseif exist('C:\Users\kedea\Documents\Dynamic_CSD_Analysis','dir') == 7
        cd('C:\Users\kedea\Documents\Dynamic_CSD_Analysis')
    end
    
    homedir = pwd;
    addpath(genpath(homedir));
end
cd (homedir),cd DATA;

%% Load in
input = dir('*.mat');
entries = length(input);
layers = {'All', 'I_II', 'IV', 'V', 'VI'};
CLstimlist = [2,5,10,20,40];

% set up simple cell sheets to hold all data: avrec of total/layers and
% peaks of pre conditions
AvrecAll = cell(length(CLstimlist),length(layers),entries);
PeakofPre = zeros(length(CLstimlist),length(layers),entries);
SP_AvrecAll = cell(length(layers),entries);
SP_PeakofPre = zeros(length(layers),entries);
CLPeakData = array2table(zeros(0,9));
AMPeakData = array2table(zeros(0,9));

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
    
    cd (homedir),cd figs;
    mkdir Single_Avrec; cd Single_Avrec;
    
    %% Clicks
    
    % 5 figures per animal
    for iLay = 1:length(layers)
        
        h = figure('Name',['Avrec_Clicks_' layers{iLay} '_' name],'Position',[10 10 1080 1200]);
        
        for iStim = 1:length(CLstimlist)
            % create container for lables
            CondN = cell(1,size(Data,2));
            
            % 1 subplot per stimulus
            subplot(length(CLstimlist),1,iStim);
            allmeas = [];
            
            for iMeas = 1:size(Data,2)
                if isempty(Data(iMeas).measurement)
                    continue
                end
                
                if ~contains((Data(iMeas).Condition),'CL_')
                    continue
                end
                
                % take an average of all channels (already averaged across trials)
                if contains(layers{iLay}, 'All')
                    avgchan = mean(Data(iMeas).LayerRecCSD{1, iStim}); 
                else
                    avgchan = mean(Data(iMeas).LayerRecCSD{1, iStim}(str2num(Layer.(layers{iLay}){thisA}),:));
                end
                avgchan = avgchan(1:1377); %standard size here, some stretch to 1390 (KIC14)
                % pull out condition
                CondN{1,iMeas} = Data(iMeas).Condition;
                % plot it
                plot(avgchan, 'LineWidth', 1)
                hold on
                % store this avg temporarily with buddies
                allmeas = vertcat(allmeas,avgchan);
                
                % store peak if preCL condition - only for normalization in
                % next step!
                if contains(CondN{1,iMeas},'preCL')
                    PeakofPre(iStim,iLay,i_In) = max(avgchan);
                end
                
                % if stim is 2 or 5 hz, pull out consecutive peak data
                if (iStim == 1 || iStim == 2) && nansum(avgchan) ~= 0
                    [peakout,latencyout,rmsout] = consec_peaks(avgchan, ...
                        CLstimlist(iStim), 1000, 1);
% %                     sanity check for peak detection
%                     if iStim == 1
%                         plot(latencyout(1)+200,peakout(1),'o')
%                         plot(latencyout(2)+700,peakout(2),'o')
%                     elseif iStim == 2
%                         plot(latencyout(1)+200,peakout(1),'o')
%                         plot(latencyout(2)+400,peakout(2),'o')
%                         plot(latencyout(3)+600,peakout(3),'o')
%                         plot(latencyout(4)+800,peakout(4),'o')
%                         plot(latencyout(5)+1000,peakout(5),'o')
%                     end
                    for itab = 1:CLstimlist(iStim)
                        CurPeakData = table({name(1:3)}, {name}, {layers{iLay}}, ...
                            {Data(iMeas).Condition},CLstimlist(iStim), ...
                            {itab}, peakout(itab), latencyout(itab),rmsout(itab));
                        CLPeakData = [CLPeakData; CurPeakData];
                    end
                end
                
            end
            
            % and store the lot
            AvrecAll{iStim,iLay,i_In} = allmeas;
            
            CondN = CondN(~cellfun('isempty',CondN));
            legend(CondN)
            title([num2str(CLstimlist(iStim)) ' Hz'])
            hold off
        end
        
        savefig(h,['Avrec_Clicks_' layers{iLay} '_' name],'compact')
        
        try
            saveas(h,['Avrec_Clicks_'  layers{iLay} '_' name '.pdf'])
        catch
            fprint('No pdf saved for this file')
        end
        
        close (h)
    end
    
    
    %% Amplitude Modulation
    
    % 5 figures per animal
    for iLay = 1:length(layers)
        
        h = figure('Name',['Avrec_Ams_' layers{iLay} '_' name],'Position',[10 10 1080 1200]);
        
        for iStim = 1:length(CLstimlist)
            % create container for lables
            CondN = cell(1,size(Data,2));
            
            % 1 subplot per stimulus
            subplot(length(CLstimlist),1,iStim);
            allmeas = [];
            
            for iMeas = 1:size(Data,2)
                if isempty(Data(iMeas).measurement)
                    continue
                end
                
                if ~contains((Data(iMeas).Condition),'AM_')
                    continue
                end
                
                % take an average of all channels (already averaged across trials)
                if contains(layers{iLay}, 'All')
                    avgchan = mean(Data(iMeas).LayerRecCSD{1, iStim}); 
                else
                    avgchan = mean(Data(iMeas).LayerRecCSD{1, iStim}(str2num(Layer.(layers{iLay}){thisA}),:));
                end
                avgchan = avgchan(1:1377); %standard size here, some stretch to 1390 (KIC14)
                % pull out condition
                CondN{1,iMeas} = Data(iMeas).Condition;
                % plot it
                plot(avgchan, 'LineWidth', 1)
                hold on
                % store this avg temporarily with buddies
                allmeas = vertcat(allmeas,avgchan);
                
                % store peak if preAM condition - only for normalization in
                % next step!
                if contains(CondN{1,iMeas},'preAM')
                    PeakofPre(iStim,iLay,i_In) = max(avgchan);
                end
                
                % if stim is 2 or 5 hz, pull out consecutive peak data
                if (iStim == 1 || iStim == 2) && nansum(avgchan) ~= 0
                    [peakout,latencyout,rmsout] = consec_peaks(avgchan, ...
                        CLstimlist(iStim), 1000, 1);

                    for itab = 1:CLstimlist(iStim)
                        CurPeakData = table({name(1:3)}, {name}, {layers{iLay}}, ...
                            {Data(iMeas).Condition},CLstimlist(iStim), ...
                            {itab}, peakout(itab), latencyout(itab),rmsout(itab));
                        AMPeakData = [AMPeakData; CurPeakData];
                    end
                end
                
            end
            
            % and store the lot
            AvrecAll{iStim,iLay,i_In} = allmeas;
            
            CondN = CondN(~cellfun('isempty',CondN));
            legend(CondN)
            title([num2str(CLstimlist(iStim)) ' Hz'])
            hold off
        end
        
        savefig(h,['Avrec_Clicks_' layers{iLay} '_' name],'compact')
        
        try
            saveas(h,['Avrec_Clicks_'  layers{iLay} '_' name '.pdf'])
        catch
            fprint('No pdf saved for this file')
        end
        
        close (h)
    end
    
    
    %% Spontaneous
    
    for iLay = 1:length(layers)
        
        h = figure('Name',['Avrec_Spontaneous_' layers{iLay} '_' name],...
            'Position',[100 100 800 400]);
        
        CondN = cell(1,size(Data,2));
        allmeas = [];
        
        for iMeas = 1:size(Data,2)
            if isempty(Data(iMeas).measurement)
                continue
            end
            
            if ~contains((Data(iMeas).Condition),'sp')
                continue
            end
            
            % take an average of all channels (already averaged across trials)
            % for spont data we are averaging all Stim into 1 after
            % stacking all channels (mean(vertcat(Data(iMeas).LayerRecCSD{1, :})))
            if contains(layers{iLay}, 'All')
                avgchan = mean(vertcat(Data(iMeas).LayerRecCSD{1, :}));
            else
                chan1 = Data(iMeas).LayerRecCSD{1, 1}(str2num(Layer.(layers{iLay}){thisA}),:);
                chan2 = Data(iMeas).LayerRecCSD{1, 2}(str2num(Layer.(layers{iLay}){thisA}),:);
                chan3 = Data(iMeas).LayerRecCSD{1, 3}(str2num(Layer.(layers{iLay}){thisA}),:);
                chan4 = Data(iMeas).LayerRecCSD{1, 4}(str2num(Layer.(layers{iLay}){thisA}),:);
                chan5 = Data(iMeas).LayerRecCSD{1, 5}(str2num(Layer.(layers{iLay}){thisA}),:);
                avgchan = mean(vertcat(chan1,chan2,chan3,chan4,chan5));
            end
            % pull out condition
            CondN{1,iMeas} = Data(iMeas).Condition;
            % plot it
            plot(avgchan, 'LineWidth', 1)
            hold on
            % store this avg temporarily with buddies
            if ~isempty(allmeas) && length(allmeas)>length(avgchan)
                diflength = length(allmeas) - length(avgchan);
                if diflength > 100
                    disp(['There is something wrong with the length on ' name])
                end
                endchunk = avgchan(end-diflength+1:end);
                avgchan = horzcat(avgchan, endchunk);
            end
            allmeas = vertcat(allmeas,avgchan);
            
            % store peak if preCL condition
            if contains(CondN{1,iMeas},'spPre')
                SP_PeakofPre(iLay,i_In) = max(avgchan);
            end
        end
        
        if isempty(allmeas)
            h = gcf; close(h)
            SP_PeakofPre(iLay,i_In) = 10;
            continue
        end
        
        % and store the lot
        SP_AvrecAll{iLay,i_In} = allmeas;
        
        CondN = CondN(~cellfun('isempty',CondN));
        legend(CondN)
        title('Spontaneous Data')
        hold off
        
        savefig(h,['Avrec_Spontaneous_Clicks_' layers{iLay} '_' name],'compact')
        
        try
            saveas(h,['Avrec_Spontaneous_Clicks_'  layers{iLay} '_' name '.pdf'])
        catch
            fprint('No pdf saved for this file')
        end
        
        close(h)
    end
    
    
    cd(homedir); cd DATA;
end

% give the table variable names after everything is collected
CLPeakData.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','PeakAmp','PeakLat','RMS'};
AMPeakData.Properties.VariableNames = {'Group','Animal','Layer','Measurement',...
    'ClickFreq','OrderofClick','PeakAmp','PeakLat','RMS'};

% save it out
cd (homedir),cd figs;
mkdir Group_Avrec; cd Group_Avrec;
save('AvrecAll','AvrecAll','PeakofPre');
save('Spont_AvrecAll','SP_AvrecAll','SP_PeakofPre');
% save the table in the main folder - needs to be moved to the Julia folder
% for stats
cd(homedir)
writetable(CLPeakData,'AVRECPeakCL.csv')
writetable(AMPeakData,'AVRECPeakAM.csv')