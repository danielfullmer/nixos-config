{ config, ... }:
{
  imports = [
    ./dunst/config.nix
    ./neovim/config.nix
    ./tmux/config.nix
  ];
}
