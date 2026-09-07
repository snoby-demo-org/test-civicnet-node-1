# Troubleshooting

A recovery-oriented runbook for the `test-civicnet-node-1` node. Start with
**Is it up?**, then follow the table.

!!! warning "Rule of thumb"
    The daemon reads config only from `~/.civicnet/civicnet.conf` (mounted
    read-only). If a change "isn't taking," you edited the wrong file, or didn't
    restart the unit.

## Is it up?

```bash
systemctl is-active test-civicnet-node-1          # expect: active
docker ps | grep test-civicnet-node-1             # expect: Up
systemctl status test-civicnet-node-1             # logs + exit info
```

## Common failure modes

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `systemctl` shows `failed` | daemon crashed on boot | `journalctl -u test-civicnet-node-1 -n 50`; check config syntax |
| Container exits immediately | missing/empty `civicnet.conf` | ensure `/root/.civicnet/civicnet.conf` exists on host |
| `getblockcount` errors | RPC not up / wrong port | confirm `9332`, `server=1`, correct creds |
| Block height stuck | sync lag / poor peers | check `getnetworkinfo`; raise `maxconnections` (already 32 via patch) |
| `rpcpassword` rejected | credential mismatch | reset on host, restart unit |
| Staking not minting | `staking=0` or small UTXO | enable staking + check `getstakinginfo` |
| Read-only config "ignored" | edited inside container | edit host file, `systemctl restart` |

## Diagnose the daemon

```bash
# live logs
journalctl -u test-civicnet-node-1 -f

# last crash
journalctl -u test-civicnet-node-1 -n 100

# process inside container
docker exec -it <container> sh
```

## Recovery steps

**Recreate the volume from scratch** (loses chain state, not the config):

```bash
sudo systemctl stop test-civicnet-node-1
docker volume rm test-civicnet-node-1-data   # CAUTION: wipes chain data
sudo systemctl start test-civicnet-node-1
```

**Force re-sync** if the chain is corrupt/stuck:

1. Stop the node.
2. Move (don't delete) the datadir: `sudo mv /var/lib/docker/volumes/test-civicnet-node-1-data /tmp/...`
3. Start fresh — the node re-syncs from peers.

## Escalation

- Check the **GitHub Actions** tab for build/CI failures on the image.
- Check **GitHub Insights** for contributor/language context if the source
  changed unexpectedly.
- Reference the [Architecture](architecture.md) and [Deployment](deployment.md)
  pages for the full picture.

!!! tip
    These runbooks are part of this entity's **TechDocs** — they are
    searchable across all entities in Backstage, so the next operator (or you, in
    six months) can find "how do I recover a stuck CivicNet node" without being
    shown which repo owns it.
