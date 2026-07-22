# Remote SSH login with agent forwarding: replace OpenSSH's ephemeral
# socket path with a stable per-user path for tmux and long-lived shells.
# Skip if SSH_AUTH_SOCK is already pointing at the stable symlink — it has
# either been set by a parent shell or we are inside an existing tmux session.
_remote_agent_socket="$XDG_RUNTIME_DIR/remote-ssh-agent.socket"
if [ -n "$SSH_CONNECTION" ] &&
   [ -n "$SSH_AUTH_SOCK" ] &&
   [ "$SSH_AUTH_SOCK" != "$_remote_agent_socket" ] &&
   [ -S "$SSH_AUTH_SOCK" ]; then
    ln -snf "$SSH_AUTH_SOCK" "$_remote_agent_socket"
    export SSH_AUTH_SOCK="$_remote_agent_socket"
fi
unset _remote_agent_socket

# Local/default case: use the systemd-activated local agent socket
# when SSH_AUTH_SOCK was not provided.
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"
