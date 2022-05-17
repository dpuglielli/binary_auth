#!/bin/sh
. ./SA-vars.sh

# create artifact repository
gcloud artifacts repositories create ${CONTAINER_DIR} \
    --repository-format=Docker \
    --location=${LOCATION} \
    --description="deploy containers" \
    --project=${DEPLOYER_PROJECT_ID}

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