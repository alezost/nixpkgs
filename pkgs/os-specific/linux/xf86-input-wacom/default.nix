{ stdenv, fetchurl, 
  file, inputproto, libX11, libXext, libXi, libXrandr, libXrender,
  ncurses, pkgconfig, randrproto, xorgserver, xproto }:

stdenv.mkDerivation rec {
  name = "xf86-input-wacom";
  version = "0.10.10";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/${name}-${version}.tar.bz2";
    sha256 = "03yggp2ww64va6gmasl0gy0rbfcyb1zlj9kapp9kvhk2j4458fdr";
  };

  buildInputs = [ file inputproto libX11 libXext libXi libXrandr libXrender
    ncurses pkgconfig randrproto xorgserver xproto ];

  preConfigure = ''
    ensureDir $out/share/X11/xorg.conf.d
    configureFlags="--with-xorg-module-dir=$out/lib/xorg/modules
    --with-sdkdir=$out/include/xorg --with-xorg-conf-dir=$out/share/X11/xorg.conf.d"
  '';

  postInstall =
    ''
      ensureDir $out/lib/udev/rules.d
      cp ${./10-wacom.rules} $out/lib/udev/rules.d/10-wacom.rules
    '';

  meta = with stdenv.lib; {
    maintainers = [ maintainers.goibhniu maintainers.urkud ];
    description = "Wacom digitizer driver for X11";
    homepage = http://linuxwacom.sourceforge.net;
    license = licenses.gpl2;
    platforms = platforms.linux; # Probably, works with other unices as well
  };
}
