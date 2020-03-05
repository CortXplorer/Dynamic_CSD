%% GroupCL_ChangInSpikes.m

% This script takes *.mat files out of the figs/Group_Spikes folder which is
% generated by the ChangeInSpikes.m script. MAKE SURE you run the Change in
% Spikes script on the current group.m and _DATA.mat so that things match
% up. This script is dynamic in group size but will need tweaking if a
% group is added. 

% Normalization of the layer to the highest peak of any pre laser
% measurement in that measurement can be toggled (yesnorm)

%Input:     D:\MyCode\Dynamic_CSD_Analysis\figs\Group_Spikes -> *SpikesAll.mat
%Output:    D:\MyCode\Dynamic_CSD_Analysis\figs\Group_Spikes -> figures and
%           pdfs of full Spikes and layer-wise Spikes 

clear
%% standard operations
warning('OFF');
dbstop if error

% Change directory to your working folder
if exist('D:\MyCode\Dynamic_CSD_Analysis','dir') == 7
    cd('D:\MyCode\Dynamic_CSD_Analysis');
elseif exist('C:\Users\kedea\Documents\Dynamic_CSD_Analysis','dir') == 7
    cd('C:\Users\kedea\Documents\Dynamic_CSD_Analysis')
end

home = pwd; 
addpath(genpath(home));
layers = {'All', 'I_IIE', 'IVE', 'VE', 'VIE'};
stimlist = [2,5,10,20,40];

%% Group specific calling!

cd (home),cd groups
% get active animals lists
run('KIC.m')
KICan = animals;
run('KIT.m')
KITan = animals;
run('KIV.m')
KIVan = animals;
clear animals Cond Layer dB_lev channels
group = {'KIC','KIT','KIV'};

%% Choose Type

yesnorm = 1;            % 1 = normalize to highest Pre peak; 0 = don't


cd (home),cd figs,cd Group_Spikes
load('SpikesAll.mat')

%% To Norm or not to Norm

% normalize to all stim of a layerwise or full column call to the highest
% peak of any stimulus (i.e. 2 Hz) of the layer of that animal
Subject = 0;
if yesnorm == 1
    for iAn = 1:size(PeakofPre,3)
        if sum(sum(PeakofPre(:,:,iAn))) == 0
            continue
        end
        Subject = Subject + 1;
        for iStim = 1:size(PeakofPre,1)
            for iLay = 1:size(PeakofPre,2)
                toNormto = PeakofPre(iStim,iLay,iAn);
                SpikesAll{iStim,iLay,Subject} = SpikesAll{iStim,iLay,iAn}/toNormto;
            end
        end
    end
    % if number of actual animals is less, cut off the end to the correct size
    if Subject < size(PeakofPre,3)
        SpikesAll = SpikesAll(:,:,1:Subject);
    end
end

%% Split the groups out

% known alphabetical order is also the order the matrix is generate in
KICgroup = SpikesAll(:,:,1:length(KICan));
KITgroup = SpikesAll(:,:,length(KICan)+1:length(KICan)+length(KITan));
KIVgroup = SpikesAll(:,:,length(KICan)+length(KITan)+1:length(KICan)+length(KITan)+length(KIVan));

 
%% stack groups and generate figures

% Note on how groups are currently structure: 
%       KICgroup{stimulus(i.e. 2 Hz),layer(i.e. IV),animal(i.e.KIC02)}...
%       (condition(i.e. pre-laser),time(ms))

for iGroup = 1:length(group)
    
    for iLay = 1:length(layers)
        
        % GA = group average
        AvgSpikesCurves = figure('Name',['GA_Spikes_Clicks_' layers{iLay} '_' group{iGroup}],'Position',[-1000 100 800 1100]);
        
        for iStim = 1:length(stimlist)
            subplot(length(stimlist),1,iStim);
            if iStim == 1
                title(['Group Spikes Clicks ' layers{iLay} ' ' group{iGroup}])
            end
            hold on
            
            if iGroup == 1
                stackedgroup = vertcat(KICgroup{iStim,iLay,:});
            elseif iGroup == 2
                stackedgroup = vertcat(KITgroup{iStim,iLay,:});
            elseif iGroup == 3
                stackedgroup = vertcat(KIVgroup{iStim,iLay,:});
            end
            
            cond1 = stackedgroup(1:5:end,:);
            cond2 = stackedgroup(2:5:end,:);
            % cond3 = stackedgroup(3:5:end,:);
            % cond4 = stackedgroup(4:5:end,:);
            cond5 = stackedgroup(5:5:end,:);
            
            % Pre
            plot(nanmean(cond1),'color',[0 0.4470 0.7410],'LineWidth',3)
            plot(nanstd(cond1)+nanmean(cond1),':','color',[0 0.4470 0.7410]) % errorbars at every ms...
            % post 1
            plot(nanmean(cond2),'color',[0.6350 0.0780 0.1840],'LineWidth',1.5)
            plot(nanstd(cond2)+nanmean(cond2),':','color',[0.6350 0.0780 0.1840])
            % post 2
            % plot(nanmean(cond3),'color',[0.8500 0.3250 0.0980],'LineWidth',1.5)
            % plot(nanstd(cond3)+nanmean(cond3),':','color',[0.8500 0.3250 0.0980])
            % post 3
            % plot(nanmean(cond4),'color',[0.4940 0.1840 0.5560],'LineWidth',1.5)
            % plot(nanstd(cond4)+nanmean(cond4),':','color',[0.4940 0.1840 0.5560])
            % post 3
            plot(nanmean(cond5),'color',[0.9290 0.6940 0.1250],'LineWidth',1.5)
            plot(nanstd(cond5)+nanmean(cond5),':','color',[0.9290 0.6940 0.1250])
        end
        
        legend('Pre Laser','std','15 min','std','60 min','std');
        h = gcf;
        savefig(h,['GA_Spikes_Clicks_' layers{iLay} '_' group{iGroup}],'compact')
        % sometimes pdf makes a funky error
        try
            saveas(h,['GA_Spikes_Clicks_'  layers{iLay} '_' group{iGroup} '.pdf'])
        catch
            fprint('No pdf saved for this file')
        end
        
        close (h)
    end
    
end
