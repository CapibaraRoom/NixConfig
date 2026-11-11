{ config, lib, pkgs, userspace, ... }:

{
    config = lib.mkMerge [
        (lib.mkIf userspace.programs.docker.enable {
            virtualisation.docker = {
                enable = true;
                enableOnBoot = true;
                extraPackages = with pkgs; [ docker-compose ];
            };
        })

        (lib.mkIf userspace.programs.podman.enable {
            virtualisation.podman = {
                enable = true;
                dockerCompat = userspace.programs.podman.replaceDocker;
                defaultNetwork.settings.dns_enabled = true;
            };
        })
    ];
}
