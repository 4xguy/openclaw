#!/bin/bash
set -e

# Setup SSH if public key is provided
if [ -n "$SSH_PUBLIC_KEY" ]; then
  mkdir -p /home/node/.ssh
  printf '%b\n' "$SSH_PUBLIC_KEY" > /home/node/.ssh/authorized_keys
  chmod 700 /home/node/.ssh
  chmod 600 /home/node/.ssh/authorized_keys
  chown -R node:node /home/node/.ssh

  # Generate host keys if not present (persists across container restarts)
  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
  fi

  # Add shell aliases for interactive SSH sessions
  # Pass gateway token if set so tui auth works over SSH
  if [ -n "$OPENCLAW_GATEWAY_TOKEN" ]; then
    echo "alias tui='node /app/openclaw.mjs tui --token $OPENCLAW_GATEWAY_TOKEN'" > /home/node/.bash_aliases
  else
    echo 'alias tui="node /app/openclaw.mjs tui"' > /home/node/.bash_aliases
  fi
  chown node:node /home/node/.bash_aliases

  # Start SSH daemon
  /usr/sbin/sshd
fi

# Start cron daemon for scheduled tasks (e.g. nightly memory maintenance)
if command -v service >/dev/null 2>&1; then
  service cron start || true
elif command -v cron >/dev/null 2>&1; then
  cron || true
fi

# Ensure volume mount ownership (Docker creates volumes as root)
chown -R node:node /home/node/.openclaw 2>/dev/null || true

# Ensure QMD is present in a persistent path under /home/node/.openclaw
# (survives container redeploys because /home/node/.openclaw is a volume)
QMD_PREFIX="/home/node/.openclaw/qmd-tools"
QMD_BIN="$QMD_PREFIX/node_modules/.bin/qmd"
if [ ! -x "$QMD_BIN" ]; then
  echo "[entrypoint] qmd not found at $QMD_BIN; installing @tobilu/qmd..."
  gosu node npm install --prefix "$QMD_PREFIX" @tobilu/qmd >/dev/null 2>&1 || true
fi
if [ -x "$QMD_BIN" ]; then
  ln -sf "$QMD_BIN" /usr/local/bin/qmd || true
fi

# Auto-fix invalid config keys to prevent crash loops
gosu node node /app/openclaw.mjs doctor --fix 2>/dev/null || true

# Drop privileges and exec the main command as node user
exec gosu node "$@"
