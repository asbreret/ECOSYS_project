import os
import re
import pandas as pd
import numpy as np
from netCDF4 import Dataset
from multiprocessing import Pool, cpu_count

def createNetCDFFromTable(fname, replacements):
    '''
    This function converts a csv file to a NetCDF file.
    
    fname: csv file name
    replacements: dictionary of replacements
    '''
    try:
        # Create a NetCDF file name by adding .nc to the original file name
        ncfile = fname + '.nc'
    
        # If the file already exists, remove it
        if os.path.isfile(ncfile):
            os.remove(ncfile)
    
        # Read the file using pandas
        TABLE = pd.read_csv(fname, delim_whitespace=True)
    
        # Add leading zeros to the DATE column
        TABLE["DATE"] = TABLE["DATE"].astype(str).str.zfill(8)
    
        # Convert the DATE column to datetime format directly
        A = pd.to_datetime(TABLE["DATE"].astype(str), format="%d%m%Y", errors='coerce')
        # Take only the non-na values
        ind = ~A.isna()
        TABLE = TABLE[ind]
    
        # Convert the datetime to serial date numbers
        dateNum = np.array(pd.to_datetime(A[ind]).astype(np.int64) // 10**9)
    
        # Create a NetCDF file with the 'time' dimension
        with Dataset(ncfile, 'w') as nc:
            nc.createDimension('time', len(dateNum))
            time_var = nc.createVariable('time', np.int64, ('time',))
            time_var[:] = dateNum
    
            # Get the headers from the dataframe
            headers = TABLE.columns[2:]
            # Get the values from the dataframe
            data = TABLE[headers].values
    
            # Vectorize the replace_values function
            vectorized_replace = np.vectorize(lambda val: replacements.get(val, val))
            # Replace the values in the data
            data = vectorized_replace(data)
    
            # Loop over each variable and add it to the NetCDF file
            for i, varName in enumerate(headers):
                varData = data[:, i]
                varName_cleaned = varName.replace('[', '').replace(']', '')
                nc.createVariable(varName_cleaned, np.float64, ('time',))
                nc[varName_cleaned][:] = varData
    except Exception as e:
        print(f"Error processing file {fname}: {e}")


def process_files(MN_value, replacements):
    '''
    This function processes all files that match a pattern.
    
    MN_value: a tuple with the values of M and N
    replacements: dictionary of replacements
    '''
    M, N = MN_value
    # Create a regex pattern
    fname_pattern = f'^\\d{{4}}{M}\\d{{4}}{N}$'
    # Get all the files that match the pattern
    matching_files = [f for f in os.listdir() if re.match(fname_pattern, f)]

    for ascii_fname in matching_files:
        createNetCDFFromTable(ascii_fname, replacements)

def run_parallel(M_values, N_values, replacements):
    '''
    This function runs the process_files function in parallel.
    
    M_values: list of possible M values
    N_values: list of possible N values
    replacements: dictionary of replacements
    '''
    # Create a list of all combinations of M and N values
    MN_combinations = [(M, N) for M in M_values for N in N_values]

    # Get the number of CPU cores
    num_cores = cpu_count()

    print("Number of CPU cores available:", num_cores)

    # Create a pool of processes
    with Pool(processes=num_cores) as pool:
        # Run the process_files function in parallel
        pool.starmap(process_files, [(mn, replacements) for mn in MN_combinations])

if __name__ == "__main__":
    # Define the M and N values and the replacements dictionary
    M_values = [0,1]
    N_values = ['dc', 'dn','dp', 'dw', 'dh']

    replacements = {
        'EMERGENCE': '9000',
        'FLORAL_INIT.': '9001',
        'JOINTING': '9002',
        'ELONGATION': '9003',
        'ANTHESIS': '9004',
        'SEED_FILL': '9005',
        'SEED_NO._SET': '9006',
        'SEED_MASS_SET': '9007',
        'END_SEED_FILL': '9008',
        'PLANTING': '9009',
        'HEADING' : '9010',
    }

    # Run the main function
    run_parallel(M_values, N_values, replacements)

