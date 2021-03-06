{ kde, cmake, kdelibs, automoc4 }:

kde.package {
  buildInputs = [ cmake kdelibs automoc4 ];

  meta = {
    description = "KDE creature for your desktop";
    kde = {
      name = "amor";
      module = "kdetoys";
      version = "2.4.0";
      versionFile = "src/version.h";
    };
  };
}
