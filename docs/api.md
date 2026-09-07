# API & Monitoring

The node exposes a **JSON-RPC** interface (like Bitcoin Core) and additional
**monitoring** surface. This page documents both.

## JSON-RPC

The JSON-RPC server listens on port **`9332`** with user
`civicnet`. Requests are HTTP POSTs with basic auth.

!!! example "Common calls"

    **Block count (is it synced?)**
    ```bash
    curl -s --user civicnet:PASS \
      --data-binary '{"jsonrpc":"1.0","id":"1","method":"getblockcount","params":[]}' \
      -H 'content-type: text/plain;' http://127.0.0.1:9332/
    ```

    **Network info (peers / connections)**
    ```bash
    curl -s --user civicnet:PASS \
      --data-binary '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' \
      -H 'content-type: text/plain;' http://127.0.0.1:9332/
    ```

    **Staking info (worth it if you enabled PoS)**
    ```bash
    curl -s --user civicnet:PASS \
      --data-binary '{"jsonrpc":"1.0","id":"1","method":"getstakinginfo","params":[]}' \
      -H 'content-type: text/plain;' http://127.0.0.1:9332/
    ```

The RPC interface is registered in Backstage as this entity's **API
definition** — see the catalog. In the graph view you can trace
`test-civicnet-node-1` → its system → its API.

## ZeroMQ (optional)

When ZMQ is enabled, the node publishes block/tx events on ports
**28332–28335** (hashblock / hashtx / rawblock / rawtx). This is what a pool or
analytics pipeline consumes.

```
tcp://<node>:28332  hashblock, hashtx, rawblock, rawtx
```

## Health check

The repo ships `healthcheck.sh`, used as the container healthcheck. It probes the
daemon and exits 0 when healthy. The systemd unit + Docker healthcheck surface
this to the platform.

## Metrics / observability

- **Run:** `systemctl status` + container `docker inspect` health status.
- **RPC:** `getnetworkinfo` / `getblockcount` for liveness and sync.
- Cross-check block height against network explorers for sync health.

!!! note
    In this homelab, broader metrics/telemetry (pool stratum events, hits on
    scanners/bans) are surfaced through the **Miningcore/stratum** tooling and
    Grafana, which Backstage's dashboard plugin can embed per-entity if wired.
