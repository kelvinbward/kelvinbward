# Kelvin Ward

Welcome to my personal monorepo-style polyrepo setup. This repository (`kelvinbward`) acts as the public face and documentation hub for my ecosystem of projects.

## 🏗 System Architecture

The following diagram illustrates the relationship between the various repositories and services in my "Personal Cloud":

```mermaid
graph TD
    subgraph Public["Public Zone"]
        KBW[kelvinbward]
        RES[resume]
        GOOB[goobface]
        CAJS[creativeAudioJS]
    end

    subgraph Private["Private Zone"]
        PCC[pi-cluster-configs]
    end

    subgraph Infrastructure["Shared Infrastructure"]
        WG[Web Gateway<br>(Nginx Proxy Manager)]
        DB[(Shared PostgreSQL)]
    end

    %% Network Connections
    RES -->|Depends on| PCC
    RES -->|Connects to| DB
    RES -->|Routed by| WG

    CAJS -->|Routed by| WG

    GOOB -->|Static Assets| KBW

    %% Documentation Links
    KBW -.->|Defines Architecture| PCC
    KBW -.->|Defines Architecture| RES
    KBW -.->|Defines Architecture| GOOB
    KBW -.->|Defines Architecture| CAJS

    classDef public fill:#dbfbb6,stroke:#333,stroke-width:2px;
    classDef private fill:#ffcccb,stroke:#333,stroke-width:2px;
    classDef infra fill:#e0e0e0,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;

    class KBW,RES,GOOB public;
    class PCC,CAJS private;
    class WG,DB infra;
```

## 📚 Repositories

| Repository | Visibility | Role | Status |
| :--- | :--- | :--- | :--- |
| **[kelvinbward](.)** | Public | **Root & Profile**. Documentation hub and static site. | - |
| **[resume](../resume)** | Public | Full-stack Vue.js/Node.js application. | [Live](https://www.kelvinbward.com) |
| **[goobface](../goobface)** | Public | Game showcase (Astro/Phaser). | [Live](https://www.goobface.com) |
| **[creativeAudioJS](../creativeAudioJS)** | Public | Audio experiments (Tone.js). | [Demo](https://kelvinbward.github.io/creativeAudioJS) |
| **[pi-cluster-configs](../pi-cluster-configs)** | Private | Infrastructure configuration (Nginx, DB). | Internal |

## 🚀 Getting Started

Please refer to [AGENTS.md](./AGENTS.md) for the "Root" architecture documentation and contribution guidelines.
