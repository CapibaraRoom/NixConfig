{ pkgs }:

{
    boot = {
        timeout = 10;          # таймаут меню загрузки, сек
        configLimit = 10;      # сколько поколений хранить
        useZenKernel = false;  # zen-kernel вместо дефолтного
        rotate = 0;            # вращение меню загрузчика (пример: 270)
    };

    partitions = {
        mount = [ ];                    # разделы для авто-монтирования (диски): { inp = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1-part1"; out = "/media/nvme1"; }
        usbAutomount = false;           # автмонтирование USB
        defaultOutput = "/media";       # базовая точка монтирования
        defaultOptions = [ "nofail" "x-systemd.automount" "x-systemd.idle-timeout=60" ]; # опции монтирования по-умолчанию
    };

    users = {
        list = [ ];                     # список основных пользователей: users.list = [ { name = "bob"; pwd (or pwdhash from /etc/shadow) = "..."; home = "/mnt/data/bob"; } ];
        default = "defaultuser0";       # имя основного пользователя
        guestFsSize = 4096;             # размер tmpfs для гостя, Мб
        directories = [ ".config" ".local" ".local/share" ".local/state" "Desktop" "Documents" "Downloads" "Music" "Pictures" "Public" "Templates" "Videos" ];  # директории
        extraGroups = [ ];              # доп. группы пользователей
        extraGroupsDefault = [ "video" "input" "ydotool" ];  # группы по умолчанию
    };

    system = {
        fonts = [ ];                   # устанавливаемые шрифты
        packages = [ ];                # устанавливаемые пакеты
        allowPorts = { tcp = [ ]; udp = [ ]; tcpRanges = [ ]; udpRanges = [ ]; };  # открытые порты фаервола
        timezone = null;               # часовой пояс
        allowPrebuilt = false;         # проброс путей для бинарников
        allowUnfree = false;           # разрешение установки несвободных пакетов
        geolocation = false;           # включение геолокации
        session = "mango";             # сессия по умолчанию
        displays = {
            presets = [ ];             # настройки дисплеев: строки "name:WxH@R+x+y"
            params = [ ];              # распарсенные пресеты (генерируется самостоятельно)
        };
    };

    shell = {
        packages = [ ];        # доп. пакеты для шелла
        aliases = { };         # алиасы команд
    };

    git = {
        userName = "";         # git user.name
        userEmail = "";        # git user.email
    };

    ssh = {
        sftp = {
            enable   = false;  # включить sftp-сервер
            writable = false;  # разрешить запись
            port     = 22;     # порт
            dirs     = [ ];    # создание временных директорий для хранения в них данных (например /shared )
            shared   = [ ];    # общие директории (rw для всех): { user = "shareuser0"; password = "share"; dirs = [ { inp = "/shared"; out = "games"; } ]; }
        };
    };

    theme = {
        activePreset = "";                 # активный пресет ("" = preset)
        preset = {
            font = "Maple Mono NF";        # общий шрифт
            darkmode = true;               # тёмная тема

            terminal.font_size = 11;       # kitty: размер шрифта
            terminal.cursor_type = "underline";  # kitty: тип курсора

            workspaces.border_radius = 12;      # mango: скругление границ
            workspaces.border_px = 2;           # mango: толщина границ
            workspaces.num = 5;                 # mango: число тегов
            workspaces.type = "scroller";       # mango: тип тайлинга
            workspaces.center_focus = false;    # mango: центрировать фокус
            workspaces.focus_follows_mouse = false;  # mango: фокус за мышью
            workspaces.warp_cursor = false;     # mango: перемещение курсора к активному окну
            workspaces.window_rules = [ ];      # mango: правила окон: { app_id = "helium"; rule = "scroller_proportion:1.0"; }

            cursor.style = "catppuccin-frappe-dark-cursors";  # тема курсора
            cursor.size = 24;                   # размер курсора

            keyboard.repeat_delay = 250;        # задержка автоповтора, мс
            keyboard.repeat_rate = 40;          # частота автоповтора
            keyboard.layout = "us,ru";          # раскладки

            scheme.shell = "Gruvbox Material";  # палитра Noctalia
            scheme.greetd = "Gruvbox";          # палитра greeter
            scheme.gtk = "Everforest-Dark";     # GTK-тема
            scheme.gtk_icons = "Gruvbox-Plus-Dark";  # иконки GTK

            greetd.wallpaper = "/usr/share/wallpapers/sakura-calmness.jpg";  # обои greeter
            greetd.fill_mode = "crop";          # режим вписывания обоев

            lydm.animation = "matrix";          # анимация lydm

            noctalia.wallhaven_api = "";        # API-ключ wallhaven
            noctalia.bongocat_devices = [ ];    # устройства для bongocat
            noctalia.avatar = "/usr/share/wallpapers/hamster.jpg";  # аватар
            noctalia.wallpaper = "/usr/share/wallpapers/chunli-power.jpg";  # обои
        };
        # preset1 = {
        #     workspaces.num = 9;              # переопределение для preset1
        # };
    };

    programs = {
        lydm         = { enable = false; };
        greetd       = { enable = true; };
        kitty        = { enable = true; };
        mangowm      = { enable = true; };
        noctalia     = { enable = true; };

        sunshine     = { enable = false; };
        wine         = { enable = false; };
        winboat      = { enable = false; };
        docker       = { enable = false; };
        podman       = { enable = false; replaceDocker = false; };
    };
}
