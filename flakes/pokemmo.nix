{ lib, stdenv, makeWrapper, wget, unzip, libGL, libpulseaudio, alsa-lib, libX11, libxkbcommon, wayland, gtk3, glib, gsettings-desktop-schemas }:

stdenv.mkDerivation rec {
    name = "pokemmo";
    dontUnpack = true;

    src = null;
    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
        mkdir -p $out/bin
        cat > $out/bin/pokemmo << 'EOF'
            #!/bin/sh
            GAME_DIR="$HOME/.local/share/pokemmo"
            TMP_ARCHIVE="/tmp/pokemmo-latest.zip"
            DOWNLOAD_URL="https://pokemmo.com/download_file/1/"

            if [ ! -d "$GAME_DIR" ] || [ ! -f "$GAME_DIR/PokeMMO.sh" ]; then
                echo "PokeMMO not found. Installing..."

                if [ ! -f "$TMP_ARCHIVE" ]; then
                    echo "Downloading..."
                    mkdir -p "$(dirname "$TMP_ARCHIVE")"
                    wget -q --show-progress -O "$TMP_ARCHIVE" "$DOWNLOAD_URL"
                fi

                echo "Extracting: $GAME_DIR..."
                mkdir -p "$GAME_DIR"
                unzip -q -o "$TMP_ARCHIVE" -d "$GAME_DIR"
                chmod +x "$GAME_DIR/PokeMMO.sh"

                echo "Done! exec: 'pokemmo' again."
            fi

            cd "$GAME_DIR" || exit 1
            exec ./PokeMMO.sh "$@"
        EOF
        chmod +x $out/bin/pokemmo
    '';

    postFixup = ''
        wrapProgram "$out/bin/pokemmo" \
            --prefix PATH : ${lib.makeBinPath [ wget unzip ]} \
            --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL libpulseaudio alsa-lib libX11 libxkbcommon wayland gtk3 glib ]} \
            --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${gsettings-desktop-schemas.version}:${gtk3}/share/gsettings-schemas/${gtk3.name}" \
            --set GIO_EXTRA_MODULES "${gtk3}/lib/gio/modules"
    '';
}
