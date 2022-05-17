#!/bin/sh
. ./SA-vars.sh

echo "Creating ${RUN_DEPLOYER_EMAIL} service account in ${DEPLOYER_PROJECT_ID} project"
gcloud iam service-accounts create ${RUN_DEPLOYER_ID} \
  --project=${DEPLOYER_PROJECT_ID} \
  --description="Deployer service account" \
  --display-name="GH_TEST"

echo "Setting ${RUN_DEPLOYER_EMAIL} as service account in ${DEPLOYER_PROJECT_ID} project"
gcloud iam service-accounts add-iam-policy-binding \
    ${RUN_DEPLOYER_EMAIL} \
    --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" \
    --role="roles/iam.serviceAccountUser" \
    --project=${DEPLOYER_PROJECT_ID}

echo "Setting role permissions on  ${DEPLOYER_PROJECT_ID} for ${RUN_DEPLOYER_EMAIL} service account"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/artifactregistry.writer"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.developer"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.serviceAgent"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.admin"
#gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/containeranalysis.occurrences.editor"

echo "Setting role permissions on  ${ATTESTOR_PROJECT_ID} for ${RUN_DEPLOYER_EMAIL} service account"
gcloud projects add-iam-policy-binding ${ATTESTOR_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/binaryauthorization.attestorsVerifier"
gcloud projects add-iam-policy-binding ${ATTESTOR_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/cloudkms.signerVerifier"

echo "Setting note permissions on  ${ATTESTOR_PROJECT_ID} for ${RUN_DEPLOYER_EMAIL} service account"
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
            "serviceAccount:${RUN_DEPLOYER_EMAIL}"
          ]
        },
        {
          "role": "roles/containeranalysis.notes.attacher",
          "members": [
            "serviceAccount:${RUN_DEPLOYER_EMAIL}"
          ]
        }]
      }
    }
EOF

echo "Setting permissions on  ${ATTESTOR_PROJECT_ID} for ${RUN_DEPLOYER_EMAIL} service account"
gcloud projects add-iam-policy-binding ${ATTESTOR_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/containeranalysis.ServiceAgent"


