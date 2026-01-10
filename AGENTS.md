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

## 🤝 Human Protocol
*Since "Require Approvals" is disabled to allow Solo-Maintainer merging, strict discipline is required.*
1.  **Process**:
    *   Create Feature Branch -> Push -> Open PR.
    *   **Self-Review**: Review the "Files changed" tab in the PR.
    *   **Merge**: Use "Squash and merge" or "Rebase and merge" to keep history clean.
2.  **Emergency Bypass**:
    *   Only acceptable for critical hotfixes when GitHub Actions are down.
    *   Requires manual admin override.


## 📋 Role
**System Hub**: This repository is the central entry point for the "Kelvin B. Ward" digital ecosystem. It directs traffic to specialized nodes (Professional vs. Personal) and holds the global architectural definition.
1.  **Professional Hub**: Hosts the static build of the `resume` application (via GitHub Actions).
2.  **System Root**: The central source of truth for the Polyrepo architecture (`kelvinbward/AGENTS.md`).

## 📂 Project Map & Structure
- **`pi-cluster-configs/`**: (Private) The "Engine Room". Contains Nginx Proxy Manager, shared PostgreSQL, and global network definitions.
- **`resume/`**: (Public) Full-stack application. **Deployed to Hub** (`kelvinbward.com/resume/`).
- **`creativeAudioJS/`**: (Private) Generative audio experiments.
- **`goobface/`**: (Public) Hybrid Game & Hobby Node. **Standalone** (`goobface.com`).
- **`kelvinbward/`**: (Public) **System Hub**. Hosts the central landing page and the Resume module.

## 🔄 Self-Documentation Protocol (CRITICAL)
After completing ANY task within an individual project folder, you MUST:
1.  **Update the local `AGENTS.md`** in that specific repository with any changes to ports, dependencies, or commands.
2.  **Update this Root `AGENTS.md`** if the high-level structure, repository relationships, or global environment variables have changed.
3.  **Summarize the "Next State"** so the user can resume work seamlessly.

## 🛠 Shared Infrastructure Rules
- **Network**: All apps connect via the `web_gateway` Docker network (External).
- **Dual Mode Architecture**:
    - **Cluster Mode (Default)**: Use `docker-compose.cluster.yml` (or `docker-compose.yml` if no ports). NO exposed ports. Traffic via Gateway.
    - **Standalone Mode (Dev)**: Use `docker-compose.standalone.yml`. Exposed ports allowed for isolated development.
- **Routing**: Use `[app].localhost` subdomain routing via Nginx Proxy Manager.
- **Consistency**: Container names must use suffix `-1` (e.g., `shared-cms-1`).

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
