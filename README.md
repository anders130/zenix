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
    imports = [inputs.zenix.hmModules.default];
    programs.zenix = {
        enable = true;
        package = pkgs.zen-browser;
        chrome = {
            findbar = true;
            hideTitlebarButtons = true;
        };
        profiles = rec {
            default = {
                isDefault = true;
                extensions = with pkgs.nur.repos.rycee.firefox-addons; [
                    ublock-origin
                ];
            };
            work = default // {
                isDefault = false;
            };
        };
    };
}
```
