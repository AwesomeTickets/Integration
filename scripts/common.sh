#!/bin/sh

REGISTRY="registry.cn-shenzhen.aliyuncs.com"

STACK="awesometickets"
STACK_TEST="${STACK}-test"

NS="${STACK}"

SERVER_SERVICE="ServiceServer"
SERVER_PROXY="StaticPageServer"
SERVER_CACHE="CacheServer"
SERVER_DB="DatabaseServer"

IMAGE_SERVICE="service-server"
IMAGE_PROXY="proxy-server"
IMAGE_CACHE="cache-server"
IMAGE_DB="db-server"

FILE_COMPOSE="docker-compose.yml"
FILE_COMPOSE_TEST="docker-compose-test.yml"

run_quiet() {
    $1 > /dev/null 2>&1
}

clean_stack() {
    printf "Removing stacks..."
    run_quiet "docker stack rm ${STACK}"
    run_quiet "docker stack rm ${STACK_TEST}"
    printf "Done.\n"
}

clean_data() {
    printf "Removing persistent data..."
    # Wait db-server to stop
    while [ true ]; do
        sleep 1
        db_container=$(docker ps -aqf "name=${IMAGE_DB}")
        if [ ! ${db_container} ]; then
            break
        fi
    done
    if [ $# -eq 0 ]; then
        rm -rf ./data/db/*
        cp ./data/cache/.gitkeep ./data/db/.gitkeep
    elif [ $1 = "test" ]; then
        rm -rf ./data/test/db/*
        cp ./data/test/cache/.gitkeep ./data/test/db/.gitkeep
    fi
    printf "Done.\n"
}
