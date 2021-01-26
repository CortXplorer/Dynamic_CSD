function AvgCSDfig(homedir)
%% Averaged CSD

% The purpose of this script is to provide an averaged CSD for visual
% representation of each analysis group. It gives specifically the pre and
% first post laser click and amplitude modulated csd 

%Input:     is DATA; specifically named per Kat's PhD groups
%Output:    is in figure folder AvgCSDs; figures only for representation of
%           characteristic profile


%% Load in info
cd(homedir);cd Data
input = dir('*.mat');
entries = length(input);
Group = {'KIC','KIT','KIV'};

% make some decisions about size
chanlength = 25; %max number of channels
timeaxis   = 1400; %actual time usually 1377ms
subjects   = 10;  %max number of subjects in group is 10

    for iGro = 1:length(Group)

        % preallocate csd holders
        CL5hzPre  = NaN(chanlength,timeaxis,subjects);
        CL5hzPos  = CL5hzPre;
        AM5hzPre  = CL5hzPre;
        AM5hzPos  = CL5hzPre;
        CL10hzPre = CL5hzPre;
        CL10hzPos = CL5hzPre;
        AM10hzPre = CL5hzPre;
        AM10hzPos = CL5hzPre;
        % count variables to keep our insertions orderly:
        count = 1;

        for iEnt = 1:entries
            cd(homedir);cd Data
            if ~contains(input(iEnt).name,Group(iGro))
                continue % skip if not the current group
            end
            if contains(input(iEnt).name,'Spikes')
                continue % skip if spikes data
            end

            % finally load the animal data in
            load(input(iEnt).name)
            % find the pre laser click measurement
            index = find(strcmp({Data.Condition}, 'preCL_1')==1);
            CurCL5hzPre = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurCL10hzPre = Data(index).CSD{1,3};
            % find the 1st post laser click measurement
            index = find(strcmp({Data.Condition}, 'CL_1')==1);
            CurCL5hzPos = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurCL10hzPos = Data(index).CSD{1,3};
            % find the pre laser AM measurement
            index = find(strcmp({Data.Condition}, 'preAM_1')==1);
            CurAM5hzPre = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurAM10hzPre = Data(index).CSD{1,3};
            % find the 1st post laser AM measurement
            index = find(strcmp({Data.Condition}, 'AM_1')==1);
            CurAM5hzPos = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurAM10hzPos = Data(index).CSD{1,3};
            % add the current data to the preallocated containers
            CL5hzPre(1:size(CurCL5hzPre,1),1:size(CurCL5hzPre,2),count)  = CurCL5hzPre;
            CL5hzPos(1:size(CurCL5hzPos,1),1:size(CurCL5hzPos,2),count)  = CurCL5hzPos;
            AM5hzPre(1:size(CurAM5hzPre,1),1:size(CurAM5hzPre,2),count)  = CurAM5hzPre;
            AM5hzPos(1:size(CurAM5hzPos,1),1:size(CurAM5hzPos,2),count)  = CurAM5hzPos;
            CL10hzPre(1:size(CurCL10hzPre,1),1:size(CurCL10hzPre,2),count) = CurCL10hzPre;
            CL10hzPos(1:size(CurCL10hzPos,1),1:size(CurCL10hzPos,2),count) = CurCL10hzPos;
            AM10hzPre(1:size(CurAM10hzPre,1),1:size(CurAM10hzPre,2),count) = CurAM10hzPre;
            AM10hzPos(1:size(CurAM10hzPos,1),1:size(CurAM10hzPos,2),count) = CurAM10hzPos;
            count = count + 1;
        end

        CL5hzPre = nanmean(CL5hzPre,3);
        CL5hzPos = nanmean(CL5hzPos,3);
        AM5hzPre = nanmean(AM5hzPre,3);
        AM5hzPos = nanmean(AM5hzPos,3);
        CL10hzPre = nanmean(CL10hzPre,3);
        CL10hzPos = nanmean(CL10hzPos,3);
        AM10hzPre = nanmean(AM10hzPre,3);
        AM10hzPos = nanmean(AM10hzPos,3);

        % produce CSD figure
        figure('Name',[Group{iGro} ' Average CSD'])

        subplot(241)
        imagesc(CL5hzPre(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('CL 5 Hz Pre')

        subplot(242)
        imagesc(CL5hzPos(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('CL 5 Hz Post')

        subplot(243)
        imagesc(AM5hzPre(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('AM 5 Hz Pre')

        subplot(244)
        imagesc(AM5hzPos(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('AM 5 Hz Post')

        subplot(245)
        imagesc(CL10hzPre(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('CL 10 Hz Pre')

        subplot(246)
        imagesc(CL10hzPos(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('CL 10 Hz Post')

        subplot(247)
        imagesc(AM10hzPre(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('AM 10 Hz Pre')

        subplot(248)
        imagesc(AM10hzPos(1:20,1:1377))
        caxis([-0.0005 0.0005])
        colormap('jet')
        title('AM 10 Hz Post')

        sgtitle([Group{iGro} ' Average CSD'])

        cd(homedir);cd figs; cd AvgCSDs
        h = gcf;
        set(h, 'PaperType', 'A4');
        set(h, 'PaperOrientation', 'landscape');
        set(h, 'PaperUnits', 'centimeters');
        savefig(h,[Group{iGro} ' Average CSD'],'compact')
        close (h)


    end
end




