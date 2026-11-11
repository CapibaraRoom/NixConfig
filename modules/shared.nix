{ config, lib, pkgs, userspace, ... }:

let
    shareDir  = "/srv";
    shareRoot = "/share";

    userMounts = u:
        map (d: lib.nameValuePair "${shareDir}/${u.user}/${d.out}" {
            device = d.inp;
            fsType = "none";
            options = [ "bind" ] ++ (if (d.writable or userspace.ssh.sftp.writable) then [] else [ "ro" ]);
        }) u.dirs;

    chrootRules = lib.concatMap (u:
        [ "d ${shareDir}/${u.user} 0755 root root -" ]
        ++ map (d: "d ${shareDir}/${u.user}/${d.out} 0755 root root -") u.dirs
    ) userspace.ssh.sftp.shared;

    matchBlock = u: ''
        Match User ${u.user}
            ChrootDirectory ${shareDir}/${u.user}
            ForceCommand internal-sftp
            AllowTcpForwarding no
            X11Forwarding no
            PermitTTY no
    '';
    sshExtra = lib.concatMapStringsSep "\n" matchBlock userspace.ssh.sftp.shared;

    usersAttrs = lib.listToAttrs (map (u: lib.nameValuePair u.user {
        isNormalUser = true;
        createHome   = false;
        password     = u.password;
    }) userspace.ssh.sftp.shared);
in lib.mkMerge [
    {
        fileSystems."${shareDir}" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "mode=0755" "uid=0" "gid=0" "size=2G" ];
        };
    }

    (lib.mkIf userspace.ssh.sftp.enable {
        fileSystems = lib.listToAttrs ( lib.concatMap userMounts userspace.ssh.sftp.shared );
        systemd.tmpfiles.rules = map (name: "d ${shareRoot}/${name} 1777 root root -") userspace.ssh.sftp.dirs ++ chrootRules;

        users.users = usersAttrs;
        networking.firewall.allowedTCPPorts = [ userspace.ssh.sftp.port ];
        services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
            extraConfig = sshExtra;
        };
    })
]
