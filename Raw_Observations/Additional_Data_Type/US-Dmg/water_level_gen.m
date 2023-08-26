clearvars;
clc;
close all;

% Add t_tide to the MATLAB path
addpath('C:\Users\asbre\OneDrive\Desktop\t_tide_v1.4beta');

% Load data and extract relevant variables
load('website_data.mat');
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
    fileID = fopen(filename, 'w');
    for j = 1:length(unique_days)
        fprintf(fileID, '%02d%02d%d 23 %.2f\n', day(unique_days(j)), month(unique_days(j)), year(unique_days(j)), daily_avg_values(j));
    end
    fclose(fileID);
end




function water_level_out = modelTidalSignal(time, water_level, time_out_daily)

    % Known tidal frequencies (M2, S2, N2, K2, K1, O1, P1, Q1 - more can be added)
    tidal_freqs = [28.9841042; 30; 28.4397295; 30.0821373; 15.0410686; 13.9430356; 14.9589314; 13.3986609] / (24*60.0); 

    % Convert 'time' to numeric values for ease of computation
    time_numeric = datenum(time);
    reconstructed_time_numeric = datenum(time_out_daily(1)):mean(diff(time_numeric)):datenum(time_out_daily(end));

    reconstructed_signal = zeros(size(reconstructed_time_numeric));
    for i = 1:length(tidal_freqs)
        omega = 2 * pi * tidal_freqs(i);
        
        % Compute the cosine and sine amplitudes
        cos_amp = 2 * trapz(time_numeric, water_level .* cos(omega * time_numeric)) / length(time_numeric);
        sin_amp = 2 * trapz(time_numeric, water_level .* sin(omega * time_numeric)) / length(time_numeric);
        
        % Add the contribution of this frequency to the reconstructed signal
        reconstructed_signal = reconstructed_signal + ...
            cos_amp * cos(omega * reconstructed_time_numeric) + ...
            sin_amp * sin(omega * reconstructed_time_numeric);
    end
    
    % Ensure that both are column vectors
    reconstructed_time_numeric = reconstructed_time_numeric(:);
    reconstructed_signal = reconstructed_signal(:);

    % Create a timetable with the reconstructed data for the desired dates
    tt_reconstructed = timetable(datetime(reconstructed_time_numeric,'ConvertFrom','datenum'), reconstructed_signal, 'VariableNames', {'ReconstructedSignal'});
    water_level_out = tt_reconstructed;
end
