{
  description = "Xilinx Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = 
    inputs@{
      self, 
      nixpkgs,
      flake-parts,
      ...
    }:
    let 
      overlay = import ./nix/overlay.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [ 
          "x86_64-linux" 
          "aarch64-linux"
          "aarch64-darwin"
        ];
        
        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        flake.overlays.default = overlay;
        perSystem = 
        { system, pkgs, lib, ... }:
        let
          clean-script = pkgs.writeShellScriptBin "clean" ''
            echo "Cleaning build artifacts..."
            ${lib.getBin pkgs.git}/bin/git clean -fdX .
            echo "Clean complete."
          '';
        in
        {
          _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
              config.allowUnfree = true; 
          };

          packages.default = clean-script;
          apps.clean = {
            type = "app";
            program = lib.getExe clean-script;
          };

          legacyPackages = pkgs;

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.verible-verilog-format.enable = true;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # 开发辅助
              nixd
              verible
              gtkwave  
              pkgs.git
              clean-script
              xilinx-fhs-env
              vcs-fhs-env
            ];

            shellHook = ''
              echo "--- RTL Development Shell ---"
              echo "Available Simulators:"
              echo "  - VDemo (Verilator)"
              echo "  - demo-vcs-simulator (VCS, needs --impure)"
              echo ""
              echo "Available FHS Envs:"
              echo "  - vcs-fhs-env"
              echo "  - xilinx-fhs-env"
            '';
          };
        };
    };
}

