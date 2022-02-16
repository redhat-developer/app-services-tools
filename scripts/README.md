# RHOAS Health-Check Scripts

Scripts that allow the user to check whether their OpenShift Application Services function correctly.

### Prerequisits
The scripts require the following tools to be installed:
- rhoas CLI: https://github.com/redhat-developer/app-services-cli/releases
- kcat: https://github.com/edenhill/kcat
- jq: https://stedolan.github.io/jq/

## create-topic.sh
Tests topic creation on an existing OpenShift Streams for Apache Kafka instance. This script requires a browser-based login flow and does not support authentication based on offline tokens (yet).

```
Usage: create-topic.sh [args...]
    where args include:
        -k              The name of the Kafka instance you want to use
        -t              The name of the topic to be created.
```

Created resources (e.g. the topic) are cleaned up when the script completes.

## create-service-account.sh
Tests OpenShift Application Services service account creation.

```
Usage: create-service-account.sh [args...]
    where args include:
        -s              The name of the service account to be created.
        -o              Offline authentication token. Browser based login will be used if not specified.
```

Created resources (e.g. the service account) are cleaned up when the script completes.

## produce-consume.sh
Tests producing messages to an OpenShift Streams Kafka topic and consuming from the same topic. This script creates a topic with the given name dynamically during the test, and cleans it up after the test completes. This script requires a browser-based login flow and does not support authentication based on offline tokens (yet).

```
Usage: produce-consume.sh [args...]
    where args include:
        -k              The name of the Kafka instance you want to use
        -t              The name of the topic to be created.
        -s              The name of the service account to be created.
```

Created resources (e.g. the service account and topic) are cleaned up when the script completes.