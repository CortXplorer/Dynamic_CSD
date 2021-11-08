function AvgCSDawake(homedir)
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
    Group = {'CIC'};
    iGro  = 1;

    % make some decisions about size
    chanlength = 25; %max number of channels
    timeaxis   = 1400; %actual time usually 1377ms
    daysrecord = 6;  % days of recording

    % preallocate csd holders
    preCL5Hz  = NaN(chanlength,timeaxis,daysrecord);
    preCL10Hz  = NaN(chanlength,timeaxis,daysrecord);
    preAM5Hz  = NaN(chanlength,timeaxis,daysrecord);
    preAM10Hz  = NaN(chanlength,timeaxis,daysrecord);
    preAMo5Hz  = NaN(chanlength,timeaxis,daysrecord);
    preAMo10Hz  = NaN(chanlength,timeaxis,daysrecord);
    
    for iEnt = 1:entries
        cd(homedir);cd Data
        if ~contains(input(iEnt).name,Group(1))
            continue % skip if not the current group
        end
        if contains(input(iEnt).name,'Spikes')
            continue % skip if spikes data
        end

        % finally load the animal data in
        load(input(iEnt).name)
        for iday = 1:daysrecord
            preCLday = ['preCL_' num2str(iday)];
            % find the pre laser click measurement
            index = find(strcmp({Data.Condition}, preCLday)==1);
            CurCL5hzPre = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurCL10hzPre = Data(index).CSD{1,3};
            
            preAMday = ['preAMBF_' num2str(iday)];
            % find the pre AMBF measurement
            index = find(strcmp({Data.Condition}, preAMday)==1);
            CurAM5hzPre = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurAM10hzPre = Data(index).CSD{1,3};
            
            preAModay = ['preAMoBF_' num2str(iday)];
            % find the pre AMBF measurement
            index = find(strcmp({Data.Condition}, preAModay)==1);
            CurAMo5hzPre = Data(index).CSD{1,2}; %which CSD is 5hz is consistent
            CurAMo10hzPre = Data(index).CSD{1,3};
            % add the current data to the preallocated containers
            preCL5Hz(1:size(CurCL5hzPre,1),1:size(CurCL5hzPre,2),iday)   = CurCL5hzPre;
            preCL10Hz(1:size(CurCL10hzPre,1),1:size(CurCL10hzPre,2),iday)  = CurCL10hzPre;
            preAM5Hz(1:size(CurAM5hzPre,1),1:size(CurAM5hzPre,2),iday)   = CurAM5hzPre;
            preAM10Hz(1:size(CurAM10hzPre,1),1:size(CurAM10hzPre,2),iday)  = CurAM10hzPre;
            preAMo5Hz(1:size(CurAMo5hzPre,1),1:size(CurAMo5hzPre,2),iday)  = CurAMo5hzPre;
            preAMo10Hz(1:size(CurAMo10hzPre,1),1:size(CurAMo10hzPre,2),iday) = CurAMo10hzPre;
        end
    end

    preCL5Hz = nanmean(preCL5Hz,3);
    preCL10Hz = nanmean(preCL10Hz,3);
    preAM5Hz = nanmean(preAM5Hz,3);
    preAM10Hz = nanmean(preAM10Hz,3);
    preAMo5Hz = nanmean(preAMo5Hz,3);
    preAMo10Hz = nanmean(preAMo10Hz,3);
    


    % produce CSD figure
    figure('Name',[Group{1} ' Average CSD'])

    subplot(231)
    imagesc(preCL5Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('CL 5 Hz')

    subplot(234)
    imagesc(preCL10Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('CL 10 Hz')

    subplot(232)
    imagesc(preAM5Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('AM 5 Hz')

    subplot(235)
    imagesc(preAM10Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('AM 10 Hz')

    subplot(233)
    imagesc(preAMo5Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('AM off 5 Hz')

    subplot(236)
    imagesc(preAMo10Hz(1:20,1:1377))
    caxis([-0.0004 0.0004])
    colormap('jet')
    title('AM off 10 Hz')

    sgtitle([Group{iGro} ' Average CSD'])

    cd(homedir);cd figs; cd AvgCSDs
    h = gcf;
    set(h, 'PaperType', 'A4');
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperUnits', 'centimeters');
    savefig(h,[Group{iGro} ' Average CSD'],'compact')
    close (h)



end