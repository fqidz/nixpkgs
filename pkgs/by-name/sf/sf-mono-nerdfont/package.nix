{
  lib,
  fontforge,
  nerd-font-patcher,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sf-mono-nerdfont";
  version = "1.0";

  src = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
    hash = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
  };

  nativeBuildInputs = [
    undmg
    fontforge
    nerd-font-patcher
  ];

  unpackPhase = ''
    mkdir $out
    # mv $src $out
    undmg $src
    echo "BALLS"
    echo $src
    echo "BALLS"
    echo "BALLS"
    echo $out
    echo "BALLS"
  '';

  buildPhase = ''
    # runHook preBuild
    # nerd-font-patcher Inter.ttc
    # runHook postBuild
  '';

  # installPhase = ''
  #   runHook preInstall
  #   install -Dm444 'Inter Nerd Font.ttc' $out/share/fonts/truetype/InterNerdFont.ttc
  #   cp *.ttf $out/share/fonts/truetype
  #   runHook postInstall
  # '';

  meta = {
    homepage = "https://developer.apple.com/fonts/";
    description = "Nerdfont patch for SF-Mono";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.fqidz ];
  };
})
