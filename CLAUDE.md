# OpenClaw - Keith's Fork

## Branching Strategy

This is a fork of [openclaw/openclaw](https://github.com/openclaw/openclaw) at [4xguy/openclaw](https://github.com/4xguy/openclaw).

| Branch | Purpose | Tracks |
|--------|---------|--------|
| `main` | Upstream mirror | `upstream/main` (openclaw/openclaw) |
| `deploy` | Dokploy production | `origin/deploy` |

**Rules:**
- `main` stays clean - no custom commits. Syncs with `upstream/main`.
- `deploy` has all custom changes rebased on top of `main`.
- ALL local work (Dockerfile, docker-compose, entrypoint, CLAUDE.md, etc.) goes on `deploy`.
- When upstream updates: sync `main` first, then rebase `deploy` onto updated `main`.

**Custom files on deploy (not in upstream):**
- `Dockerfile` - SSH server, gosu, dev tools
- `docker-compose.yml` - Dokploy service config, volumes, ports
- `docker-entrypoint.sh` - SSH setup, auto-fix config, privilege drop
- `CLAUDE.md` - this file
- `.claude/` - agent definitions

## Remotes

```
origin    https://github.com/4xguy/openclaw.git   (Keith's fork)
upstream  https://github.com/openclaw/openclaw.git (official repo)
```

## Sync Workflow

```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
git checkout deploy
git rebase main
git push origin deploy --force
```

## Deployment

- **Platform:** Dokploy on Linode (172.238.219.64)
- **Domain:** bot.icvida.com
- **Deploy branch:** `deploy` (configured in Dokploy)
- **SSH access:** port 2222, user `node`, key-only auth
- **Volumes:** `openclaw-config` (/home/node/.openclaw), `openclaw-workspace` (/home/node/.openclaw/workspace)
- **Config file (in container):** `/home/node/.openclaw/openclaw.json` - persists in volume across restarts

## SSH Access

```bash
ssh bot.icvida.com        # uses ~/.ssh/config (port 2222, user node)
ssh openclaw              # alias via IP directly
```

Two authorized keys configured via `SSH_PUBLIC_KEY` env var (keith@openclaw, keith@BLR7OFFICEKR).

## Known Issues

- Container config (`openclaw.json`) persists in Docker volume. Invalid config keys cause crash loops since the gateway exits on invalid config and Docker restarts it endlessly.
- The entrypoint runs `openclaw doctor --fix` on every start to auto-heal invalid config.
- SSH host keys are NOT persisted in a volume. After rebuilds, clients may need to clear known_hosts: `ssh-keygen -R "[bot.icvida.com]:2222"`
