# local-dev

Local dev lab, one compose project (`api-gateway-env`). `compose.yaml`
includes every stack; **nginx + sso always run**, everything else is an
opt-in profile.

```
├── compose.yaml          # includes all stacks below
├── dev                   # the only command you need
├── .env / .env.example   # secrets + versions (gitignored / template)
├── .mcp.json             # keycloak + tandoor MCPs
├── general/              # shared docker network
├── nginx/
│   └── confs/            # nginx.conf + routes.d/*.map (one hostname->upstream file per stack)
├── sso/                  # keycloak + postgres            (base, always on)
│   └── mcp/              # keycloak admin MCP (uvx, pinned commit)
├── recipes/              # Tandoor recipes                (profiles: recipes, recipes-tunnel)
│   └── mcp/              # tandoor MCP
├── backup-and-restore/   # volume backup/restore scripts
└── scripts/              # copy-volume.sh
```

## Setup

```bash
cp .env.example .env   # fill in passwords
```

nginx expects a cert/key at `nginx/certs/docker-nginx.{crt,key}` (gitignored).
Add `sso.docker.local` / `recipes.docker.local` to `/etc/hosts` pointing at `127.0.0.1`.

## Commands

| Command | What it does |
|---|---|
| `./dev up` | start base (nginx, sso) |
| `./dev up recipes` | start base + that profile; other running stacks are left alone |
| `./dev up recipes --force-recreate` | docker flags after the profiles go to `docker compose up` (defaults `-d --build` stay) |
| `./dev down recipes` | stop just that profile (`./dev down all` stops everything) |
| `./dev ls` | list profiles and what is running |
| `./dev reload` | reload nginx after editing `nginx/confs/` (no container recreate) |
| `./dev logs [service]` | follow logs |
| `./dev <cmd>` | any other `docker compose` subcommand |

## MCPs (wired in `.mcp.json`)
Each `mcp/run.sh` loads `.env` and starts its MCP, so no secrets live in `.mcp.json`.

| MCP | Needs running | Notes |
|---|---|---|
| `keycloak` | base (`./dev up`) | all admin tools incl. writes; talks to `127.0.0.1:${KEYCLOAK_PORT}` |
| `tandoor-recipes` | `./dev up recipes` | build the binary first with `recipes/mcp/build.sh` |

## Adding an app

1. Add its compose file, give each service `profiles: [<name>]`, and `include:` it in `compose.yaml`.
2. Add `nginx/confs/routes.d/<name>.map` with `host.docker.local http://container:port;` lines.
3. `./dev up <name>` (starts it and reloads nginx).

To let an app be embedded in an iframe, add a `routes.d/<name>.frame` line:
`child.docker.local "frame-ancestors 'self' https://parent.docker.local";`
