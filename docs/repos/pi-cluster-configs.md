# The Engine: `pi-cluster-configs`

**Ecosystem Role**: Internal State Machine / Orchestrator Target
**Deployment Model**: Docker Compose (Local / Private Intranet)

## Overview
While the Hubs (`kelvinbward`, `goobface`) manage the public, static distribution on GitHub Pages, the `pi-cluster-configs` repository serves as the private Engine. It is the definitive source of truth regarding state, dynamic container orchestration, and secret management across the ecosystem.

## Core Responsibilities
1. **App Registry (`apps.config`)**: A centralized ledger explicitly mapping application identifiers to their repository origins and expected execution modes (Cluster or GitOps).
2. **Secret Centralization**: The `.env.template` houses all the required permutations of environment configurations. No actual `.env` files with sensitive data are committed.
3. **Gateway Subsystem**: It configures and spins up the Nginx Proxy Manager (`gateway`) to reverse proxy dynamic Cluster applications on the host's port 80/443 mapping to internal Docker IPs.
4. **Data Persistence**: Configures PostgreSQL (`core-services`) and exposes valid connections via internal networks.
5. **Tooling Target**: This is the environment the `kelvin-cli infra init` and `infra clean` commands target to dynamically bootstrap the workspace scaffolding, docker-compose generation, and execution.

## The CLI Relationship
Rather than relying on brittle bash scripts, the local ecosystem relies on `kelvin-cli` (hosted in the `kelvinbward` repo). Running `./kelvin-cli infra init --setup` uses Go to evaluate the `pi-cluster-configs` structure, trigger the templates, and launch the dynamic Docker environment bridging the gaps between your independent Spoke repositories.
