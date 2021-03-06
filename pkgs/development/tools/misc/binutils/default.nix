{stdenv, fetchurl, noSysDirs, zlib, cross ? null}:

let
    basename = "binutils-2.21";
in
stdenv.mkDerivation rec {
  name = basename + stdenv.lib.optionalString (cross != null) "-${cross.config}";

  src = fetchurl {
    url = "mirror://gnu/binutils/${basename}.tar.bz2";
    sha256 = "1iyhc42zfa0j2gaxy4zvpk47sdqj4rqvib0mb8597ss8yidyrav0";
  };

  patches = [
    # Turn on --enable-new-dtags by default to make the linker set
    # RUNPATH instead of RPATH on binaries.  This is important because
    # RUNPATH can be overriden using LD_LIBRARY_PATH at runtime.
    ./new-dtags.patch
  ];

  buildInputs = [ zlib ];

  inherit noSysDirs;

  preConfigure = ''
    # Clear the default library search path.
    if test "$noSysDirs" = "1"; then
	echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt
    fi

    # Use symlinks instead of hard links to save space ("strip" in the
    # fixup phase strips each hard link separately).
    for i in binutils/Makefile.in gas/Makefile.in ld/Makefile.in; do
        substituteInPlace $i --replace 'ln ' 'ln -s '
    done
  '';

  configureFlags = "--disable-werror" # needed for dietlibc build
      + stdenv.lib.optionalString (stdenv.system == "mips64-linux")
        " --enable-fix-loongson2f-nop"
      + stdenv.lib.optionalString (cross != null) " --target=${cross.config}";

  meta = {
    description = "GNU Binutils, tools for manipulating binaries (linker, assembler, etc.)";

    longDescription = ''
      The GNU Binutils are a collection of binary tools.  The main
      ones are `ld' (the GNU linker) and `as' (the GNU assembler).
      They also include the BFD (Binary File Descriptor) library,
      `gprof', `nm', `strip', etc.
    '';

    homepage = http://www.gnu.org/software/binutils/;

    license = "GPLv3+";

    /* Give binutils a lower priority than gcc-wrapper to prevent a
       collision due to the ld/as wrappers/symlinks in the latter. */
    priority = "10";
  };
}
