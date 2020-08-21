%% Brown Forsythe 

clear; clc;
cd('D:\Dynamic_CSD');
homedir = pwd; 
addpath(genpath(homedir));
cd DATA
mkdir('BrownForsythe');cd BrownForsythe

% Trial Averaged
PeakDataTA = readtable('AVRECPeakData.csv');

% seperate just stimulus presentation from full table
Stim2Hz = PeakDataTA(PeakDataTA.ClickFreq == 2,:);
Stim5Hz = PeakDataTA(PeakDataTA.ClickFreq == 5,:);

%% Peak Amp/Lat/RMS response variance 2Hz
peaks = ["First" "Second"];
layers = ["All" "I_II" "IV" "V" "VI"];
measurement = ["preCL_1" "CL_1" "CL_2" "CL_3" "CL_4"];
BrownFor2Hz = array2table(zeros(0,9));
BrownFor2Hz.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
    'AmpF','LatP','LatF','RMSP','RMSF'};

for ipeak = 1:length(peaks)
    
    Stat2  = Stim2Hz(Stim2Hz.OrderofClick == ipeak,:);
    
    for imeas = 1:length(measurement)
        Stat2meas = Stat2(Stat2.Measurement == measurement(imeas),:);
        for ilay = 1:length(layers)
            Stat2lay = Stat2meas(Stat2meas.Layer == layers(ilay),:);
            % get groups and concatonate for comparisons
            gKIC = Stat2lay(Stat2lay.Group == "KIC",:);
            gKIT = Stat2lay(Stat2lay.Group == "KIT",:);
            if ilay == 2 %KIT04 missing layer II
                CvTAmp = horzcat(gKIC.PeakAmp, vertcat(gKIT.PeakAmp, NaN));
                CvTLat = horzcat(gKIC.PeakLat, vertcat(gKIT.PeakLat, NaN));
                CvTRMS = horzcat(gKIC.RMS, vertcat(gKIT.RMS, NaN));
            else
                CvTAmp = horzcat(gKIC.PeakAmp, gKIT.PeakAmp);
                CvTLat = horzcat(gKIC.PeakLat, gKIT.PeakLat);
                CvTRMS = horzcat(gKIC.RMS, gKIT.RMS);
            end
            
            [AmpP,AmpStat] = vartestn(CvTAmp,'testtype','BrownForsythe');
            [LatP,LatStat] = vartestn(CvTLat,'testtype','BrownForsythe');
            [RMSP,RMSStat] = vartestn(CvTRMS,'testtype','BrownForsythe');
            close all
            
            CurBrFs = table(peaks(ipeak), measurement(imeas), ...
                layers(ilay), (AmpP), AmpStat.fstat, LatP, LatStat.fstat,...
                RMSP,RMSStat.fstat);
            CurBrFs.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
                'AmpF','LatP','LatF','RMSP','RMSF'};
            BrownFor2Hz = [BrownFor2Hz; CurBrFs];
        end
    end
end

writetable(BrownFor2Hz,'BrownFor2Hz.csv')

%% Peak Amp/Lat/RMS response variance 5Hz
peaks = ["First" "Second" "Third" "Fourth" "Fifth"];
layers = ["All" "I_II" "IV" "V" "VI"];
measurement = ["preCL_1" "CL_1" "CL_2" "CL_3" "CL_4"];
BrownFor5Hz = array2table(zeros(0,9));
BrownFor5Hz.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
    'AmpF','LatP','LatF','RMSP','RMSF'};

for ipeak = 1:length(peaks)
    
    Stat5  = Stim5Hz(Stim5Hz.OrderofClick == ipeak,:);
    
    for imeas = 1:length(measurement)
        Stat5meas = Stat5(Stat5.Measurement == measurement(imeas),:);
        for ilay = 1:length(layers)
            Stat5lay = Stat5meas(Stat5meas.Layer == layers(ilay),:);
            % get groups and concatonate for comparisons
            gKIC = Stat5lay(Stat5lay.Group == "KIC",:);
            gKIT = Stat5lay(Stat5lay.Group == "KIT",:);
            if ilay == 2 %KIT04 missing layer II
                CvTAmp = horzcat(gKIC.PeakAmp, vertcat(gKIT.PeakAmp, NaN));
                CvTLat = horzcat(gKIC.PeakLat, vertcat(gKIT.PeakLat, NaN));
                CvTRMS = horzcat(gKIC.RMS, vertcat(gKIT.RMS, NaN));
            else
                CvTAmp = horzcat(gKIC.PeakAmp, gKIT.PeakAmp);
                CvTLat = horzcat(gKIC.PeakLat, gKIT.PeakLat);
                CvTRMS = horzcat(gKIC.RMS, gKIT.RMS);
            end
            
            [AmpP,AmpStat] = vartestn(CvTAmp,'testtype','BrownForsythe');
            [LatP,LatStat] = vartestn(CvTLat,'testtype','BrownForsythe');
            [RMSP,RMSStat] = vartestn(CvTRMS,'testtype','BrownForsythe');
            close all
            
            CurBrFs = table(peaks(ipeak), measurement(imeas), ...
                layers(ilay), (AmpP), AmpStat.fstat, LatP, LatStat.fstat,...
                RMSP,RMSStat.fstat);
            CurBrFs.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
                'AmpF','LatP','LatF','RMSP','RMSF'};
            BrownFor5Hz = [BrownFor5Hz; CurBrFs];
        end
    end
end

writetable(BrownFor5Hz,'BrownFor5Hz.csv')


%% Single Trial %%
PeakDataTA = readtable('AVRECPeakDataST.csv');

% seperate just stimulus presentation from full table
Stim2Hz = PeakDataTA(PeakDataTA.ClickFreq == 2,:);
Stim5Hz = PeakDataTA(PeakDataTA.ClickFreq == 5,:);

%% Peak Amp/Lat/RMS response variance 2Hz
peaks = ["First" "Second"];
layers = ["All" "I_II" "IV" "V" "VI"];
measurement = ["preCL_1" "CL_1" "CL_2" "CL_3" "CL_4"];
BrownFor2HzST = array2table(zeros(0,9));
BrownFor2HzST.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
    'AmpF','LatP','LatF','RMSP','RMSF'};

for ipeak = 1:length(peaks)
    
    Stat2  = Stim2Hz(Stim2Hz.OrderofClick == ipeak,:);
    
    for imeas = 1:length(measurement)
        Stat2meas = Stat2(Stat2.Measurement == measurement(imeas),:);
        for ilay = 1:length(layers)
            Stat2lay = Stat2meas(Stat2meas.Layer == layers(ilay),:);
            % get groups and concatonate for comparisons
            gKIC = Stat2lay(Stat2lay.Group == "KIC",:);
            gKIT = Stat2lay(Stat2lay.Group == "KIT",:);
            % single trials are not alway even, clip the longer one
            if size(gKIC,1) > size(gKIT,1)
                gKIC = gKIC(1:size(gKIT,1),:);
            elseif size(gKIT,1) > size(gKIC,1)
                gKIT = gKIT(1:size(gKIC,1),:);
            end
            CvTAmp = horzcat(gKIC.PeakAmp, gKIT.PeakAmp);
            CvTLat = horzcat(gKIC.PeakLat, gKIT.PeakLat);
            CvTRMS = horzcat(gKIC.RMS, gKIT.RMS);
            
            [AmpP,AmpStat] = vartestn(CvTAmp,'testtype','BrownForsythe');
            [LatP,LatStat] = vartestn(CvTLat,'testtype','BrownForsythe');
            [RMSP,RMSStat] = vartestn(CvTRMS,'testtype','BrownForsythe');
            close all
            
            CurBrFs = table(peaks(ipeak), measurement(imeas), ...
                layers(ilay), (AmpP), AmpStat.fstat, LatP, LatStat.fstat,...
                RMSP,RMSStat.fstat);
            CurBrFs.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
                'AmpF','LatP','LatF','RMSP','RMSF'};
            BrownFor2HzST = [BrownFor2HzST; CurBrFs];
        end
    end
end

writetable(BrownFor2HzST,'BrownFor2HzST.csv')

%% Peak Amp/Lat/RMS response variance 5Hz
peaks = ["First" "Second" "Third" "Fourth" "Fifth"];
layers = ["All" "I_II" "IV" "V" "VI"];
measurement = ["preCL_1" "CL_1" "CL_2" "CL_3" "CL_4"];
BrownFor5HzST = array2table(zeros(0,9));
BrownFor5HzST.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
    'AmpF','LatP','LatF','RMSP','RMSF'};

for ipeak = 1:length(peaks)
    
    Stat5  = Stim5Hz(Stim5Hz.OrderofClick == ipeak,:);
    
    for imeas = 1:length(measurement)
        Stat5meas = Stat5(Stat5.Measurement == measurement(imeas),:);
        for ilay = 1:length(layers)
            Stat5lay = Stat5meas(Stat5meas.Layer == layers(ilay),:);
            % get groups and concatonate for comparisons
            gKIC = Stat5lay(Stat5lay.Group == "KIC",:);
            gKIT = Stat5lay(Stat5lay.Group == "KIT",:);
            % single trials are not alway even, clip the longer one
            if size(gKIC,1) > size(gKIT,1)
                gKIC = gKIC(1:size(gKIT,1),:);
            elseif size(gKIT,1) > size(gKIC,1)
                gKIT = gKIT(1:size(gKIC,1),:);
            end
            CvTAmp = horzcat(gKIC.PeakAmp, gKIT.PeakAmp);
            CvTLat = horzcat(gKIC.PeakLat, gKIT.PeakLat);
            CvTRMS = horzcat(gKIC.RMS, gKIT.RMS);
            
            [AmpP,AmpStat] = vartestn(CvTAmp,'testtype','BrownForsythe');
            [LatP,LatStat] = vartestn(CvTLat,'testtype','BrownForsythe');
            [RMSP,RMSStat] = vartestn(CvTRMS,'testtype','BrownForsythe');
            close all
            
            CurBrFs = table(peaks(ipeak), measurement(imeas), ...
                layers(ilay), (AmpP), AmpStat.fstat, LatP, LatStat.fstat,...
                RMSP,RMSStat.fstat);
            CurBrFs.Properties.VariableNames = {'Peak','Measurement','Layer','AmpP',...
                'AmpF','LatP','LatF','RMSP','RMSF'};
            BrownFor5HzST = [BrownFor5HzST; CurBrFs];
        end
    end
end

writetable(BrownFor5HzST,'BrownFor5HzST.csv')