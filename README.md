To refactor the `hadoop.md` file by condensing it and providing tables and formatted explanations based on the `hadoop.html` and `timeline.html` documentation, here’s an approach that can be taken:

### 1. **Combine Sections with Overlapping Content**
   - **Purpose & Overview**: Combine the purpose of setting up a Hadoop cluster with an overview of the YARN Timeline Server, highlighting the key points of each system.
   - **Prerequisites**: List all prerequisites (e.g., Java installation, downloading Hadoop) in a table format for clarity.
   - **Installation & Deployment**: Merge these sections to streamline the installation and deployment process.

### 2. **Use Tables for Configurations**
   - **Configurations**: Create tables for different configuration parameters, such as Hadoop Daemons, YARN, and Timeline Server configurations.
   - **Environment Variables**: Consolidate all environment variables into a single table with columns for Daemon, Environment Variable, and Description.
   - **Web Interfaces**: Provide a table with columns for Daemon, Web Interface, and Default Port.

### 3. **Summarize Key Information**
   - **Operating the Cluster**: Provide a bullet-point summary of steps to start and stop the Hadoop cluster, focusing on critical commands.
   - **Health Monitoring & Logging**: Summarize the key aspects of monitoring NodeManager health and configuring logging in concise bullet points.

### 4. **Use Formatting for Emphasis**
   - Use **bold** and *italic* formatting to emphasize important notes or cautions.
   - Include code blocks for commands and configuration examples.

### 5. **Provide Visual Structure**
   - Utilize headers (`h2`, `h3`, etc.) to organize the content, making it easy to navigate.
   - Include diagrams or flowcharts if possible to represent processes like the Timeline Server structure.

### Sample Refactored Sections:


# Hadoop Cluster and YARN Timeline Server Setup

## Purpose & Overview

This document guides you through setting up a Hadoop cluster, including configuring YARN's Timeline Server for tracking application history.

### Prerequisites

| Requirement           | Description                                    | Link                                                                                            |
|-----------------------|------------------------------------------------|-------------------------------------------------------------------------------------------------|
| **Java Installation** | Install a compatible Java version.             | [Hadoop Java Versions](https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions) |
| **Hadoop Download**   | Download a stable version from Apache mirrors. | [Apache Hadoop](https://hadoop.apache.org/releases.html)                                        |

## Installation & Deployment

### Hadoop Installation

Unpack the Hadoop software on all cluster machines. Assign roles to each machine:
- **NameNode**: Master for HDFS.
- **ResourceManager**: Master for YARN.
- **DataNodes/NodeManagers**: Workers for HDFS and YARN.

### YARN Timeline Server Deployment

Configure the Timeline Server by setting properties in `yarn-site.xml`:

| Configuration Property                | Description                        | Default Value                                                 |
|---------------------------------------|------------------------------------|---------------------------------------------------------------|
| **yarn.timeline-service.enabled**     | Enables the Timeline service.      | `false`                                                       |
| **yarn.timeline-service.store-class** | Store class for timeline storage.  | `org.apache.hadoop.yarn.server.timeline.LeveldbTimelineStore` |
| **yarn.timeline-service.hostname**    | Hostname for the Timeline service. | `0.0.0.0`                                                     |

## Configurations

### Hadoop Daemons

| Daemon          | Environment Variable        | Description                       |
|-----------------|-----------------------------|-----------------------------------|
| **NameNode**    | `HDFS_NAMENODE_OPTS`        | Options for configuring NameNode. |
| **DataNode**    | `HDFS_DATANODE_OPTS`        | Options for configuring DataNode. |
| **YARN**        | `YARN_RESOURCEMANAGER_OPTS` | Options for ResourceManager.      |
| **NodeManager** | `YARN_NODEMANAGER_OPTS`     | Options for NodeManager.          |

### Web Interfaces

| Daemon                | Web Interface                                  | Default Port |
|-----------------------|------------------------------------------------|--------------|
| **NameNode**          | [NameNode Web UI](http://nn_host:9870/)        | 9870         |
| **ResourceManager**   | [ResourceManager Web UI](http://rm_host:8088/) | 8088         |
| **JobHistory Server** | [JobHistory Web UI](http://jhs_host:19888/)    | 19888        |

## Operating the Cluster

### Startup

1. **Format HDFS** (First-time only):  
   ```shell
   $ hdfs namenode -format
   ```
2. **Start HDFS**:
   ```shell
   $ start-dfs.sh
   ```
3. **Start YARN**:
   ```shell
   $ start-yarn.sh
   ```

### Shutdown

1. **Stop YARN**:
   ```shell
   $ stop-yarn.sh
   ```
2. **Stop HDFS**:
   ```shell
   $ stop-dfs.sh
   ```

## Monitoring and Logging

- **NodeManager Health**: Configure scripts in `yarn-site.xml` to monitor node health.
- **Logging**: Edit `log4j.properties` in the `etc/hadoop` directory to customize logging.

---

This is a condensed and organized version of the documentation, providing a 
clear, concise, and easy-to-follow guide for setting up and maintaining a 
Hadoop cluster and YARN Timeline Server.

[See here for more details:](https://hadoop.apache.org/docs/r3.3.1/ "Hadoop Documentation")

