#!/bin/bash

kind load docker-image docker.io/library/cert-checker:latest --name single-node-cluster

kubectl apply -f ./app-deployment.yaml

status_code=$?

if [ $status_code -ne 0 ]; then 
    echo "Something went wrong...Well..what can you do "
    exit status_code
fi

echo "Container deployed successfully..."

pod_name=$(kubectl get pods --no-headers | awk '{print $1}')

## give time for the container to complete
sleep 5

echo "Fetching logs from the pod..."

kubectl logs $pod_name


