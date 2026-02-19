
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

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

  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.desktopManager.gnome.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.eburs = import ./home.nix;

  # Install firefox.
  programs.firefox.enable = true;

  # Default apps
  environment.variables = {
    BROWSER = "firefox";
  };

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
  ];


  # Regular automatic storage optimization
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
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
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libffi
      libxml2
      libssh
      libsodium
      bzip2
      xz
      zstd
      curl
      systemd
      util-linux
      glib
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
