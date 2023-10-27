% Clear workspace, command window, and close all figures
clear all;
clc;
close all;

% File path
filename = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Core_Samples\US-EKH\bulk_density_2022.xlsx';
sheet = 'bulk density';

% Read data using readtable
dataTbl = readtable(filename, 'Sheet', sheet);

% Convert depth range to average value
depth_intervals = cellfun(@(x) mean(sscanf(x, '%f-%f')), dataTbl.Var3);

% Convert bulk_density to a matrix if it's a cell
if iscell(dataTbl.Var4)
    bulk_density = cell2mat(dataTbl.Var4);
else
    bulk_density = dataTbl.Var4;
end

% Extract unique depth intervals and sort them
[unique_depths, sortIdx] = sort(unique(depth_intervals, 'stable'));

% Calculate mean and standard deviation for each depth interval using the sorted indices
means = zeros(length(unique_depths), 1);
std_devs = zeros(length(unique_depths), 1);

for i = 1:length(unique_depths)
    idx = depth_intervals == unique_depths(i);
    means(i) = mean(bulk_density(idx));
    std_devs(i) = std(bulk_density(idx));
end

% Ensure means and standard deviations are sorted corresponding to the sorted unique depths
means = means(sortIdx);
std_devs = std_devs(sortIdx);

% Plotting the data
figure;
plot(means, unique_depths, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8);
hold on;

capLength = 0.2; % This determines the length of the caps on the error bars. Adjust as needed.

for i = 1:length(unique_depths)
    % Main horizontal error bar
    line([means(i) - std_devs(i), means(i) + std_devs(i)], [unique_depths(i), unique_depths(i)], 'Color', 'b', 'LineWidth', 1.5);
    
    % Caps for the error bars
    line([means(i) - std_devs(i), means(i) - std_devs(i)], [unique_depths(i) - capLength, unique_depths(i) + capLength], 'Color', 'b', 'LineWidth', 1.5);
    line([means(i) + std_devs(i), means(i) + std_devs(i)], [unique_depths(i) - capLength, unique_depths(i) + capLength], 'Color', 'b', 'LineWidth', 1.5);
end

set(gca, 'YDir', 'reverse'); % Reverse the y-axis to show depth from surface downwards
ylabel('Depth (cm)');
xlabel('Bulk Density (g/cm^3)');
title('Soil Bulk Density Profile');
grid on;



% Display the results
disp('Mean Bulk Densities:');
disp(means);
disp('Standard Deviations:');
disp(std_devs);
