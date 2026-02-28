{
  description = "Hyprland helpers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    crane = {
      url = "github:ipetkov/crane";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      crane,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        { config, pkgs, ... }:
        let
          craneLib = crane.mkLib pkgs;
          version = "0.1.0";
          src = craneLib.cleanCargoSource (craneLib.path ./src);
          commonArgs = {
            inherit src version;
            strictDeps = true;
            pname = "hyprland-helpers";
            name = "hyprland-helpers";
            buildInputs = nixpkgs.lib.optionals pkgs.stdenv.isDarwin [
              pkgs.libiconv
            ];
          };

          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          hyprland-helpers = craneLib.buildPackage (
            commonArgs
            // {
              inherit cargoArtifacts;
              meta.mainProgram = "";
            }
          );

          workspaceMembers = (builtins.fromTOML (builtins.readFile ./src/Cargo.toml)).workspace.members;
          workspaceNixPackages = builtins.listToAttrs (
            map (name: {
              inherit name;
              value = craneLib.buildPackage {
                inherit src cargoArtifacts version;
                pname = name;
                cargoExtraArgs = "-p ${name}";
                meta.mainProgram = name;
              };
            }) workspaceMembers
          );
        in
        {
          packages = {
            default = hyprland-helpers;
            inherit hyprland-helpers;
          }
          // workspaceNixPackages;

          devShells.default = craneLib.devShell {
            checks = config.checks;
            packages = [
              pkgs.rust-analyzer
            ];
          };
        };

      flake = {
        homeManagerModules = {
          hyprland-helpers = import ./homeManagerModules self;
          hyprland-language-switch-notifier = import ./homeManagerModules/hyprland-language-switch-notifier.nix self;
          hyprland-mode-switch-notifier = import ./homeManagerModules/hyprland-mode-switch-notifier.nix self;
          hyprland-workspace-switch-notifier = import ./homeManagerModules/hyprland-workspace-notifier.nix self;
        };
      };
    };
}
