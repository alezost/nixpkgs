{ stdenv, fetchurl, perl, gettext, makeWrapper, lib, PerlMagick,
  TextMarkdown, URI, HTMLParser, HTMLScrubber, HTMLTemplate, TimeDate,
  CGISession, CGIFormBuilder, DBFile, LocaleGettext, RpcXML, XMLSimple
, gitSupport ? false
, git ? null
, monotoneSupport ? false
, monotone ? null
, extraUtils ? []
}:

assert gitSupport -> (git != null);
assert monotoneSupport -> (monotone != null);

let
  name = "ikiwiki";
  version = "3.20100704";
in
stdenv.mkDerivation {
  name = "${name}-${version}";

  src = fetchurl {
    url = "http://ftp.de.debian.org/debian/pool/main/i/ikiwiki/${name}_${version}.tar.gz";
    sha256 = "1kakh2bf9k0fhvqhn9p9g4wwck64if2y9z23zmlcrm02bw1m6lr9";
  };

  buildInputs = [ perl TextMarkdown URI HTMLParser HTMLScrubber HTMLTemplate
    TimeDate gettext makeWrapper DBFile CGISession CGIFormBuilder LocaleGettext
    RpcXML XMLSimple PerlMagick]
    ++ stdenv.lib.optionals gitSupport [git]
    ++ stdenv.lib.optionals monotoneSupport [monotone];


  patchPhase = ''
    sed -i s@/usr/bin/perl@${perl}/bin/perl@ pm_filter mdwn2man
    sed -i s@/etc/ikiwiki@$out/etc@ Makefile.PL
    sed -i /ENV{PATH}/d ikiwiki.in
    # State the gcc dependency, and make the cgi use our wrapper
    sed -i -e 's@$0@"'$out/bin/ikiwiki'"@' \
        -e "s@'cc'@'${stdenv.gcc}/bin/gcc'@" IkiWiki/Wrapper.pm
  '';

  configurePhase = "perl Makefile.PL PREFIX=$out";

  postInstall = ''
    for a in $out/bin/*; do
      wrapProgram $a --suffix PERL5LIB : $PERL5LIB --prefix PATH : ${perl}/bin:$out/bin \
      ${lib.optionalString (git != null)
        ''--prefix PATH : ${git}/bin \''}
      ${lib.optionalString (monotone != null)
        ''--prefix PATH : ${monotone}/bin \''}
      ${lib.concatMapStrings (x: "--prefix PATH : ${x}/bin ") extraUtils}
    done
  '';

  meta = {
    description = "Wiki compiler, storing pages and history in a RCS";
    homepage = http://ikiwiki.info/;
    license = "GPLv2+";
  };
}
