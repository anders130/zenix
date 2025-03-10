{
    description = "zenix flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs:
        inputs.flake-parts.lib.mkFlake {inherit inputs;} {
            systems = ["x86_64-linux"];
            flake = {
                homeModules.default = import ./module inputs;
                overlays.default = final: prev: {
                    zen-browser-unwrapped = prev.callPackage ./package.nix {};
                    zen-browser = prev.wrapFirefox final.zen-browser-unwrapped {
                        pname = "zen-browser";
                    };
                };
            };
            perSystem = {
                pkgs,
                system,
                ...
            }: {
                _module.args.pkgs = import inputs.nixpkgs {
                    inherit system;
                    overlays = [inputs.self.overlays.default];
                };
                packages.default = pkgs.zen-browser;
            };
        };
}
