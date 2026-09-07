# Deployment Runbook

This is the operational runbook for standing up and running the
`test-civicnet-node-1` node. Follow it top to bottom for a first deploy, or
jump to a section for a specific operation.

<!-- run on GitHub Actions (k8s runner); status shows in the Backstage Actions tab -->

## Prerequisites

- A Linux host with **Docker** and **systemd**.
- Docker image `iotapi322/civicnet` reachable (built via CI or `build.sh`).
- A prepared `civicnet.conf` (see [Configuration](configuration.md)).

## First deploy

```bash
# 1. Vendor upstream source + apply patches (first time, on a build host)
./patch.sh

# 2. Build the image (CI does this on push; here it's manual)
cp civicnet.conf.example /tmp/civicnet.conf      # then edit rpcpassword
./build.sh

# 3. Install the systemd unit + config on the target host
sudo cp deploy-test-civicnet-node-1.service /etc/systemd/system/test-civicnet-node-1.service
sudo mkdir -p /root/.civicnet
sudo cp /tmp/civicnet.conf /root/.civicnet/civicnet.conf
sudo nano /root/.civicnet/civicnet.conf          # set rpcpassword

# 4. Start + enable
sudo systemctl daemon-reload
sudo systemctl enable --now test-civicnet-node-1
```

## Verify it's up

```bash
systemctl status test-civicnet-node-1
docker ps | grep test-civicnet-node-1
# RPC reachable?
curl -s --user civicnet:<pass> \
  --data-binary '{"jsonrpc":"1.0","id":"1","method":"getblockcount","params":[]}' \
  -H 'content-type: text/plain;' http://127.0.0.1:9332/
```

## State & data

- Node state lives in the docker volume **`test-civicnet-node-1-data`**.
- The chain/settings datadir is `/root/.civicnet/` inside the container (from the
  default datadir lookup), backed by that volume.
- **Back up the wallet/keys separately** — the volume holds chain data; treat the
  wallet as precious (see [secrets](#secrets) below).

## Upgrades

The image is tagged with the source commit SHA. To upgrade:

1. Push/pull upstream changes into `src/` (or pass a tag to the CI workflow).
2. CI rebuilds `iotapi322/civicnet:<sha>`.
3. Update the systemd `Image=` line to the new tag, or use a mutable `latest`
   tag pointed at the newest build.
4. `sudo systemctl daemon-reload && sudo systemctl restart test-civicnet-node-1`

## Rollback

```bash
sudo systemctl stop test-civicnet-node-1
# point the unit back at a known-good image tag, then
sudo systemctl start test-civicnet-node-1
```

## Secrets

!!! danger "RPC password"
    The `rpcpassword` in `civicnet.conf` is a live credential. Never commit it.
    If you set it in this repo, rotate it immediately. In this homelab, secrets
    live in **Infisical** (see Backstage secrets docs), not in git.

## Healthy / degraded signals

| Signal | Meaning |
|--------|---------|
| `systemctl is-active` = `active` | service running |
| `getblockcount` responds | RPC up, daemon synced |
| healthcheck.sh exit 0 | container probe OK |
| stale block count vs peers | sync lag (see troubleshooting) |
