clearvars
clc
close all

% Base directory
base_dir = 'C:\Users\asbre\OneDrive\Desktop\Desktop_Aug_2023\ECOSYS\Input files\';
base_dir1 = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\';

% Read the site data
filename = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\site_data.xlsx';
data = readtable(filename);
code = data.LocationCode;

% Define directories
options_dir     = [base_dir1, 'Options_Files\'        ];
weather_dir     = [base_dir1, 'Weather_Files\'        ];  % Specific to each code
site_dir        = [base_dir1, 'Site_files\'           ];
soil_dir        = [base_dir1, 'Soil_files\'           ];
topography_dir  = [base_dir1, 'Topography_files\'     ];
soil_manage_dir1 = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\', 'Soil_Management_Files\'];
soil_manage_dir2 = [base_dir1, 'Soil_Management_Files\'];
run_dir         = [base_dir1, 'Run_files\'            ];  % Specific to each code
pft_dir         = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\' , 'PFT_files\'];
output_dir      = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\' , 'Output_files\'];

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
    copyfile([options_dir     , code{i}, '\*']               , current_destination_dir);
    copyfile([weather_dir     , code{i}, '\*']               , current_destination_dir);
    copyfile([site_dir        , code{i}, '\*']               , current_destination_dir);
    copyfile([soil_dir        , code{i}, '\*']               , current_destination_dir);
    copyfile([topography_dir  , code{i}, '\*']               , current_destination_dir);
    copyfile([soil_manage_dir1          , '*']               , current_destination_dir);

    try
        copyfile([soil_manage_dir2, code{i}, '\*'], current_destination_dir);
    catch ME
        % If the error is about "No matching files", just continue. Otherwise, rethrow the error.
        if ~contains(ME.message, 'No matching files')
            rethrow(ME);
        end

    end
    copyfile([pft_dir                   , '*']               , current_destination_dir);
    copyfile([output_dir                , '*']               , current_destination_dir);
    copyfile([run_dir         , code{i}, '\*']               , [current_destination_dir, '\RUN']);
end
