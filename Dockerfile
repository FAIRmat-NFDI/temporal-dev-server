FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV TEMPORAL_CLI_VERSION=1.3.0
ENV DB_FILE=/data/temporal_file.db
ENV UI_PORT=8080

# Download and install Temporal CLI
RUN curl -L https://github.com/temporalio/cli/releases/download/v{$TEMPORAL_CLI_VERSION}/temporal_cli_{$TEMPORAL_CLI_VERSION}_linux_amd64.tar.gz \
    -o /tmp/temporal.tar.gz && \
    tar -xzf /tmp/temporal.tar.gz -C /usr/local/bin && \
    rm /tmp/temporal.tar.gz

# Create directory for DB (to support volumes)
RUN mkdir -p /data

# Expose Temporal gRPC port and UI port
EXPOSE 7233
EXPOSE ${UI_PORT}

# Add entrypoint script using EOF syntax
RUN cat << 'EOF' > /entrypoint.sh
#!/bin/sh
set -e

# Start Temporal dev server with DB and custom UI port
temporal server start-dev --ip 0.0.0.0 --db-filename ${DB_FILE} --ui-port ${UI_PORT} &

# Keep container alive with server process
wait
EOF

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
