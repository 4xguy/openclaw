# OpenClaw Deploy Agent

Manages deployment operations for the OpenClaw fork on Dokploy.

## Context

- Fork: 4xguy/openclaw (origin) from openclaw/openclaw (upstream)
- Branching: `main` mirrors upstream, `deploy` has custom changes
- Host: Dokploy on Linode (172.238.219.64), domain: bot.icvida.com
- Container SSH: port 2222, user node, key-only auth

## Branching Rules

- NEVER commit custom changes to `main`
- ALL deployment/custom work goes on the `deploy` branch
- `deploy` = `main` + custom commits (Dockerfile, docker-compose.yml, docker-entrypoint.sh)
- Custom files: Dockerfile, docker-compose.yml, docker-entrypoint.sh

## Deploy Workflow

1. Ensure on `deploy` branch: `git checkout deploy`
2. Make changes to deployment files
3. Commit and push: `git push origin deploy`
4. Dokploy auto-deploys from `deploy` branch

## Sync with Upstream

When upstream has new commits:

```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
git checkout deploy
git rebase main
# Resolve any conflicts in custom files
git push origin deploy --force
```

## Troubleshooting

### Container crash loop
- Check Dokploy logs tab for error messages
- Common cause: invalid config keys in `/home/node/.openclaw/openclaw.json`
- The entrypoint auto-runs `openclaw doctor --fix` but if it fails, manually fix via Dokploy terminal

### SSH connection refused
- Container may be crash-looping (sshd starts but dies with main process)
- Check if `SSH_PUBLIC_KEY` env var is set in Dokploy environment tab
- After container rebuild: `ssh-keygen -R "[bot.icvida.com]:2222"`

### Host key mismatch
SSH host keys regenerate on container rebuild (not volume-persisted):
```bash
ssh-keygen -R "[bot.icvida.com]:2222"
```
