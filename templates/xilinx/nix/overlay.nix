let 
  getEnv' = 
    key:
    let 
      val = builtins.getEnv key;
    in
    if val == "" then builtins.throw " ${key} not set or 'impure' not appiled" else val;
in
final: prev: {
  vcs-fhs-env = final.callPackage ./pkgs/vcs-fhs-env.nix { inherit getEnv';};
  # xilinx-fhs-env = final.callPackage ./pkgs/xilinx-fhs-env.nix { inherit getEnv';};
  demo = final.lib.recurseIntoAttrs (final.callPackage ./demo { });
}
