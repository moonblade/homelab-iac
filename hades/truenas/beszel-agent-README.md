# Beszel Agent for TrueNAS

Manual installation guide for Beszel agent on TrueNAS SCALE.

## Prerequisites

- TrueNAS SCALE with Apps enabled
- SSH access to TrueNAS (or shell access via web UI)
- Beszel hub running and the system added
- Beszel public key from the hub (get from Add System dialog)

## Option 1: Docker Compose (Recommended)

1. SSH into TrueNAS or use the web shell
2. Create the directory and docker-compose file:

```bash
mkdir -p /mnt/primary/root/config/beszel-agent
cd /mnt/primary/root/config/beszel-agent

# Replace YOUR_BESZEL_KEY with the key from Beszel hub
cat > docker-compose.yml << 'EOF'
services:
  beszel-agent:
    image: henrygd/beszel-agent:0.18.7
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      PORT: 45876
      KEY: "${BESZEL_KEY}"
    env_file:
      - beszel.env
EOF

# Create env file with your key
echo 'BESZEL_KEY=ssh-ed25519 YOUR_KEY_HERE' > beszel.env
```

3. Start the agent:
```bash
docker compose up -d
```

4. Verify it's running:
```bash
docker ps | grep beszel
docker logs beszel-agent
```

## Option 2: TrueNAS Custom App

1. Go to Apps → Discover Apps → Custom App
2. Configure with:
   - Application Name: `beszel-agent`
   - Image Repository: `henrygd/beszel-agent`
   - Image Tag: `0.18.7`
   - Network Mode: Host
   - Environment Variables:
     - `PORT`: `45876`
     - `KEY`: (your Beszel public key from hub)

## Beszel Hub Configuration

Add TrueNAS in the Beszel web UI:
- **Name**: TrueNAS
- **Host**: `192.168.1.10` (or Tailscale IP if available)
- **Port**: `45876`

## Firewall

TrueNAS should allow port 45876 by default with host networking.
If not connecting, check:
```bash
ss -tlnp | grep 45876
```
