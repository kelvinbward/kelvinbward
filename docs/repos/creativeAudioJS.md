# Spoke: `creativeAudioJS`

**Ecosystem Role**: Frontend / Sandbox Application
**Assigned Hub**: Personal (`goobface`)
**Execution Mode**: GitOps (Static Export)

## Overview
The `creativeAudioJS` repository is an experimental Spoke dedicated to pushing the boundaries of web audio using Vite and Tone.js. It acts as a sandbox for building synthesizers and in-browser interactive music generation.

## Architectural Flow
Unlike professional apps, `creativeAudioJS` is routed to the Personal Hub (`goobface.com`). 

When development is finalized locally inside its own standalone development container, a push to the `main` branch engages the standard CI/CD deployment flow (imported from `kelvinbward/.github`). The resulting application bundle is sent via PR to `goobface/public/creativeAudioJS`, exposing it purely as a high-speed static asset distribution with zero server-side maintenance required.
