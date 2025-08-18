{
  kernel,
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ch341";
  version = "1.8";
  nativeBuildInputs = kernel.moduleBuildDependencies;

  src = fetchFromGitHub {
    owner = "WCHSoftGroup";
    repo = "ch341ser_linux";
    rev = "0c0e8a289366b654dc5bc222d3fabed6c631f6eb";
    hash = "sha256-7hh3kP3xuknb0OPjpPjFpqxHxCk758bQbFUNrXop/Co=";
  };

  patches = [ ./fix-linux-6-12-build.patch ];

  sourceRoot = "${finalAttrs.src.name}/driver";
  hardeningDisable = [ "pic" ];

  preBuild = ''
    substituteInPlace Makefile \
      --replace-fail '/lib/modules/$(shell uname -r)' "${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  '';

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -v -D -m 644 ./ch341.ko "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/usb/serial/ch341.ko"
    runHook postInstall
  '';

  meta = {
    description = "CH340/CH341 USB to serial port driver";
    homepage = "https://www.wch.cn/downloads/CH341SER_LINUX_ZIP.html";
    downloadPage = "https://github.com/WCHSoftGroup/ch341ser_linux";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fqidz ];
  };
})
