# rhoas-tools-image

Tools docker image that contain number of CLIs that can be executed as container:

- OC
- RHOAS
- ODO


## Running RHOAS CLI from image

```
docker run -ti --rm --name rhoas-devsandbox --entrypoint /bin/bash quay.io/rhosak/rhoas-tools
```
