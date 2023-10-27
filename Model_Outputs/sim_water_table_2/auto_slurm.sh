#!/bin/bash

# Counter to create new simulation directory
simulation_count=0

values_1st_2nd=(1)
values_1st_4th=(1)
values_3rd_1st=(0)
values_3rd_4th=(1)
values_3rd_5th=(1.0)
values_3rd_6th=(-1.5)
values_3rd_7th=(0.5)

# Nested loops to go through each combination
for value_1st_2nd in "${values_1st_2nd[@]}"; do
    for value_1st_4th in "${values_1st_4th[@]}"; do
        for value_3rd_1st in "${values_3rd_1st[@]}"; do
            for value_3rd_4th in "${values_3rd_4th[@]}"; do
                for value_3rd_5th in "${values_3rd_5th[@]}"; do
                    for value_3rd_6th in "${values_3rd_6th[@]}"; do
                        for value_3rd_7th in "${values_3rd_7th[@]}"; do
                            # Increment the counter
                            ((simulation_count++))

                            # Create the simulation_N directory
                            sim_dir="sim_water_table_$simulation_count"
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

                            # Modify the site_US-EDN.txt file
                            awk -v v1_2="$value_1st_2nd" -v v1_4="$value_1st_4th" -v v3_1="$value_3rd_1st" -v v3_4="$value_3rd_4th" -v v3_5="$value_3rd_5th" -v v3_6="$value_3rd_6th" -v v3_7="$value_3rd_7th" 'NR==1 {$2=v1_2; $4=v1_4} NR==3 {$1=v3_1; $4=v3_4; $5=v3_5; $6=v3_6; $7=v3_7}1' site_US-EDN.txt > tmp.txt && mv tmp.txt site_US-EDN.txt

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

