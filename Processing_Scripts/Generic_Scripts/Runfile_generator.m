clearvars
clc
close all

% Define the main data file
input_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\';
fname = 'site_data.xlsx';
data = readtable([input_dir,fname]);
code = data.LocationCode;

for k = 1:length(code)

    p=0;
    if k == 1

        p = 1;

    elseif k==10

        p = 1;

    end

    % Define the directory path for the current code
    weatherDirectory = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Weather_Files\', code{k}, '\'];

    % Use the dir function to get a list of all weather files in the directory
    weatherFiles = dir([weatherDirectory, 'weather_*.txt']);

    % Extract the years from the filenames
    years = zeros(1, length(weatherFiles));
    for idx = 1:length(weatherFiles)
        % Extract year from filename (assuming format is weather_YYYY.txt)
        years(idx) = str2double(weatherFiles(idx).name(9:12));
    end

    % Determine the number of files (N) and the earliest year
    N = length(years);
    earliest_year = min(years);

    % Define the initial and final years
    initialYear = 1901;
    finalYear = 2019;

    % Open the input file for writing
    runFileDirectory = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Run_files\', code{k}, '\'];
    runFileName = [runFileDirectory, 'Runfile_', code{k}, '.txt'];
    fileID = fopen(runFileName, 'w');

    % Write the initial content of the input file line by line
    headerContent = {
        '#!/bin/bash -l'
        '#SBATCH --partition=lr3'
        '#SBATCH --ntasks=1'
        '#SBATCH --mem=512mb'
        '#SBATCH --time=0:30:00'
        '#SBATCH --qos=lr_normal'
        '/global/home/users/ashbre/ecosys13022023/ecosys.x << eor > logdl'
        '1 1 1 1'
        ['site_',code{k},'.txt']
        ['topo_',code{k},'.txt']
        '120 1'
    };

    for i = 1:numel(headerContent)
        fprintf(fileID, '%s\n', headerContent{i});
    end

    % Generate the content for each year and write it to the file
    content = generateYearContent(1900, 0, N, earliest_year,p);
    for j = 1:numel(content)
        fprintf(fileID, '%s\n', content{j});
    end

    for year = initialYear:finalYear
        content = generateYearContent(year, 1, N, earliest_year,p);

        for j = 1:numel(content)
            fprintf(fileID, '%s\n', content{j});
        end
    end

    fprintf(fileID, '%s', '0 0');

    % Close the file
    fclose(fileID);
end

% Display confirmation message
disp("Extended input file generated successfully.");

% Function to generate the content for each year
function content = generateYearContent(year, flag, N, earliest_year,p)
    weatherFile = sprintf('weather_%d.txt', mod((year - earliest_year), N) + earliest_year);
    optionsFile = sprintf('Options_%d.txt', year);

    if p == 1

    soilManageFile = sprintf('soil_manage_%d', year);

    else

        soilManageFile = sprintf('Soil_manage.txt');

    end

    if flag == 0
        content = {
            '1 1'
            weatherFile
            optionsFile
            soilManageFile
            'pft_plant'
            'NO'
            'NO'
            'NO'
            'NO'
            'NO'
            'dc'
            'dw'
            'dn'
            'dp'
            'dh'
        };
    else
        content = {
            '1 1'
            weatherFile
            optionsFile
            soilManageFile
            'pft_grow'
            'NO'
            'NO'
            'NO'
            'NO'
            'NO'
            'dc'
            'dw'
            'dn'
            'dp'
            'dh'
        };
    end
end
