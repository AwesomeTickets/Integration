#!/bin/sh

. ./scripts/common.sh

UPLOAD=false
QUIET=""

for param in $*; do
    if [ ${param} = "-u" ]; then
        UPLOAD=true
    elif [ ${param} = "-q" ]; then
        QUIET="-q"
    elif [ ${param} = "-h" ]; then
        printf "Usage: $0 [OPTIONS]\n\n\
OPTIONS:\n\
  -u  upload images to remote repository if tests pass (require env 'REPO_USR' and 'REPO_PSWD')\n\
  -q  suppress the docker build output
  -h  show this help prompt\n"
        exit 0
    fi
done

load_repo() {
    printf "Loading repository '$1'...\n"
    if [ ! -e $1 ]; then
        git clone --branch=master https://github.com/AwesomeTickets/$1.git
    else
        cd $1
        git pull origin master
        cd ..
    fi
    printf "Done.\n\n"
}

build_image() {
    printf "Building image '$2'...\n"
    cd $1
    docker build ${QUIET} -t $2 .
    cd ..
    printf "Done.\n\n"
}

upload_image() {
    printf "Uploading image '$1'...\n"
    registry_image=${REGISTRY}/${NS}/$1
    docker tag $1 ${registry_image}
    docker push ${registry_image}
    printf "Done.\n\n"
}

load_all() {
    load_repo ${SERVER_CACHE}
    load_repo ${SERVER_DB}
    load_repo ${SERVER_SERVICE}
    load_repo ${SERVER_STATICPAGE}
}

build_all() {
    build_image ${SERVER_CACHE} ${IMAGE_CACHE}
    build_image ${SERVER_DB} ${IMAGE_DB}
    build_image ${SERVER_SERVICE} ${IMAGE_SERVICE}
    build_image ${SERVER_STATICPAGE} ${IMAGE_STATICPAGE}
    run_quiet "docker rmi $(docker images -qf 'dangling=true')"
}

upload_all() {
    run_quiet "docker login -u ${REPO_USR} -p ${REPO_PSWD} ${REGISTRY}"
    upload_image ${IMAGE_CACHE}
    upload_image ${IMAGE_DB}
    upload_image ${IMAGE_SERVICE}
    upload_image ${IMAGE_STATICPAGE}
}

load_all
build_all

printf "Creating integration test stack...\n"
docker swarm init
docker stack deploy -c ${FILE_COMPOSE_TEST} ${STACK_TEST}
printf "Done.\n\n"

printf "Getting test container...\n"
# Wait contrainer to be built
while [ true ]; do
    sleep 1
    service_container=$(docker ps -aqf "name=${IMAGE_SERVICE}")
    if [ ${service_container} ]; then
        break
    fi
done
printf "Container: ${service_container}\n\n"

printf "Attaching test container...\n"
docker attach ${service_container}
exit_code=$(docker inspect -f "{{.State.ExitCode}}" ${service_container})
clean_stack
clean_data "test"
if [ ${exit_code} != 0 ]; then
    printf "Integration test failed with exit code ${exit_code}.\n"
    exit ${exit_code}
else
    printf "Integration test passed.\n"
    if [ ${UPLOAD} = true ]; then
        printf "\n"
        upload_all
    fi
fi
