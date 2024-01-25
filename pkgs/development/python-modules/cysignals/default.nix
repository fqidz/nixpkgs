{ lib
, autoreconfHook
, fetchPypi
, buildPythonPackage
, cython_3
, pariSupport ? true, pari # for interfacing with the PARI/GP signal handler
}:

assert pariSupport -> pari != null;

buildPythonPackage rec {
  pname = "cysignals";
  version = "1.11.4";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Dx4yHlWgf5AchqNqHkSX9v+d/nAGgdATCjjDbk6yOMM=";
  };

  # explicit check:
  # build/src/cysignals/implementation.c:27:2: error: #error "cysignals must be compiled without _FORTIFY_SOURCE"
  hardeningDisable = [
    "fortify"
  ];

  # known failure: https://github.com/sagemath/cysignals/blob/582dbf6a7b0f9ade0abe7a7b8720b7fb32435c3c/testgdb.py#L5
  doCheck = false;
  checkTarget = "check-install";

  preCheck = ''
    # Make sure cysignals-CSI is in PATH
    export PATH="$out/bin:$PATH"
  '';

  propagatedBuildInputs = [
    cython_3
  ] ++ lib.optionals pariSupport [
    # When cysignals is built with pari, including cysignals into the
    # buildInputs of another python package will cause cython to link against
    # pari.
    pari
  ];

  nativeBuildInputs = [ autoreconfHook ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Interrupt and signal handling for Cython";
    homepage = "https://github.com/sagemath/cysignals/";
    maintainers = teams.sage.members;
    license = licenses.lgpl3Plus;
  };
}
