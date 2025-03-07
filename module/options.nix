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
        default = {
            id = 0;
        };
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
                surface0 = mkColorOpt "#363a4f";
                surface1 = mkColorOpt "#494d64";
                surface2 = mkColorOpt "#5b6078";
                overlay0 = mkColorOpt "#6e738d";
                text = mkColorOpt "#cad3f5";
                maroon = mkColorOpt "#ee99a0";
                base = mkColorOpt "#24273a";
                mantle = mkColorOpt "#1e2030";
                crust = mkColorOpt "#181926";
                highlight = mkColorOpt "#aac0f4";

                blue = mkColorOpt "#8aadf4";
                blueInvert = mkColorOpt "#8aadf4";
                bluePale = mkColorOpt "#91d7e3";

                purple = mkColorOpt "#c6a0f6";
                purpleInvert = mkColorOpt "#c6a0f6";
                purplePale = mkColorOpt "#b7bdf8";

                cyan = mkColorOpt "#8bd5ca";
                cyanInvert = mkColorOpt "#8bd5ca";
                cyanPale = mkColorOpt "#91d7e3";

                orange = mkColorOpt "#f08f66";
                orangeInvert = mkColorOpt "#f08f66";
                orangePale = mkColorOpt "#f5a97f";

                yellow = mkColorOpt "#eed49f";
                yellowInvert = mkColorOpt "#eed49f";
                yellowPale = mkColorOpt "#eed49f";

                pink = mkColorOpt "#f5bde6";
                pinkInvert = mkColorOpt "#f5bde6";
                pinkPale = mkColorOpt "#f0c6c6";

                green = mkColorOpt "#a6da95";
                greenInvert = mkColorOpt "#a6da95";
                greenPale = mkColorOpt "#a6da95";

                red = mkColorOpt "#ed8796";
                redInvert = mkColorOpt "#ed8796";
                redPale = mkColorOpt "#f5bde6";

                gray = mkColorOpt "#939ab7";
                grayInvert = mkColorOpt "#939ab7";
                grayPale = mkColorOpt "#b8c0e0";
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
        tabGroups = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };
}
