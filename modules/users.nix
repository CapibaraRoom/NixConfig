{ config, lib, pkgs, userspace, ... }:

let
    userList = if userspace.users.list == [] then [{ name = userspace.users.default; }] else userspace.users.list;
    
    regularUsersAttrs = lib.listToAttrs (map (u:
        let passwordAttr = if u ? pwdhash then { hashedPassword = u.pwdhash; } else if u ? pwd then { password = u.pwd; } else { password = u.name; };
        in lib.nameValuePair u.name ({
            home = if u ? home then u.home else "/home/${u.name}";
            createHome = true;
            isNormalUser = true;
            extraGroups = userspace.users.extraGroupsDefault ++ userspace.users.extraGroups;
        } // passwordAttr)
    ) userList);
    
in {
    users.users = {
        guest = {
            uid = 1000;
            initialPassword = "guest";
            isNormalUser = true;
            extraGroups = lib.subtractLists [ "wheel" ] (userspace.users.extraGroupsDefault ++ userspace.users.extraGroups);
        };
    } // regularUsersAttrs;
    
    fileSystems."/home/guest" = {
        device = "none";
        fsType = "tmpfs";
        options = [ "size=${toString userspace.users.guestFsSize}M" "mode=0755" "uid=1000" "gid=100" ];
    };
    
    systemd.tmpfiles.rules = [
        "d /root/.config 0700 root root -"
    ] ++ (map (dir: "d /home/guest/${dir} 0755 guest users -") userspace.users.directories);
    
    systemd.services.setup-user-homes = {
        description = "Copy guest home template to regular users";
        after = [ "local-fs.target" "systemd-tmpfiles-setup.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "setup-user-homes" ''
                ${lib.concatMapStringsSep "\n" (u:
                    let home_dir = if u ? home then u.home else "/home/${u.name}"; in ''
                    [ -z "${home_dir}" ] || [ "${home_dir}" = "/" ] && { echo "ERROR: home_dir: ${u.name}"; exit 1; }
                    mkdir -p "${home_dir}"
                    chmod 755 "${home_dir}"
                    [ -d /home/guest ] && cp -rnp /home/guest/. "${home_dir}/" 2>/dev/null || true
                    chown -R ${u.name}:users "${home_dir}"
                '') userList}
            '';
        };
    };
}
