#!/bin/sh
source ./vars.sh

# Create projects
ATTESTOR_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTOR_PROJECT_ID}" \
    --format="value(projectNumber)")

if [ -z "$ATTESTOR_PROJECT_NUMBER" ]
then
      echo "$ATTESTOR_PROJECT_ID \$ATTESTOR_PROJECT_NUMBER is empty"
      gcloud projects create $ATTESTOR_PROJECT_ID --organization=$ORG_ID

fi

DEPLOYER_PROJECT_NUMBER=$(gcloud projects describe "${DEPLOYER_PROJECT_ID}" \
    --format="value(projectNumber)")

 if [ -z "$DEPLOYER_PROJECT_NUMBER" ]
then
      echo "$DEPLOYER_PROJECT_ID \$DEPLOYER_PROJECT_NUMBER is empty"
      gcloud projects create $DEPLOYER_PROJECT_ID --organization=$ORG_ID
fi



ATTESTATION_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTATION_PROJECT_ID}" \
    --format="value(projectNumber)")

 if [ -z "$ATTESTATION_PROJECT_NUMBER" ]
then
      echo "$ATTESTATION_PROJECT_ID \$ATTESTATION_PROJECT_NUMBER is empty"
      gcloud projects create $ATTESTATION_PROJECT_ID --organization=$ORG_ID
fi

# Set up billing
gcloud beta billing projects link ${ATTESTOR_PROJECT_ID} --billing-account=${BILLING_ACCOUNT}
gcloud beta billing projects link ${DEPLOYER_PROJECT_ID} --billing-account=${BILLING_ACCOUNT}
gcloud beta billing projects link ${ATTESTATION_PROJECT_ID} --billing-account=${BILLING_ACCOUNT}

# enable services 
gcloud --project=${ATTESTOR_PROJECT_ID} \
  services enable \
    containeranalysis.googleapis.com \
    binaryauthorization.googleapis.com \
    cloudkms.googleapis.com


gcloud --project=${DEPLOYER_PROJECT_ID} \
  services enable \
    container.googleapis.com \
    artifactregistry.googleapis.com \
    binaryauthorization.googleapis.com \
    run.googleapis.com

gcloud --project=${ATTESTATION_PROJECT_ID} \
  services enable \
    containeranalysis.googleapis.com \
    binaryauthorization.googleapis.com \
    cloudkms.googleapis.com

# setup owners
gcloud projects add-iam-policy-binding ${ATTESTOR_PROJECT_ID} --member="user:dvega@flexion.us" --role="roles/owner"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="user:dvega@flexion.us" --role="roles/owner"
gcloud projects add-iam-policy-binding ${ATTESTATION_PROJECT_ID} --member="user:dvega@flexion.us" --role="roles/owner"