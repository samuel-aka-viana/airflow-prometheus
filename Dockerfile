FROM quay.io/astronomer/astro-runtime:12.10.0

USER astro
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
