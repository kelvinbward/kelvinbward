# 🛠️ Infrastructure Scripts

This directory contains utility scripts for managing the Kelvin B. Ward Polyrepo ecosystem.

## ⚙️ Configuration

### `repos.sh`
The central registry of all active repositories in the workspace.
*   **Purpose**: Defines the list of paths that other scripts iterate over.
*   **Usage**: Edit this file to add/remove repositories from batch operations.
*   **Design Pattern**: Sourced by other scripts (`source ./repos.sh`) to ensure a Single Source of Truth.

## 🚀 Utilities

### `git_cleanup.sh`
**Protocol Enforcement**: Automates the "Start of Next Task" workflow.
*   **Usage**: `./git_cleanup.sh [-f]`
*   **Behavior**:
    *   **Standard Repos**: Stashes changes, checkouts `main`, pulls latest, prunes local feature branches.
    *   **Sandbox (`pi-cluster-configs`)**: Resets hard to `origin/main`.
    *   **Safety**: Default mode preserves `secrets.env` and data volumes. Use `-f` to force delete untracked files.
    *   **⚠️ WARNING**: This script performs `git branch -D` (Force Delete) on local branches aside from `main`. Ensure all work is **PUSHED** to origin before running. Stashing only saves uncommitted local changes, not the branch history itself.

### `git_broadcast.sh`
**Batch Execution**: Runs an arbitrary command across all registered repositories.
*   **Usage**: `./git_broadcast.sh "<command>"`
*   **Example**:
    ```bash
    ./git_broadcast.sh "git status -s"
    ./git_broadcast.sh "npm install"
    ```

### `init_infra.sh`
**Bootstrap**: Initializes the infrastructure from scratch.
*   **Usage**: `../init_infra.sh` (from project root)
*   **Purpose**: Clones repositories and sets up the environment based on `apps.config`.
