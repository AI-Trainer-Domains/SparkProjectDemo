#!/bin/bash

# Start SSH
#service ssh start

# Install apache spark
sudo yum update -y &&
sudo yum install -y make
#make install-spark &&
#make install-python3 &&
#make start-namenode

# Start Hadoop NameNode
#$HADOOP_HOME/sbin/hadoop-daemon.sh start --config $HADOOP_CONF_DIR --script hdfs start namenode
