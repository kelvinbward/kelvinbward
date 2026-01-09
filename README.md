# Kelvin Ward

Welcome to my personal monorepo-style polyrepo setup. This repository (`kelvinbward`) acts as the public face and documentation hub for my ecosystem of projects.

## 🏗 System Architecture

The following diagram illustrates the relationship between the various repositories and services in my "Personal Cloud":

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'lineColor': '#8b949e' }}}%%
graph TD
    subgraph Public["Public Zone"]
        KBW[kelvinbward]
        RES[resume]
        GOOB[goobface]
        CAJS[creativeAudioJS]
    end

    subgraph Private["Private Zone"]
        PCC[pi-cluster-configs]
        WG["Web Gateway<br>(Nginx Proxy Manager)"]
        DB[(Shared PostgreSQL)]
    end

    %% Network Connections
    RES -->|Depends on| PCC
    RES -->|Connects to| DB
    RES -->|Routed by| WG

    CAJS -->|Routed by| WG
    GOOB -->|Static Assets| KBW

    %% Documentation Links
    KBW -.-> PCC
    KBW -.-> RES
    KBW -.-> GOOB
    KBW -.-> CAJS

    %% Using 8-digit hex for transparency to avoid rgba() parser errors
    classDef public stroke:#2ea043,stroke-width:2px,fill:#2ea0431a;
    classDef private stroke:#f85149,stroke-width:2px,fill:#f851491a;
    classDef infra stroke:#8b949e,stroke-width:2px,fill:#8b949e1a,stroke-dasharray: 5 5;

    class KBW,RES,GOOB,CAJS public;
    class PCC private;
    class WG,DB infra;
```

## 📚 Repositories

| Repository | Visibility | Role | Status |
| :--- | :--- | :--- | :--- |
| **[kelvinbward](https://github.com/kelvinbward/kelvinbward)** | Public | **Root & Profile**. Documentation hub and static site. | - |
| **[resume](https://github.com/kelvinbward/resume)** | Public | Full-stack Vue.js/Node.js application. | [Live](https://www.kelvinbward.com) |
| **[goobface](https://github.com/kelvinbward/goobface)** | Public | Game showcase (Astro/Phaser). | [Live](https://www.goobface.com) |
| **[creativeAudioJS](https://github.com/kelvinbward/creativeAudioJS)** | Public | Audio experiments (Tone.js). | [Demo](https://kelvinbward.github.io/creativeAudioJS) |
| **[pi-cluster-configs](https://github.com/kelvinbward/pi-cluster-configs)** | Private | Infrastructure configuration (Nginx, DB). | Internal |

## 🚀 Getting Started

Please refer to [AGENTS.md](./AGENTS.md) for the "Root" architecture documentation and contribution guidelines.
