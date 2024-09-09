{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  cups,
  coreutils,
  file,
  perl,
  gnused,
  ghostscript,
  psutils,
  libredirect,
  pkgsi686Linux,
  debugLvl ? 0,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "brother-dcpt510w";
  version = "1.0.1-0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103620/dcpt510wpdrv-${finalAttrs.version}.i386.deb";
    hash = "sha256-hbfVL+sO9/A62q62rafzHHJ8LjuEaHNVXLXZySXiVtw=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  buildInputs = [
    cups
    ghostscript
    psutils
  ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    runHook preInstall

    LPDDIR=$out/opt/brother/Printers/dcpt510w/lpd
    WRAPPER=$out/opt/brother/Printers/dcpt510w/cupswrapper/brother_lpdwrapper_dcpt510w

    interpreter=${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2

    # Subsitute variables/paths to work with nix paths
    # note:
    #   (1) the function on brother_ldpwrapper_dcpt510w:878
    #     tries to execute $lpdconf_command, but $lpdconf file doesn't
    #     exist ($out/opt/brother/Printers/dcpt510w/lpd/brprintconf_dcpt510w)
    #   (2) this file uses $LPDIR/filter_dcpt510w (on line 106)
    substituteInPlace $WRAPPER \
      --replace-fail "/usr/bin/perl" "${perl}/bin/perl" \
      --replace-fail "PRINTER =~" "PRINTER = \"dcpt510w\"; #" \
      --replace-fail "\$DEBUG=0;" "\$DEBUG=${toString debugLvl};" \
      --replace-fail "basedir =~" "basedir = \"$out/opt/brother/Printers/dcpt510w/\"; #"

    # note: this file uses $LPDIR/brdcpt510wfilter (on line 71)
    substituteInPlace $LPDDIR/filter_dcpt510w \
      --replace-fail "/usr/bin/perl" "${perl}/bin/perl" \
      --replace-fail "/usr/bin/pdf2ps" "${ghostscript}/bin/pdf2ps" \
      --replace-fail "GHOST_SCRIPT=" "GHOSTCRIPT=\"${ghostscript}/bin/gs\"; #" \
      --replace-fail "PRINTER =~" "PRINTER = \"dcpt510w\"; #" \
      --replace-fail "BR_PRT_PATH =~" "BR_PRT_PATH = \"$out/opt/brother/Printers/dcpt510w/\"; #"

    patchelf --set-interpreter "$interpreter" \
      "$LPDDIR/brdcpt510wfilter"

    # Allows the program to execute commands that they use from these packages
    wrapProgram $WRAPPER \
      --set PATH ${
        lib.makeBinPath [
          cups
          coreutils
          psutils
          gnused
        ]
      }

    wrapProgram $LPDDIR/filter_dcpt510w \
      --set PATH ${
        lib.makeBinPath [
          coreutils
          file
          gnused
        ]
      }

    mkdir -p "$out/lib/cups/filter"
    mkdir -p "$out/share/cups/model"

    # Allow cups to discover the files (?)
    ln -s $out/opt/brother/Printers/dcpt510w/cupswrapper/brother_lpdwrapper_dcpt510w \
      $out/lib/cups/filter/brother_lpdwrapper_dcpt510w

    ln -s $out/opt/brother/Printers/dcpt510w/cupswrapper/brother_dcpt510w_printer_en.ppd \
      $out/share/cups/model/brother_dcpt510w_printer_en.ppd

    runHook postInstall
  '';

  meta = {
    homepage = "http://www.brother.com/";
    description = "Brother DCP-T510W printer driver";
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=us_ot&lang=en&prod=dcpt510w_all&os=128";
    longDescription = ''
      Install this with printing services:
      ```
      ...
        services.printing.enable = true;
        services.printing.drivers = [
          pkgs.brother-dcpt510w
        ];
      ...
      ```
    '';
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.fqidz ];
  };
})
