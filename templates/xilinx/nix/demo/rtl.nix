{
  lib,
  stdenvNoCC,
  rtl,        
  target,     
}:

stdenvNoCC.mkDerivation {
  name = "${target}-rtl";

  src = rtl;

  dontBuild = true;

  passthru = {
    inherit target;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -r ./* $out/

    pushd $out
    find . -type f \( -name "*.v" -o -name "*.sv" \) > ./filelist.f
    popd

    runHook postInstall
  '';
}
