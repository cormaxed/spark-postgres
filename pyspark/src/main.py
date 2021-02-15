#!/usr/bin/python
import pyspark

if __name__ == '__main__':
    sc = pyspark.SparkContext(appName='CoinToss')

    try:
        session = pyspark.sql.SparkSession(sc)

        jdbc_url = 'jdbc:postgresql://postgres/postgres'
        connection_properties = {
            'user': 'postgres',
                    'password': 'postgres',
                    'driver': 'org.postgresql.Driver',
                    'stringtype': 'unspecified'}

        df = session.read.jdbc(jdbc_url, 'public.coin_toss',
                               properties=connection_properties)

        samples = df.count()
        heads_freq = df.filter("outcome == 'heads'").count() / samples
        tails_freq = df.filter("outcome == 'tails'").count() / samples

        stats = df.groupBy('outcome').count()

        for row in stats.rdd.collect():
            print("{} {}%".format(row['outcome'],
                                  row['count'] / samples * 100))
    finally:
        sc.stop()
