{
  outputs = inputs @ {
    self,
    home,
    nixpkgs,
    utils,
    wezterm,
    neovim,
    ...
  }: let
    host = "vm";
    user = "vicenzo";
    system = "x86_64-linux";
    modules = [
      home.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user} = {};
          sharedModules = import_ ./home;
          extraSpecialArgs = {inherit host user inputs system;};
        };
      }
    ];
    sharedOverlays = [
      overlay
      utils.overlay
      neovim.overlays.default
    ];
    x = builtins;
    import_ = name:
      map (i: "${name}/${i}")
      (x.attrNames (x.readDir name));
    overlay = y: z: let
      dirContents = x.readDir ./pkgs;
      genPackage = name: {
        inherit name;
        value = y.callPackage (./pkgs + "/${name}") {};
      };
      names = x.attrNames dirContents;
    in
      x.listToAttrs (map genPackage names);
    outputsBuilder = x: let
      pkgs = x.nixpkgs;
    in {
      formatter = pkgs.alejandra;
    };
    channelsConfig = import ./nix {inherit nixpkgs user;};
    hosts = {
      ${host} = {
        modules = [
          ./systems/${host}.nix
        ];
        extraArgs = {inherit host system;};
      };
    };
    hostDefaults = {
      inherit modules;
      channelName = "unstable";
      extraArgs = {inherit user;};
    };
  in
    utils.lib.mkFlake {
      inherit self inputs sharedOverlays channelsConfig outputsBuilder hostDefaults hosts;
      supportedSystems = [system];
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home.url = "github:nix-community/home-manager";
    wezterm.url = "github:wez/wezterm?dir=nix";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
  };
  nixConfig = {
    substituters = [
      "https://zv.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "zv.cachix.org-1:IvFyOKHzPNNVSapGzeNPbrF65OoX/r+MROLHpGwsYfg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
