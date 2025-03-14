lib: rec {
    inherit (lib) mapAttrsToList imap0;
    inherit (builtins) attrNames concatMap concatStringsSep listToAttrs readDir readFile;

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

    mkZenixFiles = cfg: cfg.profiles
        |> attrNames
        |> concatMap (name: [
            {
                name = ".zen/profiles.ini";
                value.text = generateIni cfg.profiles;
            }
            {
                name = ".zen/${name}/chrome/colors.css";
                value.text = mkCssVars cfg.chrome.variables;
            }
            {
                name = ".zen/${name}/chrome/zenix";
                value = {
                    source = ../chrome/zenix;
                    recursive = true;
                };
            }
            {
                name = ".zen/${name}/chrome/zenix-pages";
                value = {
                    source = ../chrome/zenix-pages;
                    recursive = true;
                };
            }
        ])
        |> listToAttrs;
}
