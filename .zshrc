# default to xterm if terminfo is missing
[ -e "/usr/share/terminfo/${TERM:0:1}/${TERM}" ] || export TERM=xterm

# exa
if whence exa >/dev/null; then
    alias ls='exa --classify'
    alias ll='exa --classify -l'
    alias l='exa --classify -l'
    alias ltr='exa --classify -l --sort modified'
fi

# system update
alias syu='sudo pacman -Syu --noconfirm'
alias yaysyu='yay -Syu --noconfirm'

# other aliases
alias dgit='git --work-tree=$HOME --git-dir=$HOME/home.git'
alias qemu='qemu-system-x86_64'

# virsh
alias v='virsh'
alias sv='virsh --connect qemu:///system'

# keymap
bindkey -e
bindkey -r "^Ed" # Leave my end-of-line key alone
bindkey "^[[27;2;13~" accept-line
bindkey "^[[27;3;13~" accept-line
bindkey "^[[27;4;13~" accept-line
bindkey "^[[27;5;13~" accept-line
bindkey "^[[27;6;13~" accept-line
bindkey "^[[27;7;13~" accept-line
bindkey "^[[27;8;13~" accept-line

# grc-rs
if command -v grc-rs >/dev/null; then
    source <(grc-rs --aliases --except=ip)
fi

# user paths
[[ -d "$HOME/bin" ]] && export PATH=$PATH:$HOME/bin
[[ -d "$HOME/.cargo/bin" ]] && export PATH=$PATH:$HOME/.cargo/bin
[[ -d "$HOME/.local/bin" ]] && export PATH=$HOME/.local/bin:$PATH
[[ -d "$HOME/.yarn" ]] && export PATH=$HOME/.yarn/bin:$PATH
if whence ruby >/dev/null; then
    PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
    export PATH
fi

# tmux
alias remux='tmux new-session -As default'
remux-widget() {
    BUFFER='remux'
    zle accept-line
}
zle -N remux-widget
bindkey "^[k" remux-widget

# syntax highlighting
if [ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    . /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# fzf
if [ -e /usr/share/fzf/key-bindings.zsh ]; then
    . /usr/share/fzf/key-bindings.zsh
    bindkey "^T" transpose-chars  # restore default bindings
    bindkey "^[o" fzf-file-widget
fi
if [[ -f /usr/share/fzf/completion.zsh ]]; then
    . /usr/share/fzf/completion.zsh
fi
if command -v fzf >/dev/null; then
    fzf-edit-widget() {
        local cmd="${FZF_ALT_E_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -type f -print 2> /dev/null | cut -b3-"}"
        setopt localoptions pipefail no_aliases 2> /dev/null
        local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
        if [[ -z "$dir" ]]; then
            zle redisplay
            return 0
        fi
        zle push-line # Clear buffer. Auto-restored on next prompt.
        BUFFER="${EDITOR} ${(q)dir}"
        zle accept-line
        local ret=$?
        unset dir # ensure this doesn't end up appearing in prompt expansion
        zle reset-prompt
        return $ret
    }
    zle -N fzf-edit-widget
    bindkey '^[E' fzf-edit-widget
fi

# local configuration (~/.zshrc.d)
[[ ! -d "$HOME/.zshrc.d" ]] || source <(cat $(find "$HOME/.zshrc.d" -type f) /dev/null)
