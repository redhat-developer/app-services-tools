set -e

KAFKA_NAME="${KAFKA_NAME:-script-kafka}"
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-script-sa}"

if ! command -v rhoas &> /dev/null
then
    echo "rhoas cli could not be found"
    exit
fi


echo "Login and create kafka" 

rhoas login --token=$OFFLINE_TOKEN

rhoas kafka create --wait --name=$KAFKA_NAME

sleep 10

echo "Verify can connect to dataplane from RHOAS CLI" 

rhoas kafka topic list

echo "create service account for connectivity"

rhoas service-account create --overwrite --file-format=env --output-file=sa.env --short-description=$SERVICE_ACCOUNT_NAME 

source ./sa.env

USER=$RHOAS_SERVICE_ACCOUNT_CLIENT_ID
PASSWORD=$RHOAS_SERVICE_ACCOUNT_CLIENT_SECRET

if ! command -v kcat &> /dev/null
then
    echo "kcat cli could not be found"
    exit
fi

echo "TODO kcat produce consume"
