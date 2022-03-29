%% PIPELINE Ebru PhD 

% this code is intended only for use with the data specifically for
% Ebru's PhD Work and subsequent publication related additions.
% Any other data run through here will require manual edits and seperate scripts.

% Please ensure that any external files are not in main folders groups or
% DATA. Files generated from the output folder are called manually; all
% other input is dynamic and will attempt to run whatever is inside the
% main folder. 

clear; clc;
cd('D:\MyCode\Dynamic_CSD'); % 'D:\Dynamic_CSD'
homedir = pwd; 
addpath(genpath(homedir));
%% TO WATCH THE TONOTOPIES

whichday = 3;
% full list for days of tonotopy observation
CondList = {'tono_day1','tono_day2','tono_day3','tono_day2','tono_day3'}; 
% truncate based on which day to let the code know how much to run
Condition = CondList(1:whichday);

%% Data Structure Building:

%Input:     sink_dura.m and several other functions, ..\groups\*.m
%           files to indicated layer sorting and file types, raw data
%           corresponding to group scripts
%Output:    Figures of all single animals in "Single..." folder 
%           DATA.mat files in DATA folder

disp('Running Dynamic_CSD')
Dynamic_CSD_gerbil(homedir,Condition)

%% Ongoing Tonotopy

%Input:     
%Output:    Figures in ..\figs\Ongoing Tonotopies

% write in which layers you need
Layers = {'I_IIL','IVE','IVL','VaE','VbE','VIaE','VIbL'}; 
OngoingTonotopy(homedir,Layers,Condition);











