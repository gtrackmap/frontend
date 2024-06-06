{
  description = "trackmap frontend";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pnpm2nix.url = "github:nzbr/pnpm2nix-nzbr";
  };

  outputs = { nixpkgs, flake-utils, pnpm2nix, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages.default = pnpm2nix.packages.${system}.mkPnpmPackage {
            name = "trackmap-frontend";
            version = "0.1.0";
            src = ./.;
            distDir = "build";
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nodejs
              nodePackages.pnpm
              openssl
            ];

            PROJECT_ROOT = builtins.getEnv "PWD";

            shellHook = ''
              [ -d node_modules ] || pnpm i
              echo "Start development by running pnpm run dev"
            '';
          };
        }
      );
}
