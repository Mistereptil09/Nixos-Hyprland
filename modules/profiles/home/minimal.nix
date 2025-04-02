{ config, pkgs, ... }:

{
  # Home configuration
  home = {
    stateVersion = "23.11";
    packages = with pkgs; [
      htop
      ripgrep
    ];
  };
}