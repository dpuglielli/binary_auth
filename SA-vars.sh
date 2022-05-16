#!/bin/sh
# project info
source ./vars.sh

# Reference to binary auth service accounts
export DEPLOYER_PROJECT_NUMBER=$(gcloud projects describe "${DEPLOYER_PROJECT_ID}" --format="value(projectNumber)")
export DEPLOYER_BA_SA="service-${DEPLOYER_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

export ATTESTOR_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTOR_PROJECT_ID}" --format="value(projectNumber)")
export ATTESTOR_BA_SA="service-${ATTESTOR_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

export ATTESTATION_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTATION_PROJECT_ID}" --format="value(projectNumber)")
export ATTESTATION_BA_SA="service-${ATTESTATION_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

