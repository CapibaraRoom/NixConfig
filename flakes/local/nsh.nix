{ writeShellApplication }:

let
    zshCompletion = builtins.toFile "nsh.zsh" ''
        #compdef nsh

        _nsh() {
            local -a commands
            commands=(
                'check:проверить сборку (dry-build)'
                'update:активировать конфигурацию до перезагрузки'
                'upgrade:активировать конфигурацию и сохранить (пункт в меню GRUB)'
                'full-upgrade:обновить все пакеты в системе'
                'clean:удалить старые поколения и оптимизировать store'
                'edit:открыть конфигурацию в редакторе'
                'tree:интерактивный граф зависимостей (nix-graph)'
                'list:список пакетов системы'
                'help:показать справку'
            )

            _arguments -C '1: :->command' '*:: :->args'

            case $state in
                command)
                    _describe 'команда' commands
                    if [[ $words[2] == -* ]]; then
                        _arguments \
                            '-p[пакет для установки]:пакет:' \
                            '--run[команда для выполнения]:команда:' \
                            '-I[добавить путь в NIX_PATH]:путь:_files -/'
                    fi ;;
                args)
                    case $words[1] in
                        edit) _files -/ ;;
                        full-upgrade) _files -/ ;;
                        tree) _files -/ ;;
                        list)
                            _arguments \
                                '--hash[показать хэш]' \
                                '--size[показать размер]' \
                                '--biggest[по убыванию размера]' \
                                '--smallest[по возрастанию размера]'
                            ;;
                    esac ;;
            esac
        }

        _nsh "$@"
    '';
in (writeShellApplication {
    name = "nsh";

    text = ''
        CURRENT_HOSTNAME="''${HOST:-$(hostname -s)}"

        cmd_help() {
            cat <<EOF
        Использование:
            nsh <аргументы>        запустить nix-shell (по умолчанию ~/.nixdev.nix)

        Подкоманды:
            check                  проверить конфигурацию (dry-build)
            update                 активировать конфигурацию до перезагрузки
            upgrade                активировать конфигурацию и сохранить (пункт в меню GRUB)
            full-upgrade [путь]    обновить все пакеты в системе (по умолчанию /etc/nixos)
            clean                  удалить старые поколения и оптимизировать store
            edit [путь]            открыть конфигурацию в редакторе (по умолчанию /etc/nixos)
            tree [путь]            интерактивный граф зависимостей (nix-graph)
            list [опции]           список пакетов текущей системы
                --hash               показать хэш
                --size               показать размер
                --biggest[=N]        по убыванию размера (топ-N)
                --smallest[=N]       по возрастанию размера (топ-N)
            help                   показать справку

        Текущий хост для системы: $CURRENT_HOSTNAME
        EOF
        }

        cmd_default() {
            if [ $# -eq 0 ]; then
                exec nix-shell "$HOME/.nixdev.nix" --run "exec zsh"
            else
                exec nix-shell "$@"
            fi
        }

        cmd_update() {
            sudo nixos-rebuild test --flake "/etc/nixos#''${CURRENT_HOSTNAME}"
        }

        cmd_upgrade() {
            sudo nixos-rebuild switch --flake "/etc/nixos#''${CURRENT_HOSTNAME}"
        }
        
        cmd_full_upgrade() {
            sudo nix flake update --flake "''${1:-/etc/nixos}" nixpkgs
            sudo nixos-rebuild switch --flake "''${1:-/etc/nixos}#''${CURRENT_HOSTNAME}"
        }

        cmd_check() {
            sudo nixos-rebuild dry-build --flake "/etc/nixos#''${CURRENT_HOSTNAME}"
            echo "OK!"
        }

        cmd_clean() {
            sudo nix-collect-garbage -d
            sudo nix-store --optimize
        }

        cmd_edit() {
            sudo XDG_RUNTIME_DIR="/run/user/$(id -u)" codium \
                --ozone-platform=wayland \
                --no-sandbox \
                --user-data-dir=/tmp/codium-root-data \
                "''${1:-/etc/nixos}"
        }

        cmd_tree() {
            exec nix-graph "$@"
        }

        cmd_list() {
            local show_hash=0 show_size=0 sort_order="" limit=0

            while [ $# -gt 0 ]; do
                case "$1" in
                    --hash)     show_hash=1; shift ;;
                    --size)     show_size=1; shift ;;
                    --biggest)  show_size=1; sort_order=desc; shift ;;
                    --smallest) show_size=1; sort_order=asc;  shift ;;
                    --biggest=*|--smallest=*)
                        show_size=1
                        limit="''${1#*=}"
                        [[ "$limit" =~ ^[0-9]+$ ]] || { echo "nsh list: $1 требует число после =" >&2; exit 1; }
                        if [[ "$1" == --biggest=* ]]; then sort_order=desc; else sort_order=asc; fi
                        shift ;;
                    *) echo "nsh list: неизвестный аргумент: $1" >&2; exit 1 ;;
                esac
            done

            local parsed
            parsed=$(nix path-info -r -s /run/current-system | awk '{
                n = split($1, a, "/"); base = a[n]
                print substr(base,1,32) "\t" substr(base,34) "\t" $2
            }')

            case "$sort_order" in
                desc) parsed=$(printf '%s\n' "$parsed" | sort -t$'\t' -k3,3nr) ;;
                asc)  parsed=$(printf '%s\n' "$parsed" | sort -t$'\t' -k3,3n)  ;;
                *)    parsed=$(printf '%s\n' "$parsed" | sort -t$'\t' -k2,2)   ;;
            esac

            printf '%s\n' "$parsed" | awk -F'\t' -v h="$show_hash" -v s="$show_size" -v l="$limit" '
                function human(b) {
                    if (b < 1024) return b "B"
                    if (b < 1024*1024) return sprintf("%.1fK", b/1024)
                    if (b < 1024*1024*1024) return sprintf("%.1fM", b/1024/1024)
                    return sprintf("%.1fG", b/1024/1024/1024)
                }
                l > 0 && NR > l { next }
                h && s { print $1 "\t" human($3) "\t" $2; next }
                h      { print $1 "\t" $2; next }
                s      { print human($3) "\t" $2; next }
                       { print $2 }
            ' | column -t -s $'\t'
        }

        case "''${1:-}" in
            help|-h|--help) cmd_help ;;
            "")             cmd_default              "$@" ;;
            -*)             cmd_default              "$@" ;;
            update)         shift; cmd_update        "$@" ;;
            upgrade)        shift; cmd_upgrade       "$@" ;;
            full-upgrade)   shift; cmd_full_upgrade  "$@" ;;
            check)          shift; cmd_check         "$@" ;;
            clean)          shift; cmd_clean         "$@" ;;
            edit)           shift; cmd_edit          "$@" ;;
            list)           shift; cmd_list          "$@" ;;
            tree)           shift; cmd_tree          "$@" ;;
            *)
                echo "nsh: неизвестная команда: $1" >&2
                echo "'nsh help' для справки." >&2
                exit 1 ;;
        esac
    '';
}).overrideAttrs (old: {
    buildCommand = (old.buildCommand or "") + ''
        mkdir -p $out/share/zsh/site-functions
        cp ${zshCompletion} $out/share/zsh/site-functions/_nsh
    '';
})
