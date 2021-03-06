{ stdenv, fetchurl, gperf, pkgconfig, glib, acl
, libusb, usbutils, pciutils }:

assert stdenv ? glibc;

stdenv.mkDerivation rec {
  name = "udev-160";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/kernel/hotplug/${name}.tar.bz2";
    sha256 = "0wx43bxiff8i80k7w3j2iszksdzw1hz6sanx8cjsiypgppi4fr12";
  };

  buildInputs = [ gperf pkgconfig glib acl libusb usbutils ];

  configureFlags =
    ''
      --with-pci-ids-path=${pciutils}/share/pci.ids
      --disable-introspection
      --with-firmware-path=/root/test-firmware:/var/run/current-system/firmware
    '';

  postInstall =
    ''
      # The path to rule_generator.functions in write_cd_rules and
      # write_net_rules is broken.  Also, don't store the mutable
      # persistant rules in /etc/udev/rules.d but in
      # /var/lib/udev/rules.d.
      for i in $out/libexec/write_cd_rules $out/libexec/write_net_rules; do
        substituteInPlace $i \
          --replace /lib/udev $out/libexec \
          --replace /etc/udev/rules.d /var/lib/udev/rules.d
      done

      # Don't set PATH to /bin:/sbin; won't work in NixOS.
      sed -e '/PATH=/d' -i $out/libexec/rule_generator.functions

      ln -s $out/lib/ConsoleKit $out/etc/ConsoleKit
    '';
  
  meta = {
    homepage = http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html;
    description = "Udev manages the /dev filesystem";
  };
}
