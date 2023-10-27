clearvars;
clc;
close all;

% Set directories and paths
base_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Files\';
filePath = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Soil_file\map_data.xlsx';

% Read in the matrix and set initial values
Matrix = readmatrix('lake_soil');


% Matrix = [Matrix, Matrix(:,end)]; % Append the last column
Matrix(1,end-2:end) = [0, 1, 0];

% Read in the table data
table = readtable(filePath);
code = table.code;

% 1. Set all nan values in the 4th row and above to the 11th value of the respective row:
for i = 4:size(Matrix, 1)
    row_val = Matrix(i, 11);
    Matrix(i, isnan(Matrix(i, :))) = row_val;
end

% 2. Modify the second row:
N = 20;
z_new = 0.01 + 3.49 * ((0:(N-1)) / (N-1)).^2;

% 3. Modify the first row:
Matrix(1, 17) = N - 1;

% 4. Modify from the 9th column of the second row based on the grid stretching of z_new:
start_val = 1.0;
end_val = 1.5;
start_index = 9;
end_index = N - 1;  % because we start at 9

Matrix(2,:) = z_new;

% Interpolate based on the grid stretching of z_new
interp_values = interp1([z_new(start_index), z_new(end_index)], [start_val, end_val], z_new(start_index:end_index), 'linear', 'extrap');
Matrix(3, start_index:end_index) = interp_values;
Matrix(3,8) = 0.0;

% Process and save the files
for i = 1:length(code)
    directoryPath = fullfile(base_dir, code{i});
    filename = fullfile(directoryPath, ['soil_',code{i},'.txt']);
    roundedMatrix = round(Matrix, 2);
    writematrix(roundedMatrix, filename);
    disp('Input file generated successfully.');
end
