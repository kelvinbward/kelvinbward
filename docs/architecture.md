# The Federated Hub-and-Spoke Architecture

The Kelvin Ecosystem is organized into a modular structure designed to standardize deployments, protect public-facing code, and separate our logical servers from our web-facing sandboxes.

To accomplish this, the repositories in this workspace operate under a **Federated Hub-and-Spoke System**. 

---

## 🏗️ 1. The Ops Library (`kelvinbward/.github`)
At the core of our automation is the Operations Library.
- **What it does**: It acts as the central CI/CD workflow provider.
- **Why we need it**: By hosting reusable workflows (like `.github/workflows/standard-static-deploy.yml`), *every single application* uses the exact same build-and-deploy logic, creating an ecosystem "Golden Path".

---

## 🌐 2. The Hubs (Distribution & Identity)
Hubs are the repositories directly tied to our public domain names. They consume pre-built code and distribute it to the world. We separate them by their "vibe":

- **Professional Hub (`kelvinbward`)**
  - **Domain**: `kelvinbward.com`
  - **Purpose**: Hosts the professional portfolio, resume, and case studies.
- **Personal Hub (`goobface`)**
  - **Domain**: `goobface.com`
  - **Purpose**: A creative sandbox for web games, 3D printing blogs, and audio experiments.

---

## ⚙️ 3. The Engine (`pi-cluster-configs` & `kelvin-cli`)
The Engine is the brain behind our private, self-hosted networking.
- **Responsibility**: It manages the `apps.config` registry, handles all Docker networks, and centralizes our secret management (`.env.template`).
- **Tooling**: We interact with the Engine using `kelvin-cli` (a compiled Go binary). This tool safely initializes the cluster (`infra init --setup`), keeps our repositories synced (`repos sync -u`), and manages destructive clean-ups.

---

## 🚲 4. The Spokes (Logical Applications)
Spokes are where the actual coding happens. 
- **What they are**: Autonomous applications (like the `resume` React app, or the `middleware` API) developed in total isolation.
- **How they deploy**: Instead of deploying directly to the internet, Spokes build themselves using the Hub's Ops Library and automatically push their final files into the `/public/` directory of their assigned **Hub**. 

---

## Why did we do this?
- **Modularity**: You can develop a Spoke entirely on your local machine without needing the rest of the ecosystem.
- **Security**: It is incredibly easy to see exactly what is exposed to the public internet by simply looking at the `/public/` folder in a Hub repository. 
- **Consistency**: Centralized workflows mean when we improve our deployment strategy once, every application gets the upgrade immediately.

---

## 🧪 CLI Testing Architecture
The `kelvin-cli` implements a hermetic testing environment avoiding side-effects (like spinning up actual docker networks or creating dummy Git repositories) during CI/CD execution.
- **`TestHelperProcess` Mocking:** Calls to `exec.Command` natively fork into a sub-shell invoking a fake test process instead of hitting actual shell environments.
- **Hook Variables:** All Go source code relies on the swappable `execCommand` hook locally defined in `cli/cmd/exec.go`.
- Agents and developers expanding this CLI MUST follow this precise testing paradigm, returning pre-populated mocked CLI text string outputs matching the expected target utility tool, rather than hitting actual infrastructure endpoints inside the automated pipeline tests.
