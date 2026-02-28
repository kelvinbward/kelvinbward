# Kelvin Ecosystem Architecture

Welcome to the documentation index for the Kelvin Ecosystem. This repository structure is designed using a **Federated Hub-and-Spoke** architecture to maintain a strong separation of concerns across infrastructure, logical applications, and creative sandboxes. We use this system to keep our production hubs stable and our autonomous spokes modular.

## Core Concepts

The ecosystem is divided into three fundamental categories of repositories:

1.  **The Engine**: The central source of truth for configuration, secret management, Docker orchestration, and ecosystem lifecycle CLI tools.
2.  **The Hubs**: Aggregation endpoints that consume content and applications to present to the public via specific domains (e.g., `kelvinbward.com`, `goobface.com`).
3.  **The Spokes**: Autonomous application domains that contain specific business logic, built in isolation, and "pushed" to their respective Hubs.

---

## Repository Index

### The Engine
*   [**pi-cluster-configs**](repos/pi-cluster-configs.md): The internal state machine, orchestration configs, and `kelvin-cli` target environment.

### The Hubs
*   [**kelvinbward**](repos/kelvinbward.md): The Professional Hub (`kelvinbward.com`). Houses the core identity, professional portfolio, and operations library.
*   [**goobface**](repos/goobface.md): The Personal Hub (`goobface.com`). A sandbox for games, experimental web applications, and blogging.

### The Spokes
*   [**resume**](repos/resume.md): A full-stack data-driven resume application deployed via GitOps.
*   [**middleware**](repos/middleware.md): Logic layer API supporting professional hub services.
*   [**creativeAudioJS**](repos/creativeAudioJS.md): An experimental Tone.js sandbox app.
*   [**3D-Printing**](repos/3D-Printing.md): An Astro-based documentation resource and blog.
*   [**clipboard-spoke**](repos/clipboard-spoke.md): A discrete feature application.

---

## Tooling: `kelvin-cli`
To interact with the multi-repository workspace seamlessly, we utilize a unified compiled Go binary (`kelvin-cli`) stored in `kelvinbward/cli`. It allows safe initialization of the cluster, automated repository syncing, and destructive safe-state recovery natively.

For a deeper dive into the architectural reasoning, review the [Ecosystem Architecture Guide](architecture.md).
