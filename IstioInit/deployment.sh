#!/bin/bash

# Install istioctl
curl -L https://istio.io/downloadIstioctl | sh -
sudo mv ~/.istioctl/bin/istioctl /usr/local/bin/

# Set up Istio on the Kubernetes cluster
istioctl install --set profile=demo

# Verify Istio installation
istioctl verify-install

# Install control plane supporting components (grafana, kiali, prometheus, jaeger)
# Files under the istioctl directory
kubectl apply -f ./samples/addons

# Create the namespace for the application
kubectl create namespace istioinaction
kubectl config set-context $(kubectl config current-context) \
 --namespace=istioinaction

