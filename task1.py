import findspark
findspark.init('/opt/spark')
from pyspark.sql import SparkSession

spark = SparkSession.builder \
        .appName("TestWithHive") \
        .enableHiveSupport() \
        .getOrCreate()

# Directly query the Hive table named my_table
df = spark.table("my_table")
df.show()

# Alternatively, you can run a SQL query on it
spark.sql("SELECT * FROM my_table").show()

print(spark.conf.get("spark.sql.catalogImplementation"))
spark.stop()
