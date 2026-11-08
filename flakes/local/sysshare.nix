{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
    name = "capibara-shared";

    src = fetchFromGitHub {
        owner = "CapibaraRoom";
        repo = "SystemShared";
        rev = "ed38b49e97a524264c16247bfad5c0136671abe8";
        hash = "sha256-VS4yWxbiPC86xffp1j0VQrwJvR7nPG4gIwiLgE/xX5g=";
    };

    installPhase = ''
        mkdir -p $out/share
        cp -r wallpapers $out/share/
        cp -r sounds     $out/share/
    '';
}
