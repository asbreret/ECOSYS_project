clearvars
clc
close all

sites = {'US-Dmg', 'US-EDN', 'US-EKH', 'US-EKP','US-EKY','US-Hsm', 'US-Myb', 'US-Sne', 'US-Srr', 'US-Tw1', 'US-Tw4'};

obs_data = struct();
model_data = struct();

for s = 1:length(sites)
    site = sites{s};
    safe_site_name = strrep(site, '-', '_');  % Replace hyphen with underscore

    % Paths for observation and model files
    obs_filename_fluxnet = fullfile('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations', site, '*FLUXNET*nc');
    obs_file_fluxnet = dir(obs_filename_fluxnet);

    if isempty(obs_file_fluxnet)
        obs_filename_base = fullfile('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Atmospheric_Observations', site, '*BASE*nc');
        obs_file = dir(obs_filename_base);

        if isempty(obs_file)
            fprintf('No observation files found for site %s. Skipping...\n', site);
            continue;  % Skip the rest of the loop for this site
        else
            obs_file_path = fullfile(obs_file.folder, obs_file.name);
        end

    else
        obs_file_path = fullfile(obs_file_fluxnet.folder, obs_file_fluxnet.name);
    end



    % Extract observation data
    obs_info = ncinfo(obs_file_path);
    varnames = {obs_info.Variables.Name};

    % Extract NEE data
    matching_vars_nee = startsWith(varnames, 'NEE');
    matching_vars_gpp = startsWith(varnames, 'GPP');
  

    if ~any(matching_vars_nee)
        continue;  % Skip to the next iteration if no matching NEE variables are found
    end

    time_obs = ncread(obs_file_path, 'time');
    time_obs = datetime(time_obs, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime
    time_obs1 = time_obs;


    % Fetch NEE values from obs file
    nee_values = [];
    for j = 1:length(varnames)
        if matching_vars_nee(j)
            data = ncread(obs_file_path, varnames{j});
            nee_values = [nee_values, data];
        end
    end
    avg_nee = mean(nee_values, 2);

    [~, avg_nee] = convert_obs(time_obs, avg_nee);

    
    obs_data.(safe_site_name).nee_values = nee_values;
    obs_data.(safe_site_name).avg_nee = avg_nee;

    % Fetch GPP values from obs file (if available)
    gpp_values = [];
    for j = 1:length(varnames)
        if matching_vars_gpp(j)
            data = ncread(obs_file_path, varnames{j});
            gpp_values = [gpp_values, data];
        end
    end
    avg_gpp = mean(gpp_values, 2);

    [time_obs, avg_gpp] = convert_obs(time_obs, avg_gpp);

    obs_data.(safe_site_name).time = time_obs;
    obs_data.(safe_site_name).full_time = time_obs1;
    obs_data.(safe_site_name).gpp_values = gpp_values;
    obs_data.(safe_site_name).avg_gpp = avg_gpp;

end



for s = 1:length(sites)


    site = sites{s};
    safe_site_name = strrep(site, '-', '_');  % Replace hyphen with underscore
    model_filename = fullfile('C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs', site, '0_dc.nc');

    % Extract model data for NEE and GPP
    ECO_GPP = ncread(model_filename, 'ECO_GPP');
    AUTO_RESP = ncread(model_filename, 'AUTO_RESP'); % check
    ECO_RA = ncread(model_filename, 'ECO_RA');
    NEE_model = ECO_GPP - (AUTO_RESP + ECO_RA);
    time_model = ncread(model_filename, 'time');
    time_model = datetime(time_model, 'ConvertFrom', 'posixtime');  % Convert POSIX time to datetime




    [~, ECO_GPP]   = convert_model(time_model, ECO_GPP);
    [~, AUTO_RESP] = convert_model(time_model, AUTO_RESP);
    [~, ECO_RA]    = convert_model(time_model, ECO_RA);
    [time_model, NEE_model] = convert_model(time_model, NEE_model);





    model_data.(safe_site_name).time = time_model;
    model_data.(safe_site_name).NEE = NEE_model;
    model_data.(safe_site_name).GPP = ECO_GPP;  % Storing model GPP
end










% NEE comparison plotting
figure;
sgtitle('Net Ecosystem Exchange (NEE)');

for s = 1:length(sites)
    site = sites{s};
    safe_site_name = strrep(site, '-', '_');  % Replace hyphen with underscore

    if isfield(obs_data, safe_site_name)
        subplot(ceil(length(sites)/2), 2, s);



        TIME = obs_data.(safe_site_name).time;
        DATA = obs_data.(safe_site_name).avg_nee;

        yyaxis left;
        plot(TIME, DATA, 'b', 'DisplayName', 'Observed NEE Daily Avg');
        ylabel('g C m^{-2} d^{-1}');

        hold on;

        % Convert and plot model data for NEE
        yyaxis right;
        TIME = model_data.(safe_site_name).time;
        DATA = model_data.(safe_site_name).NEE;

        plot(TIME, DATA, 'r', 'DisplayName', 'Model NEE Daily');
        ylabel('g C m^{-2} d^{-1}');

        % Set xlim based on observations
        xlim([min(obs_data.(safe_site_name).time) max(obs_data.(safe_site_name).time)]);

        title(['Site: ', site]);
        legend('Obs','Model','Location','Best')
        hold off;
    end
end




% GPP comparison plotting
figure;
sgtitle('Gross Primary Production (GPP)');
for s = 1:length(sites)
    site = sites{s};
    safe_site_name = strrep(site, '-', '_');  % Replace hyphen with underscore

    if isfield(obs_data, safe_site_name)
        subplot(ceil(length(sites)/2), 2, s);

        % Convert and plot observation GPP data
        TIME = obs_data.(safe_site_name).time;
        DATA = obs_data.(safe_site_name).avg_gpp;


        yyaxis left;
        plot(TIME, DATA, 'b', 'DisplayName', 'Observed GPP Daily Avg');
        ylabel('g C m^{-2} d^{-1}');

        hold on;

        % Convert and plot model GPP data
        yyaxis right;
        TIME = model_data.(safe_site_name).time;
        DATA = model_data.(safe_site_name).GPP;


        plot(TIME, DATA, 'r', 'DisplayName', 'Model GPP Daily');
        ylabel('g C m^{-2} d^{-1}');

        % Set xlim based on observations
        xlim([min(obs_data.(safe_site_name).time) max(obs_data.(safe_site_name).time)]);

        title(['Site: ', site]);
        legend('Obs','Model','Location','Best')
        hold off;
    end
end






% Conversion functions
function [daily_time, daily_nee_or_gpp] = convert_obs(obs_time, obs_nee_or_gpp)
    % Parameters
    conversion_factor = 12.011 * 1e-6;  % Conversion from µmol CO2 to g C
    time_step_seconds = seconds(diff(obs_time(1:2)));
    values_per_day = round(86400 / time_step_seconds);  % 86400 seconds in a day

    % Average the observed NEE or GPP over each day, multiply by the total seconds in a day, and convert to g C m^-2 day^-1
    daily_nee_or_gpp = mean(reshape(obs_nee_or_gpp, values_per_day, []), 1) * 86400 * conversion_factor;
    daily_time = obs_time(1:values_per_day:end);
end


function [daily_time, daily_nee_or_gpp] = convert_model(model_time, model_nee_or_gpp_cumulative)
% Compute the daily values by taking the difference between successive cumulative values
daily_nee_or_gpp = diff(model_nee_or_gpp_cumulative);

% Detect year boundaries
year_boundaries = find(year(model_time(1:end-1)) < year(model_time(2:end)));

% Handle the change of year by simply taking the value for the first day of the new year
for idx = year_boundaries'
    daily_nee_or_gpp(idx) = model_nee_or_gpp_cumulative(idx+1);
end

% Adjust daily_time to match the length of daily_nee_or_gpp
daily_time = model_time(1:end-1);
end
