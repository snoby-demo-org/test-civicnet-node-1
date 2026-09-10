# test-civicnet-node-1

!!! abstract "What this is"
    CivicNet node scaffolded from Backstage template — fully documented showcase

    A **CivicNet (CIVIC)** full node — a hybrid **Proof-of-Work + Proof-of-Stake** blockchain node with a 60-second target block time and a 30% PoS ceiling. This repository vendors the upstream CivicNet source code, applies local patches, builds a Docker image, and deploys it as a systemd unit.

<!-- status badges: rendered by the GitHub Actions + GitHub Insights plugins in Backstage -->

## Quick facts

| | |
|---|---|
| Network | CivicNet (CIVIC) |
| Consensus | Hybrid PoW + PoS (60s target, PoS ceiling 30%) |
| Component | `test-civicnet-node-1` |
| System | `civicnet-system` |
| Owner | `guest` |
| Repository | [`https://github.com/snoby-demo-org/test-civicnet-node-1`](https://github.com/snoby-demo-org/test-civicnet-node-1) |
| RPC | port `9332` |
| P2P | port `9333` |
| Lifecycle | Experimental |

## What's in this documentation

This documentation is authored as **markdown in the repository** and rendered by
**Backstage TechDocs**. It is built and published automatically by CI on every
change to `main` — there is no separate documentation source to maintain.

- **[Architecture](architecture.md)** — how the node works under the hood
- **[Deployment runbook](deployment.md)** — from zero to a running node
- **[Configuration](configuration.md)** — every config option explained
- **[API & monitoring](api.md)** — RPC endpoints, health checks, metrics
- **[Troubleshooting](troubleshooting.md)** — how to recover from common issues

!!! tip "In Backstage"
    This entity is registered in the Backstage **software catalog**. Use the
    **GitHub Actions** tab to see CI status, the **GitHub Insights** tab for repo
    metrics, and the **graph** view to see how this node relates to its system and
    API.
