{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./omen-rgb.nix
  ];

  networking.hostName = "Rechenschieber";
  gaming.enable = true;
  nvidia.enable = true;
  nvidia.open = false;
  nvidia.persistenced.enable = true;
}
