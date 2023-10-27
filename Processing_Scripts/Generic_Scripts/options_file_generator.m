clearvars
clc
close all

all_years = 1900:2019;

% Read the site data
filename = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\site_data.xlsx';
data = readtable(filename);
code_list = data.LocationCode;

base_dir1 = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Options_Files\';

for j = 1:length(code_list)

    code = code_list{j};

    for i = all_years

        t = datetime(   i,01,01,'Format','ddMMyyyy'); start_date = char(t); % Start Date
        t = datetime(   i,12,31,'Format','ddMMyyyy'); end_date = char(t); % End Date
        t = datetime(1900,01,01,'Format','ddMMyyyy'); start_date_init = char(t); % Start Date of Model Run


        % Dynamic visulation; Store output for later run; Initialise run from
        % stored output.

        options = {'NO'; 'NO'; 'NO'};

        % [Multiplier for solar radiation,
        % Addition to maximum daily temperature,
        % Addition to minimum daily temperature,
        % Multiplier for humidity,
        % Multiplier for precipitation,
        % Multiplier for irrigation,
        % Multiplier for wind speed,
        % Multiplier for atmospheric CO2,
        % Multiplier for NH4+ in precipitation,
        % Multiplier for NO3- in precipitation]


        climate_change_multipliers = [
            1, 0.00, 0.00, 1, 1.00, 1, 1, 1, 1, 1;
            1, 0.00, 0.00, 1, 1.00, 1, 1, 1, 1, 1;
            1, 0.00, 0.00, 1, 1.00, 1, 1, 1, 1, 1;
            1, 0.00, 0.00, 1, 1.00, 1, 1, 1, 1, 1
            ];

        time_step = 15; %15
        gas_exchange_step = 3;
        hourly_output_freq = 12;
        daily_output_freq = 1;
        restart_file_freq = -1;
        climate_change_flag = 1;

        vec = [time_step,gas_exchange_step,hourly_output_freq,daily_output_freq,restart_file_freq,climate_change_flag];

        % Save the file
        % Determine the full path for saving the file
        directoryPath = fullfile(base_dir1, code);

        filename = fullfile(directoryPath, ['Options_', num2str(i), '.txt']);
        fid = fopen(filename, 'w');

        % Write each line separately with append mode
        fprintf(fid, '%s\n', start_date);
        fprintf(fid, '%s\n', end_date);
        fprintf(fid, '%s\n', start_date_init);

        fprintf(fid, '%s\n', options{1});
        fprintf(fid, '%s\n', options{2});
        fprintf(fid, '%s', options{3});

        % Close the file
        fclose(fid);

        writematrix(climate_change_multipliers,filename,'WriteMode','append')
        writematrix(                       vec,filename,'WriteMode','append')

    end

end

disp('Input file generated successfully.');