# Rust/cargo env (skip gracefully on machines without rustup installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Silence zoxide's doctor false-positive in non-interactive shells
# (e.g. tooling that sources a shell snapshot where the precmd hook never fires)
[[ -o interactive ]] || export _ZO_DOCTOR=0
