# Monitoramento de Pipelines do Airflow com Prometheus, StatsD e Grafana

Este projeto configura um ambiente completo para monitoramento de pipelines no Apache Airflow utilizando **Prometheus**, **StatsD** e **Grafana**. Com essa configuração, você poderá monitorar o desempenho das DAGs e das tarefas em tempo real, identificar problemas rapidamente e otimizar seus fluxos de trabalho de dados.

## Estrutura do Projeto

Abaixo, uma visão geral dos principais diretórios e arquivos:

- **/config**: Contém as configurações do Prometheus (`prometheus-config.yml`) e do StatsD Exporter (`statsd_exporter_mapping.yaml`).
- **/dags**: Diretório para armazenar as DAGs que serão monitoradas no Airflow.
- **/grafana**: Contém configurações e dashboards do Grafana, incluindo provisionamento e dashboards personalizados.
- **/logs**: Armazena os logs gerados pelo Airflow.
- **/plugins**: Diretório para plugins customizados do Airflow, se necessário.
- **docker-compose.yaml**: Arquivo de configuração do Docker Compose para subir todos os serviços de uma vez.
- **requirements.txt**: Dependências adicionais para o Airflow.

## Pré-requisitos

Certifique-se de ter o **Docker** e o **Docker Compose** instalados em seu ambiente.

## Configuração e Execução

1. Clone o repositório:
```bash
   git clone https://github.com/samuel-aka-viana/airflow-prometheus.git
   cd airflow_monitoring
```
2. Suba o ambiente com Docker Compose:
```bash
   docker-compose up -d
```

## Esse comando irá iniciar os seguintes serviços:

* Airflow: Inclui o Web Server, Scheduler, Worker e Triggerer.
* Prometheus: Coleta as métricas do Airflow via StatsD.
* Grafana: Conecta-se ao Prometheus para visualização de métricas.
* StatsD Exporter: Traduz as métricas do StatsD para o formato Prometheus.

## Acessando os Serviços

* Airflow: Acesse http://localhost:8080
* Grafana: Acesse http://localhost:23000 
* Prometheus: Acesse http://localhost:29090/
## Monitoramento das DAGs

Assim que as DAGs estiverem em execução, o Prometheus coletará as métricas e o Grafana exibirá essas informações em dashboards interativos. Dois dashboards padrão do Airflow já estão configurados no Grafana, oferecendo uma visão detalhada do status das DAGs, duração das tarefas, erros e uso de recursos.


minikube start -p minikube --driver=docker
minikube update-context -p minikube
kubectl config use-context minikube

minikube status -p minikube
kubectl cluster-info
kubectl get nodes


# Delete the Helm release
helm uninstall airflow -n airflow

# Wait a moment, then delete any remaining resources
kubectl delete all --all -n airflow

# Delete any persistent volume claims (this will delete your data!)
kubectl delete pvc --all -n airflow

# Delete any remaining secrets and configmaps
kubectl delete secret --all -n airflow
kubectl delete configmap --all -n airflow

# Delete any jobs that might be stuck
kubectl delete job --all -n airflow

# If there are any stuck finalizers, you can force delete pods
kubectl delete pod --all -n airflow --force --grace-period=0


# force finalize
for t in $(kubectl api-resources --verbs=list --namespaced -o name); do
  for r in $(kubectl get -n airflow "$t" -o name 2>/dev/null); do
    kubectl patch -n airflow "$r" -p '{"metadata":{"finalizers":[]}}' --type=merge || true
  done
done


kubeclt create ns airflow


helm uninstall airflow -n airflow

kubectl create secret generic airflow-postgresql-secret \
  --from-literal=password=airflow \
  --from-literal=postgres-password=airflow \
  -n airflow


helm upgrade --install airflow apache-airflow/airflow -n airflow -f infra/values.yaml
