#FROM apache/airflow:2.10.5
#ADD requirements.txt .
#RUN pip install apache-airflow==${AIRFLOW_VERSION} -r requirements.txt

# Airflow 2.10.5 → Runtime 12.8.0
FROM quay.io/astronomer/astro-runtime:12.8.0

# (opcional) pacotes de SO
USER root
# RUN apt-get update && apt-get install -y build-essential libsasl2-dev && rm -rf /var/lib/apt/lists/*

USER astro
# dependências Python do projeto
COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

# (se necessário) copie DAGs/plugins se não for usar bind mount
# COPY dags/ ${AIRFLOW_HOME}/dags/
# COPY plugins/ ${AIRFLOW_HOME}/plugins/