{ lib, newScope }:
lib.makeScope newScope (
  scope:
  let
    designTarget = "demo";
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

    vcs-xilinx = scope.callPackage ./vcs-xilinx.nix { 
      enableTrace = true; 
    };

    # vivado simulation flow
    vivado-sim = scope.callPackage ./vivado-sim.nix { };

    # Verdi
    verdi = scope.callPackage ./verdi.nix { };
  }
)
