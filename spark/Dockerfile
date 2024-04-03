FROM python:3.9-bullseye

ENV DEBIAN_FRONTEND noninteractive

ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV SPARK_VERSION=${SPARK_VERSION:-3.5.1}
ENV SPARK_MAJOR_VERSION=${SPARK_MAJOR_VERSION:-3.5}
ENV ICEBERG_VERSION=${ICEBERG_VERSION:-1.5.0}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.9}
ENV AWS_S3_ENABLE=${AWS_S3_ENABLE:-"true"}
ENV WAREHOUSE_DIR=${WAREHOUSE_DIR:-"/home/iceberg/warehouse"}
ENV LOCAL_WAREHOUSE_DIR=${LOCAL_WAREHOUSE_DIR:-"/home/iceberg/localwarehouse"}
ENV NOTEBOOKS_DIR=${NOTEBOOKS_DIR:-"/home/iceberg/notebooks"}
ENV SOFTWARE_LOCATION=${SOFTWARE_LOCATION:-"/opt/software"}
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
RUN mkdir -p $WAREHOUSE_DIR $LOCAL_WAREHOUSE_DIR $NOTEBOOKS_DIR $SOFTWARE_LOCATION

# Copy the data to /opt directory
ADD conf /opt
ADD scripts /opt
ADD entrypoint.sh /opt
ADD software ${SOFTWARE_LOCATION}
RUN chmod 755 /opt/*

# Install Ubuntu dependencies
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    netcat sudo curl vim \
    unzip locales \
    openjdk-11-jdk \
    build-essential \
    software-properties-common \
    ssh && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'
ENV PYTHONIOENCODING=utf-8

# Install python and its dependencies
RUN bash /opt/install_python.sh

# Install Spark
RUN bash /opt/install_spark.sh
ENV PATH="${SPARK_HOME}/sbin:${SPARK_HOME}/bin:${PATH}"

# Setup a notebook
RUN bash /opt/setup_notebook.sh
RUN rm -rf ${SOFTWARE_LOCATION}
ENTRYPOINT ["/opt/entrypoint.sh"]
