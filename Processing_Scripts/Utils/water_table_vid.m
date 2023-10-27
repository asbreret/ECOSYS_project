clear all
clc
close all


t = 0:0.01:1;
EWT = 0.5 * sin( 2*pi*t ) - 0.5;
IWT = 0.5 * sin( 2*pi* (t - 0.1) ) - 0.5;

createWaterTableVideo(EWT, IWT);






function createWaterTableVideo(EWT, IWT)
    % Ensure the input vectors are of the same length
    if length(EWT) ~= length(IWT)
        error('Both EWT and IWT must be of the same length.');
    end

    % Set up the video
    video = VideoWriter('water_table_demo.avi'); % Create a VideoWriter object
    video.FrameRate = 10; % Set frame rate
    open(video);
    figure;

    for i = 1:length(EWT)
        clf; % Clear the current frame
        
        % External water block
        drawWaterBlock(-2, -3, EWT(i));

        % Soil block
        rectangle('Position', [0, -3, 2, 2], 'FaceColor', [0.6 0.4 0.2]); % RGB for brown
        
        % Internal water block
        drawWaterBlock(0, -1, IWT(i));

        % Set labels for the blocks with vertical alignment
        text(-1, -2, 'External Water Table', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'k', 'Rotation', 90);
        text(1, -2, 'Ecosys', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 10, 'Color', 'k', 'Rotation', 90);

        % Remove x-axis numbers
        xticks([]);
        axis([-3, 3, -3, 1]);
        
        % Capture the plot as an image 
        frame = getframe(gcf);
        writeVideo(video, frame); % Write this frame to the video

        pause(0.1); % Pause for 0.1 second for visual effect
    end

    % Close the video file
    close(video);
end

% Subroutine to draw the water blocks
function drawWaterBlock(xPos, yPos, waterLevel)
    waterHeight = abs(yPos) + waterLevel;
    rectangle('Position', [xPos, yPos, 2, waterHeight], 'FaceColor', 'blue');
end
