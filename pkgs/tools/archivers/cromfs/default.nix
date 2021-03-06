{stdenv, fetchurl, pkgconfig, fuse, perl}:

stdenv.mkDerivation rec {
  name = "cromfs-1.5.9.1";
  src = fetchurl {
    url = "http://bisqwit.iki.fi/src/arch/${name}.tar.bz2";
    sha256 = "02k0nd7zvcksn7vjxlynsdgdvkayfzzhv622n9zkka94756lr0fk";
  };

  patchPhase = ''sed -i 's@/bin/bash@/bin/sh@g' configure; set -x'';

  meta = {
    description = "FUSE Compressed ROM filesystem with lzma"  ;
	  homepage = http://bisqwit.iki.fi/source/cromfs.html;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux;
  };

  # Removing the static linking, as it doesn't compile in x86_64.
  makeFlags = "cromfs-driver util/mkcromfs util/unmkcromfs util/cvcromfs";
  
  installPhase = ''
    install -d $out/bin
    install cromfs-driver $out/bin
    install util/cvcromfs $out/bin
    install util/mkcromfs $out/bin
    install util/unmkcromfs $out/bin
  '';

  buildInputs = [pkgconfig fuse perl];
}
