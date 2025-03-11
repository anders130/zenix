inputs: {
    config,
    lib,
    ...
}: let
    cfg = config.programs.zenix;
    utils = import ./utils.nix lib;
    inherit (utils) generateIni mkChromeDirectories mkUserChrome mkUserContent;
    inherit (builtins) mapAttrs;
    mkFirefoxModule = import ./mkFirefoxModule.nix;
in {
    imports = [
        (mkFirefoxModule {
            modulePath = ["programs" "zenix"];
            name = "zenix";
            description = "A nixos module for the zen-browser";
            wrappedPackageName = "zen-browser";
            unwrappedPackageName = "zen-browser-unwrapped";
            visible = true;
            platforms.linux.configPath = ".zen";
            defaultProfileConfig = {
                settings = with cfg.chrome; {
                    "zenix.findbar.disabled" = !findbar;
                    "zenix.hide-titlebar-buttons" = hideTitlebarButtons;
                    "zenix.tab-groups.enabled" = tabGroups;
                    "browser.tabs.groups.enabled" = tabGroups;
                    "zen.theme.accent-color" = variables.colors.primary;
                    "zen.view.grey-out-inactive-windows" = false; # fix inactive window color
                };
                userChrome = mkUserChrome cfg.chrome.variables;
                userContent = mkUserContent cfg.chrome.variables;
            };
            homeManagerPath = inputs.home-manager;
        })
    ];
    options.programs.zenix = import ./options.nix lib;
    config = lib.mkIf cfg.enable {
        home.file =
            {
                ".zen/profiles.ini".text = generateIni cfg.profiles;
            }
            // mkChromeDirectories cfg.profiles;
    };
}
