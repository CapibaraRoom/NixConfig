{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
    name = "noctalia-plugins";
    dontUnpack = true;

    officialSrc = fetchFromGitHub {
        owner = "noctalia-dev";
        repo  = "official-plugins";
        rev   = "dc7ce57ed977ba830f524ade9ceac4fad914f533";
        hash  = "sha256-NTv4ftS8HNzEz2eCsrzkGEI3SmlXvG0NP666Dx5P+Yg=";
        sparseCheckout = [ "bongocat" "notes" "wallhaven" ];
    };

    communitySrc = fetchFromGitHub {
        owner = "noctalia-dev";
        repo  = "community-plugins";
        rev   = "e6281062920da3b9038cf14f49d4487b987993d9";
        hash  = "sha256-f0r/SDTyJIOmSGbxpRQ9wRW1kCyOeG+OmR+zUr6+I7s=";
        sparseCheckout = [ "region-recorder" "udiskie" "webapp-maker" ];
    };

    installPhase = ''
        mkdir -p $out/share/noctalia/plugins

        cp -r ${officialSrc}/bongocat         $out/share/noctalia/plugins/
        cp -r ${officialSrc}/notes            $out/share/noctalia/plugins/
        cp -r ${officialSrc}/wallhaven        $out/share/noctalia/plugins/

        cp -r ${communitySrc}/region-recorder $out/share/noctalia/plugins/
        cp -r ${communitySrc}/udiskie         $out/share/noctalia/plugins/
        cp -r ${communitySrc}/webapp-maker    $out/share/noctalia/plugins/
    '';
}
