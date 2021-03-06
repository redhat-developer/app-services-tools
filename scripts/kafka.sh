set -e

#KAFKA_NAME="${KAFKA_NAME:-script-kafka}"
#SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-script-sa}"

function startHealthCheck {
    echo "\n"
    echo "##########################################################"
    echo "Starting OpenShift Streams Health Check"
    echo "##########################################################"
}

function completeHealthCheck {
    echo "\n"
    echo "##########################################################"
    echo "OpenShift Streams Health Check completed successfully"
    echo "##########################################################"
}

function checkRhoasCliAvailable {
    if ! command -v rhoas &> /dev/null
    then
        echo "rhoas cli could not be found"
        exit       
    fi
}

function checkKcatAvailable {
    if ! command -v kcat &> /dev/null
    then
        echo "kcat cli could not be found"
        exit
    fi
}

function checkJqAvailable {
    if ! command -v jq &> /dev/null
    then
        echo "jq could not be found"
        exit
    fi
}

function login {
    echo "Login to OpenShift Application Services control plane." 
    if [ -z "$1" ]
    then
        echo "Using browser-based login flow."
        rhoas login
    else
        echo "Using offline token login flow."
        rhoas login --token=$1
    fi
    
}

function createKafka {
    echo "Creating OpenShifts Streams Kafka instance with name $1"
    rhoas kafka create --wait --name=$1
}

function useKafka {
    echo "Using Kafka with name $1"
    rhoas kafka use --name=$1
}

function getBootstrapServerHost {
    echo "Retrieving Kafka bootstrap-server-host value."
    BOOTSTRAP_SERVER_HOST=$(rhoas kafka describe | jq -r .bootstrap_server_host)
}

function listTopics {
    echo "Listing Kafka topics."
    rhoas kafka topic list
}

function describeTopic {
    echo "Getting information for topic $1"
    rhoas kafka topic describe --name=$1
}

function createTopic {
    echo "Creating topic with name $1"
    rhoas kafka topic create --name=$1
}

function deleteTopic {
    echo "Deleting topic $1"
    rhoas kafka topic delete --name=$1 -y
}

function createServiceAccount {
    echo "Creating Service Account with name $1"
    rhoas service-account create --overwrite --file-format=env --output-file=sa.env --short-description=$1
    source ./sa.env
    CLIENT_ID=$RHOAS_SERVICE_ACCOUNT_CLIENT_ID
    CLIENT_SECRET=$RHOAS_SERVICE_ACCOUNT_CLIENT_SECRET
}

function getServiceAccountIdByClientId {
    echo "Retrieving the Service Account ID from the account's Client ID."
    SERVICE_ACCOUNT_ID=$(rhoas service-account list | awk -v service_id=$1 '$2==service_id{print $1}')
}

function grantTopicProducerConsumerAccessToServiceAccount {

    echo "Grant produce and consume rights for topic $2 to service account $1"
    rhoas kafka acl grant-access --producer --consumer --service-account $1 --topic $2 --group healthcheck -y
}

function deleteServiceAccount {
    rhoas service-account delete --id=$1 -y
}