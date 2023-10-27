clearvars
clc
close all

varname = 'WaterLevel_cm';

% Load data
load website_data.mat

% Extract data for WaterLevel_cm
ind = contains(HEADER, varname);
water_level = DATA{ind};

time = TIME{ind};
time_interp = time;

% Remove zeros and replace them with NaN
water_level(water_level == 0) = nan;
water_level(water_level == -704030) = nan;

% Remove outliers
ind = isoutlier(water_level,'movmedian',480);
water_level(ind) = nan;

% Filtering nans
ind_nan = isnan(water_level);
water_level(ind_nan) = [];
time(ind_nan) = [];


Water_level_interp = interp1(time, water_level, time_interp, 'linear');

time = time_interp;

% Plot the data
plot(time, Water_level_interp);

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
    curr_daily_avg = -daily_avg(year_inds)/100; %cm -> m
    
    % File format: ddmmyyyy 23 averageValue
    filename = sprintf('water_level_%d', yr);
    
    fileID = fopen(filename, 'w');
    for j = 1:length(curr_unique_days)
        fprintf(fileID, '%02d%02d%d 23 %.2f\n', day(curr_unique_days(j)), month(curr_unique_days(j)), year(curr_unique_days(j)), curr_daily_avg(j));
    end
    fclose(fileID);
end
