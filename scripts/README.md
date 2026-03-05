# Ecosystem Scripts

> **⚠️ DEPRECATED**
> 
> The bash scripts in this directory are legacy tools from the initial bootstrap phase. 
> All functionality has been ported to the `kelvin-cli` Go application for better 
> cross-platform support, robust error handling, and unified orchestration.

## Migrating

| Legacy Script | CLI Equivalent |
|:---|:---|
| `init_infra.sh` | `kelvin-cli infra init --setup` |
| `git_broadcast.sh` | `kelvin-cli git clean`, etc. |
| `repos.sh` | `kelvin-cli repos sync` |

Please use `kelvin-cli --help` for the modern toolchain. These scripts remain as a fallback but will be removed in a future release.
