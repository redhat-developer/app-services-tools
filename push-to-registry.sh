#!/bin/sh

set -uo pipefail

registry=${REGISTRY:-quay.io}
username=${USERNAME}
password=${PASSWORD}

docker login ${registry} --username $USERNAME --password $PASSWORD

docker push $registry/$username/tools