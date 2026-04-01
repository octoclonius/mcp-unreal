{
  description = "Nix packaging of mcp-unreal - MCP server for Unreal Engine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.git-hooks-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { config, pkgs, ... }: let
        mcp-unreal = pkgs.buildGoModule rec {
          pname = "mcp-unreal";
          version = "0.0.0";

          src = pkgs.fetchFromGitHub {
            owner = "remiphilippe";
            repo = "mcp-unreal";
            rev = "main";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          ldflags = [
            "-s"
            "-w"
            "-X=main.version=${version}"
          ];

          meta = {
            description = "MCP server for Unreal Engine 5.7";
            homepage = "https://github.com/remiphilippe/mcp-unreal";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "mcp-unreal";
          };
        };
      in
      {
        packages = {
          inherit mcp-unreal;
          default = mcp-unreal;
        };

        formatter = pkgs.nixfmt-classic;

        pre-commit.settings.hooks = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.shellHook}
          '';
          packages = config.pre-commit.settings.enabledPackages;
        };
      };
    };
}
