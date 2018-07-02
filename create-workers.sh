#!/bin/bash

# vars
[ -z "$NUM_WORKERS" ] && NUM_WORKERS=3

# Get join token:
SWARM_TOKEN=$(docker swarm join-token -q worker)
echo $SWARM_TOKEN

# Get Swarm master IP (Docker for Mac xhyve VM IP)
SWARM_MASTER_IP=$(docker info | grep -w 'Node Address' | awk '{print $3}')
echo $SWARM_MASTER_IP
# Number of workers
NUM_WORKERS=3
#--registry-mirror http://${SWARM_MASTER_IP}:5000

for i in $(seq "${NUM_WORKERS}"); do
    docker node rm --force $(docker node ls --filter "name=worker-${i}" -q) > /dev/null 2>&1
	docker run --rm --add-host=private-registry:10.10.10.10 -d \
	 --privileged --name worker-${i} \
	 --hostname=worker-${i} \
	 -p 8084:8084 \
	 -p ${i}2375:2375 \
	 -p ${i}2377:2377/tcp \
	 -p ${i}7946:7946/tcp \
	 -p ${i}7946:7946/udp \
	 -p ${i}4789:4789/udp \
	 docker:stable-dind \
	 --insecure-registry 10.10.10.10:5000 --insecure-registry ${SWARM_MASTER_IP}:5000 --insecure-registry private-registry:5000

	docker --host=localhost:${i}2375 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER_IP}:2377
done