#!/bin/sh

if [ $# -eq 0 ]; then
    printf "Usage: $0 <container>\n"
else
    pid=$(docker inspect --format "{{ .State.Pid }}" $1)
    nsenter --target ${pid} --mount --uts --ipc --net --pid -- /usr/bin/env --ignore-environment HOME=/root /bin/bash --login
fi
