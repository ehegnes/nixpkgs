{ stdenv, fetchurl, pkgconfig, nspr, perl, python, zip, libffi, readline }:

stdenv.mkDerivation rec {
  version = "24.2.0";
  name = "spidermonkey-${version}";

  src = fetchurl {
    url = "http://ftp.mozilla.org/pub/mozilla.org/js/mozjs-${version}.tar.bz2";
    sha256 = "1n1phk8r3l8icqrrap4czplnylawa0ddc2cc4cgdz46x3lrkybz6";
  };

  propagatedBuildInputs = [ nspr ];

  buildInputs = [ pkgconfig perl python zip libffi readline ];

  postPatch = ''
    # Fixes an issue with version detection under perl 5.22.x
    sed -i 's/(defined\((@TEMPLATE_FILE)\))/\1/' config/milestone.pl
  '';

  postUnpack = "sourceRoot=\${sourceRoot}/js/src";

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${nspr}/include/nspr"
    export LIBXUL_DIST=$out
  '';

  configureFlags = [
    "--enable-threadsafe"
    "--with-system-nspr"
    "--with-system-ffi"
    "--enable-readline"
  ];

  # hack around a make problem, see https://github.com/NixOS/nixpkgs/issues/1279#issuecomment-29547393
  preBuild = "touch -- {.,shell,jsapi-tests}/{-lpthread,-ldl}";

  enableParallelBuilding = true;

  doCheck = true;
  preCheck = "rm jit-test/tests/sunspider/check-date-format-tofte.js"; # https://bugzil.la/600522

  meta = with stdenv.lib; {
    description = "Mozilla's JavaScript engine written in C/C++";
    homepage = https://developer.mozilla.org/en/SpiderMonkey;
    # TODO: MPL/GPL/LGPL tri-license.
    maintainers = [ maintainers.goibhniu ];
  };
}

