{ pkgs, ... }:
{
  home.packages = with pkgs; [
    easyeffects
    lsp-plugins
    zam-plugins
    calf
    mda_lv2
  ];

  xdg.dataFile."easyeffects/output/GentleDynamics.json" = {
    source = ./easyeffects/GentleDynamics.json;
  };
  xdg.dataFile."easyeffects/input/GentleDynamics.json" = {
    source = ./easyeffects/GentleDynamics.json;
  };

  services.easyeffects = {
    enable = true;
    preset = "GentleDynamics";
  };
}
