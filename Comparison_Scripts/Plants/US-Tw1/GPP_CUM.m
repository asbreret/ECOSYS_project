clearvars
clc
close all

% Define paths and filenames
obs_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations\US-Tw1';
obs_filename = 'AMF_US-Tw1_FLUXNET_FULLSET_HH_2011-2020_3-5.nc';
obs_file_path = fullfile(obs_path, obs_filename);

% Extract observation data
varnames = {ncinfo(obs_file_path).Variables.Name};
nee_vars = varnames(startsWith(varnames, 'NEE'));
gpp_vars = varnames(startsWith(varnames, 'GPP'));

nee_data = [];
gpp_data = [];

% Retrieve NEE and GPP data
for i = 1:length(nee_vars)
    nee_data = [nee_data, ncread(obs_file_path, nee_vars{i})];
end

for i = 1:length(gpp_vars)
    gpp_data = [gpp_data, ncread(obs_file_path, gpp_vars{i})];
end

% Compute mean values
nee_obs_mean = mean(nee_data, 2);
gpp_obs_mean = mean(gpp_data, 2);

% Convert the observation data into daily averages using timetables
time_obs = datetime(ncread(obs_file_path, 'time'), 'ConvertFrom', 'posixtime');
tt_obs = timetable(time_obs, nee_obs_mean, gpp_obs_mean);
tt_daily_avg = retime(tt_obs, 'daily', 'mean');

% Plotting section
years = unique(year(tt_daily_avg.time_obs));
colors = jet(length(years));

figure;

% Cumulative data subplot
subplot(1, 2, 2);
hold on;
for i = 1:length(years)
    idx = year(tt_daily_avg.time_obs) == years(i);
    % plot(tt_daily_avg.time_obs(idx), cumsum(tt_daily_avg.gpp_obs_mean(idx)), 'Color', colors(i, :));
    plot(tt_daily_avg.time_obs(idx), cumsum(tt_daily_avg.gpp_obs_mean(idx)), 'Color', 'r', 'LineWidth',3);
end
title('Cumulative GPP');
hold off;
ylabel('g C m^{-2}')

set(gca,'FontSize',16)

% Non-cumulative data subplot
subplot(1, 2, 1);
hold on;
for i = 1:length(years)
    idx = year(tt_daily_avg.time_obs) == years(i);
    plot(tt_daily_avg.time_obs(idx), tt_daily_avg.gpp_obs_mean(idx), 'Color', 'b', 'LineWidth',3);
end
title('Observed GPP Daily Avg');
set(gca,'FontSize',16)
ylabel('g C m^{-2}')
hold off;
