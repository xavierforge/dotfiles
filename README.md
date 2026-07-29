[English](./README.md) | [繁體中文](./README.zh-TW.md)

# Install

Clone to your home folder, then run the bootstrap script:

```bash
git clone https://github.com/xavierforge/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

> Make sure your login shell is **zsh** (`echo $SHELL`). If it isn't, switch
> with `chsh -s "$(command -v zsh)"` and reopen the terminal, otherwise
> `.zshrc` never loads. macOS already defaults to zsh; many Linux distros don't.

`install.sh` links every config with GNU Stow and, **if Homebrew is present**,
installs the dependencies from the [`Brewfile`](./Brewfile). It never installs
a package manager for you.

> If Stow complains that a target already exists (e.g. you already have a
> `~/.zshrc`), back up or remove that file first. Stow won't overwrite files
> it didn't create.

### Choosing tmux or herdr

This repo carries configs for both terminal multiplexers and links only the one
you pick:

```bash
./install.sh --herdr    # herdr only (the default on a fresh machine)
./install.sh --tmux     # tmux only
./install.sh --both     # keep both
```

A plain `./install.sh` keeps whatever is already linked, so running it as an
updater never switches multiplexers behind your back. On a fresh machine it
asks, and falls back to herdr when there is no terminal to ask on.
`DOTFILES_MUX=<tmux|herdr|both>` does the same job for scripted runs; a flag
wins over the variable.

Note that `--both` is not the same as passing nothing: no flag means "keep the
current setup", `--both` means "make it both", which re-links the multiplexer
you previously dropped.

Switching is non-destructive: it only removes symlinks that point into this
repo. Your tmux plugins, herdr session files, and any real config file are left
alone. The multiplexer you didn't pick is simply skipped in the Brewfile, so it
never gets installed.

### macOS
Install [Homebrew](https://brew.sh/) once, then `./install.sh` handles the rest
(the Brewfile also pulls in Ghostty and the Nerd Font on macOS).

### Linux
Homebrew is not required. Install the tools with your native package manager
first, then run `./install.sh` (it will skip the Brewfile and just link configs):

```bash
# Debian/Ubuntu
sudo apt install stow git neovim tmux fzf ripgrep fd-find tree chafa zoxide
# Arch
sudo pacman -S stow git neovim tmux fzf ripgrep fd tree chafa zoxide
```

Notes:
- `stylua` and `uv` aren't in most distro repos. Install them via
  `cargo install stylua` and the [uv installer](https://docs.astral.sh/uv/).
- `herdr` isn't packaged by distros either. With Homebrew it comes from the
  Brewfile; without it, use `curl -fsSL https://herdr.dev/install.sh | sh`
  (see [Herdr](#herdr) below).
- On Debian/Ubuntu the `fd` binary is named `fdfind`; symlink it so the fzf
  integration finds it: `ln -s "$(command -v fdfind)" ~/.local/bin/fd`.

# Update

```bash
cd ~/dotfiles
git pull
./install.sh          # re-links new files + installs any new Brewfile deps
                      #   (keeps your current tmux/herdr choice)
```

Other handy commands:

```bash
brew update && brew upgrade   # upgrade all Homebrew packages (macOS)
brew bundle cleanup           # list packages no longer in the Brewfile
                              #   add --force to actually uninstall them
stow --target ~/.config -D .  # unlink everything (reverse of install)
```

# Tmux plugins (TPM)

Only relevant if you picked `tmux` or `both`. Tmux plugins are managed by
[TPM](https://github.com/tmux-plugins/tpm) and are **not** tracked in this repo.
After the configs are linked, set it up once:

```bash
# 1. Clone TPM into the location tmux.conf expects
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

2. Start tmux, then press `<prefix> + I` (prefix is `Ctrl + S`) to install every
   plugin listed in `tmux.conf`. Use `<prefix> + U` to update them later.

# Herdr

[Herdr](https://herdr.dev) is the terminal workspace manager that is gradually
replacing tmux here. Its config is `herdr/config.toml`, and `install.sh --herdr`
links it to the path herdr reads: `~/.config/herdr/config.toml`.

Herdr is managed by Homebrew (it lives in the Brewfile), so upgrade with
`brew upgrade herdr`. Do **not** use the built-in `herdr update`: that
self-updater is meant for the copy the official install script places in
`~/.local/bin/herdr`, and it will overwrite the brew-managed one. For the same
reason, the preview channel (`herdr channel set preview`) isn't reachable via
brew, which only tracks stable. If you really want preview, switch back to the
official installer:

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

After changing the config, reload the running server (no need to restart
sessions):

```bash
herdr server reload-config
```

> `~/.config/herdr/` also holds the socket, the logs, and `session.json`, so
> `install.sh` first creates that real directory with `mkdir -p` and lets Stow
> link only `config.toml`. Without that step, Stow would fold the whole
> directory into a single symlink pointing at this repo on a fresh machine, and
> runtime files would get written into your dotfiles.

# Other tools

The two multiplexers are an either/or (see
[Choosing tmux or herdr](#choosing-tmux-or-herdr)); everything else is always
installed.

- [Herdr](https://herdr.dev) (terminal workspace manager, gradually replacing tmux)
- [Ghostty](https://ghostty.org/)
  - [MesloLGS Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) (required for p10k icons)
- [Zsh](https://www.zsh.org/)
  - [zinit](https://github.com/zdharma-continuum/zinit)
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
  - [fzf](https://github.com/junegunn/fzf)
  - [uv](https://github.com/astral-sh/uv) (optional)
  - [tree](https://formulae.brew.sh/formula/tree) (optional)
- [Tmux](https://github.com/tmux/tmux)
  - [tpm](https://github.com/tmux-plugins/tpm) (plugin manager)
- [NeoVim](https://neovim.io/)
  - [chafa](https://hpjansson.org/chafa/) (required for dashboard image rendering)

# Keybindings

Only the customized bindings are listed. Native LazyVim / Ghostty / Tmux /
Herdr defaults are not repeated here.

## Ghostty

| Key | Action |
| --- | --- |
| `Cmd + C` / `Cmd + V` | Copy / Paste |
| `Cmd + ,` | Open config |
| `Cmd + Shift + ,` | Reload config |
| `Cmd + Shift + O` | Toggle background opacity |

## Zsh

| Key | Action |
| --- | --- |
| `jk` *(insert)* | Exit to normal mode (vi-mode) |
| `Ctrl + P` | History search backward (prefix match) |
| `Ctrl + N` | History search forward (prefix match) |
| `t` *(command)* | Attach/create tmux session `main` |

## Herdr

The prefix is **`Ctrl + S`**, the same as tmux below, so the muscle memory
carries over between them. Each binding's tmux origin is recorded in the
`# tmux:` comment above it in `herdr/config.toml`.

| Key | Action |
| --- | --- |
| `<prefix> \|` | Split pane left/right |
| `<prefix> _` | Split pane top/bottom |
| `<prefix> c` | New tab |
| `<prefix> ,` | Rename tab |
| `<prefix> r` | Enter resize mode (then `h/j/k/l` to adjust, `Esc` to leave) |
| `<prefix> R` | Reload `config.toml` |
| `Ctrl + h / j / k / l` | Switch pane (no prefix needed) |
| `<prefix> [` | Enter copy mode |
| `Alt + 1` ~ `Alt + 9` | Jump straight to tab N |

Two differences from tmux:

- **Resize is a mode, not a repeated press.** In tmux you hit `<prefix>` and
  then repeat `h/j/k/l`; in herdr you enter the mode with `<prefix> r`, adjust,
  then leave with `Esc`. As a knock-on effect, reload moves from tmux's
  `<prefix> r` to `<prefix> R` (the herdr default).
- **Saving a session needs no keybinding.** tmux-resurrect's
  `<prefix> Ctrl+S` / `Ctrl+R` are natively replaced by herdr's server/client
  architecture.

Pane switching with `Ctrl + h/j/k/l` needs no prefix, exactly like
vim-tmux-navigator.

## Tmux

The prefix is changed from the default `Ctrl+B` to **`Ctrl + S`**. Below,
`<prefix>` means the key pressed after a single prefix press.

| Key | Action |
| --- | --- |
| `<prefix> \|` | Split pane left/right |
| `<prefix> _` | Split pane top/bottom |
| `<prefix> h / j / k / l` | Resize pane (repeatable) |
| `<prefix> r` | Reload `tmux.conf` |
| `<prefix> Ctrl + S` | Save session (tmux-resurrect) |
| `<prefix> Ctrl + R` | Restore session (tmux-resurrect) |
| `Ctrl + h / j / k / l` | Seamless vim/tmux pane switching (vim-tmux-navigator) |
| `v` *(copy-mode)* | Begin selection |
| `y` *(copy-mode)* | Copy selection |

## Neovim

Leader is `<space>` (the LazyVim default).

### General

| Key | Action |
| --- | --- |
| `jk` *(insert)* | Exit insert mode |
| `<leader>nh` | Clear search highlights |

### Windows / Splits

| Key | Action |
| --- | --- |
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close current split |

### Buffers (BufferLine)

| Key | Action |
| --- | --- |
| `Tab` | Next buffer |
| `Shift + Tab` | Previous buffer |
| `Ctrl + P` | Pick buffer |
| `<leader>X` | Close current buffer |
| `<leader>A` | Close all buffers except current |

### Treesitter (incremental selection)

| Key | Action |
| --- | --- |
| `S` | Start / expand selection |
| `Backspace` | Shrink selection |

### Tests (Neotest)

| Key | Action |
| --- | --- |
| `]n` / `[n` | Next / previous test |
| `]N` / `[N` | Next / previous **failed** test |

### Rust (crates.nvim)

| Key | Action |
| --- | --- |
| `<leader>cf` | Crate features popup |
| `<leader>cd` | Crate dependencies popup |
| `<leader>cH` | Open crate homepage |
| `<leader>cG` | Open crate repository |
| `<leader>cD` | Open crate documentation |
| `<leader>cC` | Open on crates.io |
