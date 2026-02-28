# Spoke: `middleware`

**Ecosystem Role**: Logic Layer / Internal API
**Assigned Hub**: Professional (`kelvinbward`)
**Execution Mode**: Cluster (Internal Network)

## Overview
The `middleware` repository acts as a standard logic Spoke in the federated ecosystem. Built heavily to support dynamic features of professional-tier applications, this repository isolates sensitive API endpoints, bridging applications like the `resume` database layer.

## Architectural Flow
As a "Cluster" categorized application, `middleware` is designed to be dynamically hosted inside the private Intranet bootstrapped by `kelvin-cli infra init --setup`. 
1. `middleware` executes natively on the host port `5000/8000`.
2. The Engine's gateway reverse proxy acts as the interface bridging public API calls from statically deployed Hub platforms down into this private tier.
3. Code changes merged to `main` trigger Docker image recreations or static artifact pipelines configured universally by the core Ops library in `kelvinbward/.github`.
