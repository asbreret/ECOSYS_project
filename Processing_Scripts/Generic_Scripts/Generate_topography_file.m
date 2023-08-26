function Generate_topography_file(topography_filename, topography_parameters)
    % Write the landscape parameters to the file
    fid = fopen(topography_filename, 'w');
    fprintf(fid, '%d %d %d %d %d %d %.2f %d\n', ...
        topography_parameters.nw_corner_column, topography_parameters.nw_corner_row, ...
        topography_parameters.se_corner_column, topography_parameters.se_corner_row, ...
        topography_parameters.aspect, topography_parameters.slope, ...
        topography_parameters.surface_roughness, topography_parameters.initial_snow_depth);
    fprintf(fid, topography_parameters.soil_file);
    fclose(fid);
    
    % Display a message
    disp('Topography file generated successfully.');
    disp(['File saved as: ' topography_filename]);
end