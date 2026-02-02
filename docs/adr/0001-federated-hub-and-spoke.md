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

### 1. The Ops Library (`kelvinbward/.github`)
- **Role**: Central CI/CD workflow provider.
- **Responsibility**: Hosts reusable workflows (`.github/workflows/standard-static-deploy.yml`).
- **Consumers**: ALL hubs and spokes reference these workflows.

### 2. The Hubs (Content & Distribution)
We distinct between two primary Hubs:
*   **Professional Hub (`kelvinbward`)**:
    *   **Domain**: `kelvinbward.com`
    *   **Role**: Professional portfolio, resume, and case studies.
*   **Personal Hub (`goobface`)**:
    *   **Domain**: `goobface.com`
    *   **Role**: Creative sandbox, game platform, and personal blog.

Both Hubs consume the same reusable workflows but serve different audiences.

### 3. The Engine (`pi-cluster-configs`)
- **Role**: The internal state machine.
- **Responsibility**: Manages the `apps.config` registry, valid ports, and Docker orchestration (`setup.sh`).
- **Secret Management**: All secrets and environment variables originate here.

### 4. The Spokes
- **Role**: Autonomous application domains.
- **Responsibility**: Contain business logic and source code.
- **Deployment**: They build themselves using the Hub's standard workflow and "push" artifacts to the **target Hub** (`kelvinbward` OR `goobface`) via Pull Request.

## Consequences

### Positive
- **Modularity**: Spokes can be developed in isolation (Standalone Mode).
- **Security**: Visual inspection of "What is public?" is trivial (everything in `kelvinbward/public`).
- **Consistency**: All static sites use the exact same build-and-deploy logic.

### Negative
- **Complexity**: Requires a rigorous "Registry Sync" process (`sync_registry.sh`) to ensure documentation matches reality.
- **Workflow**: Developers cannot simply "push to deploy"; they must follow the PR flow to update the Hub.
