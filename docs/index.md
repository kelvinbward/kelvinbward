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
To interact with the multi-repository workspace seamlessly, we utilize a unified compiled Go binary (`kelvin-cli`) stored in `kelvinbward/cli`. It allows safe initialization of the cluster, automated repository syncing, application scaffolding, and real-time environment monitoring.

### Core Utilities
- **`infra` command suite**: Controls local daemon and monitors clustered apps (e.g., `status`, `logs`, `reload`).
- **`app` command suite**: Standardizes the scaffolding of new Spokes explicitly into an Nginx-ready network state.
- **`git` command suite**: Protects from missed commits across fragmented microservices by auditing all synchronized spokes. 

### Setting up `kelvin-cli`

If you haven't used the CLI in a while, or are setting up a new environment, you will need to compile the Go binary and ensure it's accessible.

**1. Install Go (if not installed)**
*   [Download Go](https://go.dev/doc/install)
*   Ubuntu/Debian: `sudo apt install golang`

**2. Compile the CLI**
Navigate to the cli directory and build the binary:
```bash
cd ~/Projects/kelvinbward/cli
go build -o kelvin-cli .
```

**3. Make it globally accessible**
You can use either an **alias** OR the Go `PATH` method.

*   **Method A: Add an Alias (Quickest)**
    Add the following line to your `~/.aliases` (or `~/.bashrc` / `~/.zshrc`):
    ```bash
    alias kelvin-cli='~/Projects/kelvinbward/cli/kelvin-cli'
    ```

*   **Method B: Install to Go PATH**
    Alternatively, use `go install` to place it in your standard Go binary folder:
    ```bash
    cd ~/Projects/kelvinbward/cli
    go install .
    ```
    Then ensure your Go bin path is exported in your `~/.bashrc`:
    ```bash
    export PATH=$PATH:$(go env GOPATH)/bin
    ```

*(Remember to reload your terminal config by running `source ~/.aliases` or `source ~/.bashrc`)*

For a deeper dive into the architectural reasoning, review the [Ecosystem Architecture Guide](architecture.md).
