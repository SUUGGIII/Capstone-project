#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="."
LIVEKIT_VERSION="1.9.1"
VM_IP="$(hostname -I | awk '{print $1}')"

echo "==> Create ${SERVER_DIR}/"
mkdir -p "${SERVER_DIR}"

# Dockerfile
cat > "${SERVER_DIR}/Dockerfile" <<DOCKER
FROM livekit/livekit-server:${LIVEKIT_VERSION}
COPY livekit.yaml /etc/livekit/livekit.yaml
CMD ["--config", "/etc/livekit/livekit.yaml"]
DOCKER

# docker-compose.yml
cat > "${SERVER_DIR}/docker-compose.yml" <<'COMPOSE'
version: "3.9"
services:
  livekit:
    build: .
    container_name: livekit-server
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "7880:7880/tcp"                # HTTP/WS
      - "7881:7881/tcp"                # RTC TCP
      - "50000-60000:50000-60000/udp"  # RTP/ICE UDP
    volumes:
      - livekit_data:/var/lib/livekit
volumes:
  livekit_data:
COMPOSE

# livekit.yaml
cat > "${SERVER_DIR}/livekit.yaml" <<YAML
port: 7880
rtc:
  portTCP: 7881
  portRangeStart: 50000
  portRangeEnd: 60000
  externalIP: "${VM_IP}"

keys:
  - key: \${LIVEKIT_API_KEY}
    secret: \${LIVEKIT_API_SECRET}

logging:
  level: info
YAML

# .env 템플릿
cat > "${SERVER_DIR}/.env.example" <<'ENV'
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=devsecret
ENV

# .gitignore에 민감정보 제외
grep -qxF "server/.env" .gitignore 2>/dev/null || echo "server/.env" >> .gitignore

echo "==> Done. Edit server/livekit.yaml (externalIP) if needed."
echo "   VM_IP detected: ${VM_IP}"


