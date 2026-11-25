# AGENTS.md

For any agent asked to install, sync, or change these dotfiles. The repo is public and used by more than its author, so never assume the person in front of you is the author.

## Setup runbook

1. Ask whether they want the author's personal Claude Code setup. It is off unless `--claude` (or `DOTFILES_CLAUDE=yes`) is passed or `~/.claude/CLAUDE.md` already links here. It links `claude/CLAUDE.md` over `~/.claude/CLAUDE.md` (a real file is backed up), clones the author's skills repo and links its skills and agents (`Explore` overrides the built-in), and merges `claude/settings.json`, which skips the bypass-permissions prompt, connects Remote Control at startup, turns off commit attribution, and enables third-party plugins. Never pass `--claude` without a clear yes; someone else will usually want to fork, or trim `claude/` first.
2. With `--claude`, preview the settings merge and show the differences:
   `diff <(jq -S . ~/.claude/settings.json) <(jq -sS '.[0] * .[1]' ~/.claude/settings.json claude/settings.json)`
3. Run `./install.sh --no-install-deps` (plus `--herdr`, `--tmux` or `--both` on a fresh machine). Package installs need the user's password or consent: show the printed command instead of running it.
4. Read the last block of the output. "Still to install" lists missing tools; "Left for you" lists what only the user can set. Go through every item with the user, using the table below. Do not end with just "done".
5. Verify: `git status -s` is empty, no dead links in `~/.claude/skills` or `~/.claude/agents`, `hyprctl configerrors` is empty on Omarchy.

## What to remind the user about

Never fill these in from this repo, git history, another machine, or a guess. Ask, then set exactly what the user answers.

| Tag | Ask or say |
| --- | --- |
| `git-name`, `git-email` | Which name and email? Same for work repos, or a different one per repo? Also offer `init.defaultBranch`. |
| `gh` | The user logs in through the browser themselves. Never pass tokens around. |
| `shell` | `chsh` needs their password and only applies after a fresh login; running sessions keep the old shell. |
| `p10k` | Run the wizard, or copy their own `~/.p10k.zsh`. |
| `font` | Offer to install from the official releases into `~/.local/share/fonts`. |
| `ghostty` | Which font size? It depends on the display. |
| `herdr` | `herdr integration install claude` writes the hook script. |
| `input` | Which input method? `omarchy setup input` may rewrite `fcitx5/config`; check `git status` after. |
| `nvim` | Files left by a distro's own nvim setup. Offer to move them to a backup. |

Not detectable, so always mention:

- The coralline status line, `model`, `modelSettings` and `env` are per machine and not in this repo.
- Plugins listed in `enabledPlugins` may still need `claude plugin install <name>`.
- `.bak-<timestamp>` files and `~/.claude/replaced` are the user's to delete once the setup looks right.
- Keys removed from `claude/settings.json` are not removed from machines that already merged them.

## Syncing machines

- `cd ~/dotfiles && git pull --ff-only && ./install.sh --no-install-deps`. Stop if the tree is dirty; ask, never discard.
- `nvim/lazy-lock.json`: run `:Lazy update` on one machine only, commit it there. Everywhere else pull, then `nvim "+Lazy! restore" +qa`. If the file then shows as modified, that machine has different plugins; report it, do not commit.

## Changing this repo

- No names, emails, tokens, absolute home paths or host names in tracked files. Machine-specific values go in gitignored local files.
- `install.sh` must run on bash 3.2 and be safe to re-run. It may check and remind, but never sets identity, logins or the login shell.
- `README.md` and `README.zh-TW.md` are a pair: change both. New root files need an entry in `.stow-local-ignore`, or they get linked into `~/.config`.
- Conventional Commits, no em-dashes or en-dashes.
