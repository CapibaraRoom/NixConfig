{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
    name = "capibara-wallpapers";

    src = fetchFromGitHub {
        owner = "CapibaraRoom";
        repo = "SystemShared";
        rev = "1167749fdc44ad305274b924608f2920ede2907f";
        hash = "sha256-261k/CN6e/Lzrj2uoStyyeiJJTChCn/62Kkw33OZEAE=";
    };

    installPhase = ''
        mkdir -p $out/share
        cp -r wallpapers $out/share/
    '';
}
