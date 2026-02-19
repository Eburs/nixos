{ config, lib, pkgs, ... }:

let
  colorHex = "FFFFFF";
  sysfsAll = "/sys/devices/platform/omen-rgb-keyboard/rgb_zones/all";
  omenRgbModule = config.boot.kernelPackages.callPackage ./omen-rgb-keyboard-module.nix { };
in
{
  boot.blacklistedKernelModules = [ "hp_wmi" ];

  boot.extraModulePackages = [ omenRgbModule ];
  boot.kernelModules = [ "omen_rgb_keyboard" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="platform", KERNEL=="omen-rgb-keyboard", ATTR{rgb_zones/*}=="*", GROUP="input", MODE="0664"
    SUBSYSTEM=="platform", KERNEL=="omen-rgb-keyboard", ATTR{rgb_zones/brightness}=="*", GROUP="input", MODE="0664"
    SUBSYSTEM=="platform", KERNEL=="omen-rgb-keyboard", ATTR{rgb_zones/animation_mode}=="*", GROUP="input", MODE="0664"
    SUBSYSTEM=="platform", KERNEL=="omen-rgb-keyboard", ATTR{rgb_zones/animation_speed}=="*", GROUP="input", MODE="0664"
  '';

  systemd.services.omen-keyboard-rgb = {
    description = "Set HP Omen keyboard zones to white";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    unitConfig = {
      ConditionPathExists = sysfsAll;
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'printf 0x${colorHex} > ${sysfsAll}'";
    };
  };
}
