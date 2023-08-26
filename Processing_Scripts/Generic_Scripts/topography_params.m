clearvars
clc
close all

base_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Topography_Files\';
filename = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\site_data.xlsx';
data = readtable(filename);
code = data.LocationCode;

% Define the topography parameters structure
topography_parameters.nw_corner_column = 1;    % NW corner column
topography_parameters.nw_corner_row = 1;       % NW corner row
topography_parameters.se_corner_column = 1;    % SE corner column
topography_parameters.se_corner_row = 1;       % SE corner row
topography_parameters.aspect = 90;             % Aspect in degrees (clockwise from north)
topography_parameters.slope = 1;               % Slope in degrees
topography_parameters.surface_roughness = 0.01; % Surface roughness in meters
topography_parameters.initial_snow_depth = 0;  % Initial depth of snowpack in meters


for i = 1:length(code)
    % Call the function to generate the topography file
    directoryPath = fullfile(base_dir, code{i});
    topo_filename = fullfile(directoryPath, ['topo_',code{i},'.txt']);
    
    topography_parameters.soil_file = ['soil_',code{i},'.txt'];
    Generate_topography_file(topo_filename, topography_parameters);
end