function [peakout,latencyout] = consec_peaks(spectin, num_stim, dur_stim, start_time, BL)

if ~exist('start_time','var')
    start_time = 1; % 1 ms to avoid that the sink starts directly at 0 ms
end
if ~exist('BL','var')
    BL  = 200; % 200 ms before the first stim onset
end
if ~exist('num_stim','var')
    num_stim  = 2;
end
if ~exist('dur_stim','var')
    dur_stim   = 1000;
end

% structin   = Data(imeas).(para{ipar})(istim).(layer{ilay});

%preallocation of onset detection window containers
peakout    = nan(1,num_stim);
latencyout = nan(1,num_stim);
det_on     = nan(1,num_stim);
det_off    = nan(1,num_stim);
det_jump   = dur_stim/num_stim;

% fill detection window containers
for idet = 1:num_stim
    if idet == 1
        det_on(idet) = start_time+BL;
    else
        det_on(idet) = det_on(idet-1) + det_jump;
    end
    det_off(idet) = det_on(idet) + det_jump-2;
end


%% Take features

% this runs through all sinks for each detection window opportunity
for iSti = 1:num_stim
        
    % cut the detection window to on and off time set according to number
    % of clicks:
    det_win = spectin(:,det_on(iSti):det_off(iSti));
    
    % find peak power and peak latency
    peakout(iSti) =  nanmax(nanmax(det_win));
    [~,latencyout(iSti)] = find(det_win == peakout(iSti));
    latencyout(iSti) = latencyout(iSti);
     
end