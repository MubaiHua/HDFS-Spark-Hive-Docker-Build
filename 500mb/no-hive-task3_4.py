import findspark
findspark.init('/opt/spark')
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, TimestampType, DoubleType

spark = SparkSession.builder \
    .appName("Test500MB_Window_4") \
    .config("spark.sql.catalogImplementation", "in-memory") \
    .getOrCreate()

# Define the explicit schema
schema = StructType([
    StructField("VendorID", IntegerType(), True),
    StructField("tpep_pickup_datetime", TimestampType(), True),
    StructField("tpep_dropoff_datetime", TimestampType(), True),
    StructField("passenger_count", IntegerType(), True),
    StructField("trip_distance", DoubleType(), True),
    StructField("RatecodeID", IntegerType(), True),
    StructField("PULocationID", IntegerType(), True),
    StructField("DOLocationID", IntegerType(), True),
    StructField("payment_type", IntegerType(), True),
    StructField("fare_amount", DoubleType(), True),
    StructField("extra", DoubleType(), True),
    StructField("mta_tax", DoubleType(), True),
    StructField("tip_amount", DoubleType(), True),
    StructField("tolls_amount", DoubleType(), True),
    StructField("improvement_surcharge", DoubleType(), True),
    StructField("total_amount", DoubleType(), True)
])

# Read CSV files from HDFS using the explicit schema
df = spark.read.option("header", "true") \
    .schema(schema) \
    .csv("hdfs://master:8020/data/500mb.csv")

# Repartition the DataFrame to a fixed number of partitions (e.g., 10)
df = df.repartition(4)

# Create a temporary view to run SQL queries on the repartitioned data
df.createOrReplaceTempView("temp")

# Example SQL query to aggregate trip count, average fare, and total revenue by RatecodeID, VendorID, and payment_type
simple_query = """
SELECT 
  ratecodeid,
  vendorid,
  payment_type,
  tpep_pickup_datetime,
  fare_amount,
  ROW_NUMBER() OVER (
    PARTITION BY vendorid, ratecodeid, payment_type 
    ORDER BY tpep_pickup_datetime
  ) AS trip_rank,
  SUM(fare_amount) OVER (
    PARTITION BY vendorid, ratecodeid, payment_type 
    ORDER BY tpep_pickup_datetime 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_fare
From temp;
"""
spark.sql(simple_query).show(20)

print("Success")
spark.stop()
