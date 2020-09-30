function [peakout,latencyout,rmsout] = consec_peaksST(spectin, num_stim, dur_stim, start_time, BL)

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

% spectin should be one avrec trace on which to detect peaks (e.g. 1:1400)

%preallocation of onset detection window containers
%preallocation of onset detection window containers
peakout    = nan(1,num_stim);
latencyout = nan(1,num_stim);
rmsout     = nan(1,num_stim);
det_on     = nan(1,num_stim);
det_off    = nan(1,num_stim);
det_jump   = dur_stim/num_stim;

% fill detection window containers
for idet = 1:num_stim
    if idet == 1
        det_on(idet) = start_time + BL;
    else
        det_on(idet) = det_on(idet-1) + det_jump;
    end
    det_off(idet) = det_on(idet) + 99;
end


%% Take features

% this runs through all sinks for each detection window opportunity
for iSti = 1:num_stim
        
    % cut the detection window to on and off time set according to number
    % of clicks:
    det_win = spectin(:,det_on(iSti):det_off(iSti));
    
    [pks, locs, ~, p] = findpeaks(det_win);
    [str, maxInd]=max(p); %which peak is most prominent
    
%     plot(det_win); hold on; plot(locs(maxInd),pks(maxInd),'o');hold off
    
    % Peak Prominence check
    if str < 0.0003 %arbitrary threshold throwing out non-prominent peaks
        peakout(iSti)    = NaN;
        latencyout(iSti) = NaN;
        rmsout(iSti)     = rms(det_win(det_win > 0));
    elseif isempty(str) % this would mean the data is a straight line
        peakout(iSti)    = NaN;
        latencyout(iSti) = NaN;
        rmsout(iSti)     = NaN;
    else % peak is there and strong enough
        peakout(iSti)    = pks(maxInd);
        latencyout(iSti) = locs(maxInd);
        rmsout(iSti)     = rms(det_win(det_win > 0));
    end     
    rmsout(iSti)         = rms(det_win(det_win > 0));
end