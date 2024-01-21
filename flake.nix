
{
  description = "A server-side renderer API for Geometry Dash icons";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    crystal-flake.url = "github:manveru/crystal-flake";
  };

  outputs = { self, nixpkgs, flake-utils, crystal-flake }:
    (with flake-utils.lib; eachSystem defaultSystems) (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (crystal-flake.packages.${system}) crystal;
      in
      rec {
        packages = flake-utils.lib.flattenTree rec {
          gd-icon-renderer-web = pkgs.crystal.buildCrystalPackage {
            pname = "gd-icon-renderer-web";
            version = "0.1.0";

            src = ./.;

            format = "shards";
            lockFile = ./shard.lock;
            shardsFile = ./shards.nix;

            buildInputs = with pkgs; [ openssl pkg-config vips ] ++ [ crystal ];

            nativeBuildInputs = with pkgs; [ openssl pkg-config vips ] ++ [ crystal ];

            doInstallCheck = false;

            crystal = crystal;
          };
        };

        defaultPackage = packages.gd-icon-renderer-web;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            crystal
            shards
            vips
          ];
        };
      });
}