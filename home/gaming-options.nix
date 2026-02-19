{ lib, ... }:
{
  options.gaming.enable = lib.mkEnableOption "Gaming-specific Home Manager integration (GNOME keybindings)";
}
