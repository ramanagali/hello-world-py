#!/bin/sh

kubectl apply -f .rbac1/dev-role.yaml

# create a private key
openssl genrsa -out dev-user.key 2048

#Create a certificate signing request (CSR):
openssl req -new -key dev-user.key -out dev-user.csr -subj "/CN=dev-user/O=dev-group"

# Sign the CSR with the Kubernetes CA:
openssl x509 -req -in dev-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out dev-user.crt -days 365

# Add the user credentials to your kubeconfig file:
kubectl config set-credentials dev-user --client-certificate=dev-user.crt --client-key=dev-user.key

#Create a context for the user limited to the dev namespace:
kubectl config set-context dev-context --cluster=<CLUSTER_NAME> --namespace=dev --user=dev-user

# Use the context:
kubectl config use-context dev-context

kubectl apply -f .rbac1/dev-rolebinding.yaml