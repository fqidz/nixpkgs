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
  pkgsi686Linux,
}:
let
  model = "dcpt510w";
in
{
  driver = stdenv.mkDerivation (finalAttrs: {
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

    buildInputs = [
      cups
      ghostscript
    ];

    # dontBuild = true;

    unpackPhase = ''
      dpkg-deb -x $src $out
    '';

    # substituteInPlace $dir/lpd/filter_${model} \
    #   --replace-fail "/usr/bin/perl" "${perl}/bin/perl" \
    #   --replace-fail "/usr/bin/pdf2ps" "${ghostscript}/bin/pdf2ps"

    installPhase = ''
      dir=$out/opt/brother/Printers/${model}

      # install lpr
      patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 \
        $dir/lpd/br${model}filter

      wrapProgram $dir/inf/setupPrintcapij \
        --prefix PATH ":" ${
          lib.makeBinPath [
            coreutils
          ]
        }

      wrapProgram $dir/lpd/filter_${model} \
        --prefix PATH ":" ${
          lib.makeBinPath [
            coreutils
            perl
            ghostscript
            file
            gnused
          ]
        }


      echo "----------------------"
      echo $dir
      echo "----------------------"
    '';

    meta = {
      homepage = "http://www.brother.com/";
      description = "Brother DCP-T510W printer driver";
      downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=us_ot&lang=en&prod=dcpt510w_all&os=128";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux;
      maintainers = [ lib.maintainers.fqidz ];
    };
  });
}
