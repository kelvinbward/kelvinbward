# Ecosystem Scripts

> **\ud83d\udee0 Operational interface moved to `kelvin-cli`**
>
> All legacy bootstrap bash scripts (`init_infra.sh`, `git_broadcast.sh`, `repos.sh`,
> `infra/gen_*.sh`, etc.) have been removed. `kelvin-cli` is now the **sole entry point**
> for infrastructure operations across this ecosystem.

## Usage Reference

| Task | Command |
|:---|:---|
| Bootstrap the private cloud | `kelvin-cli infra init --setup` |
| Check cluster health | `kelvin-cli infra status` |
| Tail app/service logs | `kelvin-cli infra logs <app>` |
| Reload the Nginx gateway | `kelvin-cli infra reload` |
| Tear down local cluster | `kelvin-cli infra clean` |
| Git status across all repos | `kelvin-cli git status` |
| Clean & reset all repos | `kelvin-cli git clean` |
| Regenerate repo registry | `kelvin-cli repos sync` |
| Scaffold a new spoke app | `kelvin-cli app create <name> --type <nextjs\|astro>` |

For full flag documentation run `kelvin-cli --help` or `kelvin-cli <command> --help`.
