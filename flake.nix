
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
          ];
        };
      }) // {
        nixosModules = rec {
          gd-icon-renderer-web = { config, lib, pkgs, system, ... }:
          with lib;
          let
            cfg = config.services.gd-icon-renderer-web;
          in {
            options.services.gd-icon-renderer-web = {
              enable = mkEnableOption "Enables the gd-icon-renderer-web server";

              domain = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Which domain to host the server under; if null, NGINX is not used";
              };
              port = mkOption {
                type = types.port;
                default = 3400;
              };
              package = mkOption {
                type = types.package;
                default = self.defaultPackage.${system};
              };
            };

            config = mkIf cfg.enable {
              systemd.services."gd-icon-renderer-web" = {
                wantedBy = [ "multi-user.target" ];

                environment = {
                  LISTEN_ON = "http://localhost:${toString cfg.port}";
                };

                serviceConfig = {
                  Restart = "always";
                  RuntimeMaxSec = "30m";
                  ExecStart = "${getExe cfg.package}";
                  DynamicUser = "yes";
                  StateDirectory = "gd-icon-renderer-web";
                  StateDirectoryMode = "0755";
                  # you want to put your gd assets here
                  WorkingDirectory = "/var/lib/gd-icon-renderer-web/";
                };
              };

              services.nginx = mkIf (cfg.domain != null) {
                virtualHosts."${cfg.domain}" = {
                  enableACME = true;
                  forceSSL = true;
                  locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString cfg.port}/";
                  };
                };
              };
            };
          };
          default = gd-icon-renderer-web;
        };
      };
}