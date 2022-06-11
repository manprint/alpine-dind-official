#!/bin/bash

set -o pipefail
set -o functrace

RED=$(tput setaf 1)
YELLOW=$(tput setaf 2)
RESET=$(tput sgr0)
DESC="Run Alpine Dind"

trap '__trap_error $? $LINENO' ERR 2>&1

function __trap_error() {
	echo "Error! Exit code: $1 - On line $2"
}

function help() {
	me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
	echo
	echo $DESC
	echo
	echo "List of functions in $YELLOW$me$RESET script: "
	echo
	list=$(declare -F | awk '{print $NF}' | sort | egrep -v "^_")
	for i in ${list[@]}
	do
		echo "Usage: $YELLOW./$me$RESET$RED $i $RESET"
	done
	echo
}

function __mkdir() {
	mkdir -vp $(pwd)/data/docker
	mkdir -vp $(pwd)/data/alpine
}

function __volumes() {
	docker volume create \
		--driver local \
		--opt type=none \
		--opt device=$(pwd)/data/docker \
		--opt o=bind \
		vol_alpine_docker
	docker volume create \
		--driver local \
		--opt type=none \
		--opt device=$(pwd)/data/alpine \
		--opt o=bind \
		vol_alpine_home
}

function down() {
	docker stop alpine-dind
	docker rm alpine-dind
	docker volume rm vol_alpine_docker vol_alpine_home
}

function up() {
	down
	__mkdir
	__volumes
	docker run -dit \
		--name=alpine-dind \
		--hostname=alpine.docker.it \
		-v vol_alpine_docker:/var/lib/docker \
		-v vol_alpine_home:/home/alpine \
		--privileged \
		-p 2375:2375 \
		ghcr.io/manprint/dind:22.06-rc-official
}

if [ "_$1" = "_" ]; then
	help
else
	"$@"
fi
