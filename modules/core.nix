{ config, lib, pkgs, ... }:

{
    system.stateVersion = config.system.nixos.release;    # format: "26.05";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    _module.args.varsEdit = overrides: let base = lib.recursiveUpdate (import ./vars.nix { inherit pkgs; }) overrides;
    in base // {
        theme = base.theme // { preset = lib.recursiveUpdate base.theme.preset (base.theme.${base.theme.activePreset} or {}); };
        system = base.system // { displays = base.system.displays // { params = map (s: let
                m = builtins.match "([^:]+):([0-9]+)x([0-9]+)(@([0-9.]+))?(\\+([0-9]+)\\+([0-9]+))?" s;
                g = i: d: let v = builtins.elemAt m i; in if v == null then d else v;
            in { d = builtins.elemAt m 0; w = builtins.elemAt m 1; h = builtins.elemAt m 2; r = g 4 "60"; x = g 6 "0"; y = g 7 "0"; }) base.system.displays.presets;};};
    };

    imports = [
        ../hardware-configuration.nix

        ./bootload.nix
        ./containers.nix
        ./pkgs.nix
        ./shared.nix
        ./shell.nix
        ./systemconfig.nix
        ./users.nix

        ./utils/displaymanagers.nix
        ./utils/kitty.nix
        ./utils/mangowm.nix
        ./utils/noctalia.nix
        ./utils/sunshine.nix
        ./utils/wine.nix
    ];
}
