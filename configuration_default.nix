{ config, lib, pkgs, varsEdit, ... }:

{
    _module.args.userspace = varsEdit {
        
        boot.timeout = 4;
        boot.configLimit = 5;

        partitions.usbAutomount = true;
        partitions.mount = [
            # { inp = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1-part1"; out = "/media/nvme1"; }
        ];

        # users.list = [ { name = "bob"; pwd (or pwdhash from /etc/shadow) = "..."; home = "/mnt/data/bob"; } ];
        users.list = [ { name = "test"; pwd = "guest"; } ];
        users.default = "test";
        users.extraGroups = [ "wheel" "uinput" "docker" "podman" ];

        # system.geolocation = true;
        system.timezone = "Europe/Moscow";
        # system.displays.presets = [ "HDMI-A-1:1920x1080@75.003+0+0" ];
        system.allowPorts = {
            tcp = [ 1443 ];
            udp = [ ];
            tcpRanges = [ { from = 8000; to = 9000; } ];
            udpRanges = [ ];
        };
        system.allowPrebuilt = true;
        system.allowUnfree = true;
        system.fonts     = with pkgs; [ corefonts ];
        system.packages  = with pkgs; [
            (pcmanfm.overrideAttrs (o: { postFixup = "${o.postFixup or ""}rm -f $out/share/applications/pcmanfm-desktop-pref.desktop"; }))

            fastfetch genact gotop yazi
            gparted helium vscodium onlyoffice-desktopeditors
            loupe showtime impression fragments resources
            # drawpile freecad orca-slicer 
            zapret-rust tg-ws-proxy telegram-desktop max-messenger
            # (retroarch.withCores (cores: with cores; [ mgba ]))
        ];

        shell.packages = ''
            (python3.withPackages (ps: with ps; [ requests numpy pyyaml ]))
            pkg-config gnumake cmake gcc
            libx11 libxrandr libxinerama libxi libxcursor   # libGL mesa
        '';
        shell.aliases = {
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "~" = "cd ~";
            l = "ls -lah --color=auto";
            lg = "ls -lah --color=auto | grep";
            la = "ls -A --color=auto";
            ls = "ls --color=auto";
            "l." = "ls -d .* --color=auto";
            df = "df -h";
            du = "du -h";
            h = "history";
            hg = "history | grep";
        };

        # git.userName = "";
        # git.userEmail = "";

        # ssh.sftp.enable = true;
        # ssh.sftp.shared = [
        #     { user = "shareuser0"; password = "share"; dirs = [ { inp = "/shared"; out = "games"; } ]; }
        # ];

        theme.activePreset = "preset1";
        # theme.preset1.noctalia.wallhaven_api = "";
        # theme.preset1.noctalia.bongocat_devices = [ "/dev/input/by-id/usb-HS6209_A4tech_2.4G_Wireless_Device-event-kbd" ];
        theme.preset1.workspaces.window_rules = [
            { app_id = "helium"; rule = "scroller_proportion:1.0"; }
            { app_id = "codium"; rule = "scroller_proportion:1.0"; }
        ];

        # programs.sunshine.enable = true;
        # programs.wine.enable = true;
        # programs.winboat.enable = true;
        # programs.docker.enable = true;
        # programs.podman.enable = true;
    };

    systemd.user.services.ayugram = {
        description = "AyuGram Desktop (autostart minimized)";
        wantedBy = [ "default.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.ayugram-desktop}/bin/AyuGram -startintray";
            Restart = "on-failure";
            RestartSec = 5;
            StartLimitBurst = 3;
        };
    };
}
