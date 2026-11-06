{ rustPlatform, fetchFromGitHub, lib }:

rustPlatform.buildRustPackage rec {
    name = "croft-software";
    doCheck = false;

    src = fetchFromGitHub {
        owner = "vitali87";
        repo = "croft";
        rev = "f2615cc667d37b2467712722d970636ecc14fc60";
        hash = "sha256-meba/k9QUMUMuC99okRNcXvXLLc8KagnsffBhTO+1E4=";
    };

    # cargoHash = "";
    cargoLock.lockFile = "${src}/Cargo.lock";
}
