function OngoingTonotopy(homedir,Layers,whichday)

% Documentation goes here: purpose of code, input and output
% note - tonotopies built on SinkRMS, SinkPeakAmp can be used also if
% preffered

% if you run the code directly or miss a varargin, set defaults here:
if ~exist('homedir','var')
    if exist('E:\Dynamic_CSD','dir') == 7
        cd('E:\Dynamic_CSD');
    elseif exist('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD','dir') == 7
        cd('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD')
    end
    homedir = pwd;
    addpath(genpath(homedir));
end
if ~exist('Layers','var')
    Layers = {'IV'};
end
if ~exist('whichday','var')
    whichday = 1;
end

% Look for all data in data folder
cd (homedir); cd DATA;
input = dir('*.mat');
entries = length(input);

for i1 = 1:entries
    %% display group name and load in data
    Group = (input(i1).name(1:end-9));
    disp(['Analyzing Group: ' Group])
    tic
    load (input(i1).name) %loads data into workspace
    % list out animals
    Animals = fieldnames(Data);
    
    %% open animal specific tonotopy figure
    figure('Name','Tonotopy Obervation') 
    % create a variable which adds the amount of animals to the indexer
    % after the first loop, for subplot grid
    plusrow = 0;
    
    for iDay = 1:whichday
        % after the first loop, add to the indexer 
        if iDay > 1
            plusrow = plusrow + length(Animals);
        end
        
        for iAn = 1:length(Animals)
            % set up subplot structure
            subplot(whichday,length(Animals),iAn+plusrow)
            % preallocate container for layers final averages
            layavg = zeros(length(Layers),(length(Data(1).(Animals{iAn}).Frqz)));

            for iLay = 1:length(Layers)
                % preallocate container for averaging
                measout = zeros(size(Data,2),(length(Data(1).(Animals{iAn}).Frqz)));  

                for iMe = 1:size(Data,2)
                    measout(iMe,:) = horzcat(Data(iMe).(Animals{iAn}).SinkRMS.(Layers{iLay}));
                end % measurement loop
                layavg(iLay,:) = nanmean(measout); % for testing: layavg = rand(3,8)
            end % layer loop

            % plot average lines
            plot(layavg','LineWidth',2)
            % add features to the plot
            legend(Layers)
            ylabel ('SinkRMS [mV/µm^2]') % double check the unit is correct
            xlabel ('Time [ms]')
            xticks (1:length(Data(iMe).(Animals{iAn}).Frqz)) % force all ticks to show
            xticklabels (Data(iMe).(Animals{iAn}).Frqz) % label ticks as stimuli
            % you can rotate the labels slightly to look better later if wanted
            title (Animals{iAn})
        end % animal loop
    end % day loop
    
    cd(homedir); cd figs
    % adding mkdir means that you'll never throw an error on a new computer
    % that doesn't already have this folder. Matlab does not have an issue
    % skipping the command if the directory already exists so no
    % it-statement is needed to check for it first
    mkdir('Ongoing Tonotopies'); cd('Ongoing Tonotopies')
    
    h = gcf; % get current figure
    set(h, 'PaperType', 'A4'); 
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperUnits', 'centimeters');
    savefig(h,[Group ' Tonotopy Observation Day ' num2str(whichday)],'compact') % do we want to overwrite the previous days? Removed whichday from this
    close(h)
    
    %% open granular sink best frequency figure
    % figure('Name','Ongoing Best Frequency') 
    % we should make a plot which shows the progress of the best frequency
    % per animal. One plot with animals as color points with lines 
    % connnecting each day, BF over time[day]. 
    
    % Note! granular sink BF may not be the best choice for tracking awake
    % animal best frequency responses. If you notice that you have no layer
    % IV early sink much of the time, the infragranular thalamic sink may
    % be better for best frequency. OR we can take BF from the Avrec,
    % overall column response. We just need to either write it into the
    % dynamic csd analysis script or make an analysis script for after that
    % one to pull out and label BF. 
    
end % entry loop --- if you don't want it to look through all data in data folder, add the specific data file name into the function varargin and lose this loop