#!/bin/bash
source ./vars.sh

gcloud run services delete ${SERVICE_NAME} --quiet --project=${DEPLOYER_PROJECT_ID}

gcloud container images delete ${CONTAINER_PATH} --force-delete-tags --quiet --project=${DEPLOYER_PROJECT_ID}

cat > /tmp/policy.yaml << EOM
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_ALLOW
globalPolicyEvaluationMode: ENABLE
name: projects/${DEPLOYER_PROJECT_ID}/policy
EOM

gcloud --project=${DEPLOYER_PROJECT_ID} \
    container binauthz policy import /tmp/policy.yaml