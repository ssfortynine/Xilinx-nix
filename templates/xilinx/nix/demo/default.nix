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
      enableTrace = false; 
    };
    verilated-trace = scope.verilated.override { enableTrace = true; };

    # VCS
    vcs = scope.callPackage ./vcs.nix { 
      enableTrace = false; 
    };
    vcs-trace = scope.vcs.override { enableTrace = true; };
  }
)
