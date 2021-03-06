%% 10ms Bins for Relres

% this code will eventually take raw CSD data, bin it into 10ms chunks, run
% relres on each chunk, take the rms of that and plot the progression.


%% Load and initialize
clear 
cd('D:\MyCode\Dynamic_CSD_Analysis');
warning('OFF');

home = pwd;
addpath(genpath(home));

cd DATA;
load('AnesthetizedPre_Data.mat')
Ketamine = Data; clear Data;
load('Awake10dB_Data.mat')
Awake = Data; clear Data;
load('Muscimol_Data.mat')
Muscimol = Data; clear Data;

chunksize = 10; %10 ms chunks through CSD
% you don't want the BF, what do you want?
BFdis = 0;      % = 0 if BF, -1 for 1 below BF, etc.

%% Ketamine RMS and relres/avrec data

% preallocate lists
K_Animal = fieldnames(Ketamine);
RMS_PeakAmp = cell(size(K_Animal));
RMS_PeakLat = cell(size(K_Animal));
RMS_Mean = cell(size(K_Animal));
REL_PeakAmp = cell(size(K_Animal));
REL_PeakLat = cell(size(K_Animal));
REL_Mean = cell(size(K_Animal));
RMS = cell(size(K_Animal));
REL = cell(size(K_Animal));
RMS_PeakAmp_Avg = cell(size(K_Animal));
RMS_PeakLat_Avg = cell(size(K_Animal));
RMS_Mean_Avg = cell(size(K_Animal));
REL_PeakAmp_Avg = cell(size(K_Animal));
REL_PeakLat_Avg = cell(size(K_Animal));
REL_Mean_Avg = cell(size(K_Animal));
RMS_Avg = cell(size(K_Animal));
REL_Avg = cell(size(K_Animal));

% loop through each animal in the group
for iAn = 1:length(K_Animal)
    BF = find(Ketamine.(K_Animal{iAn}).Frqz == Ketamine.(K_Animal{iAn}).GS_BF);
    
    
    % % AVERAGE % %
    % get out CSD
    curCSD = Ketamine.(K_Animal{iAn}).CSD{1,BF+BFdis};
    
    % preallocate lists to store from loop
    chunking = 1:chunksize:size(curCSD,2); %numbers to iterate (every 10ms)
    relresRMS_Avg = zeros(size(chunking)); %list for RMS output (1:60)
    relresCSD_Avg = zeros(size(curCSD(1,:))); %list for relres output (1:600)
    
    % loop through each trial in steps of 10ms to calc relres/rms of relres
    for ichunk = chunking
        
        chunkCSD = curCSD(:,ichunk:ichunk+9);
        sumCSD = sum(chunkCSD);
        
        relresCSD_Avg(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
        relresRMS_Avg(chunking == ichunk) = rms(relresCSD_Avg(ichunk:ichunk+9));
    end
    
    [pks, locs, ~, p] = findpeaks(relresRMS_Avg(20:40));
    [~, maxInd]=max(p); %which peak is most prominent
    RMSpeakamp_Avg = pks(maxInd);
    RMSpeaklat_Avg = locs(maxInd);
    RMSmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    [pks, locs, ~, p] = findpeaks(relresCSD_Avg(200:400)*-1);
    [~, maxInd]=max(p); %which peak is most prominent
    RELpeakamp_Avg = pks(maxInd);
    RELpeaklat_Avg = locs(maxInd);
    RELmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    % % SINGLE TRIAL % %
    % get out list of single trial CSD's
    cursnglCSD = Ketamine.(K_Animal{iAn}).singletrialCSD{1,BF+BFdis};
    
    % preallocate lists
    trials = 1:size(cursnglCSD,3);
    RMSpeakamp = zeros(size(trials));
    RMSpeaklat = zeros(size(trials));
    RMSmean = zeros(size(trials));
    RELpeakamp = zeros(size(trials));
    RELpeaklat = zeros(size(trials));
    RELmean = zeros(size(trials));
    animalRMS = cell(size(trials));
    animalREL = cell(size(trials));
    
    % loop through each trial of the current CSD
    for itrial = trials
        
        trialCSD = cursnglCSD(:,:,itrial);
        
        % preallocate lists to store from loop
        chunking = 1:chunksize:size(cursnglCSD,2); %numbers to iterate (every 10ms)
        relresRMS = zeros(size(chunking)); %list for RMS output (1:60)
        relresCSD = zeros(size(trialCSD(1,:))); %list for relres output (1:600)
        
        % loop through each trial in steps of 10ms to calc relres/rms of relres
        for ichunk = chunking
            
            chunkCSD = trialCSD(:,ichunk:ichunk+9);
            sumCSD = sum(chunkCSD);
            
            relresCSD(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
            relresRMS(chunking == ichunk) = rms(relresCSD(ichunk:ichunk+9));
        end
        
        [pks, locs, ~, p] = findpeaks(relresRMS(20:40));
        [~, maxInd]=max(p); %which peak is most prominent
        RMSpeakamp(itrial) = pks(maxInd);
        RMSpeaklat(itrial) = locs(maxInd);
        RMSmean(itrial) = nanmean(relresRMS(20:40));
        
        [pks, locs, ~, p] = findpeaks(relresCSD(200:400)*-1);
        [~, maxInd]=max(p); %which peak is most prominent
        RELpeakamp(itrial) = pks(maxInd);
        RELpeaklat(itrial) = locs(maxInd);
        RELmean(itrial) = nanmean(relresRMS(20:40));
        
        animalRMS{itrial} = relresRMS;
        animalREL{itrial} = relresCSD;
    end
    

    RMS_PeakAmp{iAn} = RMSpeakamp;
    RMS_PeakLat{iAn} = RMSpeaklat;
    RMS_Mean{iAn} = RMSmean;
    REL_PeakAmp{iAn} = RELpeakamp;
    REL_PeakLat{iAn} = RELpeaklat;
    REL_Mean{iAn} = RELmean;
    RMS{iAn} = animalRMS;
    REL{iAn} = animalREL;
    RMS_PeakAmp_Avg{iAn} = RMSpeakamp_Avg;
    RMS_PeakLat_Avg{iAn} = RMSpeaklat_Avg;
    RMS_Mean_Avg{iAn} = RMSmean_Avg;
    REL_PeakAmp_Avg{iAn} = RELpeakamp_Avg;
    REL_PeakLat_Avg{iAn} = RELpeaklat_Avg;
    REL_Mean_Avg{iAn} = RELmean_Avg;
    RMS_Avg{iAn} = relresRMS_Avg;
    REL_Avg{iAn} = relresCSD_Avg;
end

Animal = K_Animal;
Ket_T = table(Animal, RMS, REL, RMS_PeakAmp, RMS_PeakLat, RMS_Mean, REL_PeakAmp,...
    REL_PeakLat, REL_Mean, RMS_Avg, REL_Avg, RMS_PeakAmp_Avg, RMS_PeakLat_Avg, ...
    RMS_Mean_Avg, REL_PeakAmp_Avg, REL_PeakLat_Avg, REL_Mean_Avg);
  
%% Awake RMS and relres/avrec data

% preallocate lists
A_Animal = fieldnames(Awake);
RMS_PeakAmp = cell(size(A_Animal));
RMS_PeakLat = cell(size(A_Animal));
RMS_Mean = cell(size(A_Animal));
REL_PeakAmp = cell(size(A_Animal));
REL_PeakLat = cell(size(A_Animal));
REL_Mean = cell(size(A_Animal));
RMS = cell(size(A_Animal));
REL = cell(size(A_Animal));
RMS_PeakAmp_Avg = cell(size(A_Animal));
RMS_PeakLat_Avg = cell(size(A_Animal));
RMS_Mean_Avg = cell(size(A_Animal));
REL_PeakAmp_Avg = cell(size(A_Animal));
REL_PeakLat_Avg = cell(size(A_Animal));
REL_Mean_Avg = cell(size(A_Animal));
RMS_Avg = cell(size(A_Animal));
REL_Avg = cell(size(A_Animal));

% loop through each animal in the group
for iAn = 1:length(A_Animal)
    
    % get out list of single trial CSD's
    BF = find(Awake.(A_Animal{iAn}).Frqz == Awake.(A_Animal{iAn}).GS_BF);   
    
    % % AVERAGE % %
    % get out CSD
    curCSD = Awake.(A_Animal{iAn}).CSD{1,BF+BFdis};
    
    % preallocate lists to store from loop
    chunking = 1:chunksize:size(curCSD,2); %numbers to iterate (every 10ms)
    relresRMS_Avg = zeros(size(chunking)); %list for RMS output (1:60)
    relresCSD_Avg = zeros(size(curCSD(1,:))); %list for relres output (1:600)
    
    % loop through each trial in steps of 10ms to calc relres/rms of relres
    for ichunk = chunking
        
        chunkCSD = curCSD(:,ichunk:ichunk+9);
        sumCSD = sum(chunkCSD);
        
        relresCSD_Avg(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
        relresRMS_Avg(chunking == ichunk) = rms(relresCSD_Avg(ichunk:ichunk+9));
    end
    
    [pks, locs, ~, p] = findpeaks(relresRMS_Avg(20:40));
    [~, maxInd]=max(p); %which peak is most prominent
    RMSpeakamp_Avg = pks(maxInd);
    RMSpeaklat_Avg = locs(maxInd);
    RMSmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    [pks, locs, ~, p] = findpeaks(relresCSD_Avg(200:400)*-1);
    [~, maxInd]=max(p); %which peak is most prominent
    RELpeakamp_Avg = pks(maxInd);
    RELpeaklat_Avg = locs(maxInd);
    RELmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    
    % % SINGLE TRIAL % %
    % get out list of single trial CSD's
    cursnglCSD = Awake.(A_Animal{iAn}).singletrialCSD{1,BF+BFdis}; %
    
    % preallocate lists
    trials = 1:size(cursnglCSD,3);
    RMSpeakamp = zeros(size(trials));
    RMSpeaklat = zeros(size(trials));
    RMSmean = zeros(size(trials));
    RELpeakamp = zeros(size(trials));
    RELpeaklat = zeros(size(trials));
    RELmean = zeros(size(trials));
    animalRMS = cell(size(trials));
    animalREL = cell(size(trials));
    
    % loop through each trial of the current CSD
    for itrial = trials
        
        trialCSD = cursnglCSD(:,:,itrial);
        
        % preallocate lists to store from loop
        chunking = 1:chunksize:size(cursnglCSD,2); %numbers to iterate (every 10ms)
        relresRMS = zeros(size(chunking)); %list for RMS output (1:60)
        relresCSD = zeros(size(trialCSD(1,:))); %list for relres output (1:600)
        
        % loop through each trial in steps of 10ms to calc relres/rms of relres
        for ichunk = chunking
            
            chunkCSD = trialCSD(:,ichunk:ichunk+9);
            sumCSD = sum(chunkCSD);
            
            relresCSD(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
            relresRMS(chunking == ichunk) = rms(relresCSD(ichunk:ichunk+9));
        end
        
        [pks, locs, ~, p] = findpeaks(relresRMS(20:40));
        [~, maxInd]=max(p); %which peak is most prominent
        RMSpeakamp(itrial) = pks(maxInd);
        RMSpeaklat(itrial) = locs(maxInd);
        RMSmean(itrial) = nanmean(relresRMS(20:40));
        
        [pks, locs, ~, p] = findpeaks(relresCSD(200:400)*-1);
        [~, maxInd]=max(p); %which peak is most prominent
        RELpeakamp(itrial) = pks(maxInd);
        RELpeaklat(itrial) = locs(maxInd);
        RELmean(itrial) = nanmean(relresRMS(20:40));
        
        animalRMS{itrial} = relresRMS;
        animalREL{itrial} = relresCSD;
    end
    

    RMS_PeakAmp{iAn} = RMSpeakamp;
    RMS_PeakLat{iAn} = RMSpeaklat;
    RMS_Mean{iAn} = RMSmean;
    REL_PeakAmp{iAn} = RELpeakamp;
    REL_PeakLat{iAn} = RELpeaklat;
    REL_Mean{iAn} = RELmean;
    RMS{iAn} = animalRMS;
    REL{iAn} = animalREL;
    RMS_PeakAmp_Avg{iAn} = RMSpeakamp_Avg;
    RMS_PeakLat_Avg{iAn} = RMSpeaklat_Avg;
    RMS_Mean_Avg{iAn} = RMSmean_Avg;
    REL_PeakAmp_Avg{iAn} = RELpeakamp_Avg;
    REL_PeakLat_Avg{iAn} = RELpeaklat_Avg;
    REL_Mean_Avg{iAn} = RELmean_Avg;
    RMS_Avg{iAn} = relresRMS_Avg;
    REL_Avg{iAn} = relresCSD_Avg;
end
Animal = A_Animal;
Aw_T = table(Animal, RMS, REL, RMS_PeakAmp, RMS_PeakLat, RMS_Mean, REL_PeakAmp,...
    REL_PeakLat, REL_Mean, RMS_Avg, REL_Avg, RMS_PeakAmp_Avg, RMS_PeakLat_Avg, ...
    RMS_Mean_Avg, REL_PeakAmp_Avg, REL_PeakLat_Avg, REL_Mean_Avg);

%% Muscimol RMS and relres/avrec data

% preallocate lists
M_Animal = fieldnames(Muscimol);
RMS_PeakAmp = cell(size(M_Animal));
RMS_PeakLat = cell(size(M_Animal));
RMS_Mean = cell(size(M_Animal));
REL_PeakAmp = cell(size(M_Animal));
REL_PeakLat = cell(size(M_Animal));
REL_Mean = cell(size(M_Animal));
RMS = cell(size(M_Animal));
REL = cell(size(M_Animal));
RMS_PeakAmp_Avg = cell(size(M_Animal));
RMS_PeakLat_Avg = cell(size(M_Animal));
RMS_Mean_Avg = cell(size(M_Animal));
REL_PeakAmp_Avg = cell(size(M_Animal));
REL_PeakLat_Avg = cell(size(M_Animal));
REL_Mean_Avg = cell(size(M_Animal));
RMS_Avg = cell(size(M_Animal));
REL_Avg = cell(size(M_Animal));

% loop through each animal in the group
for iAn = 1:length(M_Animal)
    
    % get out list of single trial CSD's
    BF = find(Muscimol.(M_Animal{iAn}).Frqz == Muscimol.(M_Animal{iAn}).GS_BF);   
    
    % % AVERAGE % %
    % get out CSD
    curCSD = Muscimol.(M_Animal{iAn}).CSD{1,BF+BFdis};
    
    % preallocate lists to store from loop
    chunking = 1:chunksize:size(curCSD,2); %numbers to iterate (every 10ms)
    relresRMS_Avg = zeros(size(chunking)); %list for RMS output (1:60)
    relresCSD_Avg = zeros(size(curCSD(1,:))); %list for relres output (1:600)
    
    % loop through each trial in steps of 10ms to calc relres/rms of relres
    for ichunk = chunking
        
        chunkCSD = curCSD(:,ichunk:ichunk+9);
        sumCSD = sum(chunkCSD);
        
        relresCSD_Avg(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
        relresRMS_Avg(chunking == ichunk) = rms(relresCSD_Avg(ichunk:ichunk+9));
    end
    
    [pks, locs, ~, p] = findpeaks(relresRMS_Avg(20:40));
    [~, maxInd]=max(p); %which peak is most prominent
    RMSpeakamp_Avg = pks(maxInd);
    RMSpeaklat_Avg = locs(maxInd);
    RMSmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    [pks, locs, ~, p] = findpeaks(relresCSD_Avg(200:400)*-1);
    [~, maxInd]=max(p); %which peak is most prominent
    RELpeakamp_Avg = pks(maxInd);
    RELpeaklat_Avg = locs(maxInd);
    RELmean_Avg = nanmean(relresRMS_Avg(20:40));
    
    
    % % SINGLE TRIAL % %
    % get out list of single trial CSD's
    cursnglCSD = Muscimol.(M_Animal{iAn}).singletrialCSD{1,BF+BFdis}; %
    
    % preallocate lists
    trials = 1:size(cursnglCSD,3);
    RMSpeakamp = zeros(size(trials));
    RMSpeaklat = zeros(size(trials));
    RMSmean = zeros(size(trials));
    RELpeakamp = zeros(size(trials));
    RELpeaklat = zeros(size(trials));
    RELmean = zeros(size(trials));
    animalRMS = cell(size(trials));
    animalREL = cell(size(trials));
    
    % loop through each trial of the current CSD
    for itrial = trials
        
        trialCSD = cursnglCSD(:,:,itrial);
        
        % preallocate lists to store from loop
        chunking = 1:chunksize:size(cursnglCSD,2); %numbers to iterate (every 10ms)
        relresRMS = zeros(size(chunking)); %list for RMS output (1:60)
        relresCSD = zeros(size(trialCSD(1,:))); %list for relres output (1:600)
        
        % loop through each trial in steps of 10ms to calc relres/rms of relres
        for ichunk = chunking
            
            chunkCSD = trialCSD(:,ichunk:ichunk+9);
            sumCSD = sum(chunkCSD);
            
            relresCSD(ichunk:ichunk+9) = sumCSD./sum(abs(chunkCSD));
            relresRMS(chunking == ichunk) = rms(relresCSD(ichunk:ichunk+9));
        end
        
        [pks, locs, ~, p] = findpeaks(relresRMS(20:40));
        [~, maxInd]=max(p); %which peak is most prominent
        RMSpeakamp(itrial) = pks(maxInd);
        RMSpeaklat(itrial) = locs(maxInd);
        RMSmean(itrial) = nanmean(relresRMS(20:40));
        
        [pks, locs, ~, p] = findpeaks(relresCSD(200:400)*-1);
        [~, maxInd]=max(p); %which peak is most prominent
        RELpeakamp(itrial) = pks(maxInd);
        RELpeaklat(itrial) = locs(maxInd);
        RELmean(itrial) = nanmean(relresRMS(20:40));
        
        animalRMS{itrial} = relresRMS;
        animalREL{itrial} = relresCSD;
    end
    

    RMS_PeakAmp{iAn} = RMSpeakamp;
    RMS_PeakLat{iAn} = RMSpeaklat;
    RMS_Mean{iAn} = RMSmean;
    REL_PeakAmp{iAn} = RELpeakamp;
    REL_PeakLat{iAn} = RELpeaklat;
    REL_Mean{iAn} = RELmean;
    RMS{iAn} = animalRMS;
    REL{iAn} = animalREL;
    RMS_PeakAmp_Avg{iAn} = RMSpeakamp_Avg;
    RMS_PeakLat_Avg{iAn} = RMSpeaklat_Avg;
    RMS_Mean_Avg{iAn} = RMSmean_Avg;
    REL_PeakAmp_Avg{iAn} = RELpeakamp_Avg;
    REL_PeakLat_Avg{iAn} = RELpeaklat_Avg;
    REL_Mean_Avg{iAn} = RELmean_Avg;
    RMS_Avg{iAn} = relresRMS_Avg;
    REL_Avg{iAn} = relresCSD_Avg;
   
end

Animal = M_Animal;
Mus_T = table(Animal, RMS, REL, RMS_PeakAmp, RMS_PeakLat, RMS_Mean, REL_PeakAmp,...
    REL_PeakLat, REL_Mean, RMS_Avg, REL_Avg, RMS_PeakAmp_Avg, RMS_PeakLat_Avg, ...
    RMS_Mean_Avg, REL_PeakAmp_Avg, REL_PeakLat_Avg, REL_Mean_Avg);

%% concatonate full table
Klist = {'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket' 'Ket'}'; 
Kextra = {'Ket' 'Ket' 'Ket' 'Ket' 'Ket'};
Alist = {'Aw' 'Aw' 'Aw' 'Aw' 'Aw' 'Aw' 'Aw' 'Aw' 'Aw'}'; 
Aextra = {'Aw' 'Aw' 'Aw' 'Aw' 'Aw' 'Aw'};
Mlist = {'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus' 'Mus'}'; 
Mextra = {'Mus' 'Mus' 'Mus' 'Mus' 'Mus'};
Groups = vertcat(Klist, Alist, Mlist);

% correct group sizes. There has to be a better way to do this...
Kfor60 = horzcat(Klist', Klist', Klist', Klist', Klist', Kextra);
Afor60 = horzcat(Alist', Alist', Alist', Alist', Alist', Alist', Aextra);
Mfor60 = horzcat(Mlist', Mlist', Mlist', Mlist', Mlist', Mextra);
Kfor600 = horzcat(Kfor60,Kfor60,Kfor60,Kfor60,Kfor60,Kfor60,Kfor60,Kfor60,Kfor60,Kfor60);
Afor600 = horzcat(Afor60,Afor60,Afor60,Afor60,Afor60,Afor60,Afor60,Afor60,Afor60,Afor60);
Mfor600 = horzcat(Mfor60,Mfor60,Mfor60,Mfor60,Mfor60,Mfor60,Mfor60,Mfor60,Mfor60,Mfor60);
Kfor3k = horzcat(Kfor600, Kfor600, Kfor600, Kfor600, Kfor600);
Afor3k = horzcat(Afor600, Afor600, Afor600, Afor600, Afor600);
Mfor3k = horzcat(Mfor600, Mfor600, Mfor600, Mfor600, Mfor600);
Kfor30k = horzcat(Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k, Kfor3k);
Afor30k = horzcat(Afor3k, Afor3k, Afor3k, Afor3k, Afor3k, Afor3k, Afor3k, Afor3k, Afor3k, Afor3k);
Mfor30k = horzcat(Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k, Mfor3k);

K_Groups60 = {Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60 Kfor60}';
A_Groups60 = {Afor60 Afor60 Afor60 Afor60 Afor60 Afor60 Afor60 Afor60 Afor60}';
M_Groups60 = {Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60 Mfor60}';
K_Groups600 = {Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600 Kfor600}';
A_Groups600 = {Afor600 Afor600 Afor600 Afor600 Afor600 Afor600 Afor600 Afor600 Afor600}';
M_Groups600 = {Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600 Mfor600}';
K_Groups3k = {Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k Kfor3k}';
A_Groups3k = {Afor3k Afor3k Afor3k Afor3k Afor3k Afor3k Afor3k Afor3k Afor3k}';
M_Groups3k = {Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k Mfor3k}';
K_Groups30k = {Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k Kfor30k}';
A_Groups30k = {Afor30k Afor30k Afor30k Afor30k Afor30k Afor30k Afor30k Afor30k Afor30k}';
M_Groups30k = {Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k Mfor30k}';

Groups60 = vertcat(K_Groups60, A_Groups60, M_Groups60); 
Groups600 = vertcat(K_Groups600, A_Groups600, M_Groups600);
Groups3k = vertcat(K_Groups3k, A_Groups3k, M_Groups3k);
Groups30k = vertcat(K_Groups30k, A_Groups30k, M_Groups30k);
T60 = {1:60}; Time60 = repmat(T60,[31 1]);
T600 = {1:600}; Time600 = repmat(T600,[31 1]);
dT60 = 1:60; T3k = {repmat(dT60, [1 50])}; Time3k = repmat(T3k, [31 1]);
dT600 = 1:600; T30k = {repmat(dT600, [1 50])}; Time30k = repmat(T30k, [31 1]);

T = vertcat(Ket_T,Aw_T,Mus_T);
T.Group = Groups;
T.Groups60 = Groups60;
T.Groups600 = Groups600;
T.Groups3k = Groups3k;
T.Groups30k = Groups30k;
T.Time60 = Time60;
T.Time600 = Time600;
T.Time3k = Time3k;
T.Time30k = Time30k;

% sizing to fit the cookie cutter
for i = 1:size(T,1)
    
    for ii = 1:50
        
        if i == 16 || i == 19 %these two animals have 49 trials and need padding to fit labels
            T.RMS{i,1}{1,ii} = NaN([1,60]);
            T.REL{i,1}{1,ii} = NaN([1,600]);
        end
        
    T.RMS{i,1}{1,ii} = T.RMS{i,1}{1,ii}(1:60);
    T.REL{i,1}{1,ii} = T.REL{i,1}{1,ii}(1:600);
    end
    
    RMS = horzcat(T.RMS{i,1}{1,:});  
    T.RMS{i,1} = RMS;
    REL = horzcat(T.REL{i,1}{1,:});  
    T.REL{i,1} = REL;
    
    % cutting the averages
    T.RMS_Avg{i,1} = T.RMS_Avg{i,1}(1:60);
    T.REL_Avg{i,1} = T.REL_Avg{i,1}(1:600);
end

%% PLOT RMS progression of AVG CSDs
cd(home); cd figs; mkdir('RelRes_BINS'); cd RelRes_BINS 

plotRMS_Avg = horzcat(T.RMS_Avg{:,1});
plotT60 = horzcat(T.Time60{:,1});
plotG60 = horzcat(T.Groups60{:,1});

clear g 

g = gramm('x', plotT60, 'y', plotRMS_Avg, 'color', plotG60);
% g.geom_point()
g.stat_summary() %'type', 'sem', 'geom', 'bar'
g.set_title(['AVG RMS of Relres from 10ms bins ' num2str(BFdis)]);
g.set_color_options('map','matlab');
g.set_names('x','Binned Time','y','RMS RelRes','color','Group');
g.axe_property('YLim',[0 0.6]);
g.draw();
g.export('file_name',['AVG RMS of Relres from 10ms bins ' num2str(BFdis)], 'file_type','png');
close all

%% PLOT Relres progression of AVG CSDs

plotREL_Avg = horzcat(T.REL_Avg{:,1});
plotT600 = horzcat(T.Time600{:,1});
plotG600 = horzcat(T.Groups600{:,1});

clear g 

g = gramm('x', plotT600, 'y', plotREL_Avg, 'color', plotG600);
g.stat_summary() %'type', 'sem', 'geom', 'line'
g.set_title(['AVG Relres from 10ms bins ' num2str(BFdis)]);
g.set_color_options('map','matlab');
g.set_names('x','Time','y','RelRes','color','Group');
g.axe_property('YLim',[-0.6 0.6]);
g.draw();
g.export('file_name',['AVG Relres from 10ms bins ' num2str(BFdis)], 'file_type','png');
close all

%% PLOT RMS progression of SINGLE CSDs

plotRMS = horzcat(T.RMS{:,1});
plotT3k = horzcat(T.Time3k{:,1});
plotG3k = horzcat(T.Groups3k{:,1});

clear g 

g = gramm('x', plotT3k, 'y', plotRMS, 'color', plotG3k);
g.stat_summary() %'type', 'sem', 'geom', 'bar'
g.set_title(['Single RMS of Relres from 10ms bins ' num2str(BFdis)]);
g.set_color_options('map','matlab');
g.set_names('x','Binned Time','y','RMS RelRes','color','Group');
g.axe_property('YLim',[0.1 0.35]);
g.draw();
g.export('file_name',['Single RMS of Relres from 10ms bins ' num2str(BFdis)], 'file_type','png');
close all

%% PLOT Relres progression of SINGLE CSDs

plotREL = horzcat(T.REL{:,1});
plotT30k = horzcat(T.Time30k{:,1});
plotG30k = horzcat(T.Groups30k{:,1});

clear g 

g = gramm('x', plotT30k, 'y', plotREL, 'color', plotG30k);
g.stat_summary() %'type', 'sem', 'geom', 'bar'
g.set_title(['Single Relres from 10ms bins ' num2str(BFdis)]);
g.set_color_options('map','matlab');
g.set_names('x','Time','y','RelRes','color','Group');
g.axe_property('YLim',[-0.35 0.25]);
g.draw();
g.export('file_name',['Single Relres from 10ms bins ' num2str(BFdis)], 'file_type','png');
close all

%%
% SINGLE TRIAL STUFF
clear g
g = gramm('x',T.RMS_PeakAmp,'y',T.RMS_Mean,'color',T.Animal, 'column', T.Group);
g.geom_point();
g.set_title(['sngle RMS Peak Amplitude vs Mean_' num2str(BFdis)]);
g.set_names('x','Highest Peak Amplitude','y','Mean during tone','color','Animal');
g.draw();
g.export('file_name',['sngle RMS Peak Amplitude vs Mean_' num2str(BFdis)], 'file_type','png');
close all

% clear g %want to just visualize mean but I'm really loosing it
% g = gramm('x',T.RMS_Mean,'color',T.Animal, 'column', T.Group);
% g.geom_jitter();
% g.set_title(['sngle RMS Peak Amplitude vs Mean_' num2str(BFdis)]);
% g.set_names('x','Highest Peak Amplitude','y','Mean during tone','color','Animal');
% g.draw();
% g.export('file_name',['sngle RMS Peak Amplitude vs Mean_' num2str(BFdis)], 'file_type','png');
% close all

clear g
g = gramm('x',T.RMS_PeakLat,'y',T.RMS_PeakAmp,'color',T.Animal, 'column', T.Group);
g.geom_point();
g.set_title(['sngle RMS Peak Latency vs Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['sngle RMS Peak Latency vs Amplitude_' num2str(BFdis)], 'file_type','png');
close all

clear g
g = gramm('x',T.REL_PeakLat,'y',T.REL_PeakAmp,'color',T.Animal, 'column', T.Group);
g.geom_point();
g.set_title(['sngle REL Peak Latency vs Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['sngle REL Peak Latency vs Amplitude_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.REL_PeakLat,'y',T.RMS_PeakLat,'color',T.Animal, 'column', T.Group); 
g.geom_point();
g.set_title(['sngle REL vs RMS Peak Latency_' num2str(BFdis)]);
g.draw();
g.export('file_name',['sngle REL vs RMS Peak Latency_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.REL_PeakAmp,'y',T.RMS_PeakAmp,'color',T.Animal, 'column', T.Group); 
g.geom_point();
g.set_title(['sngle REL vs RMS Peak Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['sngle REL vs RMS Peak Amplitude_' num2str(BFdis)], 'file_type','png');
close all

% % AVERAGE STUFF
clear g
g = gramm('x',T.RMS_PeakAmp_Avg,'y',T.RMS_Mean_Avg,'color',T.Animal, 'column', T.Group);
g.geom_point();
g.set_title(['AVG RMS Peak Amplitude vs Mean_' num2str(BFdis)]);
g.set_names('x','Highest Peak Amplitude','y','Mean during tone','color','Animal');
g.draw();
g.export('file_name',['AVG RMS Peak Amplitude vs Mean_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.RMS_PeakLat_Avg,'y',T.RMS_PeakAmp_Avg,'color',T.Animal, 'column', T.Group); 
g.geom_point();
g.set_title(['RMS Peak Latency vs Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['RMS Peak Latency vs Amplitude_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.REL_PeakLat_Avg,'y',T.REL_PeakAmp_Avg,'color',T.Animal, 'column', T.Group); 
g.geom_point();
g.set_title(['REL Peak Latency vs Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['REL Peak Latency vs Amplitude_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.REL_PeakLat_Avg,'y',T.RMS_PeakLat_Avg,'color',T.Animal, 'column', T.Group);
g.geom_point();
g.set_title(['REL vs RMS Peak Latency_' num2str(BFdis)]);
g.draw();
g.export('file_name',['REL vs RMS Peak Latency_' num2str(BFdis)], 'file_type','png');
close all


clear g
g = gramm('x',T.REL_PeakAmp_Avg,'y',T.RMS_PeakAmp_Avg,'color',T.Animal, 'column', T.Group); 
g.geom_point();
g.set_title(['REL vs RMS Peak Amplitude_' num2str(BFdis)]);
g.draw();
g.export('file_name',['REL vs RMS Peak Amplitude_' num2str(BFdis)], 'file_type','png');
close all

%% Stats of all the things
figlist = {'Musc_Box','Musc_Stat','Aw_Box','Aw_Stat'};
Fluff = {NaN([1,50])};

ARmsMean = T.RMS_Mean(strcmp('Aw', T.Group));
ARmsMean = vertcat(ARmsMean, Fluff, Fluff);
ARmsMean = horzcat(ARmsMean{:,1}, NaN, NaN)';

KRmsMean = T.RMS_Mean(strcmp('Ket', T.Group));
KRmsMean = horzcat(KRmsMean{:,1})';

MRmsMean = T.RMS_Mean(strcmp('Mus', T.Group));
MRmsMean = horzcat(MRmsMean{:,1})';

AvK_RmsMean = horzcat(ARmsMean, KRmsMean);
MvK_RmsMean = horzcat(MRmsMean, KRmsMean);

[AP,ASTATS] = vartestn(AvK_RmsMean, 'testtype','BrownForsythe');
[MP,MSTATS] = vartestn(MvK_RmsMean, 'testtype','BrownForsythe');


for ifig = 1:4
h = gcf;
set(h, 'PaperType', 'A4');
set(h, 'PaperOrientation', 'landscape');
set(h, 'PaperUnits', 'centimeters');
savefig(h, ['RMS Mean Single ' figlist{ifig} '_BF'])
saveas(gcf, ['RMS Mean Single ' figlist{ifig} '_BF.pdf'])
close (h)
end


























