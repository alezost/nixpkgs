{ stdenv, fetchurl, boost, zlib, botan, libidn
, lua, pcre, sqlite, perl, pkgconfig }:

let 
  version = "0.99.1";
  perlVersion = (builtins.parseDrvName perl.name).version;
in

assert perlVersion != "";

stdenv.mkDerivation rec {
  name = "monotone-${version}";
  
  src = fetchurl {
    url = "http://monotone.ca/downloads/${version}/monotone-${version}.tar.gz";
    sha256 = "189h5f6gqd4ng0qmzi3xwnj17nnpxm2vzras216ar6b5yc9bnki0";
  };
  
  buildInputs = [boost zlib botan libidn lua pcre sqlite pkgconfig];
  
  postInstall = ''
    ensureDir $out/share/${name}
    cp -rv contrib/ $out/share/${name}/contrib
    ensureDir $out/lib/perl5/site_perl/${perlVersion}
    cp -v contrib/Monotone.pm $out/lib/perl5/site_perl/${perlVersion}
  '';
  
  meta = {
    description = "A free distributed version control system";
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.all;
  };
}
