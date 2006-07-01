{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "docbook-xsl-1.69.1";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://nix.cs.uu.nl/dist/tarballs/docbook-xsl-1.69.1.tar.gz;
    md5 = "6f2478faea86bd55abb36ddb57291347";
  };
}
