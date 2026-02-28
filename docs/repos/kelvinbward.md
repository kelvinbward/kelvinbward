# Professional Hub: `kelvinbward`

**Ecosystem Role**: Hub / Operations Center
**Target Domain**: [kelvinbward.com](https://kelvinbward.com)

## Overview
The `kelvinbward` repository serves two critical functions in the Federated Hub-and-Spoke architecture:
1. **The Professional Portfolio**: It hosts the distribution files (in `public/`) comprising the statically deployed professional portfolio, resume application, and case studies routed out through GitHub pages.
2. **The Operations Library**: It acts as the backbone for ecosystem CI/CD. The `.github/` directory here houses the reusable Golden Path workflows (e.g., `standard-static-deploy.yml`) consumed by every other repository in the ecosystem. Additionally, it hosts the ecosystem CLI tooling (`/cli`) written in Go.

## Relationships
- **Provides**: Reusable GitHub Action workflows to all Spokes and Hubs.
- **Provides**: The `kelvin-cli` ecosystem orchestrator binary.
- **Consumes**: Pre-built artifacts "pushed" to `/public/` by professional Spokes (like `resume` and `middleware`).

## Working in this Repo
Because this repository holds the public output, developers **must not manually modify** the contents of the `/public/` directory nested under Spoke subdirectories. Those modifications must happen within the respective Spoke (`resume`, `middleware`, etc.) which will then execute a Spoke-to-Hub pull request via automation.

Modifications strictly to the top-level portfolio domain or the Go orchestration tools (`kelvin-cli`) happen natively here.
