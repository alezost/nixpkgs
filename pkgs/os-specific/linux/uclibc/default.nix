{stdenv, fetchurl, linuxHeaders, gccCross ? null}:

assert stdenv.isLinux;

let
    target = if (gccCross != null) then gccCross.target else null;
    enableArmEABI = (target == null && stdenv.system "armv5tel-linux")
      || (target != null && target.arch == "arm");

    configArmEABI = if enableArmEABI then
        ''-e 's/.*CONFIG_ARM_OABI.*//' \
        -e 's/.*CONFIG_ARM_EABI.*/CONFIG_ARM_EABI=y/' '' else "";

    enableBigEndian = (target != null && target.bigEndian);
    
    configBigEndian = if enableBigEndian then ""
      else
        ''-e 's/.*ARCH_BIG_ENDIAN.*/#ARCH_BIG_ENDIAN=y/' \
        -e 's/.*ARCH_WANTS_BIG_ENDIAN.*/#ARCH_WANTS_BIG_ENDIAN=y/' \
        -e 's/.*ARCH_WANTS_LITTLE_ENDIAN.*/ARCH_WANTS_LITTLE_ENDIAN=y/' '';

    archMakeFlag = if (target != null) then "ARCH=${target.arch}" else "";
    crossMakeFlag = if (target != null) then "CROSS=${target.config}-" else "";
in
stdenv.mkDerivation {
  name = "uclibc-0.9.30.1" + stdenv.lib.optionalString (target != null)
    ("-" + target.config);

  src = fetchurl {
    url = http://www.uclibc.org/downloads/uClibc-0.9.30.1.tar.bz2;
    sha256 = "132cf27hkgi0q4qlwbiyj4ffj76sja0jcxm0aqzzgks65jh6k5rd";
  };

  configurePhase = ''
    make defconfig ${archMakeFlag}
    sed -e s@/usr/include@${linuxHeaders}/include@ \
      -e 's@^RUNTIME_PREFIX.*@RUNTIME_PREFIX="/"@' \
      -e 's@^DEVEL_PREFIX.*@DEVEL_PREFIX="/"@' \
      -e 's@.*UCLIBC_HAS_WCHAR.*@UCLIBC_HAS_WCHAR=y@' \
      -e 's@.*DO_C99_MATH.*@DO_C99_MATH=y@' \
      -e 's@.*UCLIBC_HAS_PROGRAM_INVOCATION_NAME.*@UCLIBC_HAS_PROGRAM_INVOCATION_NAME=y@' \
      ${configArmEABI} \
      ${configBigEndian} \
      -i .config
    make oldconfig
  '';

  # Cross stripping hurts.
  dontStrip = if (target != null) then true else false;

  makeFlags = [ crossMakeFlag "VERBOSE=1" ];

  buildInputs = stdenv.lib.optional (gccCross != null) gccCross;

  patches = [ ./unifdef-getline.patch ];

  # This will allow the usual gcc-cross-wrapper strip phase work as usual
  crossConfig = if (target != null) then target.config else null;

  installPhase = ''
    mkdir -p $out
    make PREFIX=$out VERBOSE=1 install ${crossMakeFlag}
    (cd $out/include && ln -s ${linuxHeaders}/include/* .) || exit 1
    sed -i s@/lib/@$out/lib/@g $out/lib/libc.so
  '';
  
  meta = {
    homepage = http://www.uclibc.org/;
    description = "A small implementation of the C library";
    license = "LGPLv2";
  };
}