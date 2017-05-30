#!/bin/sh

REGISTRY="registry.cn-shenzhen.aliyuncs.com"

STACK="awesometickets"
STACK_TEST="${STACK}-test"

NS="${STACK}"

SERVER_CACHE="CacheServer"
SERVER_DB="DatabaseServer"
SERVER_SERVICE="ServiceServer"
SERVER_STATICPAGE="StaticPageServer"

IMAGE_CACHE="cache-server"
IMAGE_DB="db-server"
IMAGE_SERVICE="service-server"
IMAGE_STATICPAGE="proxy-server"

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
    if [ $# -eq 0 ]; then
        rm -rf ./data/db/*
        cp ./data/cache/.gitkeep ./data/db/.gitkeep
    elif [ $1 = "test" ]; then
        rm -rf ./data/test/db/*
        cp ./data/test/cache/.gitkeep ./data/test/db/.gitkeep
    fi
    printf "Done.\n"
}
