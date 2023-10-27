#!/bin/bash

BASE_PATH="/global/home/users/ashbre/Wetland_simulations/AB_LIB"

echo "Processing script for wetland simulations..."

bash "$BASE_PATH/process.sh"
bash "$BASE_PATH/soil_W_daily_att.sh"
bash "$BASE_PATH/soil_C_daily_att.sh"
bash "$BASE_PATH/plant_C_daily_att.sh"
bash "$BASE_PATH/plant_W_daily_att.sh"

echo "Processing completed!"

