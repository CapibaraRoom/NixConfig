{ stdenv, fetchzip, autoPatchelfHook, makeWrapper, lib, glibc, bash, elfutils, libelf, libglvnd, SDL2, libX11, libxcb, wayland, libxkbcommon, hicolor-icon-theme }:

stdenv.mkDerivation {
    name = "ecode";

    src = fetchzip {
        url = "https://github.com/SpartanJ/ecode/releases/download/ecode-0.8.1/ecode-linux-0.8.1-x86_64.tar.gz";
        hash = "sha256-3zllgsyiYSdwpn1L/GAbDaA6lk30C0UClYBD4fDzqJ0=";
    };

    nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

    buildInputs = [ glibc bash elfutils libelf libglvnd SDL2 libX11 libxcb wayland libxkbcommon hicolor-icon-theme ];

    installPhase = ''
        mkdir -p $out/{bin,lib/ecode,share/{applications,icons/hicolor/256x256/apps,licenses/ecode}}

        cp -r . $out/lib/ecode

        makeWrapper $out/lib/ecode/ecode $out/bin/ecode --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd SDL2 libelf libX11 libxcb wayland libxkbcommon ]}"

        [ -f $out/lib/ecode/ecode.desktop ] && cp $out/lib/ecode/ecode.desktop $out/share/applications/
        [ -f $out/lib/ecode/ecode.png ]     && cp $out/lib/ecode/ecode.png     $out/share/icons/hicolor/256x256/apps/
        [ -f $out/lib/ecode/LICENSE ]       && cp $out/lib/ecode/LICENSE       $out/share/licenses/ecode/

        runHook postInstall
    '';
}
