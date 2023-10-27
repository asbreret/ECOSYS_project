clearvars;
clc;
close all;

%% Load Input Data

% Define the main data file
input_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Site_file\';
fname = 'site_data.xlsx';
data = readtable([input_dir,fname]);
codes = data.LocationCode;


for i = 1:length(codes)
    code = codes{i};

    input_dir_1 = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Management_Files\',code];
    input_dir_2 = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Site_Files\',code];

    files = dir(fullfile(input_dir_1, 'level_*'));

    if isempty(files) % No files that start with "level_"
        % Look in the alternative directory

        site_file = fullfile(input_dir_2, ['site_',code,'.txt']);

        % Extract 5th number from the third line
        fid = fopen(site_file, 'r');
        for i = 1:2
            fgetl(fid); % Skip first two lines
        end
        third_line = str2double(strsplit(fgetl(fid)));
        constant_value = third_line(5);
        fclose(fid);

        A = -constant_value;

    else
        % Existing procedure for loading inputData
        years = arrayfun(@(x) str2double(x.name(7:10)), files);
        startYear = min(years);
        endYear = max(years);

        inputData = [];

        for year = startYear:endYear
            filename = fullfile(input_dir_1, ['level_', num2str(year)]);
            data = load(filename, '-ASCII'); % Load ASCII file

            % Append to inputData
            inputData = [inputData; data];
        end
        A = -inputData(:,3);
    end



    %% Load Output Data

    output_dir = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Model_Outputs\',code];
    outputFile = fullfile(output_dir, '0_dw.nc');

    % Check if the file exists
    if ~exist(outputFile, 'file')
        continue;  % Skip to the next iteration if the file doesn't exist
    end

    wtr_tbl = ncread(outputFile, 'WTR_TBL');
    posix_time_out = ncread(outputFile, 'time');

    % Convert POSIX time to MATLAB datetime format
    timestamps_out = datetime(double(posix_time_out), 'ConvertFrom', 'posixtime');
    B = wtr_tbl;

    %% Plot the Data for Comparison

    % Get screen dimensions
    screenSize = get(0, 'ScreenSize');

    figure('Position', screenSize);

    % Plot input data
    % subplot(2,1,1);

    if length(A) == 1
        plot(timestamps_out,A*ones(length(timestamps_out),1))
    else
        plot(datetime(num2str(inputData(:,1)), 'InputFormat', 'ddMMyyyy'), A);
    end
    xlabel('Date');
    ylabel('Water Table Depth above surface [m]');
    title('Input Water Level');

    ylim([ min([A; B]) ,  max([A; B])   ])

    % Plot output data
    hold on

    plot(timestamps_out, B);
    xlabel('Date');
    ylabel('Water Table Depth above surface [m]');
    title('Output Water Level');

    ylim([ min([A; B]) ,  max([A; B])   ])

    legend('External input','Model output','Location','Best')


    set(gca,'FontSize',18)
    saveas(gcf, ['water_level_',code,'.png']);

    close all

    % pause

end

