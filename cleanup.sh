#!/bin/sh
. ./vars.sh

gcloud run services delete ${SERVICE_NAME} --quiet --project=${DEPLOYER_PROJECT_ID}

gcloud container images delete ${CONTAINER_PATH} --force-delete-tags --quiet --project=${DEPLOYER_PROJECT_ID}

ATTESTATIONS=`gcloud --project=${ATTESTOR_PROJECT_ID} \
    container binauthz attestations list \
    --attestor=$ATTESTOR_NAME --attestor-project=$ATTESTOR_PROJECT_ID | egrep "^name\: " | awk '{print $2}'`

for occurence in $ATTESTATIONS; do
echo "Deleting attestation $occurence"
curl "https://containeranalysis.googleapis.com/v1/$occurence" \
  --request DELETE \
  --header "Content-Type: application/json"  \
  --header "Authorization: Bearer $(gcloud auth print-access-token)"
done

#cat > /tmp/policy.yaml << EOM
#defaultAdmissionRule:
#  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
#  evaluationMode: ALWAYS_ALLOW
#globalPolicyEvaluationMode: ENABLE
#name: projects/${DEPLOYER_PROJECT_ID}/policy
#EOM

#gcloud --project=${DEPLOYER_PROJECT_ID} \
#    container binauthz policy import /tmp/policy.yaml