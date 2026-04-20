# Kelvin B. Ward

Welcome to the central hub of my digital presence. This repository operates as a **Federated System Hub**, distinctively separating my professional engineering work from my personal creative experiments.

## 🎯 Choose Your Path

| [**Professional Portfolio**](https://www.kelvinbward.com) | [**Personal Sandbox**](https://www.goobface.com) |
| :--- | :--- |
| **Focus**: Full-Stack Engineering, Cloud Architecture, Leadership | **Focus**: Game Dev, 3D Printing, Generative Audio |
| **Tech**: Next.js, React, TailwindCSS, PostgreSQL | **Tech**: Astro, Phaser.js, Three.js, Tone.js |
| [📂 View Source](https://github.com/kelvinbward/kelvinbward) | [📂 View Source](https://github.com/kelvinbward/goobface) |

---

## 🏗 System Architecture & Bootstrap Flow

The ecosystem follows a **Registry-Driven** bootstrap process. The `apps.config` registry acts as the single source of truth for all active modules.

```mermaid
graph TD
    User(["User / Agent"]) -->|1. Runs| CLI["kelvin-cli infra init"]

    subgraph "Bootstrap (kelvin-cli)"
        CLI -->|Creates| NET[web_gateway Network]
        CLI -->|Reads| REG[apps.config]
        CLI -->|Runs| SETUP["pi-cluster-configs/setup.sh"]
    end

    subgraph "Orchestration (setup.sh)"
        SETUP -->|Generates| SECRETS[secrets.env via generate_secrets.sh]
        SETUP -->|Iterates| REG
        SETUP -->|Clones/Recovers| APPS["Public Repos (Modules)"]
        SETUP -->|Starts| DOCKER[Docker Compose Cluster]
        SETUP -->|Hardens| NPM[Nginx Gateway via configure_gateway.sh]
    end

    subgraph "Runtime Traffic"
        WEB[Web Client] -->|*.localhost| NPM
        NPM -->|goobface.com| GOOB[Goobface]
        NPM -->|kelvinbward.com| RES[Resume]
        NPM -->|/3d-printing| BLOG[3D Blog]
        NPM -->|Other| APPS
    end
```

## 📡 Service Discovery & Registry

| Service | Internal Host | Port | Mode |
| :--- | :--- | :--- | :--- |
| **KELVINBWARD** | `kelvinbward-app-1` | `3000` | cluster |
| **MIDDLEWARE** | `middleware-app-1` | `5000` | cluster |
| **RESUME** | `resume-frontend-1` | `80` | cluster |
| **GOOBFACE** | `goobface-app-1` | `4321` | cluster |
| **CREATIVEAUDIOJS** | `creative-audio-1` | `5173` | cluster |

## 🤖 Agent Hand-off
**Starting a new task?**
1.  **Read Protocol**: Review [AGENTS.md](./AGENTS.md) for the latest rules.
2.  **Check Registry**: Inspect `apps.config` in `pi-cluster-configs` to understand active services.
3.  **Branching**: Create `feature/<name>` or `fix/<name>`.
4.  **Sync State**: Generate `STATE.md` before PR validation.

## 🛠 Utility Tooling: `kelvin-cli`

This ecosystem uses a custom compiled Go binary (`kelvinbward/cli`) to orchestrate spanning tasks across the federated Hub-and-Spoke repositories. It is the **primary operational interface** — all legacy bash scripts have been removed.

### `infra` — Infrastructure Management
| Command | Description |
| :--- | :--- |
| `kelvin-cli infra init` | Bootstrap the private cloud: creates the `web_gateway` Docker network and runs `pi-cluster-configs/setup.sh` (includes secret generation and gateway hardening). Use `--setup` / `-s` to execute `setup.sh` automatically. |
| `kelvin-cli infra status` | Tabular health overview of all containers attached to `web_gateway`. |
| `kelvin-cli infra logs <app>` | Tail logs for any registered spoke or core service (`gateway`, `core-services`, `management`). Resolves container name via `apps.config`. |
| `kelvin-cli infra reload` | Securely restart the Nginx gateway router without tearing down the network. |
| `kelvin-cli infra clean` | Interactively stop all cluster services and remove the `web_gateway` network. |

### `git` — Workspace Git Utilities
| Command | Description |
| :--- | :--- |
| `kelvin-cli git status` | Tabular working-tree status (branch, dirty files, ahead/behind origin) for every git repo in the workspace. |
| `kelvin-cli git clean` | Safe-mode: stash changes, reset to `origin/main`, prune local branches (preserves `secrets.env`, data dirs). Use `--force` / `-f` to nuke all untracked files. |

### `repos` — Repository Registry
| Command | Description |
| :--- | :--- |
| `kelvin-cli repos sync` | Scans the workspace root for git repos and updates the ecosystem registry. Use `--update-config` / `-u` to auto-append newly discovered repos to `pi-cluster-configs/apps.config`. |

### `app` — Spoke Application Scaffolding
| Command | Description |
| :--- | :--- |
| `kelvin-cli app create <name> --type <framework>` | Scaffold a new spoke (`nextjs` or `astro`), inject ecosystem-standard `Dockerfile` + `docker-compose.yml`, bind to `web_gateway`, and register it via `repos sync`. |

## 🚀 Execution Modes

This Hub supports multiple modes of operation to ensure flexibility across development, standalone hosting, and cluster integration.

| Mode | Command | Context |
| :--- | :--- | :--- |
| **Dev** | `npm run dev` | Local development with hot-reload. |
| **Standalone** | `docker compose -f docker-compose.standalone.yml up` | Self-contained Nginx container exposing port 8080. |
| **Cluster** | `docker compose up` | Integrating with `web_gateway` network (requires `pi-cluster-configs`). |
| **Static** | `npm run build` | GitHub Pages deployment (Static HTML Export). |

### Bootstrap Your Own Private Cloud
To run the full "Cluster Mode", bootstrap a fresh `pi-cluster-configs` setup using `kelvin-cli`:

```bash
# One-shot: initialize network, generate secrets, and bring up the full cluster
kelvin-cli infra init --setup

# Or step-by-step:
kelvin-cli infra init          # creates web_gateway network
cd ../pi-cluster-configs
./setup.sh                     # generates secrets.env, starts all services
```

## 🛡️ Security & Governance

The integrity of this ecosystem is maintained through a "Defense in Depth" strategy.

*   **Code Ownership**: Critical infrastructure files are protected by `CODEOWNERS`.
*   **Agent Protocol**: All automated agents must strictly follow [AGENTS.md](./AGENTS.md), including:
    *   **Branch Naming**: `feature/`, `fix/`, `infra/`.
    *   **PR Generation**: Agents must currently generate local branches for review.
    *   **Cleanup**: Automatic deletion of slate environment branches.
*   **Branch Protection**: Direct pushes to `main` are restricted. All changes require PRs with passing build checks.
*   **Secret Management**: No secrets in repo. Environment variables managed via `pi-cluster-configs`.
*   **Immutable Public Directory**: The `/public/` directory is strictly managed.
    *   **Rule**: Modifications to `public/[app]/` must be generated by CI/CD workflows (`github-actions[bot]`).
    *   **Enforcement**: Manual changes by human users are blocked by `guard-immutable.yml` to prevent deployment drift.

## 🧠 Architectural Decisions

### Pattern: Hybrid-Mono Repository
This ecosystem uses a **Hybrid-Mono** pattern to balance Open Source portfolio constraints with production security.

-   **Public Repositories** (`middleware`, `resume`):
    -   Serve as "Products".
    -   Contain source code, tests, and standard Dockerfiles.
    -   **Goal**: Demonstrate engineering capability publicly.
    
-   **Private Repository** (`pi-cluster-configs`):
    -   Serves as the "Environment".
    -   Contains orchestrator scripts (`setup.sh`), secrets (`.env`), and runtime configuration.
    -   **Goal**: Securely manage deployment logic.

-   **The Bridge**:
    -   The `setup.sh` orchestrator **clones** public repositories into the private infrastructure.
    -   This effectively treats public repos as dynamic "modules" managed via script, maintaining clear separation of source (public) and state (private).
