#!/bin/bash

# Define target directories
TARGET_DIRS=(
"/global/home/users/ashbre/MY_TESTS/Zero_bulk_density_pond/"
"/global/home/users/ashbre/MY_TESTS/Low_bulk_density_pond/"
)

# Loop through each target directory and copy files
for dir in "${TARGET_DIRS[@]}"; do
    # Copy input files into the target directory
    cp ../*.txt "$dir"
    cp ../d* "$dir"
    cp ../gr* "$dir"
    cp ../pft* "$dir"
    cp ../GRA* "$dir"
    cp ../soil* "$dir"
    cp ../level* "$dir"
    cp ../lvl* "$dir"
    
    # Copy specific files from current directory to target directory
    cp *.sh "$dir"
    cp slurm* "$dir"
    cp Runfile_US-EDN.txt "$dir"
done

echo "Files copied successfully to target directories!"

