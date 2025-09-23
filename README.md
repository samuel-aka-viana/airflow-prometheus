Aqui está a versão reorganizada do seu `README.md`, estruturada em seções lógicas, com comandos e instruções bem agrupados:

````markdown
# Monitoramento de Pipelines do Airflow com Prometheus, StatsD e Grafana

Este projeto configura um ambiente completo para monitoramento de pipelines no Apache Airflow utilizando **Prometheus**, **StatsD** e **Grafana**.  
Com essa configuração, é possível monitorar o desempenho das DAGs e tarefas em tempo real, identificar problemas rapidamente e otimizar fluxos de trabalho de dados.

---

## Estrutura do Projeto

- **/config**: Configurações do Prometheus (`prometheus-config.yml`) e do StatsD Exporter (`statsd_exporter_mapping.yaml`).
- **/dags**: Armazena as DAGs do Airflow.
- **/grafana**: Configurações e dashboards do Grafana, incluindo provisionamento e dashboards customizados.
- **/logs**: Logs gerados pelo Airflow.
- **/plugins**: Plugins customizados do Airflow.
- **docker-compose.yaml**: Configuração do Docker Compose para subir todos os serviços.
- **requirements.txt**: Dependências adicionais para o Airflow.

---

## Pré-requisitos

- **Docker**  
- **Docker Compose**  
- (Para Kubernetes) **kubectl**, **helm** e **gcloud CLI**

---

## Execução Local com Docker Compose

1. Clone o repositório:
   ```bash
   git clone https://github.com/samuel-aka-viana/airflow-prometheus.git
   cd airflow_monitoring
````

2. Suba o ambiente:

   ```bash
   docker-compose up -d
   ```

### Serviços Disponíveis

* **Airflow**: [http://localhost:8080](http://localhost:8080)
* **Grafana**: [http://localhost:23000](http://localhost:23000)
* **Prometheus**: [http://localhost:29090](http://localhost:29090)

---

## Monitoramento das DAGs

* O Prometheus coleta métricas expostas pelo Airflow via StatsD.
* O Grafana exibe essas métricas em dashboards interativos.
* Dashboards padrão já estão configurados no Grafana, incluindo:

  * Status das DAGs
  * Duração das tarefas
  * Erros
  * Uso de recursos

---

## Execução em Minikube

### Inicializar e verificar cluster

```bash
minikube start -p minikube --driver=docker
minikube update-context -p minikube
kubectl config use-context minikube
minikube status -p minikube
kubectl cluster-info
kubectl get nodes
```

### Instalar Airflow com Helm

```bash
helm repo add apache-airflow https://airflow.apache.org
helm repo update
kubectl create ns airflow
```

### Deploy do Airflow

```bash
kubectl create secret generic airflow-postgresql-secret \
  --from-literal=password=airflow \
  --from-literal=postgres-password=airflow \
  -n airflow

helm upgrade --install airflow apache-airflow/airflow \
  -n airflow -f infra/values.yaml
```

### Port-forward para acesso local

```bash
kubectl -n airflow port-forward deployment/airflow-webserver 8080:8080
kubectl -n airflow port-forward svc/prometheus 9090:9090
kubectl -n airflow port-forward svc/grafana 3000:3000
kubectl -n airflow port-forward svc/airflow-statsd 9102:9102
```

---

## Limpeza de Recursos no Minikube

```bash
helm uninstall airflow -n airflow
kubectl delete all --all -n airflow
kubectl delete pvc --all -n airflow
kubectl delete secret --all -n airflow
kubectl delete configmap --all -n airflow
kubectl delete job --all -n airflow
kubectl delete pod --all -n airflow --force --grace-period=0
```

### Forçar remoção de finalizers

```bash
for t in $(kubectl api-resources --verbs=list --namespaced -o name); do
  for r in $(kubectl get -n airflow "$t" -o name 2>/dev/null); do
    kubectl patch -n airflow "$r" -p '{"metadata":{"finalizers":[]}}' --type=merge || true
  done
done
```

---

## Execução em Google Kubernetes Engine (GKE)

### Autenticação e configuração inicial

```bash
gcloud auth login
gcloud components install kubectl
```

### Criar cluster GKE

```bash
gcloud container clusters create airflow-cluster \
  --project=<PROJECT-ID> \
  --zone=<REGION> \
  --machine-type=e2-standard-4 \
  --num-nodes=3 \
  --release-channel=regular

gcloud container clusters get-credentials <CLUSTER-NAME> \
  --project=<PROJECT-ID> \
  --zone=<REGION>
```

---

## Integração com Google Cloud IAM

### Criar Service Account para logging

```bash
gcloud iam service-accounts create airflow-logging \
  --display-name "Airflow Logging"

gcloud projects add-iam-policy-binding SEU_PROJECT_ID \
  --member="serviceAccount:airflow-logging@SEU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectCreator"

kubectl annotate serviceaccount airflow-worker \
  iam.gke.io/gcp-service-account=airflow-logging@SEU_PROJECT_ID.iam.gserviceaccount.com -n airflow
```

### Criar Service Account para monitoring

```bash
gcloud iam service-accounts create airflow-monitoring \
  --display-name="Airflow Monitoring Service Account"

gcloud projects add-iam-policy-binding SEU_PROJECT_ID \
  --member="serviceAccount:airflow-monitoring@SEU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"

gcloud projects add-iam-policy-binding SEU_PROJECT_ID \
  --member="serviceAccount:airflow-monitoring@SEU_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectCreator"
```

### Configurar Workload Identity

```bash
gcloud iam service-accounts add-iam-policy-binding \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:SEU_PROJECT_ID.svc.id.goog[airflow/airflow-worker]" \
  airflow-monitoring@SEU_PROJECT_ID.iam.gserviceaccount.com
```

### Deletar cluster

```bash
gcloud container clusters delete <CLUSTER-NAME> --region=<REGION>
```

---

## Conclusão

Este projeto oferece duas opções de execução:

* Local com Docker Compose, para desenvolvimento rápido.
* Kubernetes (Minikube ou GKE), para cenários de produção e integração com Google Cloud.

Prometheus coleta métricas, StatsD faz a tradução e Grafana exibe dashboards para monitoramento avançado do Airflow.


