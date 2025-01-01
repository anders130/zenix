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

    mkCssVars = vars: /*css*/''
        * {
            --zenix-color-primary: ${vars.colors.primary};
            --zenix-color-secondary: ${vars.colors.secondary};
            --zenix-color-surface0: ${vars.colors.surface0};
            --zenix-color-surface1: ${vars.colors.surface1};
            --zenix-color-surface2: ${vars.colors.surface2};
            --zenix-color-overlay0: ${vars.colors.overlay0};
            --zenix-color-text: ${vars.colors.text};
            --zenix-color-maroon: ${vars.colors.maroon};
            --zenix-glass-background: ${vars.glass.background};
            --zenix-glass-blur-radius: ${vars.glass.blurRadius};
            --zenix-color-base: ${vars.colors.base};
            --zenix-color-mantle: ${vars.colors.mantle};
            --zenix-color-crust: ${vars.colors.crust};
            --zenix-color-highlight: ${vars.colors.highlight};

            --zenix-color-blue: ${vars.colors.blue};
            --zenix-color-blue-invert: ${vars.colors.blueInvert};
            --zenix-color-blue-pale: ${vars.colors.bluePale};

            --zenix-color-purple: ${vars.colors.purple};
            --zenix-color-purple-invert: ${vars.colors.purpleInvert};
            --zenix-color-purple-pale: ${vars.colors.purplePale};

            --zenix-color-cyan: ${vars.colors.cyan};
            --zenix-color-cyan-invert: ${vars.colors.cyanInvert};
            --zenix-color-cyan-pale: ${vars.colors.cyanPale};

            --zenix-color-orange: ${vars.colors.orange};
            --zenix-color-orange-invert: ${vars.colors.orangeInvert};
            --zenix-color-orange-pale: ${vars.colors.orangePale};

            --zenix-color-yellow: ${vars.colors.yellow};
            --zenix-color-yellow-invert: ${vars.colors.yellowInvert};
            --zenix-color-yellow-pale: ${vars.colors.yellowPale};

            --zenix-color-pink: ${vars.colors.pink};
            --zenix-color-pink-invert: ${vars.colors.pinkInvert};
            --zenix-color-pink-pale: ${vars.colors.pinkPale};

            --zenix-color-green: ${vars.colors.green};
            --zenix-color-green-invert: ${vars.colors.greenInvert};
            --zenix-color-green-pale: ${vars.colors.greenPale};

            --zenix-color-red: ${vars.colors.red};
            --zenix-color-red-invert: ${vars.colors.redInvert};
            --zenix-color-red-pale: ${vars.colors.redPale};

            --zenix-color-gray: ${vars.colors.gray};
            --zenix-color-gray-invert: ${vars.colors.grayInvert};
            --zenix-color-gray-pale: ${vars.colors.grayPale};
        }
    '';

    mkUserChrome = vars: /*css*/''
        @import url("zenix/findbar.css");
        @import url("zenix/hide-titlebar-buttons.css");
        @import url("zenix/tab-groups.css");
        @import url("zenix/theme.css");
    '' + mkCssVars vars;

    mkUserContent = vars: mkCssVars vars + builtins.readFile ../chrome/userContent.css;

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
                    "zenix.tab-groups.enabled" = cfg.chrome.tabGroups;
                    "browser.tabs.groups.enabled" = cfg.chrome.tabGroups;
                };
                userChrome = (mkUserChrome cfg.chrome.variables) + (if pcfg ? userChrome then pcfg.userChrome else "");
                userContent = (mkUserContent cfg.chrome.variables) + (if pcfg ? userContent then pcfg.userContent else "");
            };
        })
        |> listToAttrs;
}
