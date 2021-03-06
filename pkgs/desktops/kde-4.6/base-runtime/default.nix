{ kde, cmake, perl, bzip2, xz, qt4, alsaLib, xineLib, samba,
  shared_mime_info, exiv2, libssh , kdelibs, automoc4, strigi, soprano,
  cluceneCore, attica, virtuoso, makeWrapper, oxygen_icons }:

kde.package {

  buildInputs = [ cmake perl bzip2 xz qt4 alsaLib xineLib samba shared_mime_info
    exiv2 libssh kdelibs automoc4 strigi soprano cluceneCore attica
    makeWrapper];

# TODO: OpenSLP, OpenEXR
  postInstall = ''
    rm -v $out/share/icons/default.kde4
    wrapProgram "$out/bin/nepomukservicestub" --prefix LD_LIBRARY_PATH : "${virtuoso}/lib" \
        --prefix PATH : "${virtuoso}/bin"
  '';

  meta = {
    description = "KDE runtime";
    longDescription = "Libraries and tools which supports running KDE desktop applications";
    license = "LGPL";
    kde.module = "kdebase-runtime";
  };
}
