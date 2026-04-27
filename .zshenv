# Remote SSH login with agent forwarding: replace OpenSSH's ephemeral
# socket path with a stable per-user path for tmux and long-lived shells.
if [ -n "$SSH_CONNECTION" ] &&
   [ -n "$SSH_AUTH_SOCK" ] &&
   [ -S "$SSH_AUTH_SOCK" ]; then
    ln -snf "$SSH_AUTH_SOCK" "$XDG_RUNTIME_DIR/remote-ssh-agent.socket"
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/remote-ssh-agent.socket"
fi

# Local/default case: use the systemd-activated local agent socket
# when SSH_AUTH_SOCK was not provided.
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"
