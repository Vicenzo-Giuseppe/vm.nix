{
  user,
  pkgs,
  ...
}: let
  source = pkgs.fetchgit {
    url = "https://codeberg.org/Vicenzo/wezterm";
    sha256 = "sha256-LWqLoEf7aBF1addnhBpecAn0mdvTLY415GIWIFBCYYM=";
  };
in {
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
    file.wezterm = {
      inherit source;
      target = ".config/wezterm";
    };
  };
}
