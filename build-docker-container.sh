#!/bin/bash

set -uo pipefail

rhoas_version=$RHOAS_VERSION
image_tag=${rhoas_version/#"v"}

registry=${REGISTRY:-quay.io}
registry_org=${REGISTRY_ORG:-rhoas}

image_name=$registry/$registry_org/tools

docker build --build-arg RHOAS_VERSION=$rhoas_version --rm -t $image_name .

docker tag $image_name $image_name:latest
docker tag $image_name $image_name:$image_tag