#!/bin/sh
source ./SA-vars.sh

echo "Creating note..."
curl "https://containeranalysis.googleapis.com/v1/projects/${ATTESTOR_PROJECT_ID}/notes/?noteId=${NOTE_ID}" \
  --request "POST" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${ATTESTOR_PROJECT_ID}" \
  --data-binary @- <<EOF
    {
      "name": "projects/${ATTESTOR_PROJECT_ID}/notes/${NOTE_ID}",
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

gcloud --project=${ATTESTOR_PROJECT_ID}  container binauthz attestors list

echo "Add IAM for ${DEPLOYER_BA_SA}..."
sleep 2
gcloud --project ${ATTESTOR_PROJECT_ID} \
    container binauthz attestors add-iam-policy-binding \
    "projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}" \
    --member="serviceAccount:${DEPLOYER_BA_SA}" \
    --role=roles/binaryauthorization.attestorsVerifier

echo "Add IAM for ${ATTESTOR_BA_SA}..."
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
            "serviceAccount:${ATTESTOR_BA_SA}"
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