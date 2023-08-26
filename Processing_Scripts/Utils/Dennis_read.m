clearvars
clc
close all

% load website_data.mat

% List of suffixes and their corresponding site codes
suffixes = {'WP', 'EE', 'GT', 'HS', 'MB', 'SI'};
site_codes = {'US-TW1', 'US-TW4', 'US-Dmg', 'US-Hsm', 'US-Myb', 'US-Sne'};

% Create a map to hold the suffix to code mapping
codeMap = containers.Map(suffixes, site_codes);

% Now, codeMap holds the mapping of each suffix to its hardcoded site code.

for k = 1:length(suffixes)

    site_code = codeMap(suffixes{k})


    url = ['https://nature.berkeley.edu/biometlab/bmetdata/data.php?screen=graphs&code=',suffixes{k}];
    idNumbers = graph_numbers(url);

    startDate = datetime(2010, 1, 1);
    endDate   = datetime(  'today' );

    A = startDate:endDate;

    

    for j = 1:length(idNumbers)
        

        parfor i = 1:length(A)


            B = datestr(A(i), 'yyyy-mm-dd');
            url = ['https://nature.berkeley.edu/biometlab/bmetdata/graphs.php?GID=',num2str(idNumbers(j)),'&setT=',B,'&days=1']

            [columns(i).header, data(i).data] = Dennis_extractor(url);

        end

        
      

        header1 = columns(1).header;

        D = {data.data};
        D = vertcat(D{:});

        if ~isempty(D)

        time(j).time = datetime(D(:,1), 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
        website_data(j).data = str2double(D);
        header(j).header = header1;

        end


    end

    count = 0;
    for i = 1:length(website_data)
        for j = 2:size(website_data(i).data,2)

            count = count+1;

            TIME{count} = time(i).time;
            DATA{count} = website_data(i).data(:,j);
            HEADER{count} = header(i).header{j};

        end
    end

clear time website_data header columns data




    % Create the save path
    savePathDirectory = ['C:\Users\asbre\OneDrive\Desktop\ECOSYS_project\Raw_Observations\Additional_Data_Type\', site_code];
    
    % Form the full path to the .mat file
    savePathFull = fullfile(savePathDirectory, 'website_data.mat');

    % Save the variables to the .mat file
    save(savePathFull, 'TIME', 'DATA', 'HEADER');

    clearvars TIME DATA HEADER

end






function idNumbers = graph_numbers(url)


% Assuming the HTML content is stored in a variable named 'htmlContent'
htmlContent = webread(url);

% Define the regular expression pattern to find the ID numbers
pattern = 'graphdescriptions.php\?scrn=graphedit&id=(\d+)';

% Use regexp to find all occurrences of the pattern in the HTML content
matches = regexp(htmlContent, pattern, 'tokens');

% Initialize an empty array to store the extracted ID numbers
idNumbers = [];

% Loop through the matches and extract the ID numbers
for i = 1:length(matches)
    match = matches{i};
    idNumber = str2double(match{1}); % Convert the matched string to a number
    idNumbers = [idNumbers, idNumber]; % Append the ID number to the array
end



end







