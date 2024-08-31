# Hadoop Cluster and Secure Mode Setup

## Table of Contents

- [Introduction](#introduction)
- [Authentication](#authentication)
  - [End User Accounts](#end-user-accounts)
  - [User Accounts for Hadoop Daemons](#user-accounts-for-hadoop-daemons)
  - [Kerberos Principals for Hadoop Daemons](#kerberos-principals-for-hadoop-daemons)
    - [HDFS](#hdfs)
    - [YARN](#yarn)
    - [MapReduce JobHistory Server](#mapreduce-jobhistory-server)
  - [Mapping from Kerberos Principals to OS User Accounts](#mapping-from-kerberos-principals-to-os-user-accounts)
  - [Mapping from User to Group](#mapping-from-user-to-group)
  - [Proxy User](#proxy-user)
  - [Secure DataNode](#secure-datanode)
- [Data Confidentiality](#data-confidentiality)
  - [Data Encryption on RPC](#data-encryption-on-rpc)
  - [Data Encryption on Block Data Transfer](#data-encryption-on-block-data-transfer)
  - [Data Encryption on HTTP](#data-encryption-on-http)
- [Configuration](#configuration)
  - [Permissions for HDFS and Local FileSystem Paths](#permissions-for-hdfs-and-local-filesystem-paths)
  - [Common Configurations](#common-configurations)
  - [NameNode](#namenode)
  - [Secondary NameNode](#secondary-namenode)
  - [JournalNode](#journalnode)
  - [DataNode](#datanode)
  - [WebHDFS](#webhdfs)
  - [ResourceManager](#resourcemanager)
  - [NodeManager](#nodemanager)
  - [Configuration for WebAppProxy](#configuration-for-webappproxy)
  - [LinuxContainerExecutor](#linuxcontainerexecutor)
  - [MapReduce JobHistory Server](#mapreduce-jobhistory-server)
- [Multihoming](#multihoming)
- [Troubleshooting](#troubleshooting)
- [Troubleshooting with KDiag](#troubleshooting-with-kdiag)
- [Configuration Properties](#configuration-properties)
- [Python Example for Connecting via PySpark](#python-example-for-connecting-via-pyspark)
- [Connecting to a Hadoop Cluster from PySpark: Complete Setup and Test Workflow](#connecting-to-a-hadoop-cluster-from-pyspark-complete-setup-and-test-workflow)

---

## Introduction

In its default configuration, ensure that attackers don’t have access to your Hadoop cluster by restricting all network access. If you need restrictions on who can remotely access data or submit work, secure authentication and access for your Hadoop cluster as described in this document.

When Hadoop runs in secure mode, each Hadoop service and user must be authenticated by Kerberos. Forward and reverse host lookups for all service hosts must be configured correctly to allow services to authenticate with each other. Host lookups can be configured using DNS or `/etc/hosts` files. Knowledge of Kerberos and DNS is recommended before configuring Hadoop services in Secure Mode.

Security features of Hadoop include [Authentication](#authentication), [Service Level Authorization](#service-level-authorization), [Authentication for Web Consoles](#authentication-for-web-consoles), and [Data Confidentiality](#data-confidentiality).

---

## Authentication

### End User Accounts

When service-level authentication is enabled, end users must authenticate before interacting with Hadoop services. The simplest way is for a user to authenticate interactively using the Kerberos `kinit` command. Programmatic authentication using Kerberos keytab files may be used when interactive login with `kinit` is infeasible.

### User Accounts for Hadoop Daemons

Ensure that HDFS and YARN daemons run as different Unix users, e.g., `hdfs` and `yarn`. The MapReduce JobHistory server should run as a different user, such as `mapred`. It’s recommended to have them share a Unix group, e.g., `hadoop`.

#### Daemon Users and Groups Table

| User:Group    | Daemons                                             |
|---------------|-----------------------------------------------------|
| hdfs:hadoop   | NameNode, Secondary NameNode, JournalNode, DataNode |
| yarn:hadoop   | ResourceManager, NodeManager                        |
| mapred:hadoop | MapReduce JobHistory Server                         |

### Kerberos Principals for Hadoop Daemons

Each Hadoop service instance must be configured with its Kerberos principal and keytab file location.

The general format of a service principal is `ServiceName/_HOST@REALM.TLD`, e.g., `dn/_HOST@EXAMPLE.COM`.

#### HDFS

**NameNode Keytab Example:**

```bash
$ klist -e -k -t /etc/security/keytab/nn.service.keytab
Keytab name: FILE:/etc/security/keytab/nn.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 nn/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

#### YARN

**ResourceManager Keytab Example:**

```bash
$ klist -e -k -t /etc/security/keytab/rm.service.keytab
Keytab name: FILE:/etc/security/keytab/rm.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 rm/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

#### MapReduce JobHistory Server

**MapReduce JobHistory Server Keytab Example:**

```bash
$ klist -e -k -t /etc/security/keytab/jhs.service.keytab
Keytab name: FILE:/etc/security/keytab/jhs.service.keytab
KVNO Timestamp         Principal
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 jhs/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (AES-128 CTS mode with 96-bit SHA-1 HMAC)
   4 07/18/11 21:08:09 host/full.qualified.domain.name@REALM.TLD (ArcFour with HMAC/md5)
```

### Mapping from Kerberos Principals to OS User Accounts

Hadoop maps Kerberos principals to OS user (system) accounts using rules specified by `hadoop.security.auth_to_local`.

**Example Rule:**

```xml
<property>
  <name>hadoop.security.auth_to_local</name>
  <value>
    RULE:[2:$1/$2@$0]([ndj]n/.*@REALM.\TLD)s/.*/hdfs/
    RULE:[2:$1/$2@$0]([rn]m/.*@REALM\.TLD)s/.*/yarn/
    RULE:[2:$1/$2@$0](jhs/.*@REALM\.TLD)s/.*/mapred/
    DEFAULT
  </value>
</property>
```

This rule maps principals to the appropriate local system accounts based on their type.

### Mapping from User to Group

The system user to system group mapping can be configured via `hadoop.security.group.mapping`. For details, refer to the [Hadoop Groups Mapping documentation](#groups-mapping).

### Proxy User

Some products, such as Apache Oozie, need to impersonate end users to access Hadoop services. See the [Proxy User documentation](#proxy-user-doc) for details.

### Secure DataNode

Because the DataNode data transfer protocol does not use the Hadoop RPC framework, DataNodes must authenticate themselves using privileged ports specified by `dfs.datanode.address` and `dfs.datanode.http.address`.

---

## Data Confidentiality

### Data Encryption on RPC

To encrypt data transferred between Hadoop services and clients, set `hadoop.rpc.protection` to `privacy` in `core-site.xml`.

### Data Encryption on Block Data Transfer

Activate data encryption for DataNode by setting `dfs.encrypt.data.transfer` to `true` in `hdfs-site.xml`. Optionally, specify `dfs.encrypt.data.transfer.algorithm` for the encryption algorithm and `dfs.encrypt.data.transfer.cipher.suites` to activate AES encryption.

### Data Encryption on HTTP

Data transfer between Web consoles and clients is protected by SSL (HTTPS). To enable SSL for the web consoles of various Hadoop services, set `dfs.http.policy`, `yarn.http.policy`, or `mapreduce.jobhistory.http.policy` to `HTTPS_ONLY` in their respective configuration files.

---

## Configuration

### Permissions for HDFS and Local FileSystem Paths

Below is a table listing recommended permissions for various paths on HDFS and local filesystems:

| Filesystem | Path                                         | User:Group    | Permissions   |
|------------|----------------------------------------------|---------------|---------------|
| local      | `dfs.namenode.name.dir`                      | hdfs:hadoop   | `drwx------`  |
| local      | `dfs.datanode.data.dir`                      | hdfs:hadoop   | `drwx------`  |
| local      | `$HADOOP_LOG_DIR`                            | hdfs:hadoop   | `drwxrwxr-x`  |
| local      | `$YARN_LOG_DIR`                              | yarn:hadoop   | `drwxrwxr-x`  |
| local      | `yarn.nodemanager.local-dirs`                | yarn:hadoop   | `drwxr-xr-x`  |
| local      | `yarn.nodemanager.log-dirs`                  | yarn:hadoop   | `drwxr-xr-x`  |
| local      | `container-executor`                         | root:hadoop   | `--Sr-s--*`   |
| local      | `conf/container-executor.cfg`                | root:hadoop   | `r-------*`   |
| hdfs       | `/`                                          | hdfs:hadoop   | `drwxr-xr-x`  |
| hdfs       | `/tmp`                                       | hdfs:hadoop   | `drwxrwxrwxt` |
| hdfs       | `/user`                                      | hdfs:hadoop   | `drwxr-xr-x`  |
| hdfs       | `yarn.nodemanager.remote-app-log-dir`        | yarn:hadoop   | `drwxrwxrwxt` |
| hdfs       | `mapreduce.jobhistory.intermediate-done-dir` | mapred:hadoop | `drwxrwxrwxt` |
| hdfs       | `mapreduce.jobhistory.done-dir`              | mapred:hadoop | `drwxr-x---`  |

### Common Configurations

To turn on RPC authentication in Hadoop, set `hadoop.security.authentication` to `kerberos` and configure the necessary security settings.

---

## Configuration Properties

### Hadoop KMS Properties

| Name                                                                 | Value                                      | Description                                                                 |
|----------------------------------------------------------------------|--------------------------------------------|-----------------------------------------------------------------------------|
| `hadoop.kms.authentication.type`                                     | simple                                     | Authentication type for the KMS. Can be either 'simple' (default) or 'kerberos'. |
| `hadoop.kms.authentication.kerberos.keytab`                          | `${user.home}/kms.keytab`                  | Path to the keytab with credentials for the configured Kerberos principal.  |
| `hadoop.kms.authentication.kerberos.principal`                       | `HTTP/localhost`                           | The Kerberos principal to use for the HTTP endpoint. Must start with 'HTTP/'. |
| `hadoop.kms.authentication.kerberos.name.rules`                      | DEFAULT                                    | Rules used to resolve Kerberos principal names.                             |
| `hadoop.kms.authentication.signer.secret.provider`                   | random                                     | Indicates how the secret to sign the authentication cookies will be stored. |
| `hadoop.kms.authentication.signer.secret.provider.zookeeper.path`    | `/hadoop-kms/hadoop-auth-signature-secret` | The Zookeeper ZNode path where the KMS instances will store and retrieve the secret from. |
| `hadoop.kms.authentication.signer.secret.provider.zookeeper.connection.string` | `#HOSTNAME#:#PORT#,...`                    | The Zookeeper connection string, a list of hostnames and port comma separated. |
| `hadoop.kms.authentication.signer.secret.provider.zookeeper.auth.type` | none                                       | The Zookeeper authentication type, 'none' (default) or 'sasl' (Kerberos).   |
| `hadoop.kms.authentication.signer.secret.provider.zookeeper.kerberos.keytab` | `/etc/hadoop/conf/kms.keytab`              | The absolute path for the Kerberos keytab with the credentials to connect to Zookeeper. |
| `hadoop.kms.authentication.signer.secret.provider.zookeeper.kerberos.principal` | `kms/#HOSTNAME#`                           | The Kerberos service principal used to connect to Zookeeper.                |
| `hadoop.kms.audit.logger`                                            | `org.apache.hadoop.crypto.key.kms.server.SimpleKMSAuditLogger` | The audit logger for KMS. Default is the text-format SimpleKMSAuditLogger only. |
| `hadoop.kms.key.authorization.enable`                                | true                                       | Boolean property to Enable/Disable per Key authorization.                   |
| `hadoop.security.kms.encrypted.key.cache.size`                       | 100                                        | The size of the cache. This is the maximum number of EEKs that can be cached under each key name. |
| `hadoop.security.kms.encrypted.key.cache.low.watermark`              | 0.3                                        | A low watermark on the cache. For each key name, if after a get call, the number of cached EEKs are less than (size * low watermark), then the cache under this key name will be filled asynchronously. |
| `hadoop.security.kms.encrypted.key.cache.num.fill.threads`           | 2                                          | The maximum number of asynchronous threads overall, across key names, allowed to fill the queue in a cache. |
| `hadoop.security.kms.encrypted.key.cache.expiry`                     | 43200000                                   | The cache expiry time, in milliseconds. Internally Guava cache is used as the cache implementation. |

### HttpFS Properties

| Name                                                                 | Value                                      | Description                                                                 |
|----------------------------------------------------------------------|--------------------------------------------|-----------------------------------------------------------------------------|
| `httpfs.http.port`                                                   | 14000                                      | The HTTP port for HttpFS REST API.                                          |
| `httpfs.http.hostname`                                               | 0.0.0.0                                    | The bind host for HttpFS REST API.                                          |
| `httpfs.http.administrators`                                         |                                            | ACL for the admins, this configuration is used to control who can access the default servlets for HttpFS server. |
| `httpfs.ssl.enabled`                                                 | false                                      | Whether SSL is enabled. Default is false, i.e. disabled.                    |
| `hadoop.http.idle_timeout.ms`                                        | 60000                                      | Httpfs Server connection timeout in milliseconds.                           |
| `hadoop.http.max.threads`                                            | 1000                                       | The maximum number of threads.                                              |
| `hadoop.http.max.request.header.size`                                | 65536                                      | The maximum HTTP request header size.                                       |
| `hadoop.http.max.response.header.size`                               | 65536                                      | The maximum HTTP response header size.                                      |
| `hadoop.http.temp.dir`                                               | `${hadoop.tmp.dir}/httpfs`                 | HttpFS temp directory.                                                      |
| `httpfs.buffer.size`                                                 | 4096                                       | The buffer size used by a read/write request when streaming data from/to HDFS. |
| `httpfs.services`                                                    | `org.apache.hadoop.lib.service.instrumentation.InstrumentationService, org.apache.hadoop.lib.service.scheduler.SchedulerService, org.apache.hadoop.lib.service.security.GroupsService, org.apache.hadoop.lib.service.hadoop.FileSystemAccessService` | Services used by the httpfs server. |
| `kerberos.realm`                                                     | LOCALHOST                                  | Kerberos realm, used only if Kerberos authentication is used between the clients and httpfs or between HttpFS and HDFS. |
| `httpfs.hostname`                                                    | `${httpfs.http.hostname}`                  | Property used to synthesize the value of the `httpfs.hostname` property.     |
| `httpfs.authentication.signature.secret.file`                        | `${httpfs.config.dir}/httpfs-signature.secret` | The file containing the secret used to sign authentication cookies.         |
| `httpfs.authentication.signature.secret.provider`                    | random                                     | The provider used to store the secret.                                      |
| `httpfs.authentication.signature.secret.provider.zookeeper.path`     | `/hadoop-httpfs/httpfs-auth-signature-secret` | The Zookeeper ZNode path where the HttpFS instances will store and retrieve the secret from. |
| `httpfs.authentication.signature.secret.provider.zookeeper.connection.string` | `#HOSTNAME#:#PORT#,...`                    | The Zookeeper connection string, a list of hostnames and port comma separated. |
| `httpfs.authentication.signature.secret.provider.zookeeper.auth.type` | none                                       | The Zookeeper authentication type, 'none' (default) or 'sasl' (Kerberos).   |
| `httpfs.authentication.signature.secret.provider.zookeeper.kerberos.keytab` | `/etc/hadoop/conf/httpfs.keytab`           | The absolute path for the Kerberos keytab with the credentials to connect to Zookeeper. |
| `httpfs.authentication.signature.secret.provider.zookeeper.kerberos.principal` | `HTTPFS/#HOSTNAME#`                       | The Kerberos service principal used to connect to Zookeeper.                |
| `httpfs.authentication.simple.anonymous.allowed`                     | false                                      | Whether anonymous requests are allowed.                                     |
| `httpfs.authentication.type`                                         | simple                                     | The authentication type used by the HttpFS server.                           |
| `httpfs.authentication.token.validity`                               | 36000                                      | The validity period of the authentication tokens.                           |
| `httpfs.authentication.token.renewal`                                | false                                      | Whether authentication tokens can be renewed.                               |
| `httpfs.authentication.kerberos.principal`                           | `HTTP/_HOST@REALM`                        | The Kerberos principal to use for the HTTP endpoint. Must start with 'HTTP/'. |
| `httpfs.authentication.kerberos.keytab`                              | `${user.home}/httpfs.keytab`              | Path to the keytab with credentials for the configured Kerberos principal.  |
| `httpfs.authentication.kerberos.name.rules`                          | DEFAULT                                    | Rules used to resolve Kerberos principal names.                             |
| `httpfs.authentication.signer.secret.provider`                       | random                                     | The provider used to store the secret.                                      |
| `httpfs.authentication.signer.secret.provider.zookeeper.path`        | `/hadoop-httpfs/httpfs-auth-signature-secret` | The Zookeeper ZNode path where the HttpFS instances will store and retrieve the secret from. |
| `httpfs.authentication.signer.secret.provider.zookeeper.connection.string` | `#HOSTNAME#:#PORT#,...`                    | The Zookeeper connection string, a list of hostnames and port comma separated. |
| `httpfs.authentication.signer.secret.provider.zookeeper.auth.type`   | none                                       | The Zookeeper authentication type, 'none' (default) or 'sasl' (Kerberos).   |
| `httpfs.authentication.signer.secret.provider.zookeeper.kerberos.keytab` | `/etc/hadoop/conf/httpfs.keytab`           | The absolute path for the Kerberos keytab with the credentials to connect to Zookeeper. |
| `httpfs.authentication.signer.secret.provider.zookeeper.kerberos.principal` | `HTTPFS/#HOSTNAME#`                       | The Kerberos service principal used to connect to Zookeeper.                |
| `httpfs.audit.logger`                                                | `org.apache.hadoop.fs.http.server.HttpFSAuditLogger` | The audit logger for HttpFS. Default is the text-format HttpFSAuditLogger only. |

---

## Python Example for Connecting via PySpark

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("PySpark Hadoop Example") \
    .config("spark.jars", "/path/to/hadoop-aws-3.4.0.jar,/path/to/aws-java-sdk-bundle-1.11.375.jar") \
    .config("spark.hadoop.fs.s3a.access.key", "YOUR_ACCESS_KEY") \
    .config("spark.hadoop.fs.s3a.secret.key", "YOUR_SECRET_KEY") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .getOrCreate()

df = spark.read.csv("s3a://bucket-name/path/to/file.csv")
df.show()
```

---
