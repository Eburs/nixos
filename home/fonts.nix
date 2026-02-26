{ pkgs, ... }:
let
  spaceGrotesk = pkgs.fetchurl {
    url = "https://github.com/floriankarsten/space-grotesk/raw/master/fonts/ttf/SpaceGrotesk%5Bwght%5D.ttf";
    hash = "sha256:0wlzszxzq3wp6mjh7rv363m1lkzh3rskfh8z1xf6yhwkzkhnvbdc";
  };
in
{
  home.packages = [
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-cjk-serif
    (pkgs.runCommand "space-grotesk-font" { } ''
      mkdir -p $out/share/fonts/truetype
      cp -a ${spaceGrotesk} "$out/share/fonts/truetype/SpaceGrotesk[wght].ttf"
    '')
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Space Grotesk" "Readex Pro" "Rubik" ];
      serif = [ "Readex Pro" "Rubik" "Space Grotesk" ];
      monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono NF" ];
      emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
    };
  };
}
