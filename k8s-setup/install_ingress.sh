#!/bin/sh

# install an ingress controller like NGINX using Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace #--wait --debug

# cert-manager to automatically issue and manage Let's Encrypt certificates for your domain
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.yaml

# Manually Add a TLS Certificate and key, create a Kubernetes Secret:
kubectl create secret tls tls-secret --key <your-domain-key>.key --cert <your-domain-cert>.crt

# create ingres resource
kubectl apply -f ../k8s/ingress.yaml


# testing
#for i in $(seq 1 10); do curl -s --resolve my-app.local:$INGRESS_CONTROLLER_PORT:$INGRESS_CONTROLLER_IP my-app.local  | grep "Hostname"; done
