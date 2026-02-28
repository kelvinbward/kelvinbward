# Personal Hub: `goobface`

**Ecosystem Role**: Experimental Hub
**Target Domain**: [goobface.com](https://goobface.com)

## Overview
The `goobface` repository is the twin of the professional `kelvinbward` repository, built specifically for experimental, casual, or creative pursuits. It acts as the aggregation frontend and deployment target for creative Spokes.

Currently, it acts as a platform for 3D-printing blogs, Astro.js web experiments, and browser-based games (like the Tone.js audio applications).

## Relationships
- **Depends On**: `kelvinbward/.github` for reusable CI/CD Golden Path workflows.
- **Consumes**: Pre-built artifacts "pushed" to `/public/` by creative Spokes (e.g., `creativeAudioJS`, `3D-Printing`).

## CI/CD Flow
Like the professional hub, any Spoke assigned to `goobface` in the engine registry will, upon pushing to its main branch, execute a cross-repository GitHub Action. The workflow will build the Spoke's static assets and open an automated Pull Request against the `goobface` repository's `public/[app-name]/` directory. Reviewing and merging that PR immediately triggers the static GitHub Pages deployment to the `goobface.com` domain.
