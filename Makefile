
help:
	@echo "build - The Docker image omahoco/spark-postgres"
	@echo "network - Create the develop docker network"
	@echo "postgres - Run a Postres container (exposes port 5432)"
	@echo "spark - Run a Spark cluster (exposes port 8100)"
	@echo "jupter - Run a Jupyter server (exposes port 9999)"
	@echo "jupter-token - Print the jupyter authentication token"


all: default network postgres spark jupyter

default: build

build:
	docker build -t omahoco/spark-postgres -f Dockerfile .

network:
	@docker network inspect develop >/dev/null 2>&1 || docker network create develop

postgres:
	@docker start postgres > /dev/null 2>&1 || docker run --name postgres \
		--restart unless-stopped \
		--net=develop \
		-e POSTGRES_PASSWORD=postgres \
		-e PGDATA=/var/lib/postgresql/data/pgdata \
		-v /opt/postgres:/var/lib/postgresql/data \
		-p 5432:5432 -d postgres:11

spark:
	docker-compose up -d

spark-submit:
	cp pyspark/src/main.py /tmp/
	docker exec spark spark-submit --master spark://spark:7077 /data/main.py

jupyter:
	@docker start jupyter > /dev/null 2>&1 || docker run -p 9999:8888 \
		-p 4040:4040 \
		-p 4041:4041 \
		-v /tmp:/data \
		--net=develop \
		--name jupyter_pyspark \
		--restart always \
		-d jupyter/pyspark-notebook

jupyter_token:
	@docker logs jupyter_pyspark 2>&1 | grep '\?token\=' -m 1 | cut -d '=' -f2
