#!/bin/sh
source ./SA-vars.sh

gcloud artifacts repositories create ${CONTAINER_DIR} \
    --repository-format=Docker \
    --location=${LOCATION} \
    --description="deploy containers" \
    --project=${DEPLOYER_PROJECT_ID}

gcloud iam service-accounts create ${RUN_DEPLOYER_ID} \
    --description="Deployer service account" \
    --display-name="GH_TEST" \
    --project=${DEPLOYER_PROJECT_ID}

gcloud iam service-accounts add-iam-policy-binding \
    ${RUN_DEPLOYER_EMAIL} \
    --member="user:dpuglielli@flexion.us" \
    --role="roles/iam.serviceAccountUser" \
    --project=${DEPLOYER_PROJECT_ID}

gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/artifactregistry.writer"
# gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/containeranalysis.occurrences.editor"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.developer"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.serviceAgent"
gcloud projects add-iam-policy-binding ${DEPLOYER_PROJECT_ID} --member="serviceAccount:${RUN_DEPLOYER_EMAIL}" --role="roles/run.admin"

gcloud iam service-accounts list --project=${DEPLOYER_PROJECT_ID}

cat > /tmp/policy.yaml << EOM
    globalPolicyEvaluationMode: ENABLE
    defaultAdmissionRule:
      evaluationMode: REQUIRE_ATTESTATION
      enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
      requireAttestationsBy:
        - projects/${ATTESTOR_PROJECT_ID}/attestors/${ATTESTOR_NAME}
    name: projects/${DEPLOYER_PROJECT_ID}/policy
EOM

gcloud --project=${DEPLOYER_PROJECT_ID} \
    container binauthz policy import /tmp/policy.yaml