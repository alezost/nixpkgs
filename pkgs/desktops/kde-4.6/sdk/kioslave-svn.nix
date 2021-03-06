{ kde, cmake, kdelibs, automoc4, subversion, apr, aprutil }:

kde.package {
  buildInputs = [ cmake kdelibs automoc4 subversion apr aprutil ];

  patches = [ ./find-svn.patch ];
  cmakeFlags = "-DBUILD_kioslave=ON";

  meta = {
    description = "svn:/ kioslave";
    kde = {
      name = "kioslave-svn";
      module = "kdesdk";
      version = "4.5.90";
    };
  };
}
