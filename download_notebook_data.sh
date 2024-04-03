#!/bin/bash
set -x

NOTEBOOKS=( "Iceberg%20-%20An%20Introduction%20to%20the%20Iceberg%20Java%20API.ipynb" 
"Iceberg%20-%20Berlin%20Buzzwords%202023.ipynb" "Iceberg%20-%20Getting%20Started.ipynb" 
"Iceberg%20-%20Integrated%20Audits%20Demo.ipynb" 
"Iceberg%20-%20Table%20Maintenance%20Spark%20Procedures.ipynb" 
"Iceberg%20-%20View%20Support.ipynb" 
"Iceberg%20-%20Write-Audit-Publish%20(WAP)%20with%20Branches.ipynb" 
"PyIceberg%20-%20Getting%20Started.ipynb" 
"PyIceberg%20-%20Write%20support.ipynb" )

NOTEBOOK_DOWNLOAD_URL="https://raw.githubusercontent.com/tabular-io/docker-spark-iceberg/main/spark/notebooks/"

for notebook_url in ${NOTEBOOKS[@]}; do
  wget ${NOTEBOOK_DOWNLOAD_URL}/${notebook_url}
done