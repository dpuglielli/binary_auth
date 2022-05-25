#!/bin/sh
# project info
SEQ="-8"
export DEPLOYER_PROJECT_ID=flx-dwd-run-deploy${SEQ}
export ATTESTOR_PROJECT_ID=flx-dwd-run-attestor${SEQ}
# export ATTESTATION_PROJECT_ID=flx-dwd-run-attestation${SEQ}

export ORG_ID=432347649698
export BILLING_ACCOUNT=01249C-50AD5E-7A20E6

# Set the container name
export CONTAINER_NAME=hello-world

# Set the service name
export SERVICE_NAME=$CONTAINER_NAME

# Set the location
export LOCATION=us-central1

export CONTAINER_DIR=wif-gh-integration-test

# Set the GCR path you will use to host the container image
export CONTAINER_PATH=${LOCATION}-docker.pkg.dev/${DEPLOYER_PROJECT_ID}/${CONTAINER_DIR}/${CONTAINER_NAME}

# Set the note id for Container Analysis API
export NOTE_ID=built-from-workflow-attestor-note

# Set the attestor for the BinAuthZ API
export ATTESTOR_NAME=built-from-workflow-attestor

# KMS Details
export KEY_LOCATION=global
export KEYRING=attestor-keyring
export KEY_NAME=built-from-workflow-attestor-crypto-key
export KEY_VERSION=1

export RUN_DEPLOYER_SA_KEY="/Users/davepuglielli/sa_keys/deploy_run_8.json"
export ATTESTOR_SA_KEY="/home/vscode/attestor-sa.json"
# export ATTESTATION_SA_KEY="/Users/davepuglielli/sa_keys/attestation-sa.json"

export RUN_DEPLOYER_ID="service-deployer"
export RUN_DEPLOYER_EMAIL="${RUN_DEPLOYER_ID}@${DEPLOYER_PROJECT_ID}.iam.gserviceaccount.com"

