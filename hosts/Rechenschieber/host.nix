{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "Rechenschieber";
  gaming.enable = true;
  nvidia.enable = true;
}
