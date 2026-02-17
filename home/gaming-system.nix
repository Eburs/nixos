{ config, lib, pkgs, ... }:

let
  cfgGaming = config.gaming;
  cfgNvidia = config.nvidia;
in
{
  options.gaming.enable = lib.mkEnableOption "Gaming package bundle and related services";
  options.nvidia.enable = lib.mkEnableOption "NVIDIA driver stack (explicit switch)";
  options.nvidia.open = lib.mkEnableOption ''
    Use NVIDIA open kernel modules (recommended for Turing/RTX/GTX 16xx and newer;
    set to false for older GPUs)
  '';

  config = lib.mkMerge [
    (lib.mkIf cfgNvidia.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.open = cfgNvidia.open;
      hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

      # This option is likely wrong; see note below.
      # hardware.nvidia.datacenter = true;
    })

    (lib.mkIf cfgGaming.enable {
      services.ananicy.enable = true;
      services.ananicy.package = pkgs.ananicy-cpp;

      programs.steam.enable = true;
      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        steam-run
        mangohud
        goverlay
        vkbasalt
        gamescope
        gamemode
        heroic
        lutris
        bottles
        wineWow64Packages.stable
        winetricks
        protonup-qt
        prismlauncher
      ];
    })
  ];
}
