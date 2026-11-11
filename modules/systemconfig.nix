{ config, lib, pkgs, hostname, userspace, ... }:

{
    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    networking.firewall = {
        allowedTCPPorts = [] ++ userspace.system.allowPorts.tcp;
        allowedUDPPorts = [] ++ userspace.system.allowPorts.udp;
        allowedTCPPortRanges = [] ++ userspace.system.allowPorts.tcpRanges;
        allowedUDPPortRanges = [] ++ userspace.system.allowPorts.udpRanges;
    };
    
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = false;
    
	time.timeZone = userspace.system.timezone;
    time.hardwareClockInLocalTime = true;
    
    programs.nix-ld.enable = userspace.system.allowPrebuilt;
    nix.settings.auto-optimise-store = true;
    services.gnome.gnome-keyring.enable = true;
    services.geoclue2.enable = userspace.system.geolocation;
    
    services.logind.settings.Login.KillUserProcesses = true;
    systemd.settings.Manager.DefaultTimeoutStopSec = "5s";

    boot.kernelParams = map (p: "video=${p.d}:${p.w}x${p.h}@${p.r}") userspace.system.displays.params;
    
    boot.kernel.sysctl = {
        "vm.dirty_background_bytes" = 64 * 1024 * 1024;
        "vm.dirty_bytes" = 256 * 1024 * 1024;
    };
    
    environment.systemPackages = with pkgs; [ ntfs3g exfat udiskie appimage-run micro ];

    programs.ydotool.enable = true;

    boot.binfmt.registrations = lib.genAttrs [ "AppImage" "appimage" "APPIMAGE" ] (ext: {
        wrapInterpreterInShell = false;
        interpreter = "${pkgs.appimage-run}/bin/appimage-run";
        recognitionType = "extension";
        magicOrExtension = ext;
    });

    environment.variables.EDITOR = "micro";
    environment.sessionVariables.EDITOR = "micro";

    boot.supportedFilesystems = [ "ntfs" "exfat" "btrfs" "xfs" "ext4" ];
    boot.blacklistedKernelModules = [ "ntfs3" ];
    
    services.gvfs.enable = userspace.partitions.usbAutomount;
    services.udisks2.enable = userspace.partitions.usbAutomount;
    services.udisks2.mountOnMedia = true;
    
    fileSystems = builtins.listToAttrs (map (p: {
        name = p.out or ( let
            parts = lib.splitString "-" (builtins.baseNameOf p.inp);
            indexed = lib.imap0 (i: x: { index = i; value = x; }) parts;
            found = lib.findFirst (x: builtins.elem x.value [ "nvme" "ata" "usb" "scsi" "virtio" ]) null indexed;
            tail = if found != null then lib.drop found.index parts else parts;
            cleanName = builtins.replaceStrings [":" "." "part"] ["" "" "-part"] (builtins.concatStringsSep "" tail);
        in userspace.partitions.defaultOutput + "/" + cleanName );
        value = {
            device = p.inp;
            fsType = p.fsType or "auto";
            options = p.options or userspace.partitions.defaultOptions;
        };
    }) userspace.partitions.mount);
    
    fonts.fontconfig.enable = true;
    fonts.fontDir.enable = true;
    environment.extraSetup = ''
        ln -sf X11/fonts $out/share/fonts
    '';
    environment.pathsToLink = [
        "/share/wallpapers"
    ];
    systemd.tmpfiles.rules = [
        "L /usr/share - - - - /run/current-system/sw/share"
        "L /usr/sbin - - - - /run/current-system/sw/bin"
        "L /usr/lib - - - - /run/current-system/sw/lib"
        "L /usr/lib64 - - - - /run/current-system/sw/lib"
    ];
}
