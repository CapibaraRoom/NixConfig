{ config, lib, pkgs, userspace, ... }:

let
    nixDev = pkgs.writeText "nix-dev.nix" ''
        { pkgs ? import <nixpkgs> {} }:
        pkgs.mkShell { buildInputs = with pkgs; [ ${toString userspace.shell.packages} ]; }
    '';
in {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        
        shellInit = "zsh-newuser-install() { :; }";
        
        histFile = "$HOME/.zsh_history";
        histSize = 10000;
        
        setOptions = [
            "INTERACTIVE_COMMENTS"
            "HIST_IGNORE_ALL_DUPS"
            "HIST_IGNORE_SPACE"
            "SHARE_HISTORY"
            "HIST_FIND_NO_DUPS"
            "HIST_REDUCE_BLANKS"
        ];
        
        shellAliases = { } // userspace.shell.aliases;

        interactiveShellInit = ''
            zmodload zsh/complist
            zstyle ':completion:*' menu yes select
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-Z}'
            export LS_COLORS="$LS_COLORS:ow=01;34;40:tw=01;34;40:"
            bindkey '^[[3~' delete-char
        '';
    };

    programs.starship = {
        enable = true;
        settings = {
            add_newline = false;

            format = "\${custom.time_user}\${custom.time_root}\${custom.time_arrow_user}\${custom.time_arrow_root}$directory[](fg:green) $nix_shell$python$conda$git_branch$git_status$docker_context$line_break$hostname \${custom.user_user}\${custom.user_root} [>](bold green) ";

            custom.time_user = {
                command = "date +%H:%M:%S";
                when = "test \"$EUID\" -ne 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "bg:yellow fg:black bold";
                format = "[ $output ]($style)";
            };

            custom.time_root = {
                command = "date +%H:%M:%S";
                when = "test \"$EUID\" -eq 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "bg:red fg:black bold";
                format = "[ $output ]($style)";
            };

            custom.time_arrow_user = {
                command = "printf ''";
                when = "test \"$EUID\" -ne 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "fg:yellow bg:green";
                format = "[$output]($style)";
            };

            custom.time_arrow_root = {
                command = "printf ''";
                when = "test \"$EUID\" -eq 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "fg:red bg:green";
                format = "[$output]($style)";
            };

            nix_shell = {
                symbol = "";
                style = "bg:blue fg:black bold";
                format = "[](fg:blue)[ $symbol$state ]($style)[](fg:blue)";
                impure_msg = "impure";
                pure_msg = "pure";
                heuristic = false;
            };

            python = {
                symbol = "";
                style = "bg:purple fg:black bold";
                format = "[](fg:purple)[ $symbol$virtualenv ]($style)[](fg:purple)";
                detect_extensions = [];
            };

            conda = {
                symbol = "";
                style = "bg:bright-purple fg:black bold";
                format = "[](fg:bright-purple)[ $symbol$environment ]($style)[](fg:bright-purple)";
                ignore_base = true;
                truncation_length = 1;
            };

            git_branch = {
                symbol = "";
                style = "bg:cyan fg:black bold";
                format = "[](fg:cyan)[ $symbol$branch ]($style)";
            };

            git_status = {
                style = "bg:cyan fg:black bold";
                format = "[$all_status$ahead_behind ]($style)[](fg:cyan)";
                disabled = false;
            };

            docker_context = {
                symbol = "";
                style = "bg:bright-white fg:black bold";
                format = "[](fg:bright-white)[ $symbol$context ]($style)[](fg:bright-white)";
                only_with_files = true;
                detect_files = [ "docker-compose.yml" "docker-compose.yaml" "Dockerfile" ];
            };

            custom.user_user = {
                command = "printf '%s$' \"$USER\"";
                when = "test \"$EUID\" -ne 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "fg:blue bold";
                format = "[$output]($style)";
            };

            custom.user_root = {
                command = "printf '%s#' \"$USER\"";
                when = "test \"$EUID\" -eq 0";
                shell = [ "bash" "--noprofile" "--norc" ];
                style = "fg:red bold";
                format = "[$output]($style)";
            };

            directory = {
                style = "bg:green fg:black bold";
                format = "[ \\[$path\\] ]($style)";
                truncation_length = 4;
                truncation_symbol = "…/";
                truncate_to_repo = false;
            };
            
            hostname = {
                ssh_only = false;
                style = "fg:green";
                format = "[$hostname@]($style)";
            };
        };
    };

    programs.git = {
        enable = true;
        lfs.enable = true;
        config = {
            user.name = userspace.git.userName;
            user.email = userspace.git.userEmail;
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            pull.rebase = true;
            credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
            core.editor = "micro";
        };
    };
    
    systemd.tmpfiles.rules = [
        "L /bin/bash - - - - ${pkgs.bashInteractive}/bin/bash"
        "C+ /root/.nixdev.nix 0600 root root - ${nixDev}"
        "C+ /home/guest/.nixdev.nix 0644 guest users - ${nixDev}"
    ];
}
