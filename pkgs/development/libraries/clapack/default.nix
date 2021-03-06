{stdenv, fetchurl, cmake}:

stdenv.mkDerivation rec {
  name = "clapack-3.2.1";

  src = fetchurl {
    url = http://www.netlib.org/clapack/clapack-3.2.1-CMAKE.tgz;
    sha256 = "0nnap9q1mv14g57dl3vkvxrdr10k5w7zzyxs6rgxhia8q8mphgqb";
  };

  buildNativeInputs = [ cmake ];

  installPhase = ''
    ensureDir $out/include $out/lib
    cp SRC/*.a F2CLIBS/libf2c/*.a BLAS/SRC/*.a $out/lib
    cp ../INCLUDE/* $out/include
  '';

  doCheck = true;
  checkPhase = "ctest";

  meta = {
    homepage = http://www.netlib.org/clapack/;
    description = "f2c'ed version of LAPACK";
    license = "BSD";
  };
}
