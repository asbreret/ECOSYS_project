clearvars
clc
close all

% Add utility path
addpath('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Processing_Scripts\Utils')

% Temporarily set userpath to the current directory
userpath(pwd);

% Change working directory to where the files are
cd('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\US-Srr');

% Your scripts
dc_plotter
dn_plotter
dp_plotter
dw_plotter
dh_plotter

dc_plant_plotter
dn_plant_plotter
dp_plant_plotter
dw_plant_plotter
dh_plant_plotter

% Change back to the original directory using userpath
cd(userpath);
