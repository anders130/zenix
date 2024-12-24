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
            findBar = lib.mkOption {
                type = lib.types.bool;
                default = true;
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
            profiles = builtins.listToAttrs (map (name: let
                pcfg = cfg.profiles.${name};
            in {
                name = "zen-${name}";
                value = pcfg // {
                    inherit name;
                    # Avoid conflicts with Firefox profiles
                    id = cfg.profiles.${name}.id + 100;
                    isDefault = false;
                    # Move to zen folder
                    path = "../../.zen/${name}";

                    settings = {
                        "zenix.findbar.disabled" = !cfg.chrome.findBar;
                    };

                    userChrome = ''
                        @import url("zenix/findbar.css");

                        * {
                            --zenix-color-primary: ${cfg.chrome.variables.colors.primary};
                            --zenix-color-secondary: ${cfg.chrome.variables.colors.secondary};
                            --zenix-color-border-light: ${cfg.chrome.variables.colors.borderLight};
                            --zenix-color-border-dark: ${cfg.chrome.variables.colors.borderDark};
                            --zenix-color-surface0: ${cfg.chrome.variables.colors.surface0};
                            --zenix-color-surface1: ${cfg.chrome.variables.colors.surface1};
                            --zenix-color-surface2: ${cfg.chrome.variables.colors.surface2};
                            --zenix-color-overlay0: ${cfg.chrome.variables.colors.overlay0};
                            --zenix-color-text: ${cfg.chrome.variables.colors.text};
                            --zenix-color-mauve: ${cfg.chrome.variables.colors.mauve};
                            --zenix-color-maroon: ${cfg.chrome.variables.colors.maroon};
                            --zenix-color-red: ${cfg.chrome.variables.colors.red};
                            --zenix-glass-background: ${cfg.chrome.variables.glass.background};
                            --zenix-glass-blur-radius: ${cfg.chrome.variables.glass.blurRadius};
                        }

                    '' + (if pcfg ? userChrome then pcfg.userChrome else "");
                };
            }) (builtins.attrNames cfg.profiles));
        };
    };
}
