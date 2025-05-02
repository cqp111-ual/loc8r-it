FROM python:3.11-slim

WORKDIR /app

# Copy source code
COPY ./app/update-dns.py .
COPY ./app/requirements.txt .
COPY ./docker/scripts/crontab.tpl .

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends cron curl dnsutils && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /var/lib/apt/lists/*

# Create log file
RUN mkdir -p /var/log/cron
RUN touch /var/log/cron/update.log

# Add entrypoint
COPY ./docker/scripts/entrypoint.sh .
RUN chmod +x entrypoint.sh

ENV UPDATE_FREQ=5

ENTRYPOINT ["/app/entrypoint.sh"]
