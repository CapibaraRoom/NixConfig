{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
    name = "tg-ws-proxy-rs";
    doCheck = false;
    
    src = fetchFromGitHub {
        owner = "valnesfjord";
        repo = "tg-ws-proxy-rs";
        rev = "0bc30c19c118e8aec17bd0ff6d830e5afdda0e71";
        hash = "sha256-p5ZrqCwc3/WOJIo3eEGMQhWcREdCKOn0gV3Z/HPeC8w=";
    };
    
    # cargoHash = "";
    cargoLock.lockFile = "${src}/Cargo.lock";
}
