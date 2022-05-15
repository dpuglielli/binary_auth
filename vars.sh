#!/bin/sh
# project info
export DEPLOYER_PROJECT_ID=flx-dwd-run-deploy
export ATTESTOR_PROJECT_ID=flx-dwd-run-attest
export ATTESTATION_PROJECT_ID=${ATTESTOR_PROJECT_ID}

export ORG_ID=432347649698

export DEPLOY_SA_KEY="/Users/davepuglielli/sa_keys/run-deployer-sa.json"
export ATTEST_SA_KEY="/Users/davepuglielli/sa_keys/attest-sa.json"

export RUN_DEPLOYER_ID="service-run-deployer"
export RUN_DEPLOYER_EMAIL="${RUN_DEPLOYER_ID}@${DEPLOYER_PROJECT_ID}.iam.gserviceaccount.com"

export ATTESTATION_SA_ID="service-attestation"
export ATTESTATION_SA_EMAIL="${ATTESTATION_SA_ID}@${ATTESTOR_PROJECT_ID}.iam.gserviceaccount.com"

# Set the container name
export CONTAINER_NAME=hello-world

# Set the service name
export SERVICE_NAME=$CONTAINER_NAME

# Set the location
export LOCATION=us-central1

export CONTAINER_DIR=deploy

# Set the GCR path you will use to host the container image
export CONTAINER_PATH=${LOCATION}-docker.pkg.dev/${DEPLOYER_PROJECT_ID}/${CONTAINER_DIR}/${CONTAINER_NAME}

# Set the note id for Container Analysis API
export NOTE_ID=from-workflow-note

# Set the attestor for the BinAuthZ API
export ATTESTOR_NAME=from-workflow-attestor

# KMS Details
export KEY_LOCATION=us-central1
export KEYRING=from-workflow-binauthz-keys
export KEY_NAME=from-workflow-attestor-key
export KEY_VERSION=1

