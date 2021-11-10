function OngoingTonotopy(homedir,Layers,whichday)

% Documentation goes here: purpose of code, input and output

warning('OFF');
dbstop if error

% Change directory to your working folder
if ~exist('homedir','var')
    if exist('E:\Dynamic_CSD','dir') == 7
        cd('E:\Dynamic_CSD');
    elseif exist('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD','dir') == 7
        cd('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD')
    end
    
    homedir = pwd;
    addpath(genpath(homedir));
end

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
    
    % open figure
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
            xticklabels (Data(iMe).(Animals{iAn}).Frqz) % label ticks as stim
            % you can rotate the labels slightly to look better later if wanted
            title (Animals{iAn})
        end % animal loop
    end % day loop
    
    cd(homedir); cd figs
    mkdir('Ongoing Tonotopies'); cd('Ongoing Tonotopies')
    
    h = gcf;
    set(h, 'PaperType', 'A4');
    set(h, 'PaperOrientation', 'landscape');
    set(h, 'PaperUnits', 'centimeters');
    savefig(h,[Group ' Tonotopy Observation Day ' num2str(whichday) ],'compact')
    close (h)
end % entry loop