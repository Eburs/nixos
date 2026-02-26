{ pkgs, lib, ... }:
let
  stoatVersion = "1.1.12";
  stoatArch = if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then "x64"
    else if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then "arm64"
    else throw "Stoat is only packaged for x86_64-linux and aarch64-linux.";
  stoat = pkgs.stdenvNoCC.mkDerivation {
    pname = "stoat";
    version = stoatVersion;
    src = pkgs.fetchurl {
      url = "https://github.com/stoatchat/for-desktop/releases/download/v${stoatVersion}/Stoat-linux-${stoatArch}-${stoatVersion}.zip";
      hash = "sha256-6rvbmoSGdmlyXYS7G3iE6nUuL4IHbDTKWiSebAVXq28=";
    };
    nativeBuildInputs = [ pkgs.unzip pkgs.makeWrapper ];
    unpackPhase = ''
      mkdir -p src
      unzip -q "$src" -d src
    '';
    installPhase = ''
      mkdir -p $out/opt/stoat $out/bin $out/share/applications
      cp -a src/Stoat-linux-${stoatArch}/* $out/opt/stoat/
      makeWrapper ${pkgs.steam-run}/bin/steam-run $out/bin/stoat \
        --add-flags "$out/opt/stoat/stoat-desktop --no-sandbox" \
        --set CHROME_DISABLE_SANDBOX 1 \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.nspr pkgs.nss ]}
      cat > $out/share/applications/stoat.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=Stoat
      Exec=stoat
      Categories=Network;Chat;
      Terminal=false
      EOF
    '';
    meta = with lib; {
      description = "Stoat desktop client";
      homepage = "https://stoat.chat";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  };
in
{
  home.packages = with pkgs; [
    spotify
    discord
    stoat
  ];
}
