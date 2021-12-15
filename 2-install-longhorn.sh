#!/bin/bash

export KUBECONFIG=kubeconfig

helm repo add longhorn https://charts.longhorn.io
#helm repo update

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace

# wait until ready
kubectl rollout status deployment longhorn-driver-deployer -n longhorn-system --timeout=100s
# We need to wait for some secounds until the driver-deployer starting creating the deployments
# No alternative to sleep
echo "Waiting for longhorn-driver-deployer to start deployment"
sleep 10
kubectl wait --for=condition=available --timeout=60s --all deployments -n longhorn-system

echo "Longhorn installed!"