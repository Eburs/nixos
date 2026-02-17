{ pkgs, lib, ... }:
let
  wboaSrc = builtins.path {
    path = ./gnome-extensions;
    name = "gnome-extensions";
  } + "/workspaces-by-open-apps@favo02.github.com";

  workspacesByOpenApps = pkgs.runCommand "workspaces-by-open-apps-extension" { } ''
    mkdir -p $out
    cp -a ${wboaSrc}/* $out/
  '';

  stoatVersion = "1.1.12";
  stoatArch = if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then "x64"
    else if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then "arm64"
    else throw "Stoat is only packaged for x86_64-linux and aarch64-linux.";
  stoat = pkgs.stdenvNoCC.mkDerivation {
    pname = "stoat";
    version = stoatVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/stoatchat/for-desktop/releases/download/v${stoatVersion}/Stoat-linux-${stoatArch}-${stoatVersion}.zip";
      hash = "sha256-6rvbmoSGdmlyXYS7G3iE6nUuL4IHbDTKWiSebAVXq28=";
    };
    nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper ];
    unpackPhase = ''
      mkdir -p src
      unzip -q "$src" -d src
    '';
    installPhase = ''
      mkdir -p $out/opt/stoat $out/bin $out/share/applications
      cp -a src/Stoat-linux-${stoatArch}/* $out/opt/stoat/
      makeWrapper ${pkgs.steam-run}/bin/steam-run $out/bin/stoat \
        --add-flags "$out/opt/stoat/stoat-desktop --no-sandbox" \
        --set CHROME_DISABLE_SANDBOX 1 \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.nspr pkgs.nss ]}
      cat > $out/share/applications/stoat.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=Stoat
      Exec=stoat
      Categories=Network;Chat;
      Terminal=false
      EOF
    '';
    meta = with lib; {
      description = "Stoat desktop client";
      homepage = "https://stoat.chat";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  };
in
{
  home.packages = with pkgs; [
    gnomeExtensions.no-title-bar
    authenticator
    kora-icon-theme
    zathura
    pkgs.zathuraPkgs.zathura_pdf_mupdf
    spotify
    discord
    stoat
    easyeffects
    lsp-plugins
    zam-plugins
    calf
    mda_lv2
  ];

  xdg.dataFile."gnome-shell/extensions/workspaces-by-open-apps@favo02.github.com" = {
    source = workspacesByOpenApps;
    recursive = true;
  };

  xdg.dataFile."easyeffects/output/GentleDynamics.json" = {
    source = ./easyeffects/GentleDynamics.json;
  };
  xdg.dataFile."easyeffects/input/GentleDynamics.json" = {
    source = ./easyeffects/GentleDynamics.json;
  };

  services.easyeffects = {
    enable = true;
    preset = "GentleDynamics";
  };


  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "no-title-bar@jonaspoehler.de"
        "workspaces-by-open-apps@favo02.github.com"
      ];
      favorite-apps = [ ];
    };

    "org/gnome/shell/extensions/no-title-bar" = {
      button-position = "hidden";
      hide-buttons = true;
      buttons-for-all-win = true;
      buttons-for-snapped = true;
      title-for-snapped = true;
      only-main-monitor = false;
      ignore-list-type = "disabled";
    };

    "org/gnome/shell/extensions/workspaces-indicator-by-open-apps" = {
      position-in-panel = "CENTER";
      position-index = 0;
      indicator-show-indexes = true;
      apps-show-window-title = false;
      size-app-icon = 16;
      icons-group = "GROUP WITHOUT COUNT";
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      minimize = [ "<Super>m" ];
      toggle-fullscreen = [ "<Super>f" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];
      move-to-workspace-7 = [ "<Super><Shift>7" ];
      move-to-workspace-8 = [ "<Super><Shift>8" ];
      move-to-workspace-9 = [ "<Super><Shift>9" ];
      move-to-workspace-10 = [ "<Super><Shift>0" ];
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "kitty";
      command = "kitty";
      binding = "<Super>Return";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "firefox";
      command = "firefox";
      binding = "<Super>w";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "spotify";
      command = "spotify";
      binding = "<Super>z";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "discord";
      command = "discord";
      binding = "<Super>y";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      name = "uni-vpn";
      command = "kitty --title uni-vpn -e uni-vpn";
      binding = "<Ctrl><Alt>v";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      name = "files";
      command = "nautilus --new-window";
      binding = "<Super>e";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      name = "stoat";
      command = "stoat";
      binding = "<Super><Shift>y";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = false;
      icon-theme = "kora";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "de" ]) ];
      xkb-options = [ "caps:swapescape" ];
    };

    # Suppress extension update notifications
    "org/gnome/desktop/notifications/application/com-mattjakeman-extensionmanager" = {
      enable = false;
    };
    "org/gnome/desktop/notifications/application/org-gnome-Extensions" = {
      enable = false;
    };
    "org/gnome/desktop/notifications/application/org-gnome-SessionManager" = {
      enable = false;
    };

    # Remove window buttons (close/minimize/maximize) from titlebar
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
      num-workspaces = 10;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };
  };
}
