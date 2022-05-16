#!/bin/bash
source ./vars.sh

# setup auth
gcloud auth activate-service-account --key-file="${DEPLOY_SA_KEY}"

DIGEST=$(gcloud --project=${DEPLOYER_PROJECT_ID} container images describe ${CONTAINER_PATH}:latest --format='get(image_summary.digest)')

gcloud auth revoke --all

gcloud auth activate-service-account --key-file="${ATTEST_SA_KEY}"

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

gcloud --project=${ATTESTATION_PROJECT_ID} \
    container binauthz attestations delete \
    --attestor=$ATTESTOR_NAME --attestor-project=$ATTESTOR_PROJECT_ID

gcloud auth revoke --all