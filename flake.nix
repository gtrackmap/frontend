{
  description = "gtrackmap frontend";

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
          lib = pkgs.lib;
        in
        {
          packages.default = pnpm2nix.packages.${system}.mkPnpmPackage {
            name = "trackmap-frontend";
            version = "0.1.0";
            src = ./.;
            distDir = "build";

            meta = with lib; {
              description = "Frontend for gtrackmap";
              homepage = "https://github.com/gtrackmap/frontend";
              license = licenses.agpl3Plus;
              maintainers = [ "Joakim Repomaa <nix@pimeys.pm>" ];
            };
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
