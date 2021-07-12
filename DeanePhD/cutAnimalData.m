clear 
% Change directory to your working folder
if ~exist('homedir','var')
    if exist('D:\Dynamic_CSD','dir') == 7
        cd('D:\Dynamic_CSD');
    elseif exist('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD','dir') == 7
        cd('C:\Users\kedea\Documents\Work Stuff\Dynamic_CSD')
    end
    
    homedir = pwd;
    addpath(genpath(homedir));
end
cd(homedir),cd Data;

%% Load in
input = dir('*.mat');
entries = length(input);

for iAn = 1:entries
    
    name = input(iAn).name;
    load(name)
    oldDat = Data; % change Data to old name so we can use it for new var
    Data = struct;

    for i = 1:size(oldDat,2)
       Data(i).measurement = oldDat(i).measurement;
       Data(i).Condition = oldDat(i).Condition;
       Data(i).BL = oldDat(i).BL;
       Data(i).StimDur = oldDat(i).StimDur;
       Data(i).Frqz = oldDat(i).Frqz;
       Data(i).BF_II = oldDat(i).BF_II;
       Data(i).BF_IV = oldDat(i).BF_IV;
       Data(i).BF_V = oldDat(i).BF_V;
       Data(i).BF_VI = oldDat(i).BF_VI;
       Data(i).SglTrl_CSD = oldDat(i).SglTrl_CSD;
       Data(i).CSD = oldDat(i).CSD;
       Data(i).SingleRecCSD = oldDat(i).SingleRecCSD;
       Data(i).AVREC_raw = oldDat(i).AVREC_raw;
    end

    save(['cut' name],'Data')

end