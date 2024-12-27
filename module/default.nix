self: {
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.programs.zenix;
    utils = import ./utils.nix lib;
    inherit (utils) generateIni mkFirefoxProfiles mkChromeDirectories;
in {
    options.programs.zenix = import ./options.nix {inherit lib pkgs self;};
    config = lib.mkIf cfg.enable {
        home = {
            packages = [cfg.package];
            file =
                {
                    ".zen/profiles.ini".text = generateIni cfg.profiles;
                }
                // mkChromeDirectories cfg.profiles;
        };
        programs.firefox = {
            enable = true;
            profiles = mkFirefoxProfiles cfg;
        };
    };
}
