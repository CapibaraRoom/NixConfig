{ config, lib, pkgs, userspace, ... }:

{
    config = lib.mkIf (userspace.programs.sunshine.enable) {
        environment.systemPackages = with pkgs; [ moonlight-qt sunshine ];
        services.udev.extraRules = '' KERNEL=="uinput", MODE="0660", GROUP="input" '';
        services.sunshine = {
            enable = true;
            openFirewall = true;
        };
    };
}
