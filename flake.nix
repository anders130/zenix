{
    description = "nixfox flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs @ {
        flake-parts,
        self,
        ...
    }:
        flake-parts.lib.mkFlake {inherit inputs;} {
            systems = ["x86_64-linux"];
            flake.nixosModules.default = import ./nixos-module.nix {inherit self;};
            perSystem = {pkgs, ...}: {
                packages.default = pkgs.hello;
            };
        };
}
