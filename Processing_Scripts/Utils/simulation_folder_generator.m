clearvars
clc
close all

% Base directory
base_dir = 'C:\Users\asbre\OneDrive\Desktop\Desktop_Aug_2023\ECOSYS\Input files\';
base_dir1 = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\';

% Read the site data
filename = [base_dir, 'Site_files\site_data.xlsx'];
data = readtable(filename);
code = data.LocationCode;

% Define directories
options_dir = [base_dir, 'Option_files\'];
weather_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Weather_Files\';  % Specific to each code
site_dir = [base_dir, 'Site_files\'];
soil_dir = [base_dir, 'Soil_files\'];
topography_dir = [base_dir, 'Topography_files\'];
soil_manage_dir = [base_dir, 'Soil_management_files\'];
run_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Run_files\';  % Specific to each code
pft_dir = [base_dir1, 'PFT_files\']; % General for each code currently
output_dir = [base_dir, 'Output_files\'];

destination_base = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Lawrencium\';

for i = 1:length(code)
    current_destination_dir = [destination_base, code{i}];
    
    % Create directories
    if ~exist(current_destination_dir, 'dir')
        mkdir(current_destination_dir);
    end
    if ~exist([current_destination_dir, '\RUN'], 'dir')
        mkdir([current_destination_dir, '\RUN']);
    end

    % Copy files
    copyfile([options_dir, '*.txt'], current_destination_dir);
    copyfile([weather_dir, code{i}, '\*.txt'], current_destination_dir);
    copyfile([site_dir, 'site_', code{i}, '.txt'], current_destination_dir);
    copyfile([soil_dir, 'soil_', code{i}, '.txt'], current_destination_dir);
    copyfile([topography_dir, 'topo_', code{i}, '.txt'], current_destination_dir);
    copyfile([soil_manage_dir, 'Soil_manage.txt'], current_destination_dir);
    copyfile([pft_dir, '*'], current_destination_dir);
    copyfile([output_dir, '*'], current_destination_dir);
    copyfile([run_dir, code{i}, '\Runfile_', code{i}, '.txt'], [current_destination_dir, '\RUN']);
end
