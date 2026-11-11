{ config, lib, pkgs, userspace, ... }:

{
    config = lib.mkMerge [
        (lib.mkIf userspace.programs.wine.enable {
            environment.systemPackages = with pkgs; [
                wineWow64Packages.staging
                dxvk vkd3d-proton sdl_gamecontrollerdb
            ];

            hardware.graphics = {
                enable = true;
                enable32Bit = true;
            };

            environment.etc."gamecontrollerdb.txt".source = "${pkgs.sdl_gamecontrollerdb}/share/gamecontrollerdb.txt";
            environment.sessionVariables = {
                SDL_GAMECONTROLLERCONFIG_FILE = "/etc/gamecontrollerdb.txt";
                WINE_XINPUT_SDL = "1";
                SDL_JOYSTICK_HIDAPI = "1";
            };
            services.udev.extraRules = ''
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="users"
                KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
            '';
        })

        (lib.mkIf userspace.programs.winboat.enable {
            environment.systemPackages = with pkgs; [ winboat ];
            nixpkgs.config.permittedInsecurePackages = [ "electron-40.10.5" ];
        })
    ];
}
