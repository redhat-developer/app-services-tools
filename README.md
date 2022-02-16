# rhoas-tools-image

Tools docker image that contain number of CLIs that can be executed as container:

- OC
- RHOAS
- ODO


## Running image

```
docker run -ti --rm --name rhoas-devsandbox --entrypoint /bin/bash quay.io/rhosak/rhoas-tools
```

## Support scripts

Repository provides number of scripts for testing kafka topics and service account creation
See [./scripts](./scripts) for more information
