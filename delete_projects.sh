#!/bin/sh
. ./vars.sh

echo "$ATTESTOR_PROJECT_ID delete"
gcloud beta billing projects unlink $ATTESTOR_PROJECT_ID
gcloud projects delete $ATTESTOR_PROJECT_ID --quiet

echo "$DEPLOYER_PROJECT_ID delete"
gcloud beta billing projects unlink $DEPLOYER_PROJECT_ID
gcloud projects delete $DEPLOYER_PROJECT_ID --quiet

#echo "$ATTESTATION_PROJECT_ID delete"
#gcloud beta billing projects unlink $ATTESTATION_PROJECT_ID
#gcloud projects delete $ATTESTATION_PROJECT_ID --quiet