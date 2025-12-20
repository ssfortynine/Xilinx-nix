{ lib, newScope }:
lib.makeScope newScope (
  scope:
  let
    designTarget = "Demo";
  in
  {
    # RTL
    rtl = scope.callPackage ./rtl.nix { target = designTarget; };
    # Verilator
    verilated = scope.callPackage ./verilated.nix {
      rtl = scope.rtl; 
    };
    verilated-trace = scope.verilated.override { enable-trace = true; };

    # VCS
    vcs = scope.callPackage ./vcs.nix {
      rtl = scope.rtl;
    };
    vcs-trace = scope.vcs.override { enable-trace = true; };
    
  }
)
