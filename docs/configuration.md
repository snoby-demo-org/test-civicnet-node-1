# Configuration

All configuration happens in the **`civicnet.conf`** file, mounted read-only into
the container at `/root/.civicnet/civicnet.conf`. The daemon reads this from its
default datadir — no CLI flags needed.

A template ships as `civicnet.conf.example` in this repo.

## Reference

| Setting | Default / value | Purpose |
|---------|-----------------|---------|
| `rpcuser` | `civicnet` | Username for JSON-RPC auth |
| `rpcpassword` | *(secret)* | Password for JSON-RPC auth — keep in Infisical |
| `rpcport` | `9332` | TCP port for JSON-RPC |
| `port` | `9333` | TCP port for P2P peer connections |
| `daemon` | `1` | Run as a background daemon |
| `server` | `1` | Enable the JSON-RPC server |
| `listen` | `1` | Accept incoming P2P connections |
| `maxconnections` | *(patched: 32)* | Max peers (raised via `patches/0001-*.patch`) |
| `staking` | `0`/`1` | Enable/disable **Proof-of-Stake** minting |

!!! tip "Showcasing the config surface"
    This table is one of the ways Backstage TechDocs makes operational config
    discoverable — searchable, versioned with the repo, and right next to the
    entity that owns it.

## Defaults baked in by this repo

- **RPC user:** `civicnet`
- **RPC port:** `9332`
- **P2P port:** `9333`
- **Outbound connections:** raised to 32 (see `patches/0001-outbound-connections-32.patch`)

## Setting the RPC password

Because the password is mounted via the config file, set it once on the host:

```bash
sudo nano /root/.civicnet/civicnet.conf
# rpcpassword=<a-long-random-string>
sudo systemctl restart test-civicnet-node-1
```

## Enabling staking (PoS)

To allow this node to mint via Proof-of-Stake at the 30% PoS ceiling:

1. Set `staking=1` in `civicnet.conf`.
2. Ensure the wallet has a UTXO large enough to be competitive (PoS win is
   `hash(kernel) < target * sqrt(UTXO)`).
3. Restart the node and confirm the wallet is unlocked/loaded.

!!! warning
    Only enable staking if this node holds the staking wallet and you want it to
    participate in block production. For a pool/archive node, leave `staking=0`.

## Mounting read-only

The host config is mounted **read-only** into the container. To change it, edit
the host file and restart the unit — never edit inside the container.
