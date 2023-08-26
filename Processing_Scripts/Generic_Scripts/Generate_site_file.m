function Generate_site_file(filename, site_parameters)
% Write parameters to file
fid = fopen(filename, 'w');

% Write Geographic Characteristics
fprintf(fid, '%.1f %.1f %.1f %.1f\n', site_parameters.latitude, site_parameters.altitude, site_parameters.temperature, site_parameters.water_table_flag);

% Write Atmospheric Characteristics
fprintf(fid, '%.1f %.1f %d %.1f %.1f %.3f\n', site_parameters.o2_concentration, site_parameters.n2_concentration, site_parameters.co2_concentration, site_parameters.ch4_concentration, site_parameters.n2o_concentration, site_parameters.nh3_concentration);

% Write Site Characteristics
fprintf(fid, '%.1f %.1f %.1f %.1f %.1f %.1f %.1f\n', site_parameters.experimental_conditions, site_parameters.soil_ph_and_salinity, site_parameters.soil_erosion, site_parameters.grid_cell_interconnected, site_parameters.external_water_table_height, site_parameters.artificial_drainage_depth, site_parameters.water_table_slope);

% Write Boundary Conditions
fprintf(fid, '%.1f %.1f %.1f %.1f ', site_parameters.sbc_north, site_parameters.sbc_east, site_parameters.sbc_south, site_parameters.sbc_west);
fprintf(fid, '%.1f %.1f %.1f %.1f ', site_parameters.water_table_dist_north, site_parameters.water_table_dist_east, site_parameters.water_table_dist_south, site_parameters.water_table_dist_west);
fprintf(fid, '%.1f %.1f %.1f %.1f ', site_parameters.lbc_north, site_parameters.lbc_east, site_parameters.lbc_south, site_parameters.lbc_west);
fprintf(fid, '%.1f %.1f\n', site_parameters.lower_boundary_downward, site_parameters.lower_boundary_upward);

% Write Additional Parameters
fprintf(fid, '%.1f\n', site_parameters.width_x);
fprintf(fid, '%.1f\n', site_parameters.width_y);

% Close the file
fclose(fid);

disp('Input file generated successfully!');
end
