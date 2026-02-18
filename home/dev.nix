{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # C/C++ toolchain
    gcc
    cmake
    gdb
    ninja
    pkg-config
    go

    # Python
    python3
    python3Packages.pip
    python3Packages.jupyterlab
    python3Packages.tensorboard

    # Julia
    julia

    # LaTeX + LanguageTool
    texliveFull
    languagetool

    fastfetch
  ];
}
