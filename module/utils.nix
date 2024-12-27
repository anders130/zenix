lib: rec {
    inherit (lib) mapAttrsToList;
    inherit (builtins) concatStringsSep listToAttrs attrNames;

    generateIni = profiles: let
        profileList = mapAttrsToList (name: profile: profile // {inherit name;}) profiles;
        profileToStr = profile: ''
            [Profile${toString profile.id}]
            Name=${profile.name}
            IsRelative=1
            Path=${profile.name}
            ZenAvatarPath=chrome://browser/content/zen-avatars/avatar-55.svg
            Default=${
                if profile.isDefault
                then "1"
                else "0"
            }
        '';
    in
        concatStringsSep "\n\n" ((map profileToStr profileList)
            ++ [
                ''
                    [General]
                    StartWithLastProfile=1
                    Version=2
                ''
            ]);

    mkChromeDirectories = zenixProfiles: zenixProfiles
        |> attrNames
        |> map (name: {
            name = ".zen/${name}/chrome/zenix";
            value = {
                source = ../chrome/zenix;
                recursive = true;
            };
        })
        |> listToAttrs;

    mkUserChrome = vars: /*css*/''
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

    mkFirefoxProfiles = cfg: cfg.profiles
        |> attrNames
        |> map (name: let pcfg = cfg.profiles.${name}; in {
            name = "zen-${name}";
            value = pcfg // {
                inherit name;
                # Avoid conflicts with Firefox profiles
                id = pcfg.id + 100;
                isDefault = false;
                # Move to zen folder
                path = "../../.zen/${name}";

                settings = {
                    "zenix.findbar.disabled" = !cfg.chrome.findbar;
                    "zenix.hide-titlebar-buttons" = cfg.chrome.hideTitlebarButtons;
                };
                userChrome = (mkUserChrome cfg.chrome.variables) + (if pcfg ? userChrome then pcfg.userChrome else "");
            };
        })
        |> listToAttrs;
}
