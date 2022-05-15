#!/bin/sh
source ./vars.sh

#ATTESTOR_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTOR_PROJECT_ID}" \
#    --format="value(projectNumber)")
#
#if [ -z "$ATTESTOR_PROJECT_NUMBER" ]
#then
#      echo "$ATTESTOR_PROJECT_ID \$ATTESTOR_PROJECT_NUMBER is empty"
#      gcloud projects create $ATTESTOR_PROJECT_ID --organization=$ORG_ID
#
#fi

export DEPLOYER_PROJECT_NUMBER=$(gcloud projects describe "${DEPLOYER_PROJECT_ID}" \
    --format="value(projectNumber)")

export DEPLOYER_SERVICE_ACCOUNT="service-${DEPLOYER_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

export ATTESTOR_PROJECT_NUMBER=$(gcloud projects describe "${ATTESTOR_PROJECT_ID}" \
    --format="value(projectNumber)")
export ATTESTOR_SERVICE_ACCOUNT="service-${ATTESTOR_PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"


echo "BinAuth service accounts $DEPLOYER_SERVICE_ACCOUNT and $ATTESTOR_SERVICE_ACCOUNT"

gcloud --project=${ATTESTOR_PROJECT_ID} \
  services enable \
    containeranalysis.googleapis.com \
    container.googleapis.com \
    binaryauthorization.googleapis.com \
    cloudkms.googleapis.com

echo "Creating note..."
curl "https://containeranalysis.googleapis.com/v1/projects/${ATTESTOR_PROJECT_ID}/notes/?noteId=${NOTE_ID}" \
  --request "POST" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${GOOGLE_CLOUD_PROJECT}" \
  --data-binary @- <<EOF
    {
      "name": "projects/${GOOGLE_CLOUD_PROJECT}/notes/${NOTE_ID}",
      "attestation": {
        "hint": {
          "human_readable_name": "Application From GitHub Workflow"
        }
      }
    }
EOF

echo "Verifying notes..."
sleep 2

curl \
-H "Authorization: Bearer $(gcloud auth print-access-token)" \
"https://containeranalysis.googleapis.com/v1/projects/${ATTESTOR_PROJECT_ID}/notes/${NOTE_ID}"

echo "Creating attestor..."
# Create Attestor
gcloud container binauthz attestors create $ATTESTOR_NAME \
  --project "${ATTESTOR_PROJECT_ID}" \
  --attestation-authority-note-project "${ATTESTOR_PROJECT_ID}" \
  --attestation-authority-note "${NOTE_ID}" \
  --description "Application From GitHub Workflow Attestor"

echo "Verifying attestors..."
sleep 2

gcloud --project=${ATTESTOR_PROJECT_ID} \
    container binauthz attestors list

echo "Add IAM for ${DEPLOYER_SERVICE_ACCOUNT}..."
sleep 2
gcloud --project ${ATTESTOR_PROJECT_ID} \
    container binauthz attestors add-iam-policy-binding \
    "projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}" \
    --member="serviceAccount:${DEPLOYER_SERVICE_ACCOUNT}" \
    --role=roles/binaryauthorization.attestorsVerifier

echo "Add IAM for ${ATTESTOR_SERVICE_ACCOUNT}..."
# Set IAM Permissions for Note
curl "https://containeranalysis.googleapis.com/v1/projects/${ATTESTOR_PROJECT_ID}/notes/${NOTE_ID}:setIamPolicy" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${ATTESTOR_PROJECT_ID}" \
  --data-binary @- <<EOF
    {
      "resource": "projects/${ATTESTOR_PROJECT_ID}/notes/${NOTE_ID}",
      "policy": {
        "bindings": [{
          "role": "roles/containeranalysis.notes.occurrences.viewer",
          "members": [
            "serviceAccount:${ATTESTOR_SERVICE_ACCOUNT}"
          ]
        }]
      }
    }
EOF

# Create new keyring
gcloud kms keyrings create "${KEYRING}" \
  --project "${ATTESTOR_PROJECT_ID}" \
  --location "${KEY_LOCATION}"

# Create new key pair for the attestor
gcloud kms keys create "${KEY_NAME}" \
  --project "${ATTESTOR_PROJECT_ID}" \
  --location "${KEY_LOCATION}" \
  --keyring "${KEYRING}" \
  --purpose asymmetric-signing \
  --default-algorithm "ec-sign-p256-sha256"

# Add public key to the attestory
gcloud container binauthz attestors public-keys add \
  --project "${ATTESTOR_PROJECT_ID}" \
  --attestor "${ATTESTOR_NAME}"  \
  --keyversion "${KEY_VERSION}" \
  --keyversion-key "${KEY_NAME}" \
  --keyversion-keyring "${KEYRING}" \
  --keyversion-location "${KEY_LOCATION}" \
  --keyversion-project "${ATTESTOR_PROJECT_ID}"

echo "Verifying key for attestor..."
sleep 2

# Verify key was added
gcloud container binauthz attestors list --project "${ATTESTOR_PROJECT_ID}" 