{ config, lib, pkgs, userspace, ... }:

{
    boot.kernelPackages = if userspace.boot.useZenKernel then pkgs.linuxPackages_zen else pkgs.linuxPackages_latest;

    nixpkgs.overlays = lib.mkIf (userspace.boot.rotate != 0) [
        (import (builtins.fetchTarball {
            url = "https://github.com/iggyZiggy/chuwi-grub-rotation-nix-patch/archive/146b4415309e8cefeccbc211b30c82e3f24c641a.tar.gz";
            sha256 = "1wlpz4hs86vqapmf6bcy4zrcvcc65mpqn7f3hjmj619dr120vn44";
        } + "/overlays/grub2"))
        (final: prev: { grub2 = prev.grub2.overrideAttrs (old: { configureFlags = old.configureFlags++[ "--disable-werror" ]; }); })
    ];
    
    boot.loader = {
        timeout = userspace.boot.timeout;
        efi = {
            efiSysMountPoint = "/boot";
            canTouchEfiVariables = true;
        };
        grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
            gfxpayloadEfi = "keep";
            gfxmodeEfi = if userspace.boot.rotate != 0 then "1920x1080-${toString userspace.boot.rotate}" else "1920x1080";
            configurationLimit = userspace.boot.configLimit;
            splashImage = null;
            theme = pkgs.stdenv.mkDerivation {
                pname = "grub-of-tsushima-theme";
                version = "1.0";
                src = pkgs.fetchFromGitHub {
                    owner = "ivanimmanuel-dev";
                    repo = "grub-of-tsushima";
                    rev = "d44bbfbccd32b63e8f29c5b4b0501af4c3722a25";
                    hash = "sha256-LeoqV8V1wEmBTBetiePRhVfbPOFnl8MlbH4U5CCKpAQ=";
                };
                installPhase = ''
                    mkdir -p $out
                    cp -r grub-of-tsushima-black/* $out/
                    substituteInPlace $out/theme.txt --replace 'width = 30%' 'width = 57%'
                '';
            };
        };
    };
}
