{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixos-wsl = {
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   url = "github:nix-community/NixOS-WSL";
    # };
    # home-manager = {
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   url = "github:nix-community/home-manager";
    # };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
    imports = lib.trivial.pipe ./flake-modules [
      builtins.readDir
      (lib.attrsets.filterAttrs (name: type: type == "regular" && lib.strings.hasSuffix ".nix" name))
      builtins.attrNames
      (builtins.map (name: ./flake-modules/${name}))
    ];

    flake = flake: {
      nixosConfigurations.nixosWslVsCode = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          flake.config.nixosModules.vscodeServerWsl
          ({ lib, pkgs, config, ... }: {
            hardware.opengl.setLdLibraryPath = true;

            nix.settings.extra-substituters = [
              "https://nix-community.cachix.org"
            ];
            nix.settings.extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            nix.settings.auto-optimise-store = true;

            environment.defaultPackages = [
              pkgs.cachix
            ];

            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
  });
}
