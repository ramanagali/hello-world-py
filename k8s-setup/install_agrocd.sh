#!/bin/sh

# # install agro CD usinig helm
ARGOCD_CHART_VERSION = ""
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo-cd/argo-cd --version "${ARGOCD_CHART_VERSION}" \
  --namespace "argocd" --create-namespace \
  --values ./argocd/values.yaml \
  --wait

#To get the URL from Argo CD service
export ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname')
echo "ArgoCD URL: https://$ARGOCD_SERVER"

curl --head -X GET --retry 20 --retry-all-errors --retry-delay 15 --connect-timeout 5 --max-time 10 -k https://$ARGOCD_SERVER

# get the agrocd username and password
export ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PWD"

# link the application
kubectl apply /agrocd/link-github.yaml

# agrocd cli install
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# login agrocd
argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PWD --insecure

GITOPS_REPO_URL_ARGOCD="https://github.com/ramanagali/hello-world-py.git"

# Create an Argo CD secret to give access to the Git repository from Argo CD
argocd repo add $GITOPS_REPO_URL_ARGOCD --ssh-private-key-path ${HOME}/.ssh/gitops_ssh.pem --insecure-ignore-host-key --upsert --name git-repo


argocd app create apps --repo $GITOPS_REPO_URL_ARGOCD \
  --path apps --dest-server https://kubernetes.default.svc


argocd app list

kubectl get applications.argoproj.io -n argocd