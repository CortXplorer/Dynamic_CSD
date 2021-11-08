function ChangeInRelres(homedir)

% This script takes *.mat files out of the DATA/ folder. It checks the
% condition names and finds the measurements associated with both clicks
% and AMs (seperately). It then plots the Relress for each animal over each
% frequency presentation.

%Input:     D:\MyCode\Dynamic_CSD_Analysis\DATA -> *DATA.mat
%Output:    Figures of in "ChangeIn_Relres"

%Output:    Figures of in "Single_Relres" Figures coming out are for Click and
%           Spontaneous measurements currently. Data out are for Click and
%           Spont as *.mat files for each type of measurement in 
%           fig/"Group_Relres". mat files contain sorted Relres data and the 
%           first peak amp detected for each Relres. These are for
%           normalization and averaging in group scripts (next step)

%% standard operations
warning('OFF');
dbstop if error

% Change directory to your working folder
if ~exist('homedir','var')
    if exist('E:\Dynamic_CSD','dir') == 7
        cd('E:\Dynamic_CSD');
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
CLstimlist = [2,5,10];
stimtype = {'CL_','AM_'};

% set up simple cell sheets to hold all data: relres of total/layers and
% peaks of pre conditions
CL_RelresAll = cell(length(CLstimlist),entries);
AM_RelresAll = cell(length(CLstimlist),entries);
SP_RelresAll = cell(entries);
CLRMSData = array2table(zeros(0,6));
AMRMSData = array2table(zeros(0,6));

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
    mkdir Single_Relres; cd Single_Relres;
    
    %% Clicks & AMs
    
    % 5 figures per animal
    for iTyp = 1:length(stimtype)

        h = figure('Name',['Relres_' stimtype{iTyp} name],'Position',[10 10 1080 1200]);

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

                if ~contains((Data(iMeas).Condition),stimtype{iTyp})
                    continue
                end

                % relres already computed for full column
                avgchan = Data(iMeas).RELRES_raw{1, iStim};

                avgchan = avgchan(1:1377)'; %standard size here, some stretch to 1390 (KIC14)
                % pull out condition
                CondN{1,iMeas} = Data(iMeas).Condition;
                % plot it
                plot(avgchan, 'LineWidth', 1)
                hold on
                % store this avg temporarily with buddies
                allmeas = vertcat(allmeas,avgchan);

                % store peak if preCL condition - only for normalization in
                % next step!


                % pull out consecutive peak data
                [~,~,rmsout] = consec_peaks(avgchan, ...
                    CLstimlist(iStim), 1000, 1);

                for itab = 1:CLstimlist(iStim)
                    CurRMSData = table({name(1:3)}, {name}, ...
                        {Data(iMeas).Condition},CLstimlist(iStim), ...
                        {itab},rmsout(itab));
                    if contains(stimtype{iTyp},'CL_')
                        CLRMSData = [CLRMSData; CurRMSData];
                    elseif contains(stimtype{iTyp},'AM_')
                        AMRMSData = [AMRMSData; CurRMSData];
                    end
                end

            end

            % and store the lot
            if contains(stimtype{iTyp},'CL_')
                CL_RelresAll{iStim,i_In} = allmeas;
            elseif contains(stimtype{iTyp},'AM_')
                AM_RelresAll{iStim,i_In} = allmeas;
            end

            CondN = CondN(~cellfun('isempty',CondN));
            legend(CondN)
            title([num2str(CLstimlist(iStim)) ' Hz'])
            hold off
        end

        savefig(h,['Relres_' stimtype{iTyp} name],'compact')

        try
            saveas(h,['Relres_' stimtype{iTyp} name '.pdf'])
        catch
            fprint('No pdf saved for this file')
        end

        close (h)
    end
    
    %% Spontaneous

    h = figure('Name',['Relres_Spontaneous_' name],...
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
        avgchan = vertcat(Data(iMeas).RELRES_raw{1, :})';

        % pull out condition
        CondN{1,iMeas} = Data(iMeas).Condition;

        % store this avg temporarily with buddies
        if ~isempty(allmeas) && length(allmeas)>length(avgchan)
            diflength = length(allmeas) - length(avgchan);
            if diflength > 100
                disp(['There is something wrong with the length on ' name])
            end
            endchunk = avgchan(end-diflength+1:end);
            avgchan = horzcat(avgchan, endchunk);
        else
            avgchan = avgchan(1:1377);
        end
        allmeas = vertcat(allmeas,avgchan);

        % plot it
        plot(avgchan, 'LineWidth', 1)
        hold on
    end

    % and store the lot
    SP_RelresAll{i_In} = allmeas;

    CondN = CondN(~cellfun('isempty',CondN));
    legend(CondN)
    title('Spontaneous Data')
    hold off

    savefig(h,['Relres_Spontaneous_Clicks_' name],'compact')

    try
        saveas(h,['Relres_Spontaneous_Clicks_'  name '.pdf'])
    catch
        fprint('No pdf saved for this file')
    end

    close(h)
    
    
    cd(homedir); cd DATA;
end

% give the table variable names after everything is collected
CLRMSData.Properties.VariableNames = {'Group','Animal','Measurement',...
    'ClickFreq','OrderofClick','RMS'};
AMRMSData.Properties.VariableNames = {'Group','Animal','Measurement',...
    'ClickFreq','OrderofClick','RMS'};

% save it out
cd (homedir),cd figs;
mkdir Group_Relres; cd Group_Relres;
save('CL_RelresAll','CL_RelresAll');
save('AM_RelresAll','AM_RelresAll');
save('Spont_RelresAll','SP_RelresAll');
% save the table in the main folder - needs to be moved to the Julia folder
% for stats
cd(homedir)
writetable(CLRMSData,'RelresPeakCL.csv')
writetable(AMRMSData,'RelresPeakAM.csv')