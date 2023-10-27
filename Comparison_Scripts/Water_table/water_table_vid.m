clear all
clc
close all

% Read EWT from file lvl_1900
data = load('lvl_1900');
EWT = -data(:, 3) + 0.5;

% Read IWT from netCDF file 0_dw.nc
IWT = ncread('0_dw.nc', 'WTR_TBL')+0.5;
EL = ncread('0_dw.nc', 'SURF_ELEV');
EL = EL(1:366);
IWT = IWT(1:366) + EL;
IWT(IWT < -2) = -2;
% IWT(IWT>0) = 0;




% Check lengths of data
if length(EWT) ~= length(IWT)
    error('EWT and IWT have different lengths. Please ensure they are of the same length or handle accordingly.');
end

% Create the video
createWaterTableVideo(EWT, IWT, 2);

function createWaterTableVideo(EWT, IWT, flag)
    figure;

    time_start = datetime(2010,1,1);
    time = time_start + days(0:365);

    gifFilename = 'water_table_2nd.gif';
    aviFilename = 'water_table_2nd.avi';
    
    if flag == 1
        video = VideoWriter(aviFilename);
        video.FrameRate = 10;
        open(video);
    end

    for i = 1:100
        clf; % Clear the current frame
        
        % Draw blocks
        drawWaterBlock(-2, -2, EWT(i));
        drawEcosysBlock(0, -2, IWT(i));

        % Set labels
        text(-1, -1, 'External Water Table', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'k', 'Rotation', 90);
        text(1, -1, 'Ecosys', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'k', 'Rotation', 90);

        % Add date to the title
        title(datestr(time(i), 'dd-mmm-yyyy'), 'FontSize', 12);

        % Axis setup
        xticks([]);
        axis([-3, 3, -2, 2]);
        set(gca, 'FontSize', 18);

        drawnow;
        frame = getframe(gcf);
        img = frame2im(frame);
        
        if flag == 1 % Write to AVI
            writeVideo(video, frame);
        elseif flag == 2 % Write to GIF
            [imgInd, cmap] = rgb2ind(img, 256);
            if i == 1
                imwrite(imgInd, cmap, gifFilename, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
            else
                imwrite(imgInd, cmap, gifFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end
        
        pause(0.1);
    end

    if flag == 1
        close(video);
    end
end



function drawWaterBlock(xPos, yPos, waterLevel)
    waterHeight = abs(yPos) + waterLevel;
    rectangle('Position', [xPos, yPos, 2, waterHeight], 'FaceColor', 'blue');
end

function drawEcosysBlock(xPos, yPos, waterLevel)
    % Define colors
    wetSoilColor = [0.4, 0.3, 0.1]; % Darker brown for wet soil
    drySoilColor = [0.6, 0.4, 0.2]; % Lighter brown for dry soil

    % If water level goes above 0
    if waterLevel > 0
        rectangle('Position', [xPos, yPos, 2, 2], 'FaceColor', wetSoilColor);
        rectangle('Position', [xPos, yPos + 2, 2, waterLevel], 'FaceColor', 'blue');
    else
        % If water level is within the soil
        wetSoilHeight = abs(yPos) + waterLevel;
        drySoilHeight = 2 - wetSoilHeight;
        rectangle('Position', [xPos, yPos, 2, wetSoilHeight], 'FaceColor', wetSoilColor);
        rectangle('Position', [xPos, yPos + wetSoilHeight, 2, drySoilHeight], 'FaceColor', drySoilColor);
    end
end
