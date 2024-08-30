import os
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf

# Set environment variables
os.environ['HADOOP_HOME'] = '/opt/hadoop'
os.environ['HADOOP_USER_NAME'] = 'hadoop'  # Replace with the desired user name
os.environ['LD_LIBRARY_PATH'] = os.path.join(os.environ['HADOOP_HOME'], 'lib/native') + ':' + os.environ.get('LD_LIBRARY_PATH', '')
os.environ['HADOOP_CONF_DIR'] = '/opt/hadoop/etc/hadoop'
os.environ['YARN_CONF_DIR'] = '/opt/hadoop/etc/hadoop'

# Spark configuration
# conf = SparkConf(loadDefaults=False)

spark_properties = {
    "spark.master": "yarn",
    "spark.app.name": "NeuralNetworkFromScratchApp",
    "spark.executor.cores": "4",
    "spark.executor.memory": "4g",
    "spark.driver.memory": "2g",
    "spark.eventLog.enabled": "true",
    "spark.eventLog.dir": "hdfs://10.1.0.146:8020/logs",
    "spark.default.parallelism": "8",
    "spark.sql.shuffle.partitions": "8",
    "spark.hadoop.fs.defaultFS": "hdfs://10.1.0.146:8020",
    "spark.hadoop.yarn.resourcemanager.address": "10.1.0.146:8032",
    "spark.hadoop.yarn.resourcemanager.hostname": "10.1.0.146",
    "spark.yarn.resourcemanager.address": "10.1.0.146:8032",
    "spark.yarn.resourcemanager.scheduler.address": "10.1.0.146:8030",
}

# Initialize SparkSession with properties
spark_builder = SparkSession.builder
for key, value in spark_properties.items():
    spark_builder = spark_builder.config(key, value)

spark = spark_builder.getOrCreate()

# Set log level to DEBUG
spark.sparkContext.setLogLevel("DEBUG")

# Print the SparkSession properties
for key, value in spark.sparkContext.getConf().getAll():
    print(f'{key}: {value}')

if __name__ == '__main__':
    from src.utils.logger import getLogger
    log = getLogger(__name__)
    log.info("Starting the application")
    spark.sql("show databases").show()
    # # Verify Spark session by creating a DataFrame and performing a simple transformation
    # data = [
    #     ("Alice", 1),
    #     ("Bob", 2),
    #     ("Cathy", 3)
    # ]
    #
    # columns = ["Name", "Value"]
    #
    # df = spark.createDataFrame(data, columns)
    # df.show()
