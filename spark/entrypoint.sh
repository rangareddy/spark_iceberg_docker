#!/bin/bash

# Start Spark
echo "Starting the Spark"
bash /opt/start_spark.sh

# Start Notebook
echo "Starting the Notebook"
nohup notebook --no-browser --allow-root 2>&1 &

export IS_DOWNLOAD_TAXI_DATA=${IS_DOWNLOAD_TAXI_DATA:-"true"}
if [[ "${IS_DOWNLOAD_TAXI_DATA}" == "true" ]]; then
    echo "Downloading the taxi data"
    bash /opt/download_taxi_data.sh
fi

while true; do sleep 1000; done
