{ stdenv, fetchurl, unzip, mesa, libX11, SDL, openal }:
stdenv.mkDerivation rec {
  name = "tremulous-${version}";
  version = "1.1.0";
  src1 = fetchurl {
    url = "mirror://sourceforge/tremulous/${name}.zip";
    sha256 = "11w96y7ggm2sn5ncyaffsbg0vy9pblz2av71vqp9725wbbsndfy7";
  };
  # http://tremulous.net/wiki/Client_versions
  src2 = fetchurl {
    url = "http://releases.mercenariesguild.net/client/mgclient_source_Release_1.011.tar.gz";
    sha256 = "1vrsi7va7hdp8k824663s1pyw9zpsd4bwwr50j7i1nn72b0v9a26";
  };
  src3 = fetchurl {
    url = "http://releases.mercenariesguild.net/tremded/mg_tremded_source_1.01.tar.gz";
    sha256 = "1njrqlhzjvy9myddzkagszwdcf3m4h08wip888w2rmbshs6kz6ql";
  };
  buildInputs = [ unzip mesa libX11 SDL openal ];
  unpackPhase = ''
    unzip $src1
    cd tremulous
    tar xvf $src2
    mkdir mg_tremded_source
    cd mg_tremded_source
    tar xvf $src3
    cd ..
  '';
  buildPhase = ''
    cd Release_1.011
    make
    cd ..
    cd mg_tremded_source
    make
    cd ..
  '';
  installPhase = ''
    arch=$(uname -m | sed -e s/i.86/x86/)
    ensureDir $out/opt/tremulous
    cp -v Release_1.011/build/release-linux-$arch/tremulous.$arch $out/opt/tremulous/
    cp -v mg_tremded_source/build/release-linux-$arch/tremded.$arch $out/opt/tremulous/
    cp -rv base $out/opt/tremulous
    ensureDir $out/bin
    for b in tremulous tremded
    do
        cat << EOF > $out/bin/$b
    #!/bin/sh
    cd $out/opt/tremulous
    ./$b.$arch "$@"
    EOF
        chmod +x $out/bin/$b
    done
  '';
  meta = {
    description = "A game that blends a team based FPS with elements of an RTS";
    longDescription = ''
      Tremulous is a free, open source game that blends a team based FPS with
      elements of an RTS. Players can choose from 2 unique races, aliens and
      humans. Players on both teams are able to build working structures
      in-game like an RTS. These structures provide many functions, the most
      important being spawning. The designated builders must ensure there are
      spawn structures or other players will not be able to rejoin the game
      after death. Other structures provide automated base defense (to some
      degree), healing functions and much more...
    '';
    homepage = http://www.tremulous.net;
    license = [ "GPLv2" ];  # media under cc by-sa 2.5
    maintainers = with stdenv.lib.maintainers; [ astsmtl ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
