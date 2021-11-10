%% PIPELINE Ebru PhD 

% this code is intended only for use with the data specifically for
% Ebru's PhD Work and subsequent publication related additions.
% Any other data run through here will require manual edits and seperate scripts.

% Please ensure that any external files are not in main folders groups or
% DATA. Files generated from the output folder are called manually; all
% other input is dynamic and will attempt to run whatever is inside the
% main folder. 

clear; clc;
cd('\yourpath\Dynamic_CSD'); % 'D:\Dynamic_CSD'
homedir = pwd; 
addpath(genpath(homedir));
%% The Basics:

%Input:     sink_dura.m and several other functions, groups/*.m
%           files to indicated layer sorting and file types, raw data
%           corresponding to group scripts
%Output:    Figures of all single animals in "Single..." folder 
%           DATA.mat files in DATA folder
disp('Running Dynamic_CSD')
Dynamic_CSD_gerbil(homedir)

%% Ongoing Tonotopy











