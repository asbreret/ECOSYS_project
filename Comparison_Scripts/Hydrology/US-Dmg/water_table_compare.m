clearvars;
clc;
close all;

%% Load Input Data

input_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Management_Files\US-Dmg';
files = dir(fullfile(input_dir, 'level_*'));

% Extract start and end years automatically from filenames
years = arrayfun(@(x) str2double(x.name(7:10)), files);
startYear = min(years);
endYear = max(years);

inputData = [];

for year = startYear:endYear
    filename = fullfile(input_dir, ['level_', num2str(year)]);
    data = load(filename, '-ASCII'); % Load ASCII file
    
    % Append to inputData
    inputData = [inputData; data];
end


%% Load Output Data

output_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\US-Dmg';
outputFile = fullfile(output_dir, '0_dw.nc');

wtr_tbl = ncread(outputFile, 'WTR_TBL');
posix_time_out = ncread(outputFile, 'time');

% Convert POSIX time to MATLAB datetime format
timestamps_out = datetime(double(posix_time_out), 'ConvertFrom', 'posixtime');

%% Plot the Data for Comparison

figure;

% Plot input data
subplot(2,1,1);

A = -inputData(:,3);
B = wtr_tbl;

plot(datetime(num2str(inputData(:,1)), 'InputFormat', 'ddMMyyyy'), A);
xlabel('Date');
ylabel('Water Table Depth above surface [m]');
title('Input Water Level');

ylim([ min([A; B]) ,  max([A; B])   ])

% Plot output data
subplot(2,1,2);

plot(timestamps_out, B);
xlabel('Date');
ylabel('Water Table Depth above surface [m]');
title('Output Water Level');

ylim([ min([A; B]) ,  max([A; B])   ])

