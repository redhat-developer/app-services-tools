set -e

##################################################################################################################
#                           
# This script will verify that you can produce message to a Kafka topic,
# and consume messages from the Kafka topic. This is done using the RHOAS CLI,
# and the kcat CLI,  by performing the following actions:
#
# - Login to the rhoas CLI and OpenShift Streams Control Plane usig the provided credentials
# - Select the given Kafka instance as the instance to performa actions on.
# - Create a topic.
# - Create a Service Account
# - Configure ACLs on the service account to produce messages to, and consume messages from the new topic.
# - Produce message with kcat to the newly created topic.
# - Consume message with kcat from the newly created topic.
# - Verify that the consumed message is the same as the produced message.
# - Delete the topic.
# - Delete the Service Account.
#
##################################################################################################################


# Source function library.
if [ -f /etc/init.d/functions ]
then
        . /etc/init.d/functions
fi

################################################ Parse input parameters #############################################
function usage {
      echo "\n"
      echo "Usage: produce-consume.sh [args...]"
      echo "where args include:"
      echo "    -k              The name of the Kafka instance you want to use"
      echo "    -t              The name of the topic to be created."
      echo "    -s              The name of the service account to be created."
}

#Parse the params
while getopts ":k:t:s:h" opt; do
  case $opt in
    k)
      KAFKA_NAME=$OPTARG
      ;;
    t)
      TOPIC_NAME=$OPTARG
      ;;
    s)
      SERVICE_ACCOUNT_NAME=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

PARAMS_NOT_OK=false

#Check params
if [ -z "$KAFKA_NAME" ]
then
        echo "No Kafka name specified!"
        PARAMS_NOT_OK=true
fi
if [ -z "$TOPIC_NAME" ]
then
        echo "No topic name specified!"
        PARAMS_NOT_OK=true
fi
if [ -z "$SERVICE_ACCOUNT_NAME" ]
then
        echo "No Service Account name specified!"
        PARAMS_NOT_OK=true
fi

if $PARAMS_NOT_OK
then
        usage
        exit 1
fi

################################################ Setup params.  #############################################

#Load kafka functions.
source ./kafka.sh


################################################ Run topic creation health check.  #############################################

startHealthCheck

checkRhoasCliAvailable
checkKcatAvailable

login
useKafka $KAFKA_NAME
createTopic $TOPIC_NAME
createServiceAccount $SERVICE_ACCOUNT_NAME

echo "Waiting for topic to be created and Service Account to be created."
sleep 5

echo "Client ID of the new Service Account: $CLIENT_ID"

getServiceAccountIdByClientId $CLIENT_ID

# Check that SERVICE_ACCOUNT is not empty
if [ -z "$SERVICE_ACCOUNT_ID" ]
then
  echo "No SERVICE_ACCOUNT id set. Service Acccount not found. Unable to perform operations on the given Service Account."
  exit 1
else
  #deleteServiceAccount $SERVICE_ACCOUNT
  echo "Service Account ID of the new Service Account: $SERVICE_ACCOUNT_ID"
fi

describeTopic $TOPIC_NAME

echo "Service Account succesfully created!"

grantTopicProducerConsumerAccessToServiceAccount $CLIENT_ID $TOPIC_NAME

############## Setup complete. We can now produce and consume messages with kcat. ############## 
getBootstrapServerHost
echo "Kafka instance Bootstrap server host: $BOOTSTRAP_SERVER_HOST"

echo "Sending message to Kafka."
MESSAGE_VALUE="check"
echo '{"message": "'$MESSAGE_VALUE'"}' | kcat -b "$BOOTSTRAP_SERVER_HOST" -t healthcheck -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username="$CLIENT_ID" -X sasl.password="$CLIENT_SECRET" -P

echo "Retrieving message from Kafka"
RECEIVED_MESSAGE_VALUE=$(kcat -b "$BOOTSTRAP_SERVER_HOST" -t healthcheck -X security.protocol=SASL_SSL -X sasl.mechanisms=PLAIN -X sasl.username="$RHOAS_SERVICE_ACCOUNT_CLIENT_ID" -X sasl.password="$RHOAS_SERVICE_ACCOUNT_CLIENT_SECRET" -C -c 1 | jq -r .message)

echo "Message value: $RECEIVED_MESSAGE_VALUE"

if [ "$RECEIVED_MESSAGE_VALUE" = "$MESSAGE_VALUE" ]; then
  echo "Message content validation completed successfully."
else
  echo "Message check failed. Message content received differs from the expected value. Expected: $MESSAGE_VALUE, received: $RECEIVED_MESSAGE_VALUE"
  ERROR_CODE=1
fi

echo "Cleaning up topic and Service Account."
deleteTopic $TOPIC_NAME
deleteServiceAccount $SERVICE_ACCOUNT_ID

echo "Clean up service account environment variable file."
rm sa.env

if [ -n "$ERROR_CODE" ]
then
  echo "Errror while running healthcheck."
  exit $ERROR_CODE
fi

completeHealthCheck