{ config, lib, pkgs, userspace, ... }:

let
    disp = if userspace.system.displays.params != [] then builtins.head userspace.system.displays.params else null;
in {
    config = lib.mkMerge [
        (lib.mkIf userspace.programs.greetd.enable {
            services.displayManager.noctalia-greeter = {
                enable = true;
                settings = {
                    session.default = userspace.system.session;
                    user.default = userspace.users.default;
                    auth.request_timeout = 60;
                    clock.enabled = false;

                    keyboard = {
                        layout = "us,ru";
                        options = "grp:alt_shift_toggle";
                        numlock = true;
                    };

                    cursor = {
                        theme = userspace.theme.preset.cursor.style;
                        size = userspace.theme.preset.cursor.size;
                    };

                    appearance = {
                        scheme = userspace.theme.preset.scheme.greetd;
                        password_style = "random";
                        scheme_selector_position = "hidden";
                        theme_mode = if userspace.theme.preset.darkmode then "dark" else "light";
                        font_family = userspace.theme.preset.font;
                        hide_logo = true;
                        wallpaper = {
                            path = userspace.theme.preset.greetd.wallpaper;
                            fill_mode = userspace.theme.preset.greetd.fill_mode;
                        };
                    };

                    output = { scale = 1.0; } // lib.optionalAttrs (userspace.system.displays.params != []) {
                        name = disp.d;
                        width = lib.toInt disp.w;
                        height = lib.toInt disp.h;
                        refresh_rate = builtins.fromJSON disp.r;
                    };
                };
            };
        })

        (lib.mkIf userspace.programs.lydm.enable {
            services.displayManager.ly.enable = true;
            services.displayManager.defaultSession = userspace.system.session;
            
            services.displayManager.ly.settings = {
                animation = userspace.theme.preset.lydm.animation;
                hide_version_string = "true";
                brightness_down_key = "null";
                brightness_up_key = "null";
                hide_f1_commands = "false";
            };

            environment.etc."ly/save.ini" = {
                text = ''
                    user=${userspace.users.default}
                    session_index=2
                '';
            };
        })
    ];
}
