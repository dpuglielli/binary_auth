#!/bin/sh
# project info
source ./vars.sh

export RUN_DEPLOYER_SA_KEY="/Users/davepuglielli/sa_keys/deploy-sa.json"
export ATTESTOR_SA_KEY="/Users/davepuglielli/sa_keys/attestor-sa.json"
export ATTESTATION_SA_KEY="/Users/davepuglielli/sa_keys/attestation-sa.json"

export RUN_DEPLOYER_ID="service-deployer"
export RUN_DEPLOYER_EMAIL="${RUN_DEPLOYER_ID}@${DEPLOYER_PROJECT_ID}.iam.gserviceaccount.com"

export ATTESTATION_SA_ID="service-attestation"
export ATTESTATION_SA_EMAIL="${ATTESTATION_SA_ID}@${ATTESTOR_PROJECT_ID}.iam.gserviceaccount.com"

export ATTESTATION_SA_ID="service-repo"
export ATTESTATION_SA_EMAIL="${ATTESTATION_SA_ID}@${ATTESTOR_PROJECT_ID}.iam.gserviceaccount.com"

# Reference to binary auth service accounts
export DEPLOYER_PROJECT_NUMBER=$(gcloud projects describe "${DEPLOYER_PROJECT_ID}" --format="value(projectNumber)")
export DEPLOYER_BA_SA="service-${DEPLOYER_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

export ATTESTOR_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTOR_PROJECT_ID}" --format="value(projectNumber)")
export ATTESTOR_BA_SA="service-${ATTESTOR_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

export ATTESTATION_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTATION_PROJECT_ID}" --format="value(projectNumber)")
export ATTESTATION_BA_SA="service-${ATTESTATION_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

