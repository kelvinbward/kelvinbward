# 🧠 Service: Professional Hub (kelvinbward)

## 📋 Service Role
**Professional Hub**.
- **Domain**: `kelvinbward.com`
- **Function**: Landing page + aggregated professional content (`resume`).

## 📡 Service Topology
| Context | Hostname | Port | Visibility |
| :--- | :--- | :--- | :--- |
| **Gateway** | `gateway-app-1` | `80`, `443` | Public |
| **Resume API** | `resume-backend-1` | `3000` | Internal |
| **Middleware** | `middleware-app-1` | `5000` | Internal |

## 🚀 Execution Modes
| Mode | Config | Command | Description |
| :--- | :--- | :--- | :--- |
| **Cluster** | `docker-compose.yml` | `docker compose up -d` | Main production entry point. |
| **Static** | `package.json` | `npm run dev` | Local Next.js dev server. |

## 🔄 Handoff Protocol
1.  **Immutability**: `public/resume` is LOCKED. Update via PR from `resume` repo.
2.  **Workflow**: Push to `infra/` or `feature/` branch. Create PR to `main`.

## 🤝 Collaborative Workflow
- **Branching**: `infra/` (Ops changes), `feature/` (Content).
- **Merge Order**: Ops changes here MUST merge before dependent Spokes.
