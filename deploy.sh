#!/bin/sh

. ./scripts/common.sh

CLEAN=false
PULL=false

for param in $*; do
    if [ ${param} = "-c" ]; then
        CLEAN=true
    elif [ ${param} = "-p" ]; then
        PULL=true
    elif [ ${param} = "-h" ]; then
        printf "Usage: $0 [OPTIONS]\n\n\
OPTIONS:\n\
  -c  clean all stacks, persistent data and exit\n\
  -p  pull images from registry before deployment\n\
  -h  show this help prompt\n"
        exit 0
    fi
done

if [ ${CLEAN} = true ]; then
    clean_stack
    clean_data
    exit 0
fi

printf "Deploying...\n"
if [ ${PULL} = true ]; then
    printf "\n"
    docker pull ${REGISTRY}/${NS}/${IMAGE_SERVICE}
    docker tag ${REGISTRY}/${NS}/${IMAGE_SERVICE} ${IMAGE_SERVICE}
    printf "\n"
    docker pull ${REGISTRY}/${NS}/${IMAGE_PROXY}
    docker tag ${REGISTRY}/${NS}/${IMAGE_PROXY} ${IMAGE_PROXY}
    printf "\n"
    docker pull ${REGISTRY}/${NS}/${IMAGE_CACHE}
    docker tag ${REGISTRY}/${NS}/${IMAGE_CACHE} ${IMAGE_CACHE}
    printf "\n"
    docker pull ${REGISTRY}/${NS}/${IMAGE_DB}
    docker tag ${REGISTRY}/${NS}/${IMAGE_DB} ${IMAGE_DB}
    printf "\n"
fi
docker swarm init
docker stack deploy -c ${FILE_COMPOSE} ${STACK}
printf "Done.\n"
