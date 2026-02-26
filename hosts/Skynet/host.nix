{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "Skynet";
  gaming.enable = true;
  nvidia.enable = true;
  nvidia.open = true;

  # Desktop: always stay on balanced, never power-saver.
  systemd.services.power-profile-power-saver.enable = false;
  systemd.services.power-profile-on-battery.enable = false;
  systemd.services.power-profile-on-ac.wantedBy = [ "multi-user.target" ];
  services.udev.extraRules = lib.mkForce ''
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-on-ac.service"
  '';
}
