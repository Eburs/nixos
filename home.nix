{ ... }:
{
  imports = [
    ./home/gnome.nix
    ./home/dev.nix
    ./home/vpn.nix
    ./home/neovim.nix
    ./home/tmux.nix
    ./home/kitty.nix
    ./home/zsh.nix
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.stateVersion = "25.11";
}
