{
    lib,
    pkgs,
    self,
}: {
    enable = lib.mkEnableOption "zenix";
    package = lib.mkOption {
        type = lib.types.package;
        description = "Package for zen-browser";
        default = self.inputs.zen-browser.packages.${pkgs.system}.default;
    };
    profiles = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "This can be used like home-manager's firefox profiles";
    };
    chrome = {
        variables = let
            mkColorOpt = default:
                lib.mkOption {
                    inherit default;
                    type = lib.types.str;
                };
        in {
            colors = {
                primary = mkColorOpt "#8aadf4";
                secondary = mkColorOpt "#f5a97f";
                borderLight = mkColorOpt "#cad3f5";
                borderDark = mkColorOpt "#6e6c7e";
                surface0 = mkColorOpt "#181926";
                surface1 = mkColorOpt "#292c3c";
                surface2 = mkColorOpt "#24273a";
                overlay0 = mkColorOpt "#6e6c7e";
                text = mkColorOpt "#cad3f5";
                mauve = mkColorOpt "#c6a0f6";
                maroon = mkColorOpt "#ee99a0";
                red = mkColorOpt "#ed8796";
            };
            glass = {
                background = mkColorOpt "rgba(41, 44, 60, 0.8)";
                blurRadius = mkColorOpt "12px";
            };
        };
        findbar = lib.mkOption {
            type = lib.types.bool;
            default = true;
        };
        hideTitlebarButtons = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };
}
