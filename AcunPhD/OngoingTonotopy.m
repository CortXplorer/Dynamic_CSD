function OngoingTonotopy(homedir,Layers,Condition)

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
if ~exist('Condition','var')
    Condition = {'tono_day1'};
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
    % create a variable to determine how many measurements are in each
    % condition. If measurements in condition are not equal, this method
    % should be changed!
    num_meas = size(Data,2)/length(Condition);
    % create a corresponding index variable to tic up through consecutive
    % measurements in the following loops
    cur_cond = 0;
    
    for iDay = 1:length(Condition)
        % after the first loop, add to the indexer 
        if iDay > 1
            plusrow = plusrow + length(Animals);
        end
        
        for iAn = 1:length(Animals)
            % set up subplot structure
            subplot(length(Condition),length(Animals),iAn+plusrow)
            % preallocate container for layers final averages
            layavg = zeros(length(Layers),(length(Data(1).(Animals{iAn}).Frqz)));

            for iLay = 1:length(Layers)
                % preallocate container for averaging
                measout = zeros(num_meas,(length(Data(1).(Animals{iAn}).Frqz)));  

                for iMe = 1:num_meas
                    measout(iMe,:) = horzcat(Data(iMe+cur_cond).(Animals{iAn}).SinkRMS.(Layers{iLay}));
                end % measurement loop
                layavg(iLay,:) = nanmean(measout); % for testing: layavg = rand(3,8)
            end % layer loop

            % plot average lines
            plot(layavg','LineWidth',2)
            % add features to the plot
            legend(Layers)
            ylabel ('SinkRMS [mV/mm^2]') % double check the unit is correct
            xlabel ('Time [ms]')
            xticks (1:length(Data(iMe).(Animals{iAn}).Frqz)) % force all ticks to show
            xticklabels (Data(iMe).(Animals{iAn}).Frqz) % label ticks as stimuli
            % you can rotate the labels slightly to look better later if wanted
            title (Animals{iAn})
            
        end % animal loop
        % add to the indexer after completing current measurements
        cur_cond = cur_cond + num_meas;
    end % day loop
    
    cd(homedir); cd figs
    % adding mkdir means that you'll never throw an error on a new computer
    % that doesn't already have this folder. Matlab does not have an issue
    % skipping the command if the directory already exists so no
    % it-statement is needed to check for it first
    if exist('Ongoing Tonotopies','dir') == 7
        cd('Ongoing Tonotopies')
    else
        mkdir('Ongoing Tonotopies'); cd('Ongoing Tonotopies')
    end
    
    h = gcf; % get current figure
    set(h, 'PaperType', 'A4'); 
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperUnits', 'centimeters');
    savefig(h,[Group ' Tonotopy Observation Day ' num2str(length(Condition))],'compact') % do we want to overwrite the previous days? Removed length(Condition) from this
    close(h)
    
    %% open granular sink best frequency figure
     
    % we should make a plot which shows the progress of the best frequency
    % per animal. One plot with animals as color points with lines 
    % connnecting each day, BF over time[day]. 
    
    % figure('Name','Ongoing Best Frequency')
    
    % preallocate container for all animal data
    BFmatrix = zeros(length(Animals),length(Condition));
    
    for iAn = 1:length(Animals)
        cur_cond = 0;
        % preallocate container for Day BFs
        dayout = zeros(1,length(Condition));
        for iDay = 1:length(Condition)
            
            % preallocating measurement BF
            measout = zeros(1,num_meas);
            for iMe = 1:num_meas
                if isempty(Data(iMe+cur_cond).(Animals{iAn}).GS_BF)
                    measout(iMe) = NaN;
                    disp('There is a NaN BF')
                else
                    % get BF from each measurement
                    measout(iMe) = Data(iMe+cur_cond).(Animals{iAn}).GS_BF;
                end
            end % measurement loop
            
            cur_cond = cur_cond+num_meas;
            % average e.g. [ 2 2 4 ] = 2.6667 kHz
            % & store BF in container
            dayout(iDay) = nanmean(measout);
        end % day loop
        
        % store day BF data in container for all animals
        BFmatrix(iAn,:) = dayout;
    end % animal loop
    
    % plot BFs as points over days, per animal. 
    figure('Name', 'BF per Day')
    plot(BFmatrix(:,:)','o:','Linewidth',2);
    legend(Animals)
    ylabel ('Best Frequency') % double check the unit is correct
    xlabel ('Day')
    xticks (1:length(Condition)) % force all ticks to show
    title('Best Frequency per Day')
    
    % save it
    cd(homedir); cd figs
    cd('Ongoing Tonotopies')
    
    h = gcf; % get current figure
    set(h, 'PaperType', 'A4'); 
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperUnits', 'centimeters');
    savefig(h,[Group ' BF per Day on Day ' num2str(length(Condition))],'compact') % do we want to overwrite the previous days? Removed length(Condition) from this
    close(h)
    
    % Note! granular sink BF may not be the best choice for tracking awake
    % animal best frequency responses. If you notice that you have no layer
    % IV early sink much of the time, the infragranular thalamic sink may
    % be better for best frequency. OR we can take BF from the Avrec,
    % overall column response. We just need to either write it into the
    % dynamic csd analysis script or make an analysis script for after that
    % one to pull out and label BF. 
    
end % entry loop --- if you don't want it to look through all data in data folder, add the specific data file name into the function varargin and lose this loop