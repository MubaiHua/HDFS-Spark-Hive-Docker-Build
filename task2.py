import findspark
findspark.init('/opt/spark')
from pyspark.sql import SparkSession
spark = SparkSession.builder \
        .appName("TestWithoutHive") \
        .config("spark.sql.catalogImplementation", "in-memory") \
        .getOrCreate()

df = spark.read.option("header", "true").option("inferSchema", "true").csv("hdfs://master:8020//data/myfiles/name.csv")
df.createOrReplaceTempView("name")

spark.sql("SELECT * FROM name").show()
print(spark.conf.get("spark.sql.catalogImplementation"))
exit()