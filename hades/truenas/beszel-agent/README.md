# Beszel Agent for TrueNAS

Beszel monitoring agent for TrueNAS SCALE.

## Prerequisites

- SSH access to TrueNAS via Hades jump proxy
- Beszel hub running and configured
- `secrets/beszel.env` with `BESZEL_KEY` from the Beszel hub

## Setup

1. First, deploy the Beszel hub in the Sirius cluster
2. Add TrueNAS as a system in the Beszel web UI
3. Ensure `secrets/beszel.env` has the correct key
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

## Network

Uses SSH jump proxy through Hades (`hadests`) to reach TrueNAS at 192.168.1.10.

## Note

TrueNAS has no internet access, so this deployment downloads the binary locally
and copies it to TrueNAS (instead of using Docker). The agent runs as a background
process via nohup.
