{
  description = "Xilinx Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
      flake-utils,
      ...
    }:
    let 
      overlay = import ./overlay.nix;
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
        { system, pkgs, ... }:
        {
          _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays = with inputs; [
                overlay
              ];
          };
          legacyPackages = pkgs;

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt = {
              enable = true;
            }; 
            programs.verible-verilog-format = {
              enable = true;
            };
          };

          devShells.default = with pkgs;
              mkShell (
                {
                  inputsForm = [ demo.demo-compiled ];
                  packages = [
                    nixd
                  ];
                }
                // demo.demo-compiled.env
              );
        };
    };
}

