{ rustPlatform, fetchFromGitHub, lib, alsa-lib, wayland, libxkbcommon, libGL, libx11, libxcb, gtk3, pkg-config, makeWrapper }:

rustPlatform.buildRustPackage rec {
    name = "pinel";

    src = fetchFromGitHub {
        owner = "kashsuks";
        repo = "Pinel";
        rev = "4b8c94fcf941363ed1e1892ca87f57d378852a71";
        hash = "sha256-FDevPmkcUXPrWFkHYprOyQ+27b5byGqTEtvXmQPWCHQ=";
    };

    # cargoHash = "";
    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs = [ pkg-config makeWrapper ];

    buildInputs = [ alsa-lib wayland libxkbcommon libGL libx11 libxcb gtk3 ];

    postInstall = ''
        wrapProgram $out/bin/pinel \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ alsa-lib wayland libxkbcommon libGL libx11 libxcb gtk3 ]}"
    '';
}
