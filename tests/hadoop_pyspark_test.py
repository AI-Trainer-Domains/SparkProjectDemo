from pyspark import SparkConf, SparkContext
from pyspark.sql import SparkSession

# Step 1: Configure Spark
conf = SparkConf().setAppName("HadoopSecureConnection") \
                  .set("spark.yarn.access.hadoopFileSystems", "hdfs://your-hdfs-uri") \
                  .set("spark.hadoop.hadoop.security.authentication", "kerberos") \
                  .set("spark.hadoop.hadoop.security.authorization", "true") \
                  .set("spark.yarn.keytab", "/path/to/user.keytab") \
                  .set("spark.yarn.principal", "user@YOUR.REALM")

# Step 2: Initialize Spark Context
sc = SparkContext(conf=conf)

# Step 3: Initialize Spark Session
spark = SparkSession.builder.config(conf=conf).getOrCreate()

# Step 4: Run a Test Workflow (e.g., read a file from HDFS)
df = spark.read.csv("hdfs://your-hdfs-uri/path/to/yourfile.csv")
df.show()

# Step 5: Stop the Spark Context
sc.stop()
