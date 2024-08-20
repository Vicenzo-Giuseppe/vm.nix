{
  pkgs,
  user,
  host,
  ...
}: let
  imports = [
    ./virtualbox.nix
    ./user-config.nix
  ];
in {
  inherit imports;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.grub.fsIdentifier = "provided";
  };
  networking = {
    hostName = host;
  };
  powerManagement.enable = false;
  services = {
    xserver = {
      enable = true;
      layout = "br";
      videoDrivers = ["virtualbox" "vmware" "cirrus" "vesa" "modesetting"];
      displayManager = {
        autoLogin = {
          enable = true;
          inherit user;
        };
        sddm = {
          enable = true;
          theme = "catppuccin-mocha";
        };
      };
      desktopManager.plasma5.enable = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [catppuccin-sddm];
  hardware = {
    pulseaudio.enable = false;
  };
}
