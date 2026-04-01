{
  description = "Nix packaging of mcp-unreal - MCP server for Unreal Engine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }: let
        mcp-unreal = pkgs.buildGoModule rec {
          pname = "mcp-unreal";
          version = "0.0.0";

          src = pkgs.fetchFromGitHub {
            owner = "remiphilippe";
            repo = "mcp-unreal";
            rev = "main";
            # Hash placeholder - run `nix hash to-sri --type sha256 <path>` after first build failure to get actual hash
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
            platforms = pkgs.lib.platforms.unix;
            mainProgram = "mcp-unreal";
          };
        };
      in {
        packages = {
          inherit mcp-unreal;
          default = mcp-unreal;
        };
      };
    };
}