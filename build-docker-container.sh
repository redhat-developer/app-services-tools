#!/bin/sh

set -uo pipefail

registry=${REGISTRY:-quay.io}
username=${USERNAME}

docker build --build-arg RHOAS_VERSION=$TAG --rm -t $registry/$username/tools .
docker tag $registry/$username/tools $registry/$username:$TAG