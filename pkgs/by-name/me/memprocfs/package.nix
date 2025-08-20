{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libusb1,
  leechcore,
  pkgs,
  fuse,
  withFt601Driver ? false,
  # withQemuDevice ? false,
}:
let
  # withPlugins = withFt601Driver || withQemuDevice;
  withPlugins = withFt601Driver;
  leechcore-plugins = (pkgs.leechcore-plugins.override {
      # inherit withFt601Driver withQemuDevice;
      inherit withFt601Driver;
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "memprocfs";
  version = "5.15";

  src = fetchFromGitHub {
    owner = "ufrisk";
    repo = "MemProcFS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fZEao9HhF1GP5p+XS5qlRB6WeZ9rV5Ys+CZbqXnpBhA=";
  };

  buildInputs = [
    libusb1
    leechcore
    fuse
  ]
  ++ lib.optionals withPlugins [
    leechcore-plugins
  ];

  nativeBuildInputs = [ pkg-config ];

  # Don't copy or output libraries into '../files', but instead link them using
  # LDFLAGS.
  postPatch = ''
    substituteInPlace vmm/Makefile \
      --replace-fail "cp" "# cp" \
      --replace-fail "mv leechcore.so" "# mv leechcore.so" \
      --replace-fail "mv vmm.so ../files/" "mv vmm.so $out/lib/" \

    substituteInPlace memprocfs/Makefile \
      --replace-fail "cp" "# cp" \
      --replace-fail "cp ../files/vmm.so ." "cp $out/lib/vmm.so ." \
      --replace-fail "mv memprocfs ../files/" "mv memprocfs $out/bin/" \
  '';

  preBuild = ''
    mkdir -p $out/lib/ $out/bin/

    LDFLAGS+="-Wl,-rpath,$out/lib "
    LDFLAGS+="-Wl,-rpath,${leechcore}/lib "
    LDFLAGS+="-L$out/lib "
    LDFLAGS+="-L${leechcore}/lib"
  ''
  + lib.optionalString withPlugins ''
    LDFLAGS+=" -Wl,-rpath,${leechcore-plugins}/lib "
    LDFLAGS+="-L${leechcore-plugins}/lib"
  ''
  + "export LDFLAGS";

  dontStrip = true;
  buildPhase = ''
    runHook preBuild

    make -C ./vmm "$makeFlags"
    make -C ./memprocfs "$makeFlags"

    runHook postBuild
  '';

  postFixup = lib.optionalString withFt601Driver ''
    patchelf $out/bin/memprocfs --add-rpath ${leechcore-plugins}/lib
    patchelf $out/bin/memprocfs --add-needed leechcore_ft601_driver_linux.so
  '';
  # + lib.optionalString withQemuDevice ''
  #   patchelf $out/bin/memprocfs --add-needed leechcore_device_qemu.so
  # '';

  meta = {
    description = "MemProcFS is an easy and convenient way of viewing physical memory as files in a virtual file system.";
    homepage = "https://github.com/ufrisk/MemProcFS";
    mainProgram = "memprocfs";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fqidz ];
    platforms = lib.platforms.linux;
  };
})
