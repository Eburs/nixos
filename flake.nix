{
  description = "NixOS + Home Manager configuration (nixos-unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dots-hyprland = {
      url = "github:end-4/dots-hyprland?submodules=1";
      flake = false;
    };
    dots-nixpkgs.url = "github:nixos/nixpkgs/93e8cdce7afc64297cfec447c311470788131cd9";
    dots-shapes = {
      url = "github:end-4/rounded-polygon-qmljs";
      flake = false;
    };
    dots-quickshell = {
      url = "github:quickshell-mirror/quickshell/db1777c20b936a86528c1095cbcb1ebd92801402";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.LabTop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hosts/LabTop/host.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Rechenschieber = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hosts/Rechenschieber/host.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Skynet = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hosts/Skynet/host.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
