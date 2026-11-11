{ config, lib, pkgs, userspace, ... }:

{
    nixpkgs.config.allowUnfree = userspace.system.allowUnfree;
    
    fonts.packages = with pkgs; [ maple-mono.NF ] ++ userspace.system.fonts;

    environment.systemPackages = with pkgs; [
        tree file killall wget tcpdump                                  # базовый функционал
        libxkbcommon libglvnd libdrm mesa ffmpeg                        # библиотеки
        unzip unrar p7zip zlib fuse                                     # архиваторы
        wayland wayland-protocols wlr-randr wl-screenrec wl-clipboard   # wayland
        localFlakes nsh nix-tree nix-update nix-graph                   # nix-инструменты
        ddcutil evtest slurp smartmontools gpu-screen-recorder
    ] ++ userspace.system.packages;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "unrar"
    ];
}
