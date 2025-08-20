{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libusb1,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "leechcore";
  version = "2.22";

  src = fetchFromGitHub {
    owner = "ufrisk";
    repo = "LeechCore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q2Uthjj8E+/LrksuUplpOcUF6eN6+l7SFHHkZN+FXUY=";
  };

  buildInputs = [ libusb1 ];
  nativeBuildInputs = [ pkg-config ];

  dontInstall = true;
  sourceRoot = "source/leechcore";

  postPatch = ''
    mkdir -p $out/lib
    substituteInPlace Makefile \
      --replace-fail "mv leechcore.so ../files/" "mv leechcore.so $out/lib/"
  '';

  buildPhase = ''
    runHook preBuild

    make "$makeFlags"
    runHook postBuild
  '';

  meta = {
    description = "Physical Memory Acquisition Library";
    longDescription = ''
      The LeechCore Memory Acquisition Library focuses on Physical Memory
      Acquisition using various hardware and software based methods.
    '';
    homepage = "https://github.com/ufrisk/LeechCore";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fqidz ];
    platforms = lib.platforms.linux;
  };
})
