inputs: {
    config,
    lib,
    ...
}: let
    cfg = config.programs.zenix;
    utils = import ./utils.nix lib;
    inherit (utils) generateIni mkChromeDirectories;
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
