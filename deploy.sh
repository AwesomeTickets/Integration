#!/bin/sh

. ./scripts/common.sh

CLEAN=false
REMOTE=false

for param in $*; do
    if [ ${param} = "-c" ]; then
        CLEAN=true
    elif [ ${param} = "-r" ]; then
        REMOTE=true
    elif [ ${param} = "-h" ]; then
        printf "Usage: $0 [OPTIONS]\n\n\
OPTIONS:\n\
  -c  clean all stacks, persistent data and exit\n\
  -r  deploy on remote server\n\
  -h  show this help prompt\n"
        exit 0
    fi
done

if [ ${CLEAN} = true ]; then
    clean_stack
    # Wait db-server to stop
    while [ true ]; do
        sleep 1
        db_container=$(docker ps -aqf "name=${IMAGE_DB}")
        if [ ! ${db_container} ]; then
            break
        fi
    done
    clean_data
    exit 0
fi

if [ ${REMOTE} != true ]; then
    printf "Deploying...\n"
    docker stack deploy -c ${FILE_COMPOSE} ${STACK}
    printf "Done.\n"
else
    printf "remote.\n"
fi
