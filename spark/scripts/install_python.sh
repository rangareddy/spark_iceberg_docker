#!/bin/bash

# Check for Python 3 (combined if/else)
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python3 is not installed."
  exit 1
fi

if ! command -v python >/dev/null 2>&1; then
  echo "Creating python symbolic link"
  sudo ln -sf $(which python3) /usr/bin/python
fi

if ! command -v pip >/dev/null 2>&1; then
  echo "Creating pip symbolic link"
  sudo ln -sf $(which pip3) /usr/bin/pip
fi

if ! command -v python >/dev/null 2>&1; then
  echo "Python is not installed. Please check the installation"
  exit 1
fi

# Upgrade pip (combined if/else) and Install required dependencies
python -m pip install --upgrade pip
pip install -r /opt/requirements.txt

# Add scala kernel via spylon-kernel
echo "Installing Scala Kernel"
python -m spylon_kernel install

# Ijava tool is used for executing Java code in Jupyter kernal.
# Download and install IJava jupyter kernel
if [ -f "$SOFTWARE_LOCATION/ijava-1.3.0.zip" ]; then
    cp "$SOFTWARE_LOCATION/ijava-1.3.0.zip" /tmp
else 
    curl -sL "https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip" -o "/tmp/ijava-1.3.0.zip"
fi 

unzip /tmp/ijava-1.3.0.zip &&
python install.py --sys-prefix &&
rm /tmp/ijava-1.3.0.zip

echo "Listing the KernelSpec"
jupyter kernelspec list
