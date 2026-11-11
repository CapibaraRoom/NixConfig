{ config, lib, pkgs, userspace, ... }:

let
    kittySettings = pkgs.writeText "kitty-settings.conf" ''
        # Шрифты и курсор
        font_family                 ${userspace.theme.preset.font}
        bold_font                   auto
        italic_font                 auto
        bold_italic_font            auto
        font_size                   ${toString userspace.theme.preset.terminal.font_size}
        cursor_shape                ${userspace.theme.preset.terminal.cursor_type}
        shell_integration           no-cursor
        
        # Настройки окна и поведения
        window_padding_width        4
        initial_window_width        90c
        initial_window_height       27c
        remember_window_size        no
        confirm_os_window_close     0
        update_check_interval       0
        scrollback_lines            10000
        shell                       zsh
        
        # Ссылки и уведомления
        detect_urls                 yes
        url_color                   #a7c080
        url_style                   curly
        visual_bell_duration        0
        enable_audio_bell           no
        repaint_delay               10
        
        # Настройка сплитов (окон)
        enabled_layouts             splits, stack
        window_border_width         1pt
        active_border_color         #a7c080
        inactive_border_color       #475258
        window_margin_width         0
        single_window_margin_width  0
        draw_minimal_borders        yes
        
        # Вкладки (панель табов)
        tab_bar_edge                bottom
        tab_bar_min_tabs            2
        tab_title_max_length        15
        tab_title_template          "{index}: {title}"
        active_tab_foreground       #2d353b
        active_tab_background       #a7c080
        inactive_tab_foreground     #d3c6aa
        inactive_tab_background     #475258
        tab_bar_background          #2d353b
        
        # Цветовая схема: Everforest Dark (Medium)
        foreground                  #d3c6aa
        background                  #2d353b
        selection_foreground        #2d353b
        selection_background        #d3c6aa
        
        # ANSI-цвета
        color0                      #475258
        color1                      #e67e80
        color2                      #a7c080
        color3                      #dbbc7f
        color4                      #7fbbb3
        color5                      #d699b6
        color6                      #83c092
        color7                      #d3c6aa
        
        color8                      #5c6a72
        color9                      #f85552
        color10                     #b9c97c
        color11                     #e7b87b
        color12                     #8fbcbb
        color13                     #e1b6cf
        color14                     #9dca9c
        color15                     #dfdecd
        
        map ctrl+shift+left_bracket   launch --location=hsplit --cwd=current
        map ctrl+shift+right_bracket  launch --location=vsplit --cwd=current
        map ctrl+shift+left           neighboring_window left
        map ctrl+shift+right          neighboring_window right
        map ctrl+shift+up             neighboring_window up
        map ctrl+shift+down           neighboring_window down
        map ctrl+shift+backspace      close_window
        map ctrl+shift+p              toggle_layout stack
    '';
in {
    config = lib.mkIf (userspace.programs.kitty.enable) {
        environment.systemPackages = with pkgs; [ kitty ];
        
        systemd.tmpfiles.rules = [
            "d /home/guest/.config/kitty 0755 guest users -"
            "C+ /home/guest/.config/kitty/kitty.conf 0644 guest users - ${kittySettings}"
        ];
    };
}
