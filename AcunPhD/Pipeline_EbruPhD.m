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


%% CSD Average Picture

% -- we can adapt this to your needs and use it also for the average tuning
% curves. For now I'm just adding it to the pipeline as is. - kat

%Input:     is DATA; specifically named per Kat's PhD groups
%Output:    is in figure folder AvgCSDs; figures only for representation of
%           characteristic profile - pre and first post laser click and 
%           amplitude modulated csd 
% AvgCSDfig(homedir)


%% Group Sorting

%Input:     ...\Dynamic_CSD_Analysis\DATA -> *DATA.mat; (bin, zscore,
%           mirror)
%Output:    Figures of groups in "Group..." folder 
%           .mat files in DATA/Output folder
%           AVG data

% Data out:     Data struct contains sorted tuning of all tonotopies per
%               layer per parameter (for FIRST sink in layer if it
%               falls between 0:65 ms, pause&click not included); 

% Figures out:  Tuning curves: peak amp, SinkRMS, temporal sinkRMS for groups
%               Latency curves: sink onset and sink peak timing tuned to
%               peak of sinkRMS

% Note:         Single trial parameters possible but commented and not
%               currently able to run. 
%               Will need to be adapted to run more than one condition.
disp('Running Group Anyalysis')
GroupAnalysis_gerbil(1,0,0,homedir);


