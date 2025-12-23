{
  lib,
  stdenv,
  bash,
  vcs-fhs-env,
}:

stdenv.mkDerivation {
  name = "verdi-wrapper";

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/bin

    substitute ${./scripts/verdi-wrapper.sh} $out/bin/verdi-view \
      --subst-var-by shell "${bash}/bin/bash" \
      --subst-var-by vcsFhsEnv "${vcs-fhs-env}/bin/vcs-fhs-env"

    chmod +x $out/bin/verdi-view
  '';

  meta.mainProgram = "verdi-view";
}
