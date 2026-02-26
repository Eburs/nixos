
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, ... }:
let
  hyprlandSddm = pkgs.writeShellScriptBin "hyprland-sddm" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_CURRENT_DESKTOP=Hyprland
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
    export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export GBM_BACKEND=nvidia-drm
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_RENDERER_ALLOW_SOFTWARE=1
    export WLR_BACKENDS=drm,libinput
    ${lib.optionalString (config.networking.hostName == "Skynet") ''
      export WLR_DRM_DEVICES=/dev/dri/card1
      export AQ_DRM_DEVICES=/dev/dri/card1
    ''}
    exec ${pkgs.hyprland}/bin/Hyprland
  '';
  hyprlandSddmSession = pkgs.stdenvNoCC.mkDerivation {
    pname = "hyprland-sddm-session";
    version = "1";
    dontUnpack = true;
    passthru.providedSessions = [ "hyprland-sddm" ];
    installPhase = ''
      mkdir -p $out/share/wayland-sessions
      cat > $out/share/wayland-sessions/hyprland-sddm.desktop <<'EOF'
      [Desktop Entry]
      Name=Hyprland (sddm)
      Comment=Hyprland with enforced DRM device env
      Exec=${hyprlandSddm}/bin/hyprland-sddm
      Type=Application
      EOF
    '';
  };
  sddmPkg =
    let
      qt6Sddm = lib.attrByPath [ "kdePackages" "sddm" ] null pkgs;
      qt5Sddm = lib.attrByPath [ "libsForQt5" "sddm" ] null pkgs;
    in
      if pkgs ? sddm-qt5 then pkgs.sddm-qt5
      else if pkgs ? sddm then pkgs.sddm
      else if pkgs ? sddm-qt6 then pkgs.sddm-qt6
      else if qt6Sddm != null then qt6Sddm
      else if qt5Sddm != null then qt5Sddm
      else throw "No SDDM package found in this nixpkgs.";
in
{
  nixpkgs.config.allowUnfree = true;
  imports =
    [
      ./home/gaming-system.nix
    ];
  home-manager.backupFileExtension = "bak";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  systemd.services.systemd-boot-reassert = {
    description = "Reassert systemd-boot as first UEFI boot entry";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    unitConfig = {
      ConditionPathExists = "/sys/firmware/efi/efivars";
      RequiresMountsFor = [ config.boot.loader.efi.efiSysMountPoint ];
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/bootctl install --esp-path=${config.boot.loader.efi.efiSysMountPoint}";
    };
  };
  boot.plymouth = {
    enable = true;
    theme = "nixos-logo";
    themePackages = [
      (pkgs.stdenvNoCC.mkDerivation {
        pname = "plymouth-theme-nixos-logo";
        version = "1.0";
        dontUnpack = true;
        installPhase = ''
          theme_dir="$out/share/plymouth/themes/nixos-logo"
          mkdir -p "$theme_dir"

          cat > "$theme_dir/nixos-logo.plymouth" <<'EOF'
          [Plymouth Theme]
          Name=NixOS Logo
          Description=Centered NixOS logo only
          ModuleName=script

          [script]
          ImageDir=/etc/plymouth/themes/nixos-logo
          ScriptFile=/etc/plymouth/themes/nixos-logo/nixos-logo.script
          EOF

          cat > "$theme_dir/nixos-logo.script" <<'EOF'
          Window.SetBackgroundTopColor(0, 0, 0);
          Window.SetBackgroundBottomColor(0, 0, 0);
          logo = Image("logo.png");
          screen_width = Window.GetWidth();
          screen_height = Window.GetHeight();
          logo_width = logo.GetWidth();
          logo_height = logo.GetHeight();
          x = (screen_width - logo_width) / 2;
          y = (screen_height - logo_height) / 2;
          sprite = Sprite();
          sprite.SetImage(logo);
          sprite.SetPosition(x, y, 0);
          EOF

          install -m 0644 ${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png "$theme_dir/logo.png"
        '';
      })
    ];
  };
  boot.consoleLogLevel = 0;
  boot.initrd = {
    verbose = false;
    systemd.enable = true;
  };
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "vt.global_cursor_default=0"
  ] ++ lib.optionals config.nvidia.enable [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "module_blacklist=simpledrm"
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable X11 for SDDM (Hyprland remains Wayland).
  services.xserver.enable = true;

  # Hyprland (Wayland) without GNOME, using SDDM.
  services.displayManager.gdm.enable = false;
  services.displayManager.gdm.wayland = false;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    package = sddmPkg;
    theme = "breeze";
    extraPackages = [
      pkgs.kdePackages.breeze
    ];
  };
  services.displayManager.defaultSession = "hyprland-sddm";
  services.displayManager.sessionPackages = [ hyprlandSddmSession ];
  services.displayManager.sddm.settings = {
    General = {
      Session = "hyprland-sddm.desktop";
    };
  };
  services.displayManager.generic.environment = lib.optionalAttrs (config.networking.hostName == "Skynet") {
    WLR_DRM_DEVICES = "/dev/dri/card2";
    AQ_DRM_DEVICES = "/dev/dri/card2";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
    LIBVA_DRIVER_NAME = "nvidia";
  };
  services.desktopManager.gnome.enable = false;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa
    ];
  };
  services.udev.packages = lib.mkIf config.nvidia.enable [
    config.hardware.nvidia.package
  ];
  services.greetd.enable = false;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Ensure German keyboard layout for GDM/Wayland sessions.
  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:swapescape";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Keep Bluetooth off by default
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eburs = {
    isNormalUser = true;
    description = "Erik Burs";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.eburs = import ./home.nix;

  # Install firefox.
  programs.firefox.enable = true;

  # Default apps
  environment.variables = {
    BROWSER = "firefox";
  };
  environment.sessionVariables =
    lib.mkIf config.nvidia.enable (
      {
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        WLR_NO_HARDWARE_CURSORS = "1";
      }
      // (lib.optionalAttrs (config.networking.hostName == "Skynet") {
        WLR_DRM_DEVICES = "/dev/dri/card2";
        AQ_DRM_DEVICES = "/dev/dri/card2";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
        LIBVA_DRIVER_NAME = "nvidia";
      })
    );

  # Allow wheel group to sudo without password
  security.sudo.wheelNeedsPassword = false;

  # Cisco Secure Client / AnyConnect default profile for Uni Heidelberg
  environment.etc."cisco/anyconnect/profile/heidelberg.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <AnyConnectProfile xmlns="http://schemas.xmlsoap.org/encoding/">
      <ServerList>
        <HostEntry>
          <HostName>Uni Heidelberg VPN</HostName>
          <HostAddress>vpn-ac.urz.uni-heidelberg.de</HostAddress>
        </HostEntry>
      </ServerList>
    </AnyConnectProfile>
  '';

  # Make the profile available for both AnyConnect and Secure Client paths
  systemd.tmpfiles.rules = [
    "d /opt/cisco/anyconnect/profile 0755 root root - -"
    "L+ /opt/cisco/anyconnect/profile/heidelberg.xml - - - - /etc/cisco/anyconnect/profile/heidelberg.xml"
    "d /opt/cisco/secureclient/vpn/profile 0755 root root - -"
    "L+ /opt/cisco/secureclient/vpn/profile/heidelberg.xml - - - - /etc/cisco/anyconnect/profile/heidelberg.xml"
    "c /dev/nvidia0 0660 root video - 195:0"
    "c /dev/nvidiactl 0660 root video - 195:255"
    "c /dev/nvidia-modeset 0660 root video - 195:254"
    "c /dev/nvidia-uvm 0660 root video - 234:0"
    "c /dev/nvidia-uvm-tools 0660 root video - 234:1"
    "d /dev/nvidia-caps 0755 root root - -"
    "c /dev/nvidia-caps/nvidia-cap1 0660 root video - 238:1"
    "c /dev/nvidia-caps/nvidia-cap2 0660 root video - 238:2"
  ];


  # Regular automatic storage optimization
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = false;
    };
  };

  systemd.services.nix-gc-generations = {
    description = "Collect garbage and keep last 180 days of system generations";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +180"
        "${pkgs.nix}/bin/nix-collect-garbage"
      ];
    };
  };
  systemd.timers.nix-gc-generations = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # Default to power-saver on startup
  services.power-profiles-daemon.enable = true;
  systemd.services.power-profile-power-saver = {
    description = "Set power profile to power-saver";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
    };
  };

  # Switch power profile based on AC adapter state
  systemd.services.power-profile-on-ac = {
    description = "Set power profile to balanced when AC is connected";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced";
    };
  };

  systemd.services.power-profile-on-battery = {
    description = "Set power profile to power-saver when on battery";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-on-ac.service"
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-on-battery.service"
  '';


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim
     curl
     wget
     kitty
     git
     gh
     uv
     oh-my-zsh
     tmux
     nodejs
     lazygit
     fzf
     zoxide
     stdenv
     zsh
     gcc
     codex
     lua
     hyprlandSddm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      glib
      libffi
      libuuid
      ncurses
      readline
      sqlite
      expat
      icu
    ] ++ lib.optionals config.nvidia.enable [
      config.hardware.nvidia.package
    ];
  };
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
