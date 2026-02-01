# 🧠 Project: kelvinbward (Public)

## 0. 🛡️ Session Startup Protocol (MANDATORY)
*Because this is a Free Tier environment, Branch Protection is manual. You must install safety hooks immediately upon starting a session.*

**Step 1:** Upon entering **ANY** repository (root or child node), execute this command to prevent accidental pushes to `main`:
```bash
echo '#!/bin/sh
branch=$(git symbolic-ref HEAD | sed -e "s,.*/\(.*\),\1,")
if [ "$branch" = "main" ]; then
  echo "🚫 DIRECT PUSH TO MAIN IS BLOCKED. USE A PR."
  exit 1
fi' > .git/hooks/pre-push && chmod +x .git/hooks/pre-push
```

**Step 2:** Verify you are on a feature branch (e.g., `feature/task-name`) before writing code.

## 🧭 Capability Matrix
| Repository | Allowed Agent Scope | Prohibited Actions |
| :--- | :--- | :--- |
| **kelvinbward** (Hub) | `infra/*`, `docs/*` | Modifying `resume` sub-app code directly (treat as submodule) |
| **pi-cluster-configs** | `setup`, `config`, `network` | Deleting production volumes |
| **apps/goobface** | `frontend`, `game-logic` | Changing deployment ports without infra approval |
| **apps/middleware** | `api`, `db-migration` | Hardcoding secrets |

## 🔄 State-Sync Protocol (MANDATORY)
At the end of **every** feature branch, you must:
1.  **Log Session**: Create a new file in `pi-cluster-configs/logs/sessions/YYYY-MM-DD_Task_Name.md` with:
    *   **Technical Summary**: What changed?
    *   **Dependency Changes**: New ports? New env vars?
    *   **Resume Command**: How to resume?
2.  **Update Global State**: Update `pi-cluster-configs/STATE.md` to reflect the current high-level state of the ecosystem.
3.  **Commit Log**: Commit these changes to a branch in `pi-cluster-configs` (e.g., `infra/log-update-taskname`).

## ✅ Pre-PR Validation
Before providing a PR link, you **MUST** run:
1.  **Lint/Format Check** (if applicable).
2.  **Config Validation**: `docker compose config` (if touching compose files).
3.  **Self-Review**: Read your own diffs.

## 🤝 Collaborative Workflow
**Role Definition**:
*   **User (@kelvinbward)**: Senior Engineer / Owner. Has `admin` rights. Merges PRs.
*   **Agent (AI)**: Junior Engineer. Has `write` access to branches but **NO** PR/Merge rights.

**Protocol**:
1.  **Agent Work**:
    *   Create branch using prefix: `feature/` (new capability), `fix/` (bug repair), or `infra/` (system/ops).
    *   Commit changes -> Push to origin.
    *   **STOP**. Do not attempt to create PR via CLI.
    *   Generate a `Direct Link` (via Walkthrough) for the User to create the PR.
2.  **User Review**:
    *   Click Link -> Review Diff -> Create PR.
    *   Wait for `Agent Gatekeeper` checks to pass.
    *   Merge (Squash/Rebase).
3.  **Agent Cleanup (Start of Next Task)**:
    *   **MANDATORY**: Before starting ANY new task, you must run the cleanup script to reset your environment:
        ```bash
        ./scripts/git_cleanup.sh
        ```
    *   This script will:
        *   Stash local changes (if any).
        *   Checkout and update `main`.
        *   Delete local feature branches.

## 📋 Role
**System Hub**: This repository is the central entry point for the "Kelvin B. Ward" digital ecosystem. It directs traffic to specialized nodes (Professional vs. Personal) and holds the global architectural definition.
1.  **Professional Hub**: Hosts the static build of the `resume` application (via GitHub Actions).
2.  **System Root**: The central source of truth for the Polyrepo architecture (`kelvinbward/AGENTS.md`).

## 📂 Project Map & Structure
- **`pi-cluster-configs/`**: (Private) The "Engine Room". Contains Nginx Proxy Manager, Portainer, shared PostgreSQL, and global network definitions.
- **`resume/`**: (Public) Full-stack application. **Deployed to Hub** (`kelvinbward.com/resume/`).
- **`creativeAudioJS/`**: (Private) Generative audio experiments.
- **`goobface/`: (Public) `apps/goobface` (Game/Blog Platform).
- **`middleware/`: (Public/Private Access) `apps/middleware` (FastAPI Backend).
- **`kelvinbward/`: (Public) **System Hub**. Hosts the central landing page and the Resume module.

## 🔄 Self-Documentation Protocol (CRITICAL)
After completing ANY task within an individual project folder, you MUST:
1.  **Update the local `AGENTS.md`** in that specific repository with any changes to ports, dependencies, or commands.
2.  **Update this Root `AGENTS.md`** if the high-level structure, repository relationships, or global environment variables have changed.
3.  **Update `scripts/init_infra.sh`** (and sub-scripts) if the infrastructure topology or setup steps change.
4.  **Summarize the "Next State"** so the user can resume work seamlessly.

## 🛠 Shared Infrastructure Rules
- **Network**: All apps connect via the `web_gateway` Docker network (External).
- **Dual Mode Architecture**:
    - **Cluster Mode (Default)**: Use `docker-compose.cluster.yml` (or `docker-compose.yml` if no ports). NO exposed ports. Traffic via Gateway.
    - **Standalone Mode (Dev)**: Use `docker-compose.standalone.yml`. Exposed ports allowed for isolated development.
- **Routing**: Use `[app].localhost` subdomain routing via Nginx Proxy Manager.
- **Consistency**: Container names must use suffix `-1` (e.g., `shared-cms-1`).

## 🔐 Security Protocols
1.  **No Hardcoded Secrets**: NEVER commit passwords or keys to git.
2.  **Secret Generation**: Use the `generate_secrets.sh` script to create a local `secrets.env` file.
3.  **Environment Variables**: All services must reference secrets via environment variables (e.g., `${POSTGRES_PASSWORD}`).
4.  **Gitignore**: Ensure `secrets.env` and `config.env` are always ignored.

## 🌳 Git Branching & Workflow
1.  **NEVER commit directly to `main`**. Main is protected and direct pushes are forbidden.
2.  **Infrastructure Gatekeeping**: All infrastructure changes (conf, docker, workflows) require a PR and manual approval from @kelvinbward.
3.  **Always create a feature branch** using the prefix `feature/`, `fix/`, or `infra/`.
4.  **Draft Pull Requests**: When starting a task, create a draft PR immediately to track progress.
5.  **Clean History**: Use `git commit --amend` for small fixes during development and `git rebase main` before final merge.
6.  **Post-Merge**: Delete the feature branch once it is merged into `main`.

## 🔗 Dependencies
- **Upstream**: None per se, but coordinates all others.
- **Downstream**: None.

## 🛠 Local Configuration
- **Ports**: (None currently)
- **Commands**:
    - `npm start` (if applicable)

## 🔄 Protocol
1.  Update this file if project structure changes.
2.  Update this file if high-level role changes.
