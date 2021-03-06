{ stdenv, fetchurl, pkgconfig, postgresql, curl, openssl, zlib }:

let

  version = "1.8.4";
  
  src = fetchurl {
    url = "mirror://sourceforge/zabbix/zabbix-${version}.tar.gz";
    sha256 = "0fhn4gw8r96dy0z227k5bl144zpmgsk1jkwzhi61qqr44mz27fqc";
  };

  preConfigure =
    ''
      substituteInPlace ./configure \
        --replace " -static" "" \
        ${stdenv.lib.optionalString (stdenv.gcc.libc != null) ''
          --replace /usr/include/iconv.h ${stdenv.gcc.libc}/include/iconv.h
        ''}
    '';

in

{

  server = stdenv.mkDerivation {
    name = "zabbix-${version}";

    inherit src preConfigure;

    configureFlags = "--enable-agent --enable-server --with-pgsql --with-libcurl";

    buildInputs = [ pkgconfig postgresql curl openssl zlib ];

    postInstall =
      ''
        ensureDir $out/share/zabbix
        cp -prvd frontends/php $out/share/zabbix/php
        ensureDir $out/share/zabbix/db/data
        cp -prvd create/data/*.sql $out/share/zabbix/db/data
        ensureDir $out/share/zabbix/db/schema
        cp -prvd create/schema/*.sql $out/share/zabbix/db/schema
      '';

    meta = {
      description = "An enterprise-class open source distributed monitoring solution";
      homepage = http://www.zabbix.com/;
      license = "GPL";
      maintainers = [ stdenv.lib.maintainers.eelco ];
      platforms = stdenv.lib.platforms.linux;
    };
  };
  
  agent = stdenv.mkDerivation {
    name = "zabbix-agent-${version}";

    inherit src preConfigure;

    configureFlags = "--enable-agent";

    meta = {
      description = "An enterprise-class open source distributed monitoring solution (client-side agent)";
      homepage = http://www.zabbix.com/;
      license = "GPL";
      maintainers = [ stdenv.lib.maintainers.eelco ];
      platforms = stdenv.lib.platforms.all;
    };
  };
  
}
