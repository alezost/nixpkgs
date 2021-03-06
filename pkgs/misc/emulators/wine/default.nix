{ stdenv, fetchurl, xlibs, flex, bison, mesa, alsaLib
, ncurses, libpng, libjpeg, lcms, freetype, fontconfig, fontforge
, libxml2, libxslt, openssl, gnutls
}:

assert stdenv.isLinux;
assert stdenv.gcc.gcc != null;

let
  s = import ./src-for-default.nix;
in

stdenv.mkDerivation rec {
  name = "wine-${s.version}";

  src = fetchurl {
    url = s.url;
    sha256 = s.hash;
  };

  gecko = fetchurl {
    url = "http://downloads.sourceforge.net/wine/wine_gecko-1.1.0-x86.cab";
    sha256 = "0a8bpqqhx146innrdwhn4c0jqi90mkmp8kw6aqwildm073yy31hp";
  };

  buildInputs = [
    xlibs.xlibs flex bison xlibs.libXi mesa
    xlibs.libXcursor xlibs.libXinerama xlibs.libXrandr
    xlibs.libXrender xlibs.libXxf86vm xlibs.libXcomposite
    alsaLib ncurses libpng libjpeg lcms fontforge
    libxml2 libxslt openssl gnutls
  ];

  # Wine locates a lot of libraries dynamically through dlopen().  Add
  # them to the RPATH so that the user doesn't have to set them in
  # LD_LIBRARY_PATH.
  NIX_LDFLAGS = map (path: "-rpath ${path}/lib ") [
    freetype fontconfig stdenv.gcc.gcc mesa mesa.libdrm
    xlibs.libXinerama xlibs.libXrender xlibs.libXrandr
    xlibs.libXcursor xlibs.libXcomposite libpng libjpeg
    openssl gnutls
  ];

  # Don't shrink the ELF RPATHs in order to keep the extra RPATH
  # elements specified above.
  dontPatchELF = true;

  postInstall = "install -D ${gecko} $out/share/wine/gecko/wine_gecko-1.1.0-x86.cab";

  enableParallelBuilding = true;

  meta = {
    homepage = "http://www.winehq.org/";
    license = "LGPL";
    description = "An Open Source implementation of the Windows API on top of X, OpenGL, and Unix";
    maintainers = [stdenv.lib.maintainers.raskin stdenv.lib.maintainers.simons];
    platforms = stdenv.lib.platforms.linux;
  };
}
