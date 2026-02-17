  # Configuration Notes for /etc/nixos

  This repository is a fully declarative NixOS + Home Manager setup. It is the single
  source of truth for the system configuration and user environment.

  ## How this config is structured
  - `configuration.nix` contains system‑level settings (NixOS, services, kernel, power,
  networking, etc.).
  - `home.nix` imports Home Manager modules under `home/`.
  - `home/*.nix` are modular user configs:
    - `home/gnome.nix` GNOME settings, keybindings, extensions, and desktop apps.
    - `home/neovim.nix` Neovim setup (LazyVim config is under `home/nvim/`).
    - `home/tmux.nix`, `home/kitty.nix`, `home/zsh.nix` terminal stack.
    - `home/dev.nix` dev toolchain (Rust/C++/Python/Julia, TeX Live full, etc.).
    - `home/vpn.nix` openconnect-based Uni Heidelberg VPN helper (`uni-vpn`).
    - `home/gaming-system.nix` optional gaming bundle + NVIDIA switch.

  ## Important decisions and constraints
  - Nixpkgs is pinned to **nixos-unstable** via `configuration.nix` and used for both
  system + Home Manager.
  - This is a Wayland GNOME system.
  - The user prefers **declarative** changes; avoid ad‑hoc manual edits under `$HOME`
  unless instructed.
  - The user language is **German**; mention app names as they appear in GNOME (often
  untranslated).
  - Avoid enabling or disabling features implicitly; use explicit toggles if possible.

  ## Current key toggles / options
  - `gaming.enable`: optional gaming package bundle (Steam, Lutris, Heroic, etc.).
  - `nvidia.enable`: explicit NVIDIA driver stack (independent of gaming).
    - Intended for the gaming laptop only.
  - Power profile behavior: balanced on AC, power‑saver on battery (udev +
  power‑profiles‑daemon).
  - Bluetooth is enabled but **powered off on boot** (`powerOnBoot = false`).

  ## VPN setup
  - `uni-vpn` script (installed under `~/.local/bin/uni-vpn`) uses openconnect with
  AnyConnect protocol.
  - Username/password are read from GNOME Keyring or local file:
    - Username fallback: `~/.config/uni-vpn/username`.
    - Password: `secret-tool lookup vpn uni-heidelberg user "$USERNAME"`.
  - OTP generation is automatic via TOTP secret in keyring:
    - Stored with: `secret-tool store --label='Uni Heidelberg VPN TOTP' vpn uni-
  heidelberg kind totp`
    - Uses `oathtool --totp` to generate the code.
  - Keybinding launches `uni-vpn` in Kitty: `Ctrl+Alt+V`.

  ## GNOME shortcuts and extensions
  - Custom bindings in `home/gnome.nix`, including Super+E for Files and Super+Shift+Y
  for Stoat.
  - Workspace indicator uses a **local fork** of `workspaces-by-open-apps` under:
    - `/etc/nixos/home/gnome-extensions/workspaces-by-open-apps@favo02.github.com`
  - Window buttons are hidden via `no-title-bar` extension.
  - Notifications for extension managers are disabled via dconf.

  ## Notable packages and behaviors
  - `stoat` is packaged manually in `home/gnome.nix` from upstream zip and run via
  `steam-run`.
  - `~/.local/bin` is added to PATH (via Home Manager + zsh init).

  ## Assistant role
  You are a configuration editor for this repo. Keep edits minimal, declarative, and
  consistent with existing modules.
  When adding new functionality, prefer new Home Manager modules or small additions to
  existing ones.
  Avoid breaking changes; ask clarifying questions when a change could affect core
  workflows.

  ## Tips for future changes
  - If you need host‑specific behavior, create a host override file and import it
  conditionally.
  - Keep GNOME settings in `home/gnome.nix`, not in `configuration.nix`.
  - Keep terminal, shell, and editor logic in the existing module split.
