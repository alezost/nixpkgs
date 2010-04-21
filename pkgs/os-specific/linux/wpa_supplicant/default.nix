{stdenv, fetchurl, openssl, qt4 ? null}:

stdenv.mkDerivation rec {
  name = "wpa_supplicant-0.7.2";

  src = fetchurl {
    url = "http://hostap.epitest.fi/releases/${name}.tar.gz";
    sha256 = "1gnwhnczli50gidsq22ya68hixmdrhd1sxw202ygihvg6xsjl06z";
  };

  preBuild = ''
    cd wpa_supplicant
    cp defconfig .config
    echo CONFIG_DEBUG_SYSLOG=y >> .config
    substituteInPlace Makefile --replace /usr/local $out
    makeFlagsArray=(ALL="wpa_supplicant wpa_passphrase wpa_cli ${if qt4 == null then "" else "wpa_gui-qt4"}")
  '';

  buildInputs = [openssl qt4];

  postInstall = ''
    ensureDir $out/share/man/man5 $out/share/man/man8
    cp doc/docbook/*.5 $out/share/man/man5/
    cp doc/docbook/*.8 $out/share/man/man8/
  '';

  meta = {
    homepage = http://hostap.epitest.fi/wpa_supplicant/;
    description = "A tool for connecting to WPA and WPA2-protected wireless networks";
  };
}
