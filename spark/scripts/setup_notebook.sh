#!/bin/bash

echo "Setup a notebook"

# Add a notebook command
echo '#! /bin/sh' >>/bin/notebook &&
    echo 'export PYSPARK_DRIVER_PYTHON=jupyter-notebook' >>/bin/notebook &&
    echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"--notebook-dir=$NOTEBOOKS_DIR  --ip='*' --NotebookApp.token='' --NotebookApp.password='' --port=8888 --no-browser --allow-root\"" >>/bin/notebook &&
    echo "pyspark" >>/bin/notebook &&
    chmod u+x /bin/notebook

mv /opt/.pyiceberg.yaml /root/.pyiceberg.yaml
