{stdenv, fetchurl, ocaml, zlib, bzip2, ncurses, file, gd, libpng }:

stdenv.mkDerivation (rec {
  name = "mldonkey-3.0.4";
  
  src = fetchurl {
    url = "mirror://sourceforge/mldonkey/${name}.tar.bz2";
    sha256 = "0wnyi2m7126dq6r5zbqplgknnypzcx0p3q2mxcdfhp94ln7vn3f6";
  };
  
  meta = {
    description = "Client for many p2p networks, with multiple frontends";
    homepage = http://mldonkey.sourceforge.net/;
  };

  patches = [ ./gcc44mips64.patch ];

  buildInputs = [ ocaml zlib ncurses bzip2 file gd libpng ];
  configureFlags = [ "--disable-gui" ];
} // (if (stdenv.system != "i686-linux" && stdenv.system != "x86_64-linux") then
{
  # Byte code compilation (the ocaml opt compiler is not supported in many platforms)
  buildPhase = "make mlnet.byte";
  installPhase = ''
    ensureDir $out/bin
    cp mlnet.byte $out/bin/mlnet
  '';

  # ocaml bytecode selfcontained binaries loose the bytecode if stripped
  dontStrip = true;
} else {}))
