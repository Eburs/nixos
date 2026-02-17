{ pkgs, ... }:
{
  home.packages = with pkgs; [
    inotify-tools
    wl-clipboard
  ];

  programs.tmux = {
    enable = true;
    prefix = "C-s";

    extraConfig = ''
      unbind C-b
      bind C-s send-prefix

      # Bootstrap TPM if missing
      if-shell '[ ! -d "$HOME/.tmux/plugins/tpm" ]' 'run-shell "git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm"'

      # TPM plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'samoshkin/tmux-plugin-sysstat'
      set -g @plugin 'janoamaral/tokyo-night-tmux'

      # Tokyo Night (tmux)
      set -g @tokyo-night-tmux_show_left_sep "yes"
      set -g @tokyo-night-tmux_show_right_sep "yes"
      set -g @tokyo-night-tmux_show_window_id "no"
      set -g @tokyo-night-tmux_show_index "yes"
      set -g @tokyo-night-tmux_transparent "yes"

      # Auto-reload config on change (requires inotify-tools)
      run-shell -b 'command -v inotifywait >/dev/null && while inotifywait -e close_write,move,create,delete "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1; do tmux source-file "$HOME/.config/tmux/tmux.conf"; tmux display-message "tmux.conf reloaded"; done'

      # Vim-like copy-mode keys
      setw -g mode-keys vi
      bind -T copy-mode-vi h send-keys -X cursor-left
      bind -T copy-mode-vi j send-keys -X cursor-down
      bind -T copy-mode-vi k send-keys -X cursor-up
      bind -T copy-mode-vi l send-keys -X cursor-right
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      run-shell '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
