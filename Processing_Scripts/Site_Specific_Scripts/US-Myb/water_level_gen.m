clearvars;
clc;
close all;

% Add t_tide to the MATLAB path
addpath('C:\Users\asbre\OneDrive\Desktop\t_tide_v1.4beta');
base_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Management_Files\US-Myb\';

% Load data and extract relevant variables
load('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Additional_Data_Type\US-Myb\website_data.mat');
varname = 'WaterLevel_cm';
ind = contains(HEADER, varname);
water_level = DATA{ind};
time = TIME{ind};

% Pre-process water level data
water_level(water_level == 0 | water_level == -704030) = NaN;
water_level(isoutlier(water_level, 'movmedian', 480)) = NaN;

% Remove NaNs and corresponding timestamps
valid_data = ~isnan(water_level);
water_level = water_level(valid_data);
time = time(valid_data);

% Filter data after a certain date
cutoff = datetime(2021,11,10);
valid_dates = time >= cutoff;
water_level = water_level(valid_dates);
time = time(valid_dates);

% Detrend data before tidal analysis
water_level_detrended = detrend(water_level);

% Compute the constant shift
constant_shift = mean(water_level) - mean(water_level_detrended);

% Convert time to days since reference for T_TIDE
time_in_days = datenum(time);

% Tidal analysis with T_TIDE
[tide_struct, ~] = t_tide(water_level_detrended, 'interval', mean(diff(time_in_days)*24), 'start', time_in_days(1));

% Loop through the years 1900-2020
for yr = 1900:2020
    % Generate half-hourly time series for the current year
    full_year_time = datetime(yr,1,1):minutes(30):datetime(yr,12,31,23,30,0);
    full_year_time_in_days = datenum(full_year_time);

    % Predict tides for the entire year
    predicted_tides_full_year_detrended = t_predic(full_year_time_in_days, tide_struct.name, tide_struct.freq, tide_struct.tidecon);

    % Reintroduce the constant shift
    predicted_tides_full_year_with_shift = predicted_tides_full_year_detrended + constant_shift;

    % Convert to timetable and compute daily average
    tt_year = timetable(full_year_time', predicted_tides_full_year_with_shift', 'VariableNames', {'PredictedTide'});
    daily_avg_year = retime(tt_year, 'daily', 'mean');

    % Extract unique days and daily averages
    unique_days = dateshift(daily_avg_year.Time, 'start', 'day');
    daily_avg_values = -daily_avg_year.PredictedTide/100; % Convert cm to m (negative is above soil)

    % Write to file
    filename = sprintf('level_%d', yr);
    fullpath = [base_dir,filename];
    fileID = fopen(fullpath, 'w');
    for j = 1:length(unique_days)
        fprintf(fileID, '%02d%02d%d 23 %.2f\n', day(unique_days(j)), month(unique_days(j)), year(unique_days(j)), daily_avg_values(j));
    end
    fclose(fileID);

    % Create and save the secondary file
    sec_filename = sprintf('%ssoil_manage_%d', base_dir, yr);
    sec_fileID = fopen(sec_filename, 'w');
    fprintf(sec_fileID, "1 1 1 1\n");
    fprintf(sec_fileID, "%s NO NO\n", filename);
    fclose(sec_fileID);
end
