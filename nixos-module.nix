self: {
    config,
    lib,
    ...
}: let
    cfg = config.nixfox;

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
    options.nixfox = {
        enable = lib.mkEnableOption "nixfox";
        package = lib.mkOption {
            type = lib.types.package;
            description = "Package for zen-browser";
        };
        profiles = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = "This can be used like home-manager's firefox profiles";
        };
        username = lib.mkOption {
            type = lib.types.str;
        };
    };

    config = lib.mkIf config.nixfox.enable {
        environment.systemPackages = [cfg.package];
        home-manager.users.${cfg.username} = {
            programs.firefox = {
                enable = true;
                profiles = builtins.listToAttrs (map (name: {
                    name = "zen-${name}";
                    value = cfg.profiles.${name} // {
                        inherit name;
                        # Avoid conflicts with Firefox profiles
                        id = cfg.profiles.${name}.id + 100;
                        isDefault = false;
                        # Move to zen folder
                        path = "../../.zen/${name}";
                    };
                }) (builtins.attrNames cfg.profiles));
            };
            home.file.".zen/profiles.ini".text = generateIni cfg.profiles;
        };
    };
}
