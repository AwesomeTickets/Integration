#!/bin/sh

. ./scripts/common.sh

save_image() {
    printf "Saving image '$2' to '$1'...\n"
    if [ ${TRAVIS_PULL_REQUEST} = false ]; then
        mkdir -p $(dirname $1)
        docker save $(docker history -q $2 | grep -v '<missing>') | gzip > $1
    fi
    printf "Done.\n\n"
}

save_image ${FILE_CACHE_SERVICE} ${IMAGE_SERVICE}
save_image ${FILE_CACHE_PROXY} ${IMAGE_PROXY}
save_image ${FILE_CACHE_CACHE} ${IMAGE_CACHE}
save_image ${FILE_CACHE_DB} ${IMAGE_DB}
