clearvars
clc
close all

% Define paths
data_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Additional_Data_Type\US-Tw1\';
save_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Management_Files\US-Tw1\';
data_file = 'website_data.mat';
full_data_path = fullfile(data_dir, data_file);

% Specify the variable name
varname = 'WaterLevel_cm';

% Load data
load(full_data_path);

% Extract and preprocess data
ind = contains(HEADER, varname);
water_level = DATA{ind};
time = TIME{ind};
time_interp = time;

water_level(water_level == 0) = nan;
water_level(water_level == -704030) = nan;
ind = isoutlier(water_level,'movmedian',480);
water_level(ind) = nan;
ind_nan = isnan(water_level);
water_level(ind_nan) = [];
time(ind_nan) = [];
Water_level_interp = interp1(time, water_level, time_interp, 'linear');
time = time_interp;

% Exclude data before 2013
Water_level_interp(year(time) < 2013) = [];
time(year(time) < 2013) = [];


% Extract 2013 data
data_2013 = Water_level_interp(year(time) == 2013);
time_2013 = time(year(time) == 2013);

% Create new timestamps for 2011 and 2012
time_2011 = time_2013 - calyears(2);
time_2012 = time_2013 - calyears(1);

% Append the data and timestamps
time = [time_2011; time_2012; time];
Water_level_interp = [data_2013; data_2013; Water_level_interp];



% Convert to timetable and compute daily average
tt = timetable(time, Water_level_interp, 'VariableNames', {'WaterLevel'});
daily_avg_tt = retime(tt, 'daily', 'mean');

% Use 2011-2020 data as the reference
reference_time = daily_avg_tt.time(year(daily_avg_tt.time) >= 2011 & year(daily_avg_tt.time) <= 2020);
reference_daily_avg = daily_avg_tt.WaterLevel(year(daily_avg_tt.time) >= 2011 & year(daily_avg_tt.time) <= 2020);



% Loop through the years 1900-2020
for yr = 1900:2020
    % Compute the offset in years
    offset = yr - 2011;

    % Apply the offset to the reference days
    offset_days = reference_time + calyears(offset);
    curr_daily_avg = -reference_daily_avg / 100; % Convert cm to m (negative is above soil)

    % Filter data for the current year
    curr_offset_days = offset_days(year(offset_days) == yr);
    curr_curr_daily_avg = curr_daily_avg(year(offset_days) == yr);

    % Write the primary file
    filename = sprintf('level_%d', yr);
    fullpath = fullfile(save_dir, filename);
    fileID = fopen(fullpath, 'w');
    for j = 1:length(curr_offset_days)
        fprintf(fileID, '%02d%02d%d 23 %.2f\n', day(curr_offset_days(j)), month(curr_offset_days(j)), year(curr_offset_days(j)), curr_curr_daily_avg(j));


        % If the year is 1900 and the current day is February 28, add an entry for February 29
        if yr == 1900 && day(curr_offset_days(j)) == 28 && month(curr_offset_days(j)) == 2
            fprintf(fileID, '29021900 23 %.2f\n', curr_curr_daily_avg(j));  % Using the value from February 28 for simplicity
        end

    end
    fclose(fileID);

    % Create and save the secondary file
    sec_filename = sprintf('soil_manage_%d', yr);
    sec_fullpath = fullfile(save_dir, sec_filename);
    sec_fileID = fopen(sec_fullpath, 'w');
    fprintf(sec_fileID, "1 1 1 1\n");
    fprintf(sec_fileID, "%s NO NO\n", filename);
    fclose(sec_fileID);
end
