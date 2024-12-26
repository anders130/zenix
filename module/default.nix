self: {
    config,
    lib,
    ...
}: let
    cfg = config.programs.zenix;

    generateIni = profiles: let
        profileList = lib.mapAttrsToList (name: profile: profile // {inherit name;}) profiles;
        profileToStr = profile: ''
            [Profile${toString profile.id}]
            Name=${profile.name}
            IsRelative=1
            Path=${profile.name}
            ZenAvatarPath=chrome://browser/content/zen-avatars/avatar-55.svg
            Default=${if profile.isDefault then "1" else "0"}
        '';
    in
        builtins.concatStringsSep "\n\n" ((map profileToStr profileList) ++ [''
            [General]
            StartWithLastProfile=1
            Version=2
        '']);

    userChromeCSS = vars: /*css*/''
        @import url("zenix/findbar.css");
        @import url("zenix/hide-titlebar-buttons.css");

        * {
            --zenix-color-primary: ${vars.colors.primary};
            --zenix-color-secondary: ${vars.colors.secondary};
            --zenix-color-border-light: ${vars.colors.borderLight};
            --zenix-color-border-dark: ${vars.colors.borderDark};
            --zenix-color-surface0: ${vars.colors.surface0};
            --zenix-color-surface1: ${vars.colors.surface1};
            --zenix-color-surface2: ${vars.colors.surface2};
            --zenix-color-overlay0: ${vars.colors.overlay0};
            --zenix-color-text: ${vars.colors.text};
            --zenix-color-mauve: ${vars.colors.mauve};
            --zenix-color-maroon: ${vars.colors.maroon};
            --zenix-color-red: ${vars.colors.red};
            --zenix-glass-background: ${vars.glass.background};
            --zenix-glass-blur-radius: ${vars.glass.blurRadius};
        }
    '';

    mkProfile = name: pcfg: {
        name = "zen-${name}";
        value = pcfg // {
            inherit name;
            # Avoid conflicts with Firefox profiles
            id = cfg.profiles.${name}.id + 100;
            isDefault = false;
            # Move to zen folder
            path = "../../.zen/${name}";

            settings = {
                "zenix.findbar.disabled" = !cfg.chrome.findbar;
                "zenix.hide-titlebar-buttons" = cfg.chrome.hideTitlebarButtons;
            };

            userChrome = (userChromeCSS cfg.chrome.variables) + (if pcfg ? userChrome then pcfg.userChrome else "");
        };
    };
in {
    options.programs.zenix = {
        enable = lib.mkEnableOption "zenix";
        package = lib.mkOption {
            type = lib.types.package;
            description = "Package for zen-browser";
        };
        profiles = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = "This can be used like home-manager's firefox profiles";
        };
        chrome = {
            variables = let
                mkColorOpt = default: lib.mkOption {
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
    };

    config = lib.mkIf cfg.enable {
        home = {
            packages = [cfg.package];
            file = {
                ".zen/profiles.ini".text = generateIni cfg.profiles;
            } // (builtins.listToAttrs (map (name: {
                name = ".zen/${name}/chrome/zenix";
                value = {
                    source = ../chrome/zenix;
                    recursive = true;
                };
            }) (builtins.attrNames cfg.profiles)));
        };
        programs.firefox = {
            enable = true;
            profiles = builtins.listToAttrs (map (name: mkProfile name cfg.profiles.${name}) (builtins.attrNames cfg.profiles));
        };
    };
}
