#!/bin/sh

kubectl apply -f .rbac1/uat-role.yaml

# create a private key
openssl genrsa -out uat-user.key 2048

#Create a certificate signing request (CSR):
openssl req -new -key uat-user.key -out uat-user.csr -subj "/CN=uat-user/O=uat-group"

# Sign the CSR with the Kubernetes CA:
openssl x509 -req -in uat-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out uat-user.crt -days 365

# Add the user credentials to your kubeconfig file:
kubectl config set-credentials uat-user --client-certificate=uat-user.crt --client-key=uat-user.key

#Create a context for the user limited to the uat namespace:
kubectl config set-context uat-context --cluster=<CLUSTER_NAME> --namespace=uat --user=uat-user

kubectl apply -f .rbac1/rolebinding.yaml

# Use the context:
kubectl config use-context uat-context