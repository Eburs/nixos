{ config, lib, pkgs, ... }:

with lib;
let
  build-dependent-pkgs = with pkgs;
    [
      acl
      attr
      bzip2
      curl
      libsodium
      libssh
      libxml2
      openssl
      stdenv.cc.cc
      systemd
      util-linux
      xz
      zlib
      zstd
      glib
      libcxx
    ];

  makePkgConfigPath = x: makeSearchPathOutput "dev" "lib/pkgconfig" x;
  makeIncludePath = x: makeSearchPathOutput "dev" "include" x;

  nvim-depends-library = pkgs.buildEnv {
    name = "nvim-depends-library";
    paths = map lib.getLib build-dependent-pkgs;
    extraPrefix = "/lib/nvim-depends";
    pathsToLink = [ "/lib" ];
    ignoreCollisions = true;
  };
  nvim-depends-include = pkgs.buildEnv {
    name = "nvim-depends-include";
    paths = splitString ":" (makeIncludePath build-dependent-pkgs);
    extraPrefix = "/lib/nvim-depends/include";
    ignoreCollisions = true;
  };

  nvim-depends-pkgconfig = pkgs.buildEnv {
    name = "nvim-depends-pkgconfig";
    paths = splitString ":" (makePkgConfigPath build-dependent-pkgs);
    extraPrefix = "/lib/nvim-depends/pkgconfig";
    ignoreCollisions = true;
  };

  buildEnv = [
    "CPATH=${config.home.profileDirectory}/lib/nvim-depends/include"
    "CPLUS_INCLUDE_PATH=${config.home.profileDirectory}/lib/nvim-depends/include/c++/v1"
    "LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "NIX_LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "PKG_CONFIG_PATH=${config.home.profileDirectory}/lib/nvim-depends/pkgconfig"
  ];
in
{
  home.packages = with pkgs; [
    patchelf
    nvim-depends-include
    nvim-depends-library
    nvim-depends-pkgconfig
    fd
    ripgrep
  ];

  home.extraOutputsToInstall = [ "nvim-depends" ];

  home.shellAliases.nvim = (concatStringsSep " " buildEnv)
    + " SQLITE_CLIB_PATH=${pkgs.sqlite.out}/lib/libsqlite3.so " + "nvim";

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    extraWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      "${config.home.profileDirectory}/lib/nvim-depends/lib"
      "--prefix"
      "NIX_LD_LIBRARY_PATH"
      ":"
      "${config.home.profileDirectory}/lib/nvim-depends/lib"
    ];

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    extraPackages = with pkgs; [
      doq
      sqlite
      cargo
      cmake
      gcc
      gnumake
      ninja
      pkg-config
      tree-sitter
      yarn
    ];

    extraLuaPackages = ls: with ls; [ luarocks ];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
    force = true;
  };
}
