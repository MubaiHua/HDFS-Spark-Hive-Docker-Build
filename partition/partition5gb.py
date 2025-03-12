import findspark
findspark.init('/opt/spark')

from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder \
    .appName("Partitioned5GB") \
    .enableHiveSupport() \
    .getOrCreate()

# Read raw Parquet data
df = spark.read.parquet("hdfs://master:8020/data/5gb/")
df = df.withColumn("lpep_pickup_datetime", col("lpep_pickup_datetime").cast("timestamp"))
df = df.withColumn("lpep_dropoff_datetime", col("lpep_dropoff_datetime").cast("timestamp"))

# Write the data partitioned by the desired columns
df.write.partitionBy("RatecodeID", "VendorID", "payment_type") \
    .option("path", "hdfs://master:8020/data/nyc_taxi_partitioned_5gb") \
    .mode("overwrite") \
    .saveAsTable("taxi_data_partitioned_5gb")
