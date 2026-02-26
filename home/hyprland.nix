{ config, lib, pkgs, inputs, osConfig, ... }:
let
  dotsPkgs = import inputs.dots-nixpkgs {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  qsPkg = inputs.dots-quickshell.packages.${pkgs.system}.default;
  dotsQuickshellPkg = pkgs.stdenv.mkDerivation {
      name = "illogical-impulse-quickshell-wrapper";
      meta = with pkgs.lib; {
        description = "Quickshell bundled Qt deps for illogical-impulse config";
        license = licenses.gpl3Only;
      };

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.qt6.wrapQtAppsHook
      ];

      buildInputs = with pkgs; [
        qsPkg
        gsettings-desktop-schemas
        kdePackages.qtwayland
        kdePackages.qtpositioning
        kdePackages.qtlocation
        kdePackages.syntax-highlighting
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qt5compat
        qt6.qtimageformats
        qt6.qtmultimedia
        qt6.qtpositioning
        qt6.qtquicktimeline
        qt6.qtsensors
        qt6.qtsvg
        qt6.qttools
        qt6.qttranslations
        qt6.qtvirtualkeyboard
        qt6.qtwayland
      ];

      installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${qsPkg}/bin/qs $out/bin/qs \
          --prefix XDG_DATA_DIRS : ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}
        chmod +x $out/bin/qs
      '';
    };
  dots = inputs.dots-hyprland;
  configDir = "${dots}/dots/.config";
  dataDir = "${dots}/dots/.local/share";
  excludedConfig = [
    "bash"
    "fish"
    "hypr"
    "kitty"
    "nvim"
    "quickshell"
    "tmux"
    "zsh"
  ];
  configEntries = if builtins.pathExists configDir
    then lib.attrNames (builtins.readDir configDir)
    else [ ];
  filteredConfig = builtins.filter (name: !(lib.elem name excludedConfig)) configEntries;
  dotConfigFiles = lib.genAttrs filteredConfig (name: {
    source = "${configDir}/${name}";
    recursive = true;
  });

  dataEntries = if builtins.pathExists dataDir
    then lib.attrNames (builtins.readDir dataDir)
    else [ ];
  dotDataFiles = lib.genAttrs dataEntries (name: {
    source = "${dataDir}/${name}";
    recursive = true;
  });
  maybePkg = name:
    if lib.hasAttr name dotsPkgs then lib.getAttr name dotsPkgs
    else if lib.hasAttr name pkgs then lib.getAttr name pkgs
    else null;
  extraDotPkgs = builtins.filter (pkg: pkg != null) (map maybePkg [
    "darkly"
    "breeze-plus"
    "readex-pro"
    "otf-space-grotesk"
    "oneui4-icons"
    "ttf-material-symbols-variable-git"
    "ttf-jetbrains-mono-nerd"
  ]);

  hostName = osConfig.networking.hostName or "unknown";
  hostHyprDir = ../hosts/${hostName}/hypr;
  monitorsSrc =
    if builtins.pathExists (hostHyprDir + "/monitors.conf")
    then hostHyprDir + "/monitors.conf"
    else ../hosts/default/hypr/monitors.conf;
  workspacesSrc =
    if builtins.pathExists (hostHyprDir + "/workspaces.conf")
    then hostHyprDir + "/workspaces.conf"
    else ../hosts/default/hypr/workspaces.conf;
  hostEnv = lib.optionalString (hostName == "Skynet") ''
    env = WLR_DRM_DEVICES, /dev/dri/card2
    env = AQ_DRM_DEVICES, /dev/dri/card2
    env = GBM_BACKEND, nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME, nvidia
    env = __EGL_VENDOR_LIBRARY_FILENAMES, /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
    env = LIBVA_DRIVER_NAME, nvidia
  '';
  hostExecs = lib.optionalString (hostName == "Skynet") ''
    exec-once = sleep 1 && hyprctl --batch "keyword monitor DP-3,3840x2160@144,0x0,1,bitdepth,10,cm,hdr,sdrbrightness,1.2,sdrsaturation,1.9; keyword monitor DP-2,2560x1440@180,3840x0,1,bitdepth,10,cm,hdr,sdrbrightness,1.2,sdrsaturation,1.9"
  '';
  hyprConfig = pkgs.runCommand "hypr-config" { } ''
    cp -a ${configDir}/hypr $out
    chmod -R u+w $out
    mkdir -p $out/custom
    cat > $out/custom/execs.conf <<'EOF'
    ${hostExecs}
    EOF
    cat > $out/custom/general.conf <<'EOF'
    input {
      kb_layout = de
      kb_options = caps:swapescape
    }
    EOF
    : > $out/custom/rules.conf
    cat > $out/custom/env.conf <<'EOF'
    env = XDG_SESSION_TYPE, wayland
    env = XDG_SESSION_DESKTOP, Hyprland
    env = XDG_CURRENT_DESKTOP, Hyprland
    env = MOZ_ENABLE_WAYLAND, 1
    env = QT_QPA_PLATFORM, wayland
    env = GDK_BACKEND, wayland
    env = SDL_VIDEODRIVER, wayland
    env = CLUTTER_BACKEND, wayland
    env = GBM_BACKEND, nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME, nvidia
    env = __EGL_VENDOR_LIBRARY_FILENAMES, /run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
    env = LIBVA_DRIVER_NAME, nvidia
    env = WLR_NO_HARDWARE_CURSORS, 1
    env = QML2_IMPORT_PATH, /etc/profiles/per-user/eburs/lib/qt-6/qml:${qsPkg}/lib/qt-6/qml
    env = QML_IMPORT_PATH, /etc/profiles/per-user/eburs/lib/qt-6/qml:${qsPkg}/lib/qt-6/qml
    env = QT_PLUGIN_PATH, /etc/profiles/per-user/eburs/lib/qt-6/plugins
    env = XDG_DATA_DIRS, /etc/profiles/per-user/eburs/share:/run/current-system/sw/share:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/home/eburs/.local/share/flatpak/exports/share
    ${hostEnv}
    EOF
    cat > $out/custom/input.conf <<'EOF'
    input {
      kb_layout = de
      kb_options = caps:swapescape
    }
    EOF
    cat > $out/custom/keybinds.conf <<'EOF'
    bind = SUPER, Z, exec, spotify
    bind = SUPER, Y, exec, discord
    bind = SUPER SHIFT, Y, exec, stoat
    bind = CTRL ALT, V, exec, kitty --title uni-vpn -e uni-vpn
    bind = SUPER, E, exec, nautilus --new-window

    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10

    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10
    EOF
    cp -a ${monitorsSrc} $out/custom/monitors.conf
    cp -a ${workspacesSrc} $out/custom/workspaces.conf
    cp -a ${monitorsSrc} $out/monitors.conf
    cp -a ${workspacesSrc} $out/workspaces.conf
  '';
  quickshellConfig = pkgs.runCommand "quickshell-config" { } ''
    cp -a ${configDir}/quickshell $out
    chmod -R u+w $out
    mkdir -p $out/ii/modules/common/widgets/shapes
    cp -a ${inputs.dots-shapes}/* $out/ii/modules/common/widgets/shapes/
    cat > $out/ii/modules/common/widgets/shapes/qmldir <<'EOF'
module qs.modules.common.widgets.shapes
ShapeCanvas 1.0 ShapeCanvas.qml
EOF
  '';
in
{
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.packages =
    [
      dotsQuickshellPkg
      pkgs.kora-icon-theme
      pkgs.bibata-cursors
    ]
    ++ (with dotsPkgs; [
      # illogical-impulse-audio
      cava
      lxqt.pavucontrol-qt
      wireplumber
      pipewire
      libdbusmenu-gtk3
      playerctl

      # illogical-impulse-backlight
      geoclue2
      brightnessctl
      ddcutil

      # illogical-impulse-basic
      bc
      coreutils
      cliphist
      curl
      wget
      jq
      xdg-user-dirs
      rsync
      yq-go

      # illogical-impulse-fonts-themes
      adw-gtk3
      kdePackages.breeze
      kdePackages.breeze-gtk
      eza
      fontconfig
      matugen
      nerd-fonts.jetbrains-mono
      material-symbols
      rubik
      twemoji-color-font

      # illogical-impulse-hyprland
      hyprsunset

      # illogical-impulse-kde
      kdePackages.bluedevil
      gnome-keyring
      networkmanager
      kdePackages.plasma-nm
      kdePackages.polkit-kde-agent-1
      kdePackages.dolphin
      kdePackages.systemsettings

      # illogical-impulse-portal
      xdg-desktop-portal
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland

      # illogical-impulse-python
      uv
      gtk4
      libadwaita
      libsoup_3
      libportal-gtk4
      gobject-introspection

      # illogical-impulse-screencapture
      hyprshot
      slurp
      swappy
      tesseract
      wf-recorder

      # illogical-impulse-toolkit
      upower
      wtype
      ydotool

      # illogical-impulse-widgets
      fuzzel
      glib
      imagemagick
      hypridle
      hyprlock
      hyprpicker
      songrec
      translate-shell
      wlogout
      libqalculate
    ])
    ++ (with dotsPkgs.qt6; [
      qtbase
      qtdeclarative
      qt5compat
      qtimageformats
      qtmultimedia
      qtpositioning
      qtquicktimeline
      qtsensors
      qtsvg
      qttools
      qttranslations
      qtvirtualkeyboard
      qtwayland
      qtshadertools
    ])
    ++ extraDotPkgs
    ++ (with dotsPkgs; [
      kdePackages.kirigami
      kdePackages.kdialog
      kdePackages.syntax-highlighting
    ])
    ++ [
      pkgs.readexpro
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.kirigami.unwrapped
    ];

  xdg.configFile = dotConfigFiles // {
    "hypr" = {
      source = hyprConfig;
      recursive = true;
    };
    "quickshell" = {
      source = quickshellConfig;
      recursive = true;
    };
  };

  xdg.dataFile = dotDataFiles;

  home.sessionVariables = {
    XDG_DATA_DIRS = "/etc/profiles/per-user/eburs/share:/run/current-system/sw/share:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/home/eburs/.local/share/flatpak/exports/share";
    QML2_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [
      qsPkg
      dotsPkgs.qt6.qtbase
      dotsPkgs.qt6.qtdeclarative
      dotsPkgs.qt6.qt5compat
      dotsPkgs.qt6.qtimageformats
      dotsPkgs.qt6.qtmultimedia
      dotsPkgs.qt6.qtpositioning
      dotsPkgs.qt6.qtquicktimeline
      dotsPkgs.qt6.qtsensors
      dotsPkgs.qt6.qtsvg
      dotsPkgs.qt6.qttools
      dotsPkgs.qt6.qttranslations
      dotsPkgs.qt6.qtvirtualkeyboard
      dotsPkgs.qt6.qtwayland
      dotsPkgs.qt6.qtshadertools
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.kirigami.unwrapped
    ];
    QML_IMPORT_PATH = lib.makeSearchPath "lib/qt-6/qml" [
      qsPkg
      dotsPkgs.qt6.qtbase
      dotsPkgs.qt6.qtdeclarative
      dotsPkgs.qt6.qt5compat
      dotsPkgs.qt6.qtimageformats
      dotsPkgs.qt6.qtmultimedia
      dotsPkgs.qt6.qtpositioning
      dotsPkgs.qt6.qtquicktimeline
      dotsPkgs.qt6.qtsensors
      dotsPkgs.qt6.qtsvg
      dotsPkgs.qt6.qttools
      dotsPkgs.qt6.qttranslations
      dotsPkgs.qt6.qtvirtualkeyboard
      dotsPkgs.qt6.qtwayland
      dotsPkgs.qt6.qtshadertools
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.kirigami.unwrapped
    ];
    QT_PLUGIN_PATH = lib.makeSearchPath "lib/qt-6/plugins" [
      qsPkg
      dotsPkgs.qt6.qtbase
      dotsPkgs.qt6.qtdeclarative
      dotsPkgs.qt6.qt5compat
      dotsPkgs.qt6.qtimageformats
      dotsPkgs.qt6.qtmultimedia
      dotsPkgs.qt6.qtpositioning
      dotsPkgs.qt6.qtquicktimeline
      dotsPkgs.qt6.qtsensors
      dotsPkgs.qt6.qtsvg
      dotsPkgs.qt6.qttools
      dotsPkgs.qt6.qttranslations
      dotsPkgs.qt6.qtvirtualkeyboard
      dotsPkgs.qt6.qtwayland
      dotsPkgs.qt6.qtshadertools
      pkgs.kdePackages.kirigami
      pkgs.kdePackages.kirigami.unwrapped
    ];
  };

  home.file.".local/bin/start-hyprland" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      mkdir -p "$HOME/.cache"
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=Hyprland
      export XDG_CURRENT_DESKTOP=Hyprland
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      export GDK_BACKEND=wayland
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
      ${lib.optionalString (hostName == "Skynet") "export WLR_DRM_DEVICES=/dev/dri/card1\n      export AQ_DRM_DEVICES=/dev/dri/card1"}
      export WLR_LOG=1
      export HYPRLAND_LOG_WLR=1
      export WLR_RENDERER_ALLOW_SOFTWARE=1
      export WLR_BACKENDS=drm,libinput
      exec ${pkgs.dbus}/bin/dbus-run-session Hyprland > "$HOME/.cache/hyprland.log" 2>&1
    '';
  };
}
