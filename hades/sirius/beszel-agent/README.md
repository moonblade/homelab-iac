# Beszel Agent for Sirius

Beszel monitoring agent for the Sirius k3s VM.

## Prerequisites

- SSH access to `sirius` (Tailscale)
- Beszel hub running and configured
- `secrets/beszel.env` with `BESZEL_KEY` from the Beszel hub

## Setup

1. First, deploy the Beszel hub in the Sirius cluster
2. Add Sirius as a system in the Beszel web UI
3. Copy the generated public key to `secrets/beszel.env`:
   ```
   BESZEL_KEY=ssh-ed25519 AAAA...
   ```
4. Deploy the agent:
   ```bash
   make deploy
   ```

## Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy/update the agent |
| `make status` | Check if agent is running |
| `make logs` | View agent logs |
| `make restart` | Restart the agent |
| `make down` | Stop the agent |
