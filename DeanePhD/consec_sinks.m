function structout = consec_sinks(structin, sinkonset_struct, num_sinks, dur_stim, start_time)
% This function searches through the detected sink data from step 1 of the
% analysis (Dynamic_CSD). It brings in the detected parameter (eg.
% SinkRMS) and the detected SinkOnset for the measurement for which is was
% called (either AM or Click). 

% num_sinks is the number of stimuli (eg. 2 Hz) that we want to detect 
% sink data for, dur_stim is the duration of the full stimulus window 
% (1000 ms), start_time is our arbitrary time after stim onset to detect  
% sink onset. I use 1 ms to be very liberal with my detection window. 

% If the time between stimuli is greater than 90 ms, we cap the detection 
% of onset to that. This is also very liberal to account for later onset in
% supragranular layers. 


if ~exist('start_time','var')
    start_time = 1; % 1 ms to avoid that the sink starts directly at 0 ms
end
if ~exist('num_sinks','var')
    num_sinks  = 2;
end
if ~exist('dur_stim','var')
    dur_stim   = 1000;
end

% structin   = Data(imeas).(para{ipar})(istim).(layer{ilay});
% sinkonset_struct = Data(imeas).Sinkonset(istim).(layer{ilay});

%preallocation of onset detection window containers
structout  = nan(1,num_sinks);
det_on     = nan(1,num_sinks);
det_off    = nan(1,num_sinks);
det_jump   = dur_stim/num_sinks;

if det_jump > 90
    det_dur = 90; % so that onset detection window is 1:90 ms (longer window to account for I_II)
else
    det_dur = det_jump - 1; % 1 ms space between detection windows for higher click frqz
end

% fill detection window containers (eg. 2 hz -> det_on=[1,501] det_off=[91,591])
for idet = 1:num_sinks
    if idet == 1
        det_on(idet) = start_time;
    else
        det_on(idet) = det_on(idet-1) + det_jump;
    end
    det_off(idet) = det_on(idet) + det_dur;
end


%% Take features

% this runs through all sinks for each detection window opportunity
for itake = 1:num_sinks
    for isink = 1:length(structin)
        
        if isnan(structin(isink))
            continue
        end
        % if sink onset is within detection window
        if sinkonset_struct(isink) > det_on(itake) && sinkonset_struct(isink) < det_off(itake)
            
            if isnan(structout(itake))
                % pull out sink feature and place it into appropriate bin
                structout(itake) =  structin(isink);
            else
                % if there is already a sink detected here, take the bigger
                % one
                if structin(isink) > structout(itake)
                    structout(itake) =  structin(isink);
                end
            end
             
        end
    end
end