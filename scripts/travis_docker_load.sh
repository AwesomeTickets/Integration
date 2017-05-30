#!/bin/sh

. ./scripts/common.sh

load_image() {
    printf "Loading image from '$1'...\n"
    if [ -f $1 ]; then
        gunzip -c $1 | docker load
    fi
    printf "Done.\n\n"
}

load_image ${FILE_CACHE_SERVICE}
load_image ${FILE_CACHE_PROXY}
load_image ${FILE_CACHE_CACHE}
load_image ${FILE_CACHE_DB}
