clearvars
clc
close all

% Utility library
addpath('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Processing_Scripts\Utils')

% filecode
code = 'US-Dmg';

% Where observations and inputs live
basedir = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations\',code,'\'];
inputdir = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Weather_Files\',code,'\'];

% Get the list of relevant filenames in the current directory
fname = [basedir,'AMF_US-Dmg_BASE_HH_1-5.csv'];

% First let's convert the file into netcdf format, storing in observations.
nc_fname = netcdf_convert(fname);

% Genereate weather files
Weather_file_gen(nc_fname,inputdir)