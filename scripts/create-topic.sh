set -e

#############################################################################################
#                           
# This script will verify that you can create and delete topics on your Kafka instance, 
# using the RHOAS CLI and OpenShift Streams API by performing the following actions:
#
# - Login to the rhoas CLI and OpenShift Streams Control Plane usig the provided credentials
# - Select the given Kafka instance as the instance to performa actions on.
# - Create a topic.
# - Verify that the topic exists by retrieving the topic information.
# - Delete the topic.
#
#############################################################################################


# Source function library.
if [ -f /etc/init.d/functions ]
then
        . /etc/init.d/functions
fi

################################################ Parse input parameters #############################################
function usage {
      echo "\n"
      echo "Usage: create-topic.sh [args...]"
      echo "where args include:"
      echo "    -k              The name of the Kafka instance you want to use"
      echo "    -t              The name of the topic to be created."
}

#Parse the params
while getopts ":k:t:h" opt; do
  case $opt in
    k)
      KAFKA_NAME=$OPTARG
      ;;
    t)
      TOPIC_NAME=$OPTARG
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

login
useKafka $KAFKA_NAME
createTopic $TOPIC_NAME

echo "Waiting for topic to be created."
sleep 5

describeTopic $TOPIC_NAME

echo "Cleaning up topic."
deleteTopic $TOPIC_NAME

completeHealthCheck