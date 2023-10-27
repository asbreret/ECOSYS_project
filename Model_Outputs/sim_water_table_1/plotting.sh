#!/bin/bash

BASE_PATH="/global/home/users/ashbre/Wetland_simulations/AB_LIB"

echo "Plotting script for wetland simulations..."

python "$BASE_PATH/plot_water_plant.py" 30
python "$BASE_PATH/plot_water.py" 30
python "$BASE_PATH/plot_carbon.py" 30

echo "Plotting completed!"

