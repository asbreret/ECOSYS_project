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

% Generate half-hourly time series for all of 2021
full_2021_time = datetime(2021,1,1):minutes(30):datetime(2021,12,31,23,30,0);
full_2021_time_in_days = datenum(full_2021_time);

% Predict tides for all of 2021
predicted_tides_full_2021_detrended = t_predic(full_2021_time_in_days, tide_struct.name, tide_struct.freq, tide_struct.tidecon);

% Reintroduce the constant shift
predicted_tides_full_2021_with_shift = predicted_tides_full_2021_detrended + constant_shift;

% Plot
figure;

% First subplot (original data)
subplot(2, 1, 1);
plot(time, water_level,'b');
title('Original Water Level Data (2021)');
xlim([datetime(2021,1,1) datetime(2021,12,31)]);
xlabel('Time');
ylabel('Water Level');

% Second subplot (predicted tides with reintroduced shift for all of 2021)
subplot(2, 1, 2);
plot(full_2021_time, predicted_tides_full_2021_with_shift,'r');
title('Predicted Tides using T_TIDE for Full 2021 with Constant Shift');
xlim([datetime(2021,1,1) datetime(2021,12,31)]);
xlabel('Time');
ylabel('Water Level');

% Adjust the spacing between plots
sgtitle('Comparison of Original Data and T_TIDE Predictions for 2021');




stop





% 1. Remove data from 2012 and before, and 2021 and after
start_date = datetime('01-Jan-2013');
end_date = datetime('31-Dec-2020');
inds = time < start_date | time > end_date;
time(inds) = [];
Water_level_interp(inds) = [];

% 2. Create new data for 2011 and 2012, using 2013 data. Prepend
time_2013_data = Water_level_interp(year(time) == 2013);
time_2011 = time(year(time) == 2013) - calyears(2);
time_2012 = time(year(time) == 2013) - calyears(1);

time = [time_2011; time_2012; time];
Water_level_interp = [time_2013_data; time_2013_data; Water_level_interp];

% Convert the unique days to 'categorical' for accumarray
[unique_days, ~, idx] = unique(dateshift(time, 'start', 'day'));

% Use accumarray to accumulate values and then compute the mean
sums = accumarray(idx, Water_level_interp);
counts = accumarray(idx, 1);  % Count number of elements in each group
daily_avg = sums ./ counts;


for yr = 2011:2020
    year_inds = year(unique_days) == yr;

    curr_unique_days = unique_days(year_inds);
    curr_repmat = repmat(23, sum(year_inds), 1);
    curr_daily_avg = daily_avg(year_inds)/100; %cm -> m

    % File format: ddmmyyyy 23 averageValue
    filename = sprintf('water_level_%d', yr);

    fileID = fopen(filename, 'w');
    for j = 1:length(curr_unique_days)
        fprintf(fileID, '%02d%02d%d 23 %.2f\n', day(curr_unique_days(j)), month(curr_unique_days(j)), year(curr_unique_days(j)), curr_daily_avg(j));
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
