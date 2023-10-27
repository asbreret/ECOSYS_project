clearvars
clc
close all

% Matrix = base_paramters;
Matrix = readmatrix('sUS_Myb');
Matrix(:,end+1) = Matrix(:,end);
Matrix(1,end-2) = 0;
Matrix(1,end-1) = 1;
Matrix(1,end) = 0;

% Matrix1(isnan(Matrix1)) = 0;
% Matrix1(isnan(Matrix1)) = -1;
% Matrix = readmatrix('soilsample.csv');
%Matrix(:,1:12) = Matrix1(:,1:12);

% Matrix(1:size(Matrix1,1),1:size(Matrix1,2)) = Matrix1;

% Specify the Excel file path
filePath = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Soil_file\map_data.xlsx';
base_dir = 'C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Inputs\Soil_Files\';

% Read the data from the Excel file
table = readtable(filePath);

code = table.code;
labData = table.LabData;
dominantSoil = table.DominantSoil;


% 
% parfor i = 1:length(dominantSoil)
% 
%     url = labData{i};
% 
%     if ~isempty(url)
%         % url = 'https://ncsslabdatamart.sc.egov.usda.gov/rptExecute.aspx?p=69917&r=1&';
%         variables_1(i) = soil_depth_properties(url);
%         variables_1(i).data = 1;
%     else
%         variables_1(i).data = 0;
%     end
% 
% 
%     url = dominantSoil{i};
% 
%     if ~isempty(url)
%         % url = 'https://casoilresource.lawr.ucdavis.edu/soil_web/property_with_depth_table.php?&cokey=22732732';
%         variables_2(i) = soil_extract(url);
%         variables_2(i).data = 1;
%     else
%         variables_2(i).data = 0;
%     end
% 
% 
% end

%%

for i = 2:size(Matrix, 1)
    last_val = NaN;  % Initial value which will be updated
    for j = 1:size(Matrix, 2)
        if isnan(Matrix(i, j))
            if ~isnan(last_val)
                Matrix(i, j) = last_val;
            end
        else
            last_val = Matrix(i, j);
        end
    end
end



N=20;
Matrix(1,17) = N;

z_new(1:N) = 0.01 + 2.24 * ((0:(N-1)) / (N-1)).^2;

Matrix_new = NaN(size(Matrix, 1), N); % Preallocate a new matrix with N columns
Matrix_new(1, :) = Matrix(1, :); % Copy the first row as it is
Matrix_new(2, :) = z_new; % Assign the new depth values

z_old = Matrix(2, :);


for i = 3:size(Matrix, 1)
    valid_indices = ~isnan(Matrix(i, :)) & z_old ~= 0; % Indices where data is not NaN and depth is not 0

    [unique_z, unique_idx] = unique(z_old(valid_indices)); % Get unique depth values
    unique_data = Matrix(i, valid_indices);
    unique_data = unique_data(unique_idx); % Get the corresponding data values

    % Interpolation
    Matrix_new(i, :) = interp1(unique_z, unique_data, z_new, 'linear', 'extrap');
end




Matrix = Matrix_new;



for i = 1:length(code)

    directoryPath = fullfile(base_dir, code{i});
    filename = fullfile(directoryPath, ['soil_',code{i},'.txt']);

    % 1st row:
    %
    % (Soil water potential at field capacity (MPa), Soil water potential at Wilting point (MPa), Soil albedo when wet, Residue Ph, Initial fine plant residue [C,N,P], Initial coarse plant residue [C,N,P], Initial animal residue [C,N,P], plant residue type, animal manure type, Soil Surface Layer number, Layer number at max root depth, Add layers below max root depth, number of canopy layers)

    % 2nd row row depths of the soil layer (m) (zero means no more layers),

    % z = zeros(1,size(Matrix,2));
    % N = 12; % amount of depth layers
    % z(1:N) = 0.01 + 2.24 * ((0:(N-1)) / (N-1)).^2;

    % Matrix(2,:) = z_new;

    % 3rd row bulk densities (mg/m3)

     % bulk = 0.9;
     % Matrix(3,:) = bulk;

    % 4th row Water content at field capacity (m3 m-3).
    % 5th row Water content at wilting point (m3 m-3).
    % 6th row Saturated hydraulic conductivity in the vertical direction (mm h-1).
    % 7th row Saturated hydraulic conductivity in the horizontal direction (mm h-1)


    % % 8th row is sand content (g/kg)
    % % 
    %  sand = variables_2(i).sand(1);
    %  Matrix(8,:) = sand * 10; % percent -> g/kg
    % 
    % % 
    % % % 9th row is silt content (g/kg)
    % % 
    %  silt = 100 - variables_2(i).sand(1) - variables_2(i).clay(1);
    %  Matrix(9,:) = silt * 10; % percent -> g/kg

    % 10th row is volume frac of macropores - leave as 0
    % 11th row is vol frac of coarse fragments - leave as 0

    % 12th row pH 5.6

    % pH = 5.6;
    % Matrix(12,:) = pH;

    % 13th row Cation exchange capacity (cmol+ kg-1).
    % 14th row  Anion exchange capacity (cmol- kg-1).



    % 15th row       Total organic C (g C kg-1)
    % 16th row Particulate organic C (g C kg-1)
    % 17th row Particulate organic N (g N Mg-1)
    % 18th row Particulate organic P (g P Mg-1)

    % 19th row NH4 (g N Mg-1).
    % 20th row NO3 (g N Mg-1).
    % 21st row   P (g P Mg-1).
    % 22nd row  Al (g Al Mg-1).
    % 23rd row  Fe (g Fe Mg-1).
    % 24th row  Ca (g Ca Mg-1).
    % 25th row  Mg (g Mg Mg-1).
    % 26th row  Na (g Na Mg-1).
    % 27th row   K (g K Mg-1).
    % 28th row   S (g S Mg-1).
    % 29th row  Cl (g Cl Mg-1).

    % 30th row Variscite (g P Mg-1).
    % 31st row Strengite (g P Mg-1).
    % 32nd row Monetite (g P Mg-1).
    % 33rd row Hydroxyapatite (g P Mg-1).
    % 34th row Amorphous aluminum hydroxide (g Al Mg-1).
    % 35th row  Soil iron (g Fe Mg-1).
    % 36th row  Calcite (g Ca Mg-1).
    % 37th row  Gypsum (g Ca Mg-1).

    % 38th row  Gapon selectivity coefficient for Ca2+ - NH4+ exchange
    % 39th row  Gapon selectivity coefficient for Ca2+ -   H+ exchange
    % 40th row  Gapon selectivity coefficient for Ca2+ - Al3+ exchange
    % 41st row  Gapon selectivity coefficient for Ca2+ - Mg2+ exchange
    % 42nd row  Gapon selectivity coefficient for Ca2+ -  Na+ exchange
    % 43rd row  Gapon selectivity coefficient for Ca2+ -   K+ exchange


    % 44th row Initial water content (fraction [0 1]) - 0.66? (2.65 - bulk /
    % 2.65)

    % IWC = (2.65 - bulk)/2.65;
    % Matrix(44,:) = IWC; % percent -> g/kg

    % 45th row Initial   ice content (fraction [0 1]) - 0?

    % IIC = 0;
    % Matrix(45,:) = IIC; % percent -> g/kg

    % 46th row Initial fine plant residue C (g C m-2)
    % 47th row Initial fine plant residue N (g N m-2)
    % 48th row Initial fine plant residue P (g P m-2)

    % 49th row Initial coarse woody residue C (g C m-2)
    % 50th row Initial coarse woody residue N (g N m-2)
    % 51th row Initial coarse woody residue P (g P m-2)

    % 52th row Initial Animal manure C (g C m-2)
    % 53th row Initial Animal manure N (g N m-2)
    % 54th row Initial Animal manure P (g P m-2)



    roundedMatrix = round(Matrix_new, 2);

    % Write the formatted matrix to the file
    writematrix(roundedMatrix, filename);

    disp('Input file generated successfully.');

end



