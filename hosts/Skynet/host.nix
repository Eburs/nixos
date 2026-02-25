{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "Skynet";
  gaming.enable = true;
  nvidia.enable = true;
  nvidia.open = true;
}
