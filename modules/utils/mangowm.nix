{ config, lib, pkgs, userspace, ... }:

let
    mangowmSettings = pkgs.writeText "mangowm-settings.conf" ''
        # wiki: https://github.com/DreamMaoMao/mango/wiki/

        exec_once = noctalia

        cursor_theme=${userspace.theme.preset.cursor.style}
        cursor_size=${toString userspace.theme.preset.cursor.size}

        # ===== Эффекты окон =====
        focused_opacity=1.00
        unfocused_opacity=0.50
        border_radius=${toString userspace.theme.preset.workspaces.border_radius}
        border_px=${toString userspace.theme.preset.workspaces.border_px}
        gap_inner_horizontal=6
        gap_inner_vertical=8
        gap_outer_horizontal=6
        gap_outer_vertical=8

        blur=1
        blur_layer=0
        blur_optimized=1
        blur_params_num_passes=2
        blur_params_radius=6
        blur_params_noise=0.02
        blur_params_brightness=0.95
        blur_params_contrast=0.95
        blur_params_saturation=1.1

        # ===== Тени =====
        shadows=1
        layer_shadows=0
        shadow_only_floating=0
        shadows_size=7
        shadows_blur=7
        shadows_position_x=-4
        shadows_position_y=-4
        shadows_color=0x000000ff

        # ===== Анимации =====
        animations=1
        layer_animations=1
        animation_type_open=zoom
        animation_type_close=slide
        animation_fade_in=1
        animation_fade_out=1
        tag_animation_direction=0
        zoom_initial_ratio=0.4
        zoom_end_ratio=0.8
        fade_in_begin_opacity=0.5
        fade_out_begin_opacity=0.8
        animation_duration_move=500
        animation_duration_open=400
        animation_duration_tag=350
        animation_duration_close=800
        animation_duration_focus=300
        animation_curve_open=0.46,1.0,0.29,1
        animation_curve_move=0.46,1.0,0.29,1
        animation_curve_tag=0.46,1.0,0.29,1
        animation_curve_close=0.08,0.92,0,1
        animation_curve_focus=0.46,1.0,0.29,1
        animation_curve_opacity_fade_in=0.46,1.0,0.29,1
        animation_curve_opacity_fade_out=0.5,0.5,0.5,0.5

        # ===== Разное =====
        axis_bind_apply_timeout=60
        sloppy_focus=${if userspace.theme.preset.workspaces.focus_follows_mouse then "1" else "0"}
        warp_cursor=${if userspace.theme.preset.workspaces.warp_cursor then "1" else "0"}
        focus_on_activate=1
        enable_floating_snap=1
        snap_distance=30
        drag_tile_to_tile=1
        drag_tile_small=1
        sync_obj_enable=1

        # ===== Клавиатура =====
        repeat_delay=${toString userspace.theme.preset.keyboard.repeat_delay}
        repeat_rate=${toString userspace.theme.preset.keyboard.repeat_rate}
        numlock_on=1
        xkb_rules_layout=${userspace.theme.preset.keyboard.layout}
        xkb_rules_options=grp:alt_shift_toggle

        # ===== Тайлинг =====
        tag_num=${toString userspace.theme.preset.workspaces.num}
        tag_rule=id:*,layout_name:${userspace.theme.preset.workspaces.type}

        scroller_structs=5
        scroller_default_proportion=0.5
        scroller_focus_center=${if userspace.theme.preset.workspaces.center_focus then "1" else "0"}
        scroller_default_proportion_single=1.0
        scroller_proportion_preset=0.5,0.8,1.0

        ${lib.concatMapStrings (r: "window_rule=app_id:${r.app_id},${r.rule}\n") userspace.theme.preset.workspaces.window_rules}
        ${lib.concatMapStrings (p: "monitor_rule=name:^${p.d}$,width:${p.w},height:${p.h},refresh:${p.r},x:${p.x},y:${p.y}\n") userspace.system.displays.params}



        # ===== BINDS =====
        bind = SUPER, backspace, quit
        bind = SUPER, m, reload_config
        bind = SUPER, n, switch_layout


        # ===== Утилиты =====
        bind = SUPER, t, spawn, kitty
        bind = ALT, t, spawn, kitty
        bind = SUPER, Return, spawn, kitty
        bind = ALT, Return, spawn, kitty
        bind = CTRL+ALT, t, spawn, kitty

        bind = SUPER, space, spawn, noctalia msg panel-toggle launcher
        bind = SUPER, e, spawn, noctalia msg screenshot-region
        bind = none, Print, spawn, noctalia msg screenshot-region
        bind = SUPER, l, spawn, noctalia msg session lock
        bind = SUPER, v, spawn, noctalia msg panel-toggle clipboard


        # ===== Перемещение между окнами =====
        bind = SUPER, Left, focusdir, left
        bind = SUPER, Right, focusdir, right
        bind = SUPER, Up, focusdir, up
        bind = SUPER, Down, focusdir, down
        bind = SUPER, a, focusdir, left
        bind = SUPER, d, focusdir, right
        bind = SUPER, w, focusdir, up
        bind = SUPER, s, focusdir, down

        bind = ALT, Left, focusdir, left
        bind = ALT, Right, focusdir, right
        bind = ALT, a, focusdir, left
        bind = ALT, d, focusdir, right

        bind = SUPER, Tab, toggleoverview
        bind = ALT, Tab, toggleoverview

        # ===== Перемещение окон в тайле =====
        bind = SUPER+SHIFT, Left, exchange_client, left
        bind = SUPER+SHIFT, Right, exchange_client, right
        bind = SUPER+SHIFT, Up, exchange_client, up
        bind = SUPER+SHIFT, Down, exchange_client, down
        bind = SUPER+SHIFT, a, exchange_client, left
        bind = SUPER+SHIFT, d, exchange_client, right
        bind = SUPER+SHIFT, w, exchange_client, up
        bind = SUPER+SHIFT, s, exchange_client, down

        # ===== Тайлинг =====
        bind = SUPER+SHIFT, r, switch_proportion_preset
        bind = SUPER+CTRL, Left, scroller_stack, left
        bind = SUPER+CTRL, Right, scroller_stack, right
        bind = SUPER+CTRL, Up, scroller_stack, up
        bind = SUPER+CTRL, Down, scroller_stack, down
        bind = SUPER+CTRL, a, scroller_stack, left
        bind = SUPER+CTRL, d, scroller_stack, right
        bind = SUPER+CTRL, w, scroller_stack, up
        bind = SUPER+CTRL, s, scroller_stack, down

        # ===== Переключение статуса окна =====
        # bind = SUPER+SHIFT, f, togglefakefullscreen
        bind = SUPER, f, togglefullscreen
        bind = SUPER, r, togglemaximizescreen
        bind = SUPER, z, minimized
        bind = SUPER+SHIFT, z, restore_minimized
        bind = SUPER, x, togglefloating
        bind = SUPER, q, killclient
        bind = ALT, q, killclient

        # ===== Переключение тегов =====
        bind = ALT, Up, viewtoleft, 0
        bind = ALT, Down, viewtoright, 0
        bind = ALT, w, viewtoleft, 0
        bind = ALT, s, viewtoright, 0
        bind = CTRL+ALT, Left, tagtoleft, 0
        bind = CTRL+ALT, Right, tagtoright, 0
        bind = CTRL+ALT, Up, tagtoleft, 0
        bind = CTRL+ALT, Down, tagtoright, 0
        bind = CTRL+ALT, a, tagtoleft, 0
        bind = CTRL+ALT, d, tagtoright, 0
        bind = CTRL+ALT, w, tagtoleft, 0
        bind = CTRL+ALT, s, tagtoright, 0

        # ===== Переход к тегу =====
        bind = CTRL, 1, view, 1, 0
        bind = CTRL, 2, view, 2, 0
        bind = CTRL, 3, view, 3, 0
        bind = CTRL, 4, view, 4, 0
        bind = CTRL, 5, view, 5, 0
        bind = CTRL, 6, view, 6, 0
        bind = CTRL, 7, view, 7, 0
        bind = CTRL, 8, view, 8, 0
        bind = CTRL, 9, view, 9, 0

        # ===== Перемещение окна в тег =====
        bind = ALT, 1, tag, 1, 0
        bind = ALT, 2, tag, 2, 0
        bind = ALT, 3, tag, 3, 0
        bind = ALT, 4, tag, 4, 0
        bind = ALT, 5, tag, 5, 0
        bind = ALT, 6, tag, 6, 0
        bind = ALT, 7, tag, 7, 0
        bind = ALT, 8, tag, 8, 0
        bind = ALT, 9, tag, 9, 0

        # ===== Переключение мониторов =====
        bind = CTRL+SHIFT, Left, focusmon, left
        bind = CTRL+SHIFT, Right, focusmon, right
        bind = CTRL+SHIFT, a, focusmon, left
        bind = CTRL+SHIFT, d, focusmon, right
        bind = SUPER+CTRL+SHIFT, Left, tagmon, left
        bind = SUPER+CTRL+SHIFT, Right, tagmon, right
        bind = SUPER+CTRL+SHIFT, a, tagmon, left
        bind = SUPER+CTRL+SHIFT, d, tagmon, right

        # ===== Привязки кнопок мыши =====
        mousebind = SUPER, btn_left, moveresize, curmove
        mousebind = SUPER, btn_right, moveresize, curresize
        axisbind = SUPER, UP, viewtoleft_have_client
        axisbind = SUPER, DOWN, viewtoright_have_client
    '';

    gtk3Settings = pkgs.writeText "gtk3-settings.ini" ''
        [Settings]
        gtk-theme-name=${userspace.theme.preset.scheme.gtk}
        gtk-icon-theme-name=${userspace.theme.preset.scheme.gtk_icons}
        gtk-cursor-theme-name=${userspace.theme.preset.cursor.style}
    '';
in {
    config = lib.mkIf (userspace.programs.mangowm.enable) {
        programs.mango.enable = true;
        
        environment.systemPackages = with pkgs; [
            catppuccin-cursors.frappeDark
            catppuccin-cursors.frappeLight
            catppuccin-cursors.frappePeach
            gnome-themes-extra
            everforest-gtk-theme
            gruvbox-plus-icons
        ];
        
        programs.xfconf.enable = true;
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [ {
            settings."org/gnome/desktop/interface" = {
                color-scheme = "prefer-" + (if userspace.theme.preset.darkmode then "dark" else "light");
                gtk-theme = userspace.theme.preset.scheme.gtk;
                icon-theme = userspace.theme.preset.scheme.gtk_icons;
            };
        } ];

        environment.sessionVariables = {
            GTK_THEME = userspace.theme.preset.scheme.gtk;
        };
        
        systemd.tmpfiles.rules = [
            "d /home/guest/.config/mango 0755 guest users -"
            "C+ /home/guest/.config/mango/config.conf 0644 guest users - ${mangowmSettings}"

            "d /home/guest/.config/gtk-3.0 0755 guest users -"
            "C+ /home/guest/.config/gtk-3.0/settings.ini 0644 guest users - ${gtk3Settings}"
        ];
    };
}
