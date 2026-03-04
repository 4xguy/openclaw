# OpenClaw - Keith's Fork

Fork of [openclaw/openclaw](https://github.com/openclaw/openclaw) at [4xguy/openclaw](https://github.com/4xguy/openclaw).

## Branches & Syncing

- **`deploy`** - Production branch. All custom work lives here. Dokploy deploys from this branch.
- Use `/ship` to sync with upstream and push. It fetches upstream, merges into deploy, and pushes.

**Custom files on deploy (not in upstream):**
- `Dockerfile`, `docker-compose.yml`, `docker-entrypoint.sh`
- `CLAUDE.md`, `.claude/`

**Remotes:** `origin` = 4xguy/openclaw (fork), `upstream` = openclaw/openclaw (official)

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
