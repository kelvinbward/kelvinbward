# Spoke: `resume`

**Ecosystem Role**: Dynamic Web Application
**Assigned Hub**: Professional (`kelvinbward`)
**Execution Mode**: GitOps (Static Export) / Cluster (Interactive)

## Overview
The `resume` repository contains the source code for the professional portfolio's data-driven resume layer. 

## Architectural Flow
The `resume` application perfectly demonstrates the dual-mode execution logic of the Hub-and-Spoke model:

### 1. Static Extractor (GitHub Pages)
When deployed to production, the `resume` acts purely as a GitOps Spoke. Pushing to `main` executes a GitHub Action (sourced from `kelvinbward/.github`) which builds the static export of the application (e.g. Next.js export or Astro build) and subsequently forces a Pull Request directly into `kelvinbward/public/resume`.
This provides high-availability zero-cost public distribution.

### 2. Cluster Mode (Local Development/Private Instance)
Locally, or when fully self-hosted, `resume` operates closely tied to `core-services` (PostgreSQL) and `middleware`. Data is managed and extracted dynamically using Docker Compose orchestrated by the `pi-cluster-configs` engine.
