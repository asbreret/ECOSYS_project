
% Clear environment and close figures
clearvars;
clc;
close all;

% Define paths and filenames
obs_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations\US-Tw1';
obs_filename = 'AMF_US-Tw1_FLUXNET_FULLSET_HH_2011-2020_3-5.nc';

model_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\US-Tw1';
model_filename = '0_dc.nc';

% Extract observation data
obs_file_path = fullfile(obs_path, obs_filename);
obs_info = ncinfo(obs_file_path);
varnames = {obs_info.Variables.Name};

% Identify all variables that start with NEE and GPP
nee_vars = varnames(startsWith(varnames, 'NEE'));
gpp_vars = varnames(startsWith(varnames, 'GPP'));

% Initialize matrices to store the data
nee_data = [];
gpp_data = [];

% Loop through the NEE and GPP variables to read the data
for i = 1:length(nee_vars)
    nee_data = [nee_data, ncread(obs_file_path, nee_vars{i})];
end

for i = 1:length(gpp_vars)
    gpp_data = [gpp_data, ncread(obs_file_path, gpp_vars{i})];
end

% Compute the mean across all columns for NEE and GPP
nee_obs_mean = mean(nee_data, 2);
gpp_obs_mean = mean(gpp_data, 2);

% Convert the observation data into daily averages using timetables
time_obs = ncread(obs_file_path, 'time');
time_obs = datetime(time_obs, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime
tt_obs = timetable(time_obs, nee_obs_mean, gpp_obs_mean);
tt_daily_avg = retime(tt_obs, 'daily', 'mean');

% Extract model data
model_file_path = fullfile(model_path, model_filename);
ECO_GPP = ncread(model_file_path, 'ECO_GPP');
ECO_RH = ncread(model_file_path, 'ECO_RH');
ECO_RA = ncread(model_file_path, 'ECO_RA');
NEE_model = ECO_GPP - (ECO_RH + ECO_RA);
time_model = ncread(model_file_path, 'time');
time_model = datetime(time_model, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime

% Plot NEE comparison
figure;
plot(tt_daily_avg.time_obs, tt_daily_avg.nee_obs_mean, 'b', 'DisplayName', 'Observed NEE Daily Avg');
hold on;
plot(time_model, NEE_model, 'r', 'DisplayName', 'Model NEE Daily Avg');
xlabel('Time');
ylabel('g C m^{-2} d^{-1}');
title('Net Ecosystem Exchange (NEE) Comparison for US-Tw1');
legend('Location','Best');
hold off;

% Plot GPP comparison
figure;
plot(tt_daily_avg.time_obs, tt_daily_avg.gpp_obs_mean, 'b', 'DisplayName', 'Observed GPP Daily Avg');
hold on;
plot(time_model, ECO_GPP, 'r', 'DisplayName', 'Model GPP Daily Avg');
xlabel('Time');
ylabel('g C m^{-2} d^{-1} ');
title('Gross Primary Production (GPP) Comparison for US-Tw1');
legend('Location','Best');
hold off;
