# zenix

A flake for [zen-browser](https://github.com/zen-browser/desktop). It wraps the [home-manager](https://github.com/nix-community/home-manager) module for firefox.

## Usage

`flake.nix`:

```nix
{
    inputs.zenix.url = "github:anders130/zenix";
}
```

`home.nix`:

```nix
{
    imports = [inputs.zenix.homeModules.default];
    nixpkgs.overlays = [inputs.zenix.overlays.default];
    programs.zenix = {
        enable = true;
        chrome = {
            findbar = true;
            hideTitlebarButtons = true;
        };
        profiles = rec {
            default = {
                id = 0;
                isDefault = true;
                extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
                    ublock-origin
                ];
            };
            work = default // {
                id = 1;
                isDefault = false;
            };
        };
    };
}
```
