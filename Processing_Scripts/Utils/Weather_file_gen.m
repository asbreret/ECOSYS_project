function [] = Weather_file_gen(fname)

% Read the netCDF file information
ncInfo = ncinfo(fname);
ncVars = {ncInfo.Variables.Name};

% Specify variables of interest
Var_of_int = {'time', 'TA', 'VPD', 'RH', 'WS', 'P', 'SW_IN'};

% Qualifiers and their descriptions (order matters)
qualifiers = {'_F', '_PI', '_QC', '_IU', ''};

% Initialize the structure to store best variable names
bestVarNames = struct();

% Determine the best variable names based on qualifiers
for i = 1:length(Var_of_int)
    found = false;
    for j = 1:length(qualifiers)
        varName = [Var_of_int{i}, qualifiers{j}];
        if ismember(varName, ncVars)
            bestVarNames.(Var_of_int{i}) = varName;
            found = true;
            break;
        end
    end
    % Fall back to base variable if no qualifier was matched
    if ~found && ismember(Var_of_int{i}, ncVars)
        bestVarNames.(Var_of_int{i}) = Var_of_int{i};
    end
end

% Check if all variables exist
if length(fieldnames(bestVarNames)) == 7
    disp('All variables exist, wehey')
else
    disp('Some variables missing. Uh-oh')
end

% Load data from the file
for i = 1:length(Var_of_int)
    if isfield(bestVarNames, Var_of_int{i}) 
        Atmos_var.(Var_of_int{i}) = ncread(fname, bestVarNames.(Var_of_int{i}));
    else
        Atmos_var.(Var_of_int{i}) = nan(size(Atmos_var.time));
    end
end
Atmos_var.time = datetime(Atmos_var.time, 'ConvertFrom', 'posixtime');

% Extract date and time components
yr = year(Atmos_var.time);
mnth = month(Atmos_var.time);
dy = day(Atmos_var.time, "dayofyear");
hr = hour(Atmos_var.time);
mn = minute(Atmos_var.time);

% Remove half hourly times (may consider averaging in future work)
halfHourIndices = mn == 30;
hr(halfHourIndices) = [];
dy(halfHourIndices) = [];
mnth(halfHourIndices) = [];
Atmos_var.time(halfHourIndices) = [];
yr(halfHourIndices) = [];

% Compute additional parameters
Temp_kelvin = Atmos_var.TA + 273.15;
VPS = 0.61 .* exp(5360.0 .* (3.661E-03 - 1.0 ./ Temp_kelvin)); % saturated vapor pressure
P_ambient = VPS - (Atmos_var.VPD / 10); % convert VPD from hPa to kPa
RH_estimate = (P_ambient ./ VPS) * 100;
RH_estimate = max(2, min(98, RH_estimate)); % Clip RH values between 2 and 98

% Write weather data per year
uniqueYears = unique(yr);
for i = 1:length(uniqueYears)
    ind = yr == uniqueYears(i);
    filename = ['weather_', num2str(uniqueYears(i))];
    header = ["HJ0305XDHTHWPR"; "KRSMW"];
    data = [10.00, 1.00, 19.99, 0.00, 0.00, 0.00, 0.00, 0.00; 
            7.00, 0.09, 0.15, 0.00, 0.00, 0.00, 0.00, 0.00];
    writematrix(header, filename, 'FileType', 'text', 'WriteMode', 'overwrite');
    writematrix(data, filename, 'FileType', 'text', 'WriteMode', 'append', 'Delimiter', ',');

    Matrix = [yr(ind), dy(ind), hr(ind), Temp_kelvin(ind), RH_estimate(ind), ...
              Atmos_var.WS(ind), Atmos_var.P(ind), Atmos_var.SW_IN(ind)];
    Matrix = round(Matrix, 2);
    writematrix(Matrix, filename, 'WriteMode', 'append');
end

end
