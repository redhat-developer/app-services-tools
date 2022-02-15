set -e

#############################################################################################
#                           
# This script will verify that you can create and delete an OpenShift Application Services service account,
# using the RHOAS CLI and OpenShift Streams API by performing the following actions:
#
# - Login to the rhoas CLI and OpenShift Streams Control Plane usig the provided credentials
# - Create a Service Account with the given name.
# - Verify that the Service Account exists by retrieving the service account information.
# - Delete the Service Account.
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
      echo "Usage: create-service-account.sh [args...]"
      echo "where args include:"
      echo "    -s              The name of the service account to be created."
}

#Parse the params
while getopts ":s:h" opt; do
  case $opt in
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

login

createServiceAccount $SERVICE_ACCOUNT_NAME

echo "Waiting for service account to be created."
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

echo "Service Account succesfully created!"

deleteServiceAccount $SERVICE_ACCOUNT_ID

echo "Clean up service account environment variable file."
rm sa.env

completeHealthCheck