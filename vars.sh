#!/bin/sh
# project info
SEQ="-1"
export DEPLOYER_PROJECT_ID=flx-dwd-run-deploy${SEQ}
export ATTESTOR_PROJECT_ID=flx-dwd-run-attestor${SEQ}
export ATTESTATION_PROJECT_ID=flx-dwd-run-attestation${SEQ}

export ORG_ID=432347649698
export BILLING_ACCOUNT=01249C-50AD5E-7A20E6

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

