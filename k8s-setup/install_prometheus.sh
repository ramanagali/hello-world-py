#3.install prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update

#create ns for prometheus
kubectl create ns prometheus

#prometheus helm chart default values
#helm show values prometheus-community/kube-prometheus-stack > prom_values.yaml

# prometheus operator with service monitor 
helm upgrade -i prometheus prometheus-community/kube-prometheus-stack \
    --namespace prometheus \
    --set prometheus.service.type=NodePort \
    --set ingress.enabled=true \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.release="prometheus" \
    --set alertmanager.enabled=false \
    --set kubeProxy.enabled=false \
    --set grafana.enabled=true \
    --set grafana.service.type=NodePort \
    --set kubeControllerManager.enabled=false \
    --set kubeEtcd.enabled=false \
    --set kubeScheduler.enabled=false 

echo "*** Prometheus Operator Installed ****"
echo "Prometheus Operator Documentation: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack"