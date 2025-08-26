{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libusb1,
  withFt601Driver ? true,
  # withQemuDevice ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "leechcore-plugins";
  version = "0-unstable-2025-06-18";

  src = fetchFromGitHub {
    owner = "ufrisk";
    repo = "LeechCore-plugins";
    rev = "12cde3099269367540f7ed73376135e65c437955";
    hash = "sha256-tMGOCVX1jrBU5riSk/yTRVAmIxYDpoPpvJlTlR5AOao=";
  };

  buildInputs = [ libusb1 ];
  nativeBuildInputs = [ pkg-config ];

  dontInstall = true;

  postPatch = ""
  + lib.optionalString withFt601Driver ''
    substituteInPlace ./leechcore_ft601_driver_linux/Makefile \
      --replace-fail "mkdir" "# mkdir" \
      --replace-fail "mv leechcore_ft601_driver_linux.so ../files/" "mv leechcore_ft601_driver_linux.so $out/lib/"
  '';
  # + lib.optionalString withQemuDevice ''
  #   substituteInPlace ./leechcore_device_qemu/Makefile \
  #     --replace-fail "mkdir" "# mkdir" \
  #     --replace-fail "mv leechcore_device_qemu.so ../files/" "mv leechcore_device_qemu.so $out/lib/"
  # '';

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib
  ''
  + lib.optionalString withFt601Driver ''
    make -C ./leechcore_ft601_driver_linux/ "$makeFlags"
  ''
  # + lib.optionalString withQemuDevice ''
  #   CFLAGS="-Wno-unused-variable" make -C ./leechcore_device_qemu/
  # ''
  + "runHook postBuild";

  meta = {
    description = "Plugins related to LeechCore";
    homepage = "https://github.com/ufrisk/LeechCore-plugins";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fqidz ];
    platforms = lib.platforms.linux;
  };
})
