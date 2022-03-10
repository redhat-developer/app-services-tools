# rhoas-tools-image

Tools docker image that contain number of CLIs that can be executed as container:

- OC
- RHOAS
- ODO


## Running image

```shell
docker run -ti --rm --name rhoas-devsandbox --entrypoint /bin/bash quay.io/rhoas/tools
```

## Support scripts

Repository provides number of scripts for testing kafka topics and service account creation
See [./scripts](./scripts) for more information

## Running the release workflow manually

A new version of `quay.io/rhoas/tools` will be published to [Quay](https://quay.io/repository/rhoas/tools) upon a new release of the rhoas CLI.
In the event that this does not happen for some reason, you can easily trigger the workflow directly from the GitHub UI.

1. Navigate to the [**Actions > Build and Push Container**](https://github.com/redhat-developer/app-services-tools/actions/workflows/build.yaml) section of this repo.
2. Click **Run workflow** and enter the rhoas CLI release version you wish to publish the new image for.
3. Click **Run workflow** (green button) and the image will be built and then published to [quay.io/rhoas/tools](https://quay.io/repository/rhoas/tools) (this will take a few minutes so go make yourself a coffee while you wait).

![Screenshot 2022-03-10 at 12 55 42](https://user-images.githubusercontent.com/11743717/157667661-8d7ba3e0-ef3f-460a-96b1-b19b113cfbde.png)
