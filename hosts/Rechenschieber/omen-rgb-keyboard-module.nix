{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  pname = "omen-rgb-keyboard-module";
  version = "1.3-94080b1";

  src = fetchFromGitHub {
    owner = "alessandromrc";
    repo = "omen-rgb-keyboard";
    rev = "94080b1c440acedef9cde85fd5298dcf3847caf0";
    hash = "sha256-HScIJl1L5xhK+tt0HbC0GGeV74JTVmy/KsKHGZoBsyc=";
  };

  sourceRoot = "${src.name}/src";
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    install -D -m 0644 omen_rgb_keyboard.ko \
      $out/lib/modules/${kernel.modDirVersion}/extra/omen_rgb_keyboard.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "HP Omen RGB Keyboard kernel module";
    homepage = "https://omenlinux.github.io/omen-rgb-keyboard/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
