# 1. Federated Hub-and-Spoke Architecture

Date: 2026-02-01

## Status

Accepted

## Context

The ecosystem previously struggled with a monolithic identity. We had "public" apps like `resume` and "private" experiments like `creativeAudioJS` mixed with infrastructure configuration.

We needed a way to:
1.  Standardize CI/CD across all projects ("Golden Path").
2.  Prevent manual drift in public distribution paths (`/public/`).
3.  Clear separation of concerns between Infrastructure (Engine), Distribution (Hub), and Logic (Spokes).

## Decision

We have adopted a **Federated Hub-and-Spoke** model.

### 1. The Hub (`kelvinbward`)
- **Role**: The public face and distribution center.
- **Responsibility**: Hosts the landing page and aggregates built assets from Spokes.
- **Governance**: Contains the "Golden Path" reusable workflows (`.github/workflows/standard-static-deploy.yml`).

### 2. The Engine (`pi-cluster-configs`)
- **Role**: The internal state machine.
- **Responsibility**: Manages the `apps.config` registry, valid ports, and Docker orchestration (`setup.sh`).
- **Secret Management**: All secrets and environment variables originate here.

### 3. The Spokes (`resume`, `goobface`, etc.)
- **Role**: Autonomous application domains.
- **Responsibility**: Contain business logic and source code.
- **Deployment**: They build themselves using the Hub's standard workflow and "push" artifacts to the Hub's `/public/` directory via Pull Request.

## Consequences

### Positive
- **Modularity**: Spokes can be developed in isolation (Standalone Mode).
- **Security**: Visual inspection of "What is public?" is trivial (everything in `kelvinbward/public`).
- **Consistency**: All static sites use the exact same build-and-deploy logic.

### Negative
- **Complexity**: Requires a rigorous "Registry Sync" process (`sync_registry.sh`) to ensure documentation matches reality.
- **Workflow**: Developers cannot simply "push to deploy"; they must follow the PR flow to update the Hub.
