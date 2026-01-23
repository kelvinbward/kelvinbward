# Session State: Registry Pattern & Governance

## Technical Summary
- **Registry Pattern Implemented**: Moved from hardcoded apps to `apps.config` registry.
- **Dynamic Scaffolding**: `scaffold_dirs.sh` now creates dirs based on registry.
- **Generic Setup**: `setup.sh` loops through registry to clone/recover apps.
- **Governance**: Updated `AGENTS.md` and `README.md` with new protocols.

## Dependency Changes
- **New Config**: `apps.config` is now required in `pi-cluster-configs`.
- **Environment**: `gen_configs.sh` can now generate `.env.template` files dynamically.

## Resume Command
```bash
./scripts/init_infra.sh && cd ../pi-cluster-configs && ./setup.sh
```
