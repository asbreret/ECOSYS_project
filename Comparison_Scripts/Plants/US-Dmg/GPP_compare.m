% Clear environment and close figures
clearvars;
clc;
close all;

% Define paths and filenames
obs_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations\US-Dmg';
obs_filename = 'AMF_US-Dmg_BASE_HH_1-5.nc';

model_path = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\US-Dmg';
model_filename = '0_dc.nc';

% Extract observation data
obs_file_path = fullfile(obs_path, obs_filename);
obs_info = ncinfo(obs_file_path);
varnames = {obs_info.Variables.Name};

% Get NEE and GPP data from observation file
nee_obs = ncread(obs_file_path, 'NEE');
gpp_obs = ncread(obs_file_path, 'GPP');
time_obs = ncread(obs_file_path, 'time');
time_obs = datetime(time_obs, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime

% Average NEE and GPP observation data daily using timetables
tt_obs = timetable(time_obs, nee_obs, gpp_obs);
tt_daily_avg = retime(tt_obs, 'daily', 'mean');

% Extract model data
model_file_path = fullfile(model_path, model_filename);
ECO_GPP = ncread(model_file_path, 'ECO_GPP');
AUTO_RESP = ncread(model_file_path, 'AUTO_RESP');
ECO_RA = ncread(model_file_path, 'ECO_RA');
NEE_model = ECO_GPP - (AUTO_RESP + ECO_RA);
time_model = ncread(model_file_path, 'time');
time_model = datetime(time_model, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime

% Daily average for model data using timetables
tt_model = timetable(time_model, NEE_model, ECO_GPP);
tt_model_daily_avg = retime(tt_model, 'daily', 'mean');

% Plot NEE comparison
figure;
plot(tt_daily_avg.time_obs, tt_daily_avg.nee_obs, 'b', 'DisplayName', 'Observed NEE Daily Avg');
hold on;
plot(tt_model_daily_avg.time_model, tt_model_daily_avg.NEE_model, 'r', 'DisplayName', 'Model NEE Daily');
xlabel('Time');
ylabel('g C m^{-2} d^{-1}');
title('Net Ecosystem Exchange (NEE) Comparison for US-Dmg');
legend('Location','Best');
hold off;

% Plot GPP comparison
figure;
plot(tt_daily_avg.time_obs, tt_daily_avg.gpp_obs, 'b', 'DisplayName', 'Observed GPP Daily Avg');
hold on;
plot(tt_model_daily_avg.time_model, tt_model_daily_avg.ECO_GPP, 'r', 'DisplayName', 'Model GPP Daily');
xlabel('Time');
ylabel('g C m^{-2} d^{-1}');
title('Gross Primary Production (GPP) Comparison for US-Dmg');
legend('Location','Best');
hold off;
