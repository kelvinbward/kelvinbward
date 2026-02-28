# Spoke: `3D-Printing`

**Ecosystem Role**: Markdown Documentation / Blog Frontend
**Assigned Hub**: Personal (`goobface`)
**Execution Mode**: GitOps (Static Export)

## Overview
The `3D-Printing` repository serves as a knowledge base and markdown blog representing physical fabrication projects. Constructed using a statically-compiled documentation engine (like Astro.js), it abstracts content generation away from the root domain.

## Architectural Flow
This Spoke relies entirely on the Personal Hub. Pushes to `main` build the markdown structure into optimized HTML/CSS, opening an automated Pull Request to `goobface/public/3D-Printing`. 

Because it operates as a Spoke, changes to its build configuration do not affect the main `goobface.com` rendering layer, preserving strict separation of concerns.
