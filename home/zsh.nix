{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      switch = "sudo nixos-rebuild switch --flake /etc/nixos#$HOST";
      update = "sudo nix-channel --update && sudo nixos-rebuild switch --flake /etc/nixos#$HOST";
      sudo-nvim = "sudo -E nvim";
      edit-config = "cd /etc/nixos && codex";
      venv = "source .venv/bin/activate";
    };
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "cp" "kitty" "uv" "zoxide" ];
      theme = "refined";
    };

    initContent = ''
      # Disable XON/XOFF so Ctrl-S can be used by tmux.
      stty -ixon 2>/dev/null

      # Ensure user scripts are on PATH.
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
