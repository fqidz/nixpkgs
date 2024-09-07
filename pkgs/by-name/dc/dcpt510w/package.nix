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
  pkgsi686Linux,
}:
let
  model = "dcpt510w";
in
stdenv.mkDerivation (finalAttrs: {
  pname = model;
  version = "1.0.1-0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103620/dcpt510wpdrv-${finalAttrs.version}.i386.deb";
    hash = "sha256-hbfVL+sO9/A62q62rafzHHJ8LjuEaHNVXLXZySXiVtw=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  unpackPhase = ''
    dpkg-deb -x $src $out
  '';

  installPhase = ''
    dir=$out/opt/brother/Printers/${model}

    # install lpr
    substituteInPlace $dir/lpd/filter_${model} \
      --replace-fail "/usr/bin/perl" "${perl}/bin/perl" \
      --replace-fail "/usr/bin/pdf2ps" "${ghostscript}/bin/pdf2ps" \
      --replace-fail '`which gs`' "${ghostscript}/bin/gs"

    patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 \
      $dir/lpd/br${model}filter

    wrapProgram $dir/inf/setupPrintcapij \
      --prefix PATH ":" ${
        lib.makeBinPath [
          coreutils
          gnused
        ]
      }

    wrapProgram $dir/lpd/filter_${model} \
      --prefix PATH ":" ${
        lib.makeBinPath [
          coreutils
          file
          gnused
        ]
      }

    # install cupswrapper
    substituteInPlace $dir/cupswrapper/cupswrapper${model} \
      --replace-fail "/usr/bin/psnup" "${psutils}/bin/psnup" \
      --replace-fail "/usr" "$out/usr" \
      --replace-fail "/opt" "$out/opt"

    wrapProgram $dir/cupswrapper/cupswrapper${model} \
      --prefix PATH ":" ${
        lib.makeBinPath [
          cups
          coreutils
          psutils
          gnused
        ]
      }
  '';

  meta = {
    homepage = "http://www.brother.com/";
    description = "Brother DCP-T510W printer driver";
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=us_ot&lang=en&prod=dcpt510w_all&os=128";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.fqidz ];
  };
})

