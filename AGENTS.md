# 🧠 Project: kelvinbward (Public)

## 📋 Role
**Root & Profile**: This repository serves two purposes:
1.  **Public Profile**: A showcase and documentation hub for my work.
2.  **System Root**: The central source of truth for the Polyrepo architecture (`kelvinbward/AGENTS.md`). It governs the relationships, ports, and global patterns for all sub-repositories.

## 📂 Project Map & Structure
- **`pi-cluster-configs/`**: (Private) The "Engine Room". Contains Nginx Proxy Manager, shared PostgreSQL, and global network definitions.
- **`resume/`**: (Public) Full-stack application. Depends on `pi-cluster-configs` for DB and Gateway routing.
- **`creativeAudioJS/`**: (Private) Generative audio experiments using Tone.js and Vite.
- **`goobface/`**: (Public) Hybrid Game & Hobby Node. Astro/Phaser/Three.js showcase.
- **`kelvinbward/`**: (Public) Personal profile/showcase repository that documents this architecture.

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
1. **Never commit directly to `main`**.
2. **Always create a feature branch** using the prefix `feature/`, `fix/`, or `infra/`.
3. **Draft Pull Requests**: When starting a task, create a draft PR immediately to track progress.
4. **Clean History**: Use `git commit --amend` for small fixes during development and `git rebase main` before final merge.
5. **Post-Merge**: Delete the feature branch once it is merged into `main`.

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
