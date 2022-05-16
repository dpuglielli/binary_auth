#!/bin/bash
source ./vars.sh

# setup auth
SAVED_ACCOUNT=`gcloud config get-value account`
gcloud auth activate-service-account --key-file="${RUN_DEPLOYER_SA_KEY}"
export GOOGLE_APPLICATION_CREDENTIALS="${RUN_DEPLOYER_SA_KEY}"
echo $GOOGLE_APPLICATION_CREDENTIALS
gcloud auth list

# Build container
docker build -t $CONTAINER_PATH ./src

# Auth for cloud shell docker to Google Container Registry
gcloud auth configure-docker --quiet --project=${DEPLOYER_PROJECT_ID}

# Push to Google Container Registry
docker push $CONTAINER_PATH

# Get built continaer hash
DIGEST=$(gcloud --project=${DEPLOYER_PROJECT_ID} container images describe ${CONTAINER_PATH}:latest --format='get(image_summary.digest)')

echo "got hash ${DIGEST}"
# Sign and create attestation for container
gcloud beta container binauthz attestations sign-and-create  \
    --artifact-url="${CONTAINER_PATH}@${DIGEST}" \
    --attestor="${ATTESTOR_NAME}" \
    --attestor-project="${ATTESTOR_PROJECT_ID}" \
    --keyversion-project="${ATTESTOR_PROJECT_ID}" \
    --keyversion-location="${KEY_LOCATION}" \
    --keyversion-keyring="${KEYRING}" \
    --keyversion-key="${KEY_NAME}" \
    --keyversion="${KEY_VERSION}" \
    --project="${ATTESTATION_PROJECT_ID}" \
    --validate

gcloud --project=${ATTESTATION_PROJECT_ID} \
    container binauthz attestations list \
    --attestor=$ATTESTOR_NAME --attestor-project=$ATTESTOR_PROJECT_ID

gcloud run deploy ${SERVICE_NAME} \
  --image=${CONTAINER_PATH} \
  --binary-authorization=default \
  --allow-unauthenticated \
  --project="${DEPLOYER_PROJECT_ID}" 

unset GOOGLE_APPLICATION_CREDENTIALS
gcloud config set account ${SAVED_ACCOUNT}
gcloud auth list