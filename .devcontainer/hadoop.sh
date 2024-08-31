#!/bin/bash

# Install the required dependencies
curl -fsSL 'https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0.tar.gz' \
-o /tmp/hadoop-3.4.0.tar.gz
curl -fsSL 'https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0.tar.gz.asc' \
-o /tmp/hadoop-3.4.0.tar.gz.asc
curl -fsSL 'https://dlcdn.apache.org/hadoop/common/stable/hadoop-3.4.0.tar.gz.sha512' \
-o /tmp/hadoop-3.4.0.tar.gz.sha512
curl -fsSL 'https://downloads.apache.org/hadoop/common/KEYS' \
-o /tmp/KEYS

# Verify the signature
gpg --import /tmp/KEYS
gpg --verify /tmp/hadoop-3.4.0.tar.gz.asc /tmp/hadoop-3.4.0.tar.gz

# Verify the checksum
sha512sum -c /tmp/hadoop-3.4.0.tar.gz.sha512

# Extract the archive
tar -xzf /tmp/hadoop-3.4.0.tar.gz -C /usr/local/
mv /usr/local/hadoop-3.4.0 /usr/local/hadoop

# Cleanup
rm -rf /tmp/hadoop-3.4.0.tar.gz /tmp/hadoop-3.4.0.tar.gz.asc /tmp/hadoop-3.4.0.tar.gz.sha512 /tmp/KEYS

# export HADOOP_HOME=/usr/local/hadoop
#export HADOOP_MAPRED_HOME=$HADOOP_HOME
#export HADOOP_COMMON_HOME=$HADOOP_HOME
#export HADOOP_HDFS_HOME=$HADOOP_HOME
#export YARN_HOME=$HADOOP_HOME
#export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
#export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
#export HADOOP_INSTALL=$HADOOP_HOME
# Add Hadoop to the PATH
echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export YARN_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc
echo 'export HADOOP_INSTALL=$HADOOP_HOME' >> ~/.bashrc

# Add Hadoop to the environment
echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.profile
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.profile
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.profile
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.profile
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.profile
echo 'export YARN_HOME=$HADOOP_HOME' >> ~/.profile
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.profile
echo 'export HADOOP_INSTALL=$HADOOP_HOME' >> ~/.profile

# Activate the changes
source ~/.bashrc
source ~/.profile

# Create the Hadoop directories for the NameNode, DataNode,
# NodeManager, timelineserver, proxyserver and ResourceManager
mkdir -p /usr/local/hadoop_store/hdfs/namenode
mkdir -p /usr/local/hadoop_store/hdfs/datanode
mkdir -p /usr/local/hadoop_store/yarn/nodemanager
mkdir -p /usr/local/hadoop_store/yarn/resourcemanager
mkdir -p /usr/local/hadoop_store/yarn/timelineserver
mkdir -p /usr/local/hadoop_store/yarn/proxyserver


