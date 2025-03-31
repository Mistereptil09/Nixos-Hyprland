{ config, lib, pkgs, ... }:

let
  cfg = config.modules.core.nix;
in {
  options.modules.core.nix = {
    enable = lib.mkEnableOption "Enable Nix configuration";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        warn-dirty = false;
      };
      
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
    
    system.stateVersion = lib.mkDefault "23.11";
  };
}
