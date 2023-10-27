import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit
import xarray as xr
from sklearn.preprocessing import MinMaxScaler




def read_gpp_from_netcdf(file_path):
    # Read in the NetCDF data
    dataset = xr.open_dataset(file_path)

    # Extract GPP data
    gpp_vars = [var for var in dataset.data_vars if 'GPP' in var]
    gpp_data = [dataset[var].values for var in gpp_vars]
    gpp_mean = sum(gpp_data) / len(gpp_data)

    time_obs = dataset['time'].values
    gpp_df = pd.DataFrame({'time_obs': time_obs, 'gpp_mean': gpp_mean})
    gpp_df.set_index('time_obs', inplace=True)
    gpp_daily_avg = gpp_df.resample('D').mean()

    # Unrolling the years into one continuous time series
    gpp_daily_avg = gpp_daily_avg.reset_index()
    gpp_daily_avg['time_obs'] = pd.date_range(start=gpp_daily_avg['time_obs'].iloc[0], periods=len(gpp_daily_avg), freq='D')
    gpp_daily_avg.set_index('time_obs', inplace=True)

    return gpp_daily_avg


def read_weather_data(start_year=2011, end_year=2020):
    dfs = []
    for year in range(start_year, end_year + 1):
        file_name = f"weather_{year}.txt"
        df = pd.read_csv(file_name, skiprows=4, names=['year', 'dayofyear', 'hourofday', 'temperature', 'relativehumidity', 'windspeed', 'precipitation', 'solar radiation'])
        df['datetime'] = pd.to_datetime(df['year'].astype(str) + df['dayofyear'].astype(str) + df['hourofday'].astype(str), format='%Y%j%H')
        dfs.append(df.set_index('datetime'))
    final_df = pd.concat(dfs)
    return final_df

def resample_data(data):
    daily_data = data.resample('D').mean()
    daily_data['dayofyear'] = daily_data.index.dayofyear  # <-- this line sets dayofyear correctly
    daily_data['daily_precipitation'] = data['precipitation'].resample('D').sum()
    daily_data['cumulative_rainfall'] = daily_data['daily_precipitation'].cumsum()
    return daily_data

def smooth_data(daily_data, window=30):
    smoothed_data = daily_data.copy()
    for column in ['temperature', 'relativehumidity', 'windspeed', 'solar radiation']:
        smoothed_data[column] = daily_data[column].rolling(window=window, center=True).mean()
    return smoothed_data

def reset_annual_cumulative_rainfall(daily_data):
    daily_data['cumulative_rainfall'] = daily_data.groupby(daily_data.index.year)['daily_precipitation'].cumsum()
    return daily_data

def fit_fourier(t, y, n_freqs):
    def model(t, *params):
        a0 = params[0]
        terms = [a0]
        for i in range(1, n_freqs * 2 + 1, 2):
            a = params[i]
            b = params[i+1]
            terms.append(a * np.cos(2 * np.pi * (i // 2 + 1) * t / len(t)))
            terms.append(b * np.sin(2 * np.pi * (i // 2 + 1) * t / len(t)))
        return np.sum(terms, axis=0)

    p0 = [np.mean(y)]
    for _ in range(n_freqs):
        p0 += [0, 0]
    return curve_fit(model, t, y, p0=p0)[0]

def smooth_with_fourier(t, y, params, N=5, extend_by=5):
    def extrapolate_end(data, N=5, extend_by=10):
        x = np.arange(len(data) - N, len(data))
        y_last = data[-N:]
        slope, intercept = np.polyfit(x, y_last, 1)  # Linear fit to get slope and intercept
        new_x = np.arange(len(data), len(data) + extend_by)
        new_y = slope * new_x + intercept
        return np.concatenate([data, new_y])

    y_extended = extrapolate_end(y, N, extend_by)
    t_extended = np.arange(len(y_extended))
    
    def model(t, data_length):
        a0 = params[0]
        terms = [a0]
        for i in range(1, len(params), 2):
            a = params[i]
            b = params[i+1]
            terms.append(a * np.cos(2 * np.pi * (i // 2 + 1) * t / data_length))
            terms.append(b * np.sin(2 * np.pi * (i // 2 + 1) * t / data_length))
        return np.sum(terms, axis=0)

    smoothed = model(t_extended, len(t_extended))
    return smoothed[:len(t)]

# Adjustments in the plotting function for better differentiation between smoothed and raw data
def plot_data(data, daily_data, smoothed_data, gpp_daily_avg):
    plt.figure(figsize=(15, 25))

    # Temperature
    plt.subplot(7, 1, 1)
    plt.plot(data.index, data['temperature'], label='Hourly Temperature', color='grey', alpha=0.5)
    plt.plot(daily_data.index, daily_data['temperature'], label='Daily Temperature', color='red', alpha=0.5)
    plt.plot(smoothed_data.index, smoothed_data['temperature'], label='Smoothed Daily Temperature', color='red')
    plt.title('Temperature over Time (K)')
    plt.legend()

    # Relative Humidity
    plt.subplot(7, 1, 2)
    plt.plot(data.index, data['relativehumidity'], label='Hourly Relative Humidity', color='grey', alpha=0.5)
    plt.plot(daily_data.index, daily_data['relativehumidity'], label='Daily Relative Humidity', color='blue', alpha=0.5)
    plt.plot(smoothed_data.index, smoothed_data['relativehumidity'], label='Smoothed Daily Relative Humidity', color='blue')
    plt.title('Relative Humidity over Time (%)')
    plt.legend()

    # Wind Speed
    plt.subplot(7, 1, 3)
    plt.plot(data.index, data['windspeed'], label='Hourly Wind Speed', color='grey', alpha=0.5)
    plt.plot(daily_data.index, daily_data['windspeed'], label='Daily Wind Speed', color='green', alpha=0.5)
    plt.plot(smoothed_data.index, smoothed_data['windspeed'], label='Smoothed Daily Wind Speed', color='green')
    plt.title('Wind Speed over Time (m/s)')
    plt.legend()

    # Precipitation
    plt.subplot(7, 1, 4)
    plt.plot(data.index, data['precipitation'], label='Hourly Precipitation', color='grey', alpha=0.5)
    plt.plot(daily_data.index, daily_data['daily_precipitation'], label='Daily Precipitation', color='purple')
    plt.title('Precipitation over Time (mm)')
    plt.legend()

    # Cumulative Rainfall
    plt.subplot(7, 1, 5)
    plt.plot(daily_data.index, daily_data['cumulative_rainfall'], label='Cumulative Rainfall', color='blue')
    plt.title('Cumulative Rainfall over Time (mm)')
    plt.legend()

    # Solar Radiation
    plt.subplot(7, 1, 6)
    plt.plot(data.index, data['solar radiation'], label='Hourly Solar Radiation', color='grey', alpha=0.5)
    plt.plot(daily_data.index, daily_data['solar radiation'], label='Daily Solar Radiation', color='orange', alpha=0.5)
    plt.plot(smoothed_data.index, smoothed_data['solar radiation'], label='Smoothed Daily Solar Radiation', color='orange')
    plt.title('Solar Radiation over Time (W/m^2)')
    plt.legend()
    
    plt.subplot(7, 1, 7)  # Updated to subplot 7 to account for the new plot
    filtered_gpp = gpp_daily_avg[(gpp_daily_avg.index.year >= 2011) & (gpp_daily_avg.index.year <= 2018)]
    plt.plot(filtered_gpp.index, filtered_gpp['gpp_mean'], 'k-', label='Observed GPP 2011-2018')
    plt.title('Observed GPP Daily Avg (2011-2018)')
    plt.xlabel('Date')
    plt.ylabel('GPP Daily Average')
    plt.legend()



    plt.tight_layout()
    plt.show()




def create_rolling_sequences(data, window_size=365):
    sequences = []
    for i in range(len(data) - window_size):
        sequence = data.iloc[i:i+window_size]
        sequences.append(sequence)
    return sequences

def extract_input_features(sequences):
    input_features = ['temperature', 'solar radiation', 'gpp_mean']
    input_data = [seq[input_features].values for seq in sequences]
    return np.array(input_data)





def extract_output_features(data, start_index, window_size):
    # The target value for a given sequence starting at start_index is the 'gpp_mean' value window_size days later
    return data['gpp_mean'].iloc[start_index + window_size]

def create_output_data(data, window_size=365):
    output_data = []
    for i in range(len(data) - window_size):
        output_data.append(extract_output_features(data, i, window_size))
    return np.array(output_data).reshape(-1, 1, 1)






def plot_input_and_output(input_data, output_data):
    plt.figure(figsize=(15, 15))

    # Extracting the first sequence for each variable from input_data
    temperature = input_data[0, :, 0]
    solar_radiation = input_data[0, :, 1]
    gpp_mean = input_data[0, :, 2]
    gpp_output = output_data[0, 0, 0]  # extracting the output point for GPP mean

    # Temperature
    plt.subplot(3, 1, 1)
    plt.plot(temperature, color='red', label='Temperature Sequence')
    plt.title('First Temperature Sequence (Scaled between 0 and 1)')
    plt.ylabel('Temperature')
    plt.legend()

    # Solar Radiation
    plt.subplot(3, 1, 2)
    plt.plot(solar_radiation, color='orange', label='Solar Radiation Sequence')
    plt.title('First Solar Radiation Sequence (Scaled between 0 and 1)')
    plt.ylabel('Solar Radiation')
    plt.legend()

    # GPP Mean
    plt.subplot(3, 1, 3)
    plt.plot(gpp_mean, color='green', label='GPP Mean Sequence')
    plt.scatter(len(gpp_mean), gpp_output, color='blue', marker='x', label='Output (Next Day GPP Mean)')  # plot the output point
    plt.title('First GPP Mean Sequence with Output (Scaled between 0 and 1)')
    plt.ylabel('GPP Mean')
    plt.xlabel('Days in Sequence')
    plt.legend()

    plt.tight_layout()
    plt.show()















# Existing code
start_year = 2011
end_year = 2018
data = read_weather_data(start_year, end_year)
daily_data = resample_data(data)


# Modifications
gpp_daily_avg = read_gpp_from_netcdf('C:\\Users\\asbre\\OneDrive\\Desktop\\ECOSYS_project\\Raw_Observations\\Atmospheric_Observations\\US-Tw1\\AMF_US-Tw1_FLUXNET_FULLSET_HH_2011-2020_3-5.nc')
gpp_daily_avg = gpp_daily_avg.reindex(daily_data.index)
gpp_daily_avg['gpp_mean'].fillna(method='ffill', inplace=True)
daily_data = pd.merge(daily_data, gpp_daily_avg, left_index=True, right_index=True, how='left')

# Assuming you've already read and prepared your daily_data DataFrame

# Initialize the MinMaxScaler
scalers = {}

for col in ['temperature', 'relativehumidity', 'windspeed', 'solar radiation', 'gpp_mean']:
    t = np.arange(len(daily_data))
    y = daily_data[col].values
    params = fit_fourier(t, y, n_freqs=20)
    smoothed_data = smooth_with_fourier(t, y, params)
    
    # Scale the smoothed data
    scaler = MinMaxScaler(feature_range=(0, 1))
    smoothed_data_scaled = scaler.fit_transform(smoothed_data.reshape(-1, 1)).flatten()
    
    # Store the scaler for potential inverse transformations later on
    scalers[col] = scaler
    
    daily_data[col] = smoothed_data_scaled

# Continue with your existing code
sequences = create_rolling_sequences(daily_data)
input_data = extract_input_features(sequences)
print(input_data.shape)

output_data = create_output_data(daily_data)
print(output_data.shape)  # This should print (2558, 1, 1)

smoothed_data = smooth_data(daily_data)
reset_daily_data = reset_annual_cumulative_rainfall(daily_data)
plot_data(data, reset_daily_data, daily_data, gpp_daily_avg)
plot_input_and_output(input_data, output_data)




