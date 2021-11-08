function ChangeInRelresSTperAnimal(homedir,Aname)

% This script takes *.mat files out of the DATA/ folder - manually called. It checks the
% condition names and finds the measurements associated with repeated
% stimuli (currently clicks only). It then produces a table for Julia
% statistics and figure output with the peak amp and latency per single
% trial

%Input:     D:\MyCode\Dynamic_CSD_Analysis\DATA -> *DATA.mat
%Output:    Table in main folder containing peak amp and lat at a single
%           trial level

%% standard operations
cd(homedir),cd DATA;


%% Loop variables and data structures 
CLstimlist = [2,5,10]; 

% set up simple cell sheets to hold all data: Relres of total/layers and
% peaks of pre conditions
allocate = 0;
for ifreq = 1:length(CLstimlist)
    allocate = allocate + CLstimlist(ifreq);
end
allocate = allocate*50*5; % 50 trials max (extra will be removed) & 5 Measurements

CLPeakData = table('Size', [allocate 7], ...
    'VariableTypes', {'string', 'string','string','double',...
    'double','double','double'},...
    'VariableNames', {'Group','Animal','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','RMS'});
AMPeakData = table('Size', [allocate 7], ...
    'VariableTypes', {'string', 'string','string','double',...
    'double','double','double'},...
    'VariableNames', {'Group','Animal','Measurement',...
    'ClickFreq','OrderofClick','TrialNumber','RMS'});

%% Load in
load([Aname '_Data.mat']);

% load in Group .m for layer info and point to correct animal
cd (homedir),cd groups;
run([Aname(1:3) '.m']);
thisA = find(contains(animals,Aname));
clcount = 1;
amcount = 1;

%% Clicks
for iStim = 1:length(CLstimlist)
	for iMeas = 1:size(Data,2)
		
		if isempty(Data(iMeas).measurement)
			continue
		end
		
		if ~contains((Data(iMeas).Condition),'CL_')
			continue
		end
		
		% take an average of all channels at each trial
		avgchan = Data(iMeas).SglTrl_Relraw{1, iStim}(:,:,:);
        avgchan = permute(avgchan,[2 1 3]);
		if isnan(avgchan(1)) %some supragranular layers not there
			continue
		end
		avgchan = avgchan(:,1:1377,:); %standard size here, some stretch to 1390 (KIC14)
		% plot it if wanted - remember these contain all trials
%            plot(squeeze(avgchan))
		
		for itrial = 1:size(avgchan,3)
			[~,~,rmsout] = consec_peaksST(avgchan(:,:,itrial), ...
				CLstimlist(iStim), 1000, 1, 200); 
			for itab = 1:CLstimlist(iStim)
				CLPeakData.Group(clcount,1)       = {Aname(1:3)};
				CLPeakData.Animal(clcount,1)      = {Aname};
				CLPeakData.Measurement(clcount,1) = {Data(iMeas).Condition};
				CLPeakData.ClickFreq(clcount,1)   = CLstimlist(iStim);
				CLPeakData.OrderofClick(clcount,1)= itab;
				CLPeakData.TrialNumber(clcount,1) = itrial;
				CLPeakData.RMS(clcount,1)         = rmsout(itab);
			
				clcount = clcount + 1;
			end % table entry
		end % trial
	end % measurement
end % stimulus type (2 Hz, 5 Hz)

%% Amplitude Modulation

for iStim = 1:length(CLstimlist)
	for iMeas = 1:size(Data,2)
		
		if isempty(Data(iMeas).measurement)
			continue
		end
		
		if ~contains((Data(iMeas).Condition),'AM_')
						continue
		end
		
		% take an average of all channels at each trial
		avgchan = Data(iMeas).SglTrl_Relraw{1, iStim}(:,:,:);
        avgchan = permute(avgchan,[2 1 3]);
		if isnan(avgchan(1)) %some supragranular layers not there
			continue
		end
		avgchan = avgchan(:,1:1377,:); %standard size here, some stretch to 1390 (KIC14)
		% plot it if wanted - remember these contain all trials
%            plot(squeeze(avgchan))
		
		for itrial = 1:size(avgchan,3)
			[~,~,rmsout] = consec_peaksST(avgchan(:,:,itrial), ...
				CLstimlist(iStim), 1000, 1, 200); 
			for itab = 1:CLstimlist(iStim)
				% nan output for rms means there was a mechanical
				% artifact in the code (straight line in data)
				AMPeakData.Group(amcount,1)       = {Aname(1:3)};
				AMPeakData.Animal(amcount,1)      = {Aname};
				AMPeakData.Measurement(amcount,1) = {Data(iMeas).Condition};
				AMPeakData.ClickFreq(amcount,1)   = CLstimlist(iStim);
				AMPeakData.OrderofClick(amcount,1)= itab;
				AMPeakData.TrialNumber(amcount,1) = itrial;
				AMPeakData.RMS(amcount,1)         = rmsout(itab);
								   
				amcount = amcount + 1;
				
			end % table entry
		end % trial
	end % measurement
end % stimulus type (2 Hz, 5 Hz)


% save the table in the main folder - needs to be moved to the Julia folder
% for stats
CL_CSVname = [Aname 'PeakCLSTrelres.csv'];
AM_CSVname = [Aname 'PeakCLAMrelres.csv'];
cd(homedir)
writetable(CLPeakData,CL_CSVname)
writetable(AMPeakData,AM_CSVname)
end