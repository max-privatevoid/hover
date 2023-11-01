{
  description = "Hover - Home overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.default = let
          runtimeInputs = with pkgs; lib.makeBinPath [
            coreutils
            dua
            fuse-overlayfs
          ];
        in pkgs.writeShellScriptBin "hover" ''
          export HOVER_ORIGINAL_PATH="$PATH"
          export PATH="${runtimeInputs}:$PATH"
          ${builtins.readFile ./hover.sh}
        '';
      };

      flake = {
        nixosModules.default = { pkgs, ... }: {
          programs.fuse.userAllowOther = true;
          environment.systemPackages = [ self.packages.${pkgs.system}.default ];
        };

        homeManagerModules.starship = { ... }: {
          programs.starship.settings = {
            custom.hover = {
              when = "[ ! -z \${HOVER_HOME+x} ]";
              symbol = "🏂";
              style = "bold blue";
              format = "via [$symbol hover ]($style)";
            };
          };
        };
      };
    };
}
