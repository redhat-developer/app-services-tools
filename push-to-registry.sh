#!/bin/bash

set -uo pipefail

tag=${RHOAS_VERSION/#"v"} # remove "v" prefix
registry=${REGISTRY:-quay.io}
registry_org=${REGISTRY_ORG:-rhoas}

image_name=$registry/$registry_org/tools

docker push $image_name:latest
docker push $image_name:$tag