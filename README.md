# How to use?
1. Clone this repo to the home folder (`~`)
2. Install [GNU Stow](https://www.gnu.org/software/stow/)
3. Create `~/.config/` if the folder does not exist
4. `cd` into `~/dotfiles`
6. Use stow to create symlinks:
     ```bash
     stow --target ~/.config . # Use `stow --target ~/.config -D .` to delete
     stow zsh
     ```

# Other tools
- [Ghostty](https://ghostty.org/)
  - [MesloLGS Nerd Font](https://github.com/romkatv/powerlevel10k#fonts) (p10k 圖示必要)
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
