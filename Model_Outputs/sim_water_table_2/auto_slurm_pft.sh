#!/bin/bash

# Counter to create new simulation directory
simulation_count=0

# Parameters to sweep (replace with your desired values)
values_13th_1st=(-1.5)             # Maximum Osmotic Potential
values_13th_2nd=(-4.0 -6.0 -8.0)       # Shape Parameter for Stomatal Resistance
values_13th_3rd=(2000 5000)            # Cuticular Resistance

values_9th_1st=(2.0E-04 5.0E-04)       # Radius of Primary Roots
values_9th_2nd=(1.0E-04 1.5E-04 2.0E-04) # Radius of Secondary Roots
values_9th_3rd=(0.1 0.2 0.33)        # Root Porosity
values_9th_5th=(2.5E+03)               # Root Radial Resistivity (only one value suggested)
values_9th_6th=(7.5E+08 3.75E+09)      # Root Axial Resistivity

# Nested loops to go through each combination
for value_13th_1st in "${values_13th_1st[@]}"; do
    for value_13th_2nd in "${values_13th_2nd[@]}"; do
        for value_13th_3rd in "${values_13th_3rd[@]}"; do
            for value_9th_1st in "${values_9th_1st[@]}"; do
                for value_9th_2nd in "${values_9th_2nd[@]}"; do
                    for value_9th_3rd in "${values_9th_3rd[@]}"; do
                        for value_9th_5th in "${values_9th_5th[@]}"; do
                            for value_9th_6th in "${values_9th_6th[@]}"; do

                                # Increment the counter
                                ((simulation_count++))

                                # Create the simulation_N directory
                                sim_dir="sim_plant_growth_$simulation_count"
                                mkdir -p "$sim_dir"

                                # Copy input files into the simulation_N directory
                                cp ../*.txt "$sim_dir/"
                                cp ../d* "$sim_dir/"
                                cp ../gr* "$sim_dir/"
                                cp ../pft* "$sim_dir/"
                                cp ../GRA* "$sim_dir/"
                                cp ../soil* "$sim_dir/"
                                cp ../level* "$sim_dir/"
                                cp ../lvl* "$sim_dir/"

                                # Copy specific files from current directory to simulation_N
                                cp *.sh "$sim_dir/"
                                cp slurm* "$sim_dir/"
                                cp Runfile_US-EDN.txt "$sim_dir/"

                                # CD into the directory
                                cd "$sim_dir"





                                # Modify the gr3a35 file with the parameter values for this iteration


				awk -v v13_1="$value_13th_1st" \
				    -v v13_2="$value_13th_2nd" \
				    -v v13_3="$value_13th_3rd" \
				    -v v9_1="$value_9th_1st" \
				    -v v9_2="$value_9th_2nd" \
				    -v v9_3="$value_9th_3rd" \
				    -v v9_5="$value_9th_5th" \
				    -v v9_6="$value_9th_6th" \
				    'NR==13 {$1=v13_1; $2=v13_2; $3=v13_3} NR==9 {$1=v9_1; $2=v9_2; $3=v9_3; $5=v9_5; $6=v9_6} 1' \
				    gr3a35 > tmp.txt && mv tmp.txt gr3a35




                                # Submit the SLURM job
                                sbatch Runfile_US-EDN.txt

                                # CD back to the parent directory
                                cd ..
                            done
                        done
                    done
                done
            done
        done
    done
done

