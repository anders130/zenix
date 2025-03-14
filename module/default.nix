inputs: {
    config,
    lib,
    ...
}: let
    cfg = config.programs.zenix;
    utils = import ./utils.nix lib;
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
                    "zen.theme.accent-color" = variables.colors.primary;
                    "zen.view.grey-out-inactive-windows" = false; # fix inactive window color
                };
                userChrome = /*css*/''
                    @import url("colors.css");
                    @import url("zenix/findbar.css");
                    @import url("zenix/hide-titlebar-buttons.css");
                    @import url("zenix/theme.css");
                '';
                userContent = /*css*/''
                    @import url("colors.css");
                    @import url("zenix-pages/aboutPages.css");
                '';
            };
            homeManagerPath = inputs.home-manager;
        })
    ];
    options.programs.zenix = import ./options.nix lib;
    config = lib.mkIf cfg.enable {
        home.file = utils.mkZenixFiles cfg;
    };
}
