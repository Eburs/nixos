{
  description = "NixOS + Home Manager configuration (nixos-unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.LabTop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/LabTop/host.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Rechenschieber = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/Rechenschieber/host.nix
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.Skynet = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          ./hosts/Skynet/host.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
