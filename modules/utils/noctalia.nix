{ config, lib, pkgs, userspace, ... }:

let
    noctaliaSettings = pkgs.writeText "noctalia-settings.toml" ''

[plugins]
enabled = [
    "umedbazarov/webapp-maker",
    "aristides/udiskie",
    "h-jangra/region-recorder",
    "noctalia/wallhaven",
    "noctalia/notes",
    "noctalia/bongocat"
]

[plugin_settings."aristides/udiskie"]
file_manager_cmd = "pcmanfm"

[plugin_settings."h-jangra/region-recorder"]
audio_source = "both"

[plugin_settings."noctalia/wallhaven"]
api_key = "${userspace.theme.preset.noctalia.wallhaven_api}"
download_dir = "/home/guest/Pictures/wallpapers"

[bar.default]
background_opacity = 0.9
border_width = 1.0
concave_edge_corners = false
contact_shadow = true
margin_ends = 5
padding = 5
scale = 1.1
widget_spacing = 8
start = [ "group:g1", "workspaces", "media", "audio_visualizer" ]
end = [ "weather", "cat", "keyboard_layout", "group:g3", "group:g4" ]
center = [ "clipboard", "clock", "group:g2" ]

    [[bar.default.capsule_group]]
    accordion = false
    accordion_direction = "end"
    border_width = 1.0
    enabled = true
    fill = "surface_container"
    id = "g1"
    members = [ "network", "bluetooth" ]
    opacity = 1.0
    padding = 6.0

    [[bar.default.capsule_group]]
    accordion = true
    accordion_direction = "end"
    border_width = 1.0
    enabled = true
    fill = "surface_container"
    id = "g2"
    members = [ "control-center", "webapp", "nightlight", "screenshot", "widget" ]
    opacity = 1.0
    padding = 6.0

    [[bar.default.capsule_group]]
    accordion = false
    accordion_direction = "end"
    border_width = 1.0
    enabled = true
    fill = "surface_container"
    id = "g3"
    members = [ "privacy", "volume", "input_volume" ]
    opacity = 1.0
    padding = 6.0

    [[bar.default.capsule_group]]
    accordion = false
    accordion_direction = "end"
    border_width = 1.0
    enabled = true
    fill = "surface_container"
    id = "g4"
    members = [ "tray", "status", "notes", "notifications" ]
    opacity = 1.0
    padding = 6.0

[widget.cat]
input_devices = ${builtins.toJSON userspace.theme.preset.noctalia.bongocat_devices}
scale = 1.5
type = "noctalia/bongocat:cat"

[widget.clock]
anchor = true
capsule = true
color = "secondary"
format = "{:%d.%m.%y %a %H:%M:%S}"

[widget.control-center]
glyph = "settings-2"

[widget.keyboard_layout]
capsule = true
show_glyph = false

[widget.notes]
type = "noctalia/notes:notes"

[widget.privacy]
active_color = "error"
hide_inactive = true

[widget.status]
hide_when_empty = true
type = "aristides/udiskie:status"

[widget.webapp]
type = "custom_button"
glyph = "world-heart"

    [widget.webapp.actions]
    left = "exec noctalia msg panel-toggle umedbazarov/webapp-maker:panel"
    middle = "none"

[widget.widget]
type = "h-jangra/region-recorder:widget"

[widget.workspaces]
capsule = true


[dock]
active_monitor_only = true
concave_edge_corners = false
enabled = true
launcher_icon = "apps-filled"
launcher_position = "start"
pinned = [ "pcmanfm", "helium", "codium", "kitty" ]
reserve_space = false
show_dots = true
show_instance_count = false
smart_auto_hide = true


[shell]
avatar_path = "${userspace.theme.preset.noctalia.avatar}"
date_format = "{:%d.%m.%y}"
font_family = "${userspace.theme.preset.font}"
password_style = "random"
polkit_agent = true

    [shell.launcher]
    app_grid = true
    category_icons_only = true
    default_view = "all"
    search_position = "top"
    show_settings_button = false

    [shell.screenshot]
    confirm_region = true
    remember_last_region = true

    [[shell.session.actions]]
    action = "lock"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "1"
    variant = "default"

    [[shell.session.actions]]
    action = "lock_and_suspend"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "3"
    variant = "default"

    [[shell.session.actions]]
    action = "logout"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "2"
    variant = "default"

    [[shell.session.actions]]
    action = "reboot"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "4"
    variant = "default"

    [[shell.session.actions]]
    action = "shutdown"
    countdown_seconds = 0.0
    enabled = true
    shortcut = "5"
    variant = "destructive"

[theme]
builtin = "${userspace.theme.preset.scheme.greetd}"
community_palette = "${userspace.theme.preset.scheme.shell}"
source = "community"

    [theme.templates]
    builtin_ids = [ "gtk3", "gtk4", "kcolorscheme", "kitty", "mango", "qt" ]
    community_ids = [ "micro", "yazi" ]


[audio]
sound_volume = 1.0
sound_theme = "magic-nocta"

[osd.kinds]
keyboard_layout = false
lock_keys = false
media = false

[brightness]
enable_ddcutil = true

[location]
auto_locate = ${lib.boolToString userspace.system.geolocation}

[control_center]
sidebar = "full"
width = 760

    [control_center.calendar]
    show_events_card = false

    [[control_center.shortcuts]]
    type = "wifi"

    [[control_center.shortcuts]]
    type = "bluetooth"

    [[control_center.shortcuts]]
    type = "audio"

    [[control_center.shortcuts]]
    type = "mic_mute"

    [[control_center.shortcuts]]
    type = "nightlight"

    [[control_center.shortcuts]]
    type = "noctalia/wallhaven:shortcut"

[wallpaper.default]
path = "${userspace.theme.preset.noctalia.wallpaper}"

    '';
in {
    config = lib.mkIf (userspace.programs.noctalia.enable) {
        programs.noctalia.enable = true;

        environment.pathsToLink = [ "/share/noctalia/plugins" ];
        environment.systemPackages = with pkgs; [
            noctalia-plugins
            # фикс прав в tmp: (pkgs.writeShellScriptBin "noctalia" ''umask 000; exec ${pkgs.noctalia}/bin/noctalia "$@"'')
        ];

        systemd.tmpfiles.rules = [
            "d /home/guest/.config/noctalia 0755 guest users -"
            "C+ /home/guest/.config/noctalia/settings.toml 0644 guest users - ${noctaliaSettings}"

            "d /home/guest/.local/state/noctalia 0755 guest users -"
            "d /home/guest/.local/state/noctalia/plugins 0755 guest users -"
            "d /home/guest/.local/state/noctalia/plugins/materialized 0755 guest users -"
            "d /home/guest/.local/state/noctalia/plugins/materialized/official 0755 guest users -"
            "d /home/guest/.local/state/noctalia/plugins/materialized/community 0755 guest users -"

            "L /home/guest/.local/state/noctalia/plugins/materialized/official/notes - - - - /usr/share/noctalia/plugins/notes"
            "L /home/guest/.local/state/noctalia/plugins/materialized/official/bongocat - - - - /usr/share/noctalia/plugins/bongocat"
            "L /home/guest/.local/state/noctalia/plugins/materialized/official/wallhaven - - - - /usr/share/noctalia/plugins/wallhaven"
            "L /home/guest/.local/state/noctalia/plugins/materialized/community/udiskie - - - - /usr/share/noctalia/plugins/udiskie"
            "L /home/guest/.local/state/noctalia/plugins/materialized/community/webapp-maker - - - - /usr/share/noctalia/plugins/webapp-maker"
            "L /home/guest/.local/state/noctalia/plugins/materialized/community/region-recorder - - - - /usr/share/noctalia/plugins/region-recorder"
        ];
    };
}
