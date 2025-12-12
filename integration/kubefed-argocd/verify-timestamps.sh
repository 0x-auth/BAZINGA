#!/bin/bash
# Verify deployment timestamps for KubeFed to ArgoCD migration

# Vault Monitoring
echo "Checking federated-vault-monitoring timestamps..."
kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > vault-before.txt
echo "Timestamps saved to vault-before.txt"

# Prisma Operator
echo "Checking federated-prisma-operator timestamps..."
kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > prisma-before.txt
echo "Timestamps saved to prisma-before.txt"

echo "After running Spinnaker pipelines, run this again with the 'after' argument to verify timestamps weren't changed."
echo "Example: ./verify-timestamps.sh after"

if [ "$1" == "after" ]; then
  # Get after timestamps
  kubectl get deployment -n federated-vault-monitoring-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > vault-after.txt
  kubectl get deployment -n federated-prisma-operator-system -o jsonpath="{.items[?(@.metadata.name=~'.*')].metadata.creationTimestamp}" > prisma-after.txt
  
  # Compare
  echo "Comparing vault timestamps..."
  diff vault-before.txt vault-after.txt
  
  echo "Comparing prisma timestamps..."
  diff prisma-before.txt prisma-after.txt
  
  if [ $? -eq 0 ]; then
    echo "Success! Timestamps match, resources were not recreated."
  else
    echo "Warning! Timestamps changed, resources were recreated."
  fi
fi
