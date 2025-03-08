lib: rec {
    inherit (lib) mapAttrsToList imap0;
    inherit (builtins) concatStringsSep listToAttrs attrNames readDir readFile;

    camelToKebab = let
        inherit (lib.strings) match stringAsChars toLower;
        isUpper = match "[A-Z]";
    in
        stringAsChars (c: if isUpper c != null then "-${toLower c}" else c);

    mkCssVars = vars: ''
        * {
            /* colors */
            ${concatStringsSep "\n" (mapAttrsToList (name: value: "--zenix-color-${camelToKebab name}: ${value};") vars.colors)}
            /* glass */
            ${concatStringsSep "\n" (mapAttrsToList (name: value: "--zenix-glass-${camelToKebab name}: ${value};") vars.glass)}
        }
    '';

    mkUserChrome = vars: /*css*/''
        @import url("zenix/findbar.css");
        @import url("zenix/hide-titlebar-buttons.css");
        @import url("zenix/tab-groups.css");
        @import url("zenix/theme.css");
    '' + mkCssVars vars;

    mkUserContent = vars: mkCssVars vars + readFile ../chrome/userContent.css;

    prepareProfiles = profiles: profiles
        |> attrNames
        |> imap0 (index: name: let profile = profiles.${name}; in profile // {
            inherit name;
            id = profile.id or index;

        });

    generateIni = profiles: profiles
        |> prepareProfiles
        |> map (profile: ''
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
        '')
        |> (p: p ++ [''
            [General]
            StartWithLastProfile=1
            Version=2
        ''])
        |> concatStringsSep "\n\n";

    mkFirefoxProfiles = cfg: cfg.profiles
        |> prepareProfiles
        |> map (profile: profile // {
            name = "zen-${profile.name}";
            value = profile // {
                # Avoid conflicts with Firefox profiles
                id = profile.id + 100;
                isDefault = false;
                # Move to zen folder
                path = "../../.zen/${profile.name}";
                settings = profile.settings or {} // (with cfg.chrome; {
                    "zenix.findbar.disabled" = !findbar;
                    "zenix.hide-titlebar-buttons" = hideTitlebarButtons;
                    "zenix.tab-groups.enabled" = tabGroups;
                    "browser.tabs.groups.enabled" = tabGroups;
                    "zen.theme.accent-color" = variables.colors.primary;
                    "zen.view.grey-out-inactive-windows" = false; # fix inactive window color
                });
                userChrome = (mkUserChrome cfg.chrome.variables) + (profile.userChrome or "");
                userContent = (mkUserContent cfg.chrome.variables) + (profile.userContent or "");
            };
        })
        |> listToAttrs;

    mkChromeDirectories = profiles: profiles
        |> attrNames
        |> map (name: {
            name = ".zen/${name}/chrome/zenix";
            value = {
                source = ../chrome/zenix;
                recursive = true;
            };
        })
        |> listToAttrs;
}
