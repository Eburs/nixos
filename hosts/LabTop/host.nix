{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "LabTop";
  gaming.enable = false;
  nvidia.enable = false;
}
