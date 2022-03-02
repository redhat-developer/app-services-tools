#!/bin/bash

registry=${REGISTRY:-quay.io}
username=${USERNAME}

docker run -ti --rm --name rhoas-devsandbox --entrypoint /bin/bash $registry/$username/tools