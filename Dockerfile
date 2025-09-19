FROM quay.io/astronomer/astro-runtime:12.8.0-base
USER root
RUN apt-get update && apt-get install -y build-essential libc6-dev && rm -rf /var/lib/apt/lists/*
USER astro
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt