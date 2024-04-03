#!/bin/bash


export TAXI_DATA_DIR=${TAXI_DATA_DIR:-"/home/iceberg/data"}
export TRIP_DATA_URL="https://d37ci6vzurychx.cloudfront.net/trip-data"

echo "Downloading the Taxi Trip Data to ${TAXI_DATA_DIR} for the years 2021-2022"

mkdir -p ${TAXI_DATA_DIR}
curl https://data.cityofnewyork.us/resource/tg4x-b46p.json > ${TAXI_DATA_DIR}/nyc_film_permits.json

for year in {2021..2022}; do
  for month in {01..12}; do
    curl ${TRIP_DATA_URL}/yellow_tripdata_${year}-${month}.parquet \
         -o ${TAXI_DATA_DIR}/yellow_tripdata_${year}-${month}.parquet
  done
done

echo "Taxi Trip Data is downloaded to <${TAXI_DATA_DIR}>"