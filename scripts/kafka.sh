set -e

KAFKA_NAME="${KAFKA_NAME:-script-kafka}"
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-script-sa}"

if ! command -v rhoas &> /dev/null
then
    echo "rhoas cli could not be found"
    exit
fi


echo "creating kafka" 

rhoas login --token=$OFFLINE_TOKEN

rhoas kafka create --wait --name=$KAFKA_NAME

rhoas kafka topic list

rhoas service-account create --overwrite --file-format=env --output-file=sa.env --short-description=$SERVICE_ACCOUNT_NAME --

source ./sa.env

if ! command -v kcat &> /dev/null
then
    echo "kcat cli could not be found"
    exit
fi

