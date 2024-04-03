#!/bin/bash
set -x

# Set default values 
export SPARK_HOME=${SPARK_HOME:-"/opt/spark"}

SOFTWARE="spark"
SPARK_3_3=3.3.0
SOFTWARE_LOCATION=${SOFTWARE_LOCATION:-"/opt/software"}
SPARK_VERSION=${SPARK_VERSION:-"3.5.0"}
SPARK_CONF=${SPARK_CONF:-"/etc/spark/conf"}
SPARK_EVENTS_LOG_DIR=${SPARK_EVENTS_LOG_DIR:-/home/iceberg/spark-events}

# Create directories 
mkdir -p "${SPARK_HOME}" "${SPARK_CONF}" "${SOFTWARE_LOCATION}" "${SPARK_EVENTS_LOG_DIR}"

# Determine Hadoop minimum version based on Spark version
IFS=. v1_array=($SPARK_3_3) v2_array=($SPARK_VERSION)
v1=$((v1_array[0] * 100 + v1_array[1] * 10 + v1_array[2]))
v2=$((v2_array[0] * 100 + v2_array[1] * 10 + v2_array[2]))
ver_diff=$((v2 - v1))
if [[ $ver_diff -ge 0 ]] && [[ $SPARK_VERSION == [3-9].[3-9]* ]]; then
    HADOOP_MIN_VERSION="3"
elif [[ $SPARK_VERSION == 3.[0-2]* ]]; then
    HADOOP_MIN_VERSION="3.2"
else
    HADOOP_MIN_VERSION="2.7"
fi

# Define download details 
SPARK_TAR_FILE="${SOFTWARE}-${SPARK_VERSION}-bin-hadoop${HADOOP_MIN_VERSION}.tgz"
SPARK_TAR_PATH="${SOFTWARE_LOCATION}/${SPARK_TAR_FILE}"

# Download Spark if not already present 
if [ ! -f "${SPARK_TAR_PATH}" ]; then
    DOWNLOAD_URLS=(
        "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_TAR_FILE}"
        "https://www.apache.org/dyn/closer.lua/spark/spark-${SPARK_VERSION}/${SPARK_TAR_FILE}"
    )

    for DOWNLOAD_URL in "${DOWNLOAD_URLS[@]}"; do
        echo "Downloading Spark from <${DOWNLOAD_URL}>"
        wget -t 10 --show-progress --tries=3 --max-redirect 1 --retry-connrefused -O "${SPARK_TAR_FILE}" "${DOWNLOAD_URL}" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            mv "${SPARK_TAR_FILE}" "${SOFTWARE_LOCATION}"
            break;
        fi
    done
fi

if [ ! -f "$SPARK_TAR_PATH" ]; then
  echo "Spark $SPARK_TAR_PATH file is not available to extract. Please check the logs and re-download the $SPARK_TAR_PATH file."
  exit 1
fi

# Extract Spark archive
tar --extract --file "$SPARK_TAR_PATH" --directory "${SPARK_HOME}" --strip-components 1
if [ $? -ne 0 ]; then
    echo "$SOFTWARE_TGZ not extracted properly"
    exit 1
fi

# Set ownership and symbolic links
chown -R 755 ${SPARK_HOME}
ln -sf $SPARK_HOME/conf/* ${SPARK_CONF}

echo "Successfully installed ${SOFTWARE^}"

# Find PY4J source zip
PY4J_FILE_PATH=$(ls $SPARK_HOME/python/lib/py4j-*-src.zip | head -1)

# Update Python path
export PYTHONPATH=${SPARK_HOME}/python:${PY4J_FILE_PATH}-src.zip:$PYTHONPATH

# Define Iceberg Spark Runtime details
MAVEN_ICEBERG_REPO='https://repo1.maven.org/maven2/org/apache/iceberg'
ICEBERG_SPARK_RUNTIME="iceberg-spark-runtime-${SPARK_MAJOR_VERSION}_2.12"
ICEBERG_SPARK_RUNTIME_JAR="${ICEBERG_SPARK_RUNTIME}-${ICEBERG_VERSION}.jar"

# Download Iceberg Spark Runtime jar
echo "Downloading Iceberg Spark Runtime jar: ${ICEBERG_SPARK_RUNTIME_JAR}"
curl -s ${MAVEN_ICEBERG_REPO}/${ICEBERG_SPARK_RUNTIME}/${ICEBERG_VERSION}/${ICEBERG_SPARK_RUNTIME_JAR} \
    -Lo ${SPARK_HOME}/jars/${ICEBERG_SPARK_RUNTIME_JAR}

# Download and install AWS S3 dependencies
if [[ "$AWS_S3_ENABLE" == "true" ]]; then
    echo "AWS S3 is enabled, downloading and installing AWS bundle..."

    # Download Iceberg AWS bundle jar
    curl -sL ${MAVEN_ICEBERG_REPO}/iceberg-aws-bundle/${ICEBERG_VERSION}/iceberg-aws-bundle-${ICEBERG_VERSION}.jar \
        -Lo ${SPARK_HOME}/jars/iceberg-aws-bundle-${ICEBERG_VERSION}.jar

    # Install AWS CLI
    if [ -f "$SOFTWARE_LOCATION/awscliv2.zip" ]; then
        cp "$SOFTWARE_LOCATION/awscliv2.zip" /tmp
    else 
        curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    fi 
    unzip /tmp/awscliv2.zip &&
    sudo ./aws/install &&
    rm /tmp/awscliv2.zip &&
    rm -rf aws/
fi

export IJAVA_CLASSPATH=${SPARK_HOME}/jars/*

#COPY download_taxi_data.sh /opt
chmod u+x /opt/download_taxi_data.sh
