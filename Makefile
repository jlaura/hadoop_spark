network:
	sudo docker network create -d overlay --attachable workbench

traefik:
	# add --constraint node.hostname==frontend.com to deploy on particular server
	sudo docker service create --name traefik --publish 80:80 --publish 50080:8080 \
            --constraint 'node.hostname==dev-swarm-master-1' \
            --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
            --network workbench traefik \
            --docker --docker.swarmmode \
            --docker.domain=traefik --docker.watch --web --logLevel=DEBUG 

hadoop:
	sudo docker stack deploy -c docker-compose-hadoop.yml hadoop

spark:
	sudo docker stack deploy -c docker-compose-spark.yml spark

services:
	sudo docker stack deploy -c docker-compose-services.yml services

spark-worker-service:
	docker service create --detach=false --name spark-worker --network workbench -e SPARK_MASTER=spark://spark-master:7077 --container-label traefik.docker.network=workbench --container-label traefik.port=8081 bde2020/spark-worker:2.2.0-hadoop2.8-hive-java8
