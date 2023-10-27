function [] = Weather_file_gen(fname,inputdir)

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
time = Atmos_var.time;

% Extract date and time components
yr = year(time);
mnth = month(time);
dy = day(time, "dayofyear");
hr = hour(time);
mn = minute(time);

% Remove half hourly times (may consider averaging in future work)
halfHourIndices = mn == 30;
hr(halfHourIndices) = [];
dy(halfHourIndices) = [];
mnth(halfHourIndices) = [];
yr(halfHourIndices) = [];
time(halfHourIndices) = [];
Atmos_var.TA(halfHourIndices) = [];
Atmos_var.VPD(halfHourIndices) = [];
Atmos_var.WS(halfHourIndices) = [];
Atmos_var.P(halfHourIndices) = [];
Atmos_var.SW_IN(halfHourIndices) = [];


% I want to gap fill the following:

% time = Atmos_var.time;
TA = Atmos_var.TA;
VPD = Atmos_var.VPD;
WS = Atmos_var.WS;
P = Atmos_var.P;
SW_IN = Atmos_var.SW_IN;





TA = gapFill(TA, time);
VPD = gapFill(VPD, time);
WS = gapFill(WS, time);
P = gapFill(P, time);
SW_IN = gapFill(SW_IN, time);




% Calculate some variables:

Temp_kelvin = TA + 273.15;
VPS = 0.61 .* exp(5360.0 .* (3.661E-03 - 1.0 ./ Temp_kelvin)); % saturated vapor pressure
P_ambient = VPS - (VPD / 10); % convert VPD from hPa to kPa
RH_estimate = (P_ambient ./ VPS) * 100;
RH_estimate = max(2, min(98, RH_estimate)); % Clip RH values between 2 and 98



figure;

subplot(5,1,1)
plot(time,TA)
ylabel('Temp (°C)') % assuming Celsius; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,2)
plot(time,RH_estimate)
ylabel('RH (%)')
set(gca,'FontSize',14)

subplot(5,1,3)
plot(time,WS)
ylabel('Wind (m/s)') % assuming meters per second; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,4)
plot(time,P)
ylabel('Rain (mm)') % assuming millimeters; adjust if necessary
set(gca,'FontSize',14)

subplot(5,1,5)
plot(time,SW_IN)
ylabel('Solar (W/m^2)') % assuming Watts per square meter; adjust if necessary
set(gca,'FontSize',14)

sgtitle('Weather for US-Hsm') % Overall title for the




% Write weather data per year
uniqueYears = unique(yr);
for i = 1:length(uniqueYears)
    ind = yr == uniqueYears(i);
    filename = ['weather_', num2str(uniqueYears(i))];
    header = ["HJ0305XDHTHWPR"; "KRSMW"];
    data = [10.00, 1.00, 19.99, 0.00, 0.00, 0.00, 0.00, 0.00;
        7.00, 0.09, 0.15, 0.00, 0.00, 0.00, 0.00, 0.00];
    writematrix(header, [inputdir,filename], 'FileType', 'text', 'WriteMode', 'overwrite');
    writematrix(data, [inputdir,filename], 'FileType', 'text', 'WriteMode', 'append', 'Delimiter', ',');

    Matrix = [yr(ind), dy(ind), hr(ind), Temp_kelvin(ind), RH_estimate(ind), ...
        WS(ind), P(ind), SW_IN(ind)];
    Matrix = round(Matrix, 2);

    % Check the day number in the last row
    lastDay = Matrix(end, 2);

    % If the last day is 365, duplicate the rows with day 365 and append
    if lastDay == 365
        rowsToCopy = Matrix(Matrix(:, 2) == 365, :);   % Extract rows with day 365
        rowsToCopy(:, 2) = 366;                        % Change the day number to 366
        Matrix = [Matrix; rowsToCopy];                 % Append to the main matrix
    end

    writematrix(Matrix, [inputdir,filename], 'WriteMode', 'append');
end

end

