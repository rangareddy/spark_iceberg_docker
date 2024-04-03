#!/bin/bash

export SPARK_MASTER_HOSTNAME=$(hostname)
export SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077}
export SPARK_EVENTS_LOG_DIR=${SPARK_EVENTS_LOG_DIR:-/tmp/spark-events}
mkdir -p $SPARK_EVENTS_LOG_DIR

echo "Starting the Spark Master in ${SPARK_MASTER_HOSTNAME} with port ${SPARK_MASTER_PORT}"
$SPARK_HOME/sbin/start-master.sh -h ${SPARK_MASTER_HOSTNAME} -p ${SPARK_MASTER_PORT}
$SPARK_HOME/sbin/start-worker.sh spark://${SPARK_MASTER_HOSTNAME}:${SPARK_MASTER_PORT}

echo "Starting the Spark History Server"
$SPARK_HOME/sbin/start-history-server.sh
sleep 5

#echo "Starting the Spark Thrift Server"
#$SPARK_HOME//sbin/start-thriftserver.sh  --driver-java-options "-Dderby.system.home=/tmp/derby"
