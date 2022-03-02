#!/bin/bash

set -uo pipefail

tag=${TAG/#"v"} # remove "v" prefix
registry=${REGISTRY:-quay.io}
registry_org=${REGISTRY_ORG:-rhoas}
password=${PASSWORD}

image_name=$registry/$registry_org/tools

# docker push $image_name
# docker push $image_name:$tag