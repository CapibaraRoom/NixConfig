{
    description = "NixOS configuration";
    
    inputs = {
        nixpkgs.url      = "github:NixOS/nixpkgs/nixos-26.05";

        mangowm          = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:mangowm/mango/0.18.5"; };
        noctalia         = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:noctalia-dev/noctalia/v5.4.1"; };
        noctalia-greeter = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:noctalia-dev/noctalia-greeter/v1.7.0"; };
        nix-graph        = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:AlexAntonik/nix-graph"; };

        helium           = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:oxcl/nix-flake-helium-browser"; };
        zapret           = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:Sergeydigl3/zapret-discord-youtube-rust"; };
        max-messenger    = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:CapibaraRoom/max-messenger-nix"; };

        # caelestia-shell  = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:caelestia-dots/shell"; };
        # superfile        = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:yorukot/superfile"; };
        
        # ryoku            = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:Ryoku-dev/Ryoku-on-NixOS"; };
    };
    
    outputs = { self, nixpkgs, ... }@inputs: let system = "x86_64-linux";
    
        packages = pkgs: rec {

            helium = inputs.helium.packages.${system}.helium;
            zapret-rust = inputs.zapret.packages.${system}.default;
            max-messenger = inputs.max-messenger.packages.${system}.default;
            noctalia-greeter = inputs.noctalia.packages.${system}.noctalia-greeter;
            nix-graph = inputs.nix-graph.packages.${system}.default;
            # caelestia-shell = inputs.caelestia-shell.packages.${system}.with-cli;
            # superfile = inputs.superfile.packages.${system}.default;

            tg-ws-proxy = pkgs.callPackage ./flakes/tg-ws-proxy-rs.nix {};
            croft = pkgs.callPackage ./flakes/croft.nix {};
            ecode = pkgs.callPackage ./flakes/ecode.nix {};
            pinel = pkgs.callPackage ./flakes/pinel.nix {};
            pokemmo = pkgs.callPackage ./flakes/pokemmo.nix {};

            noctalia-plugins = pkgs.callPackage ./flakes/local/noctalia-plugins.nix {};
            nsh = pkgs.callPackage ./flakes/local/nsh.nix {};
            sysshare = pkgs.callPackage ./flakes/local/sysshare.nix {};
            
            localFlakes = pkgs.symlinkJoin { name  = "localFlakes"; paths = [ nsh sysshare ]; };
            
        };


        hostnames = map (f: builtins.replaceStrings [ "configuration_" ".nix" ] [ "" "" ] f)
            (builtins.filter (f: builtins.match "configuration_.+\\.nix" f != null) (builtins.attrNames (builtins.readDir ./.)));

        extraInputs = builtins.removeAttrs inputs [ "self" "nixpkgs" ];
        getModule = name: let mod = inputs.${name}.nixosModules or null; 
            in if mod != null then (mod.default or (builtins.head (builtins.attrValues mod))) else null;
        extraModules = builtins.filter (x: x != null) (map getModule (builtins.attrNames extraInputs));

        makeConfig = hostname: nixpkgs.lib.nixosSystem { inherit system; specialArgs = { inherit inputs hostname; };
            modules = [
                ./modules/core.nix
                ({ pkgs, ... }: { nixpkgs.overlays = [ (final: prev: prev // packages final) ]; })
                (./. + "/configuration_${hostname}.nix")
            ] ++ extraModules;
        };
    in {
        packages.${system} = packages nixpkgs.legacyPackages.${system};
        nixosConfigurations = builtins.listToAttrs (map (hostname: { name = hostname; value = makeConfig hostname; }) hostnames);
    };
}
